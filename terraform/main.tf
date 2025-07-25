module "vpc" {
  source        = "./modules/network/vpc"
  cidr_block    = "10.0.0.0/16"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "igw" {
  source        = "./modules/network/igw"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "public_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "public"
  common_prefix = local.common_prefix
  common_tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/elb" = "1"
    }
  )
  subnets = [
    { name = "public-1", cidr_block = "10.0.4.0/24", availability_zone = "ap-northeast-2a" },
    { name = "public-2", cidr_block = "10.0.5.0/24", availability_zone = "ap-northeast-2b" },
    { name = "public-3", cidr_block = "10.0.6.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

module "private_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "private"
  common_prefix = local.common_prefix
  common_tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
  subnets       = local.private_subnet_config
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.public_subnets.subnet_ids[0]
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}



# ------------------------------------------------------------------------------
# PostgreSQL 공급자 설정 (루트 모듈)
# 여러 Aurora 클러스터 중 'recommend' DB에 연결하여 DB 및 역할 관리를 수행합니다.
# ------------------------------------------------------------------------------
provider "postgresql" {
  alias    = "aurora_root"
  host     = module.aurora_dbs.aurora_cluster_endpoints["recommend"]
  port     = 5432
  username = var.db_master_username
  password = var.db_master_password
  sslmode  = "require"
  connect_timeout = 10
}

# ------------------------------------------------------------------------------
# 기능별 데이터베이스 및 역할 생성 (루트 모듈)
# ------------------------------------------------------------------------------
resource "postgresql_database" "dbs" {
  provider = postgresql.aurora_root
  for_each = var.enable_db_creation ? toset(keys(var.databases)) : []
  name     = "mapzip_${each.key}"
  owner    = postgresql_role.users[each.key].name
}

resource "postgresql_role" "users" {
  provider = postgresql.aurora_root
  for_each = var.enable_db_creation ? toset(keys(var.databases)) : []
  name     = "mapzip-${each.key}-${terraform.workspace}"
  login    = true
  password = var.databases[each.key].password
}

module "aurora_dbs" {
  source = "./modules/aurora"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags   = local.common_tags

  # --- 서비스별 클러스터 생성 ---
  aurora_service_names = ["recommend", "schedule"]

  # --- 네트워크 변수 전달 (network 모듈 출력값 사용) ---
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.private_subnets.subnet_ids
  availability_zones = [for s in local.private_subnet_config : s.availability_zone]

  # --- DB 사양 및 계정 정보 전달 (변수 사용) ---
  instance_class     = var.db_instance_class
  db_master_username = var.db_master_username
  db_master_password = var.db_master_password
}

module "s3_image_bucket" {
  source = "./modules/s3"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags   = local.common_tags

  # --- S3 버킷 설정 ---
  bucket_name = "image"
}

module "s3_website_bucket" {
  source = "./modules/s3"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags   = local.common_tags

  # --- S3 버킷 설정 ---
  bucket_name = "website"
  is_public   = true
}

// route 53
module "route53" {
  source        = "./modules/route53"
  domain_name   = var.service_domain
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

//cloudfront(프론트연결)
module "cloudfront" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = module.s3_website_bucket.bucket_domain_name 
  acm_certificate_arn = module.acm_frontend.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
  depends_on = [module.acm_frontend]
}
//cloudfront- a record
module "a_record_frontend" {
  source        = "./modules/record"
  record_type   = "A"
  zone_id       = module.route53.zone_id
  name          = "www.mapzip.shop" 
  alias_name    = module.cloudfront.domain_name
  alias_zone_id = module.cloudfront.zone_id
  
}

//cloudfront(이미지연결)
module "cloudfront_image" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = module.s3_image_bucket.bucket_domain_name
  acm_certificate_arn = module.acm_image.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
  depends_on = [module.acm_image]
}

//cloudfront(이미지연결)-a record
module "a_record_image" {
  source        = "./modules/record"
  record_type   = "A"
  zone_id       = module.route53.zone_id
  name          = "img.mapzip.shop"
  alias_name    = module.cloudfront.domain_name
  alias_zone_id = module.cloudfront.zone_id
}


# CloudFront (프론트엔드용)
module "acm_frontend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws.us_east_1 }
  domain_name               = "www.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}

# Ingress(ALB) 백엔드용
module "acm_backend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws }
  domain_name               = "api.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}
module "acm_image" {
  source                    = "./modules/acm"
  providers                 = { aws = aws.us_east_1 }
  domain_name               = "img.mapzip.shop"
  route53_zone_id           = module.route53.zone_id
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
}


module "ecr_backend" {
  source        = "./modules/ecr"
  name          = "backend"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

# 퍼블릭 라우팅 테이블 모듈
module "public_route_table" {
  source                = "./modules/network/route_table"
  vpc_id                = module.vpc.vpc_id
  name                  = "public-rtb"
  default_route_target_id = module.igw.igw_id
  target_type           = "igw"
  subnet_ids            = module.public_subnets.subnet_ids
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

# 프라이빗 라우팅 테이블 모듈
module "private_route_table" {
  source                = "./modules/network/route_table"
  vpc_id                = module.vpc.vpc_id
  name                  = "private-rtb"
  default_route_target_id = module.natgw.natgw_id
  target_type           = "natgw"
  subnet_ids            = module.private_subnets.subnet_ids
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "mapzip-${terraform.workspace}-eks"
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  subnet_ids          = module.private_subnets.subnet_ids
  vpc_id              = module.vpc.vpc_id
  public_access_cidrs = ["0.0.0.0/0"]
  ami_id              = var.ami_id
  eks_key_pair        = var.eks_key_pair
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
}


# Client VPN
module "client_vpn" {
  source = "./modules/network/clientvpn"

  name                    = "${local.common_prefix}-client-vpn"
  description             = "Client VPN for ${var.service_name}"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.private_subnets.subnet_ids
  client_cidr_block       = "172.16.0.0/22"
  # 테라폼 실행 전에 acm 인증서 올리고 환경 변수로 설정해야 하는 변수들
  server_certificate_arn  = var.vpn_server_certificate_arn
  root_ca_certificate_arn = var.vpn_root_ca_certificate_arn
  
  # DNS 설정
  dns_servers = ["8.8.8.8", "8.8.4.4"]
  split_tunnel = true
  
  # 인증 규칙
  authorization_rules = [
    {
      target_network_cidr  = module.vpc.vpc_cidr_block
      authorize_all_groups = true
      description          = "Allow access to VPC"
    }
  ]
  
  # 라우팅 규칙
  routes = [
    {
      destination_cidr_block = module.vpc.vpc_cidr_block
      target_vpc_subnet_id   = module.private_subnets.subnet_ids[0]
      description            = "Route to VPC"
    }
  ]
  
  # 보안 그룹 규칙
  security_group_ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
  ]
  
  tags = local.common_tags
}



module "iam" {
  source = "./modules/iam"
  common_prefix  = local.common_prefix
  common_tags    = local.common_tags

}

module "dynamodb" {
  source       = "./modules/dynamodb"
  name_prefix  = local.common_prefix
  environment  = terraform.workspace
  table_name   = "reviews"
  common_tags  = local.common_tags
}

module "elasticache_auth" {
  source                        = "./modules/elasticache"
  name_prefix                   = local.common_prefix
  environment                   = terraform.workspace
  cluster_name                  = "auth-cache"
  common_tags                   = local.common_tags
  elasticache_subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids            = [aws_security_group.elasticache_sg.id]
  node_type                     = "cache.t3.small" # 인증용은 작은 사양
}

module "elasticache_recommend" {
  source                        = "./modules/elasticache"
  name_prefix                   = local.common_prefix
  environment                   = terraform.workspace
  cluster_name                  = "recommend-cache"
  common_tags                   = local.common_tags
  elasticache_subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids            = [aws_security_group.elasticache_sg.id]
  node_type                     = "cache.t3.medium" # 추천용은 중간 사양
}

resource "aws_elasticache_subnet_group" "main" {
  name        = "${local.common_prefix}elasticache-subnet-group"
  subnet_ids  = module.private_subnets.subnet_ids
  description = "ElastiCache subnet group for Mapzip"

  tags = merge(
    local.common_tags,
    {
      Name = "mapzip-${terraform.workspace}-elasticache-subnet-group"
    }
  )
}

resource "aws_security_group" "elasticache_sg" {
  name        = "${local.common_prefix}elasticache-sg"
  description = "Allow inbound traffic to ElastiCache"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # module.vpc의 cidr_block 변수 참조
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "mapzip-${terraform.workspace}-elasticache-sg"
    }
  )
}

module "msk" {
  source                 = "./modules/msk"
  name_prefix            = local.common_prefix
  environment            = terraform.workspace
  cluster_name           = "main"
  number_of_broker_nodes = 3
  instance_type          = "kafka.t3.small"
  ebs_volume_size        = 100
  vpc_subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids     = [aws_security_group.msk_sg.id]
  common_tags            = local.common_tags
}

resource "aws_security_group" "msk_sg" {
  name        = "${local.common_prefix}${terraform.workspace}-msk-sg"
  description = "Allow inbound traffic to MSK"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 9092 # Kafka plaintext port
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_prefix}-${terraform.workspace}-msk-sg"
    }
  )
}

# s2s_vpn 
module "s2s_vpn" {
  source = "./modules/s2s"

  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  on_prem_cidr_block = var.on_prem_cidr_block
  on_prem_public_ip  = var.on_prem_public_ip
  on_prem_bgp_asn    = var.on_prem_bgp_asn
  route_table_id = module.private_route_table.route_table_id

  # tags 관련 공통 변수 전달
  common_prefix = local.common_prefix
  s2s_vpn_tags = merge(local.common_tags, {
    Name = "${local.common_prefix}s2s-vpn"
  })

}


resource "aws_route_table_association" "private_subnet_assoc" {
  for_each = zipmap(
    ["subnet-1", "subnet-2", "subnet-3"],  
    module.private_subnets.subnet_ids      
  )

  subnet_id      = each.value
  route_table_id = module.private_route_table.route_table_id
}
