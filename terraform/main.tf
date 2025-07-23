module "vpc" {
  source       = "./modules/network/vpc"
  cidr_block   = "10.0.0.0/16"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "igw" {
  source        = "./modules/network/igw"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

# 퍼블릭 서브넷 (3개 - 각각 다른 가용 영역)
module "public_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "public"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "public-1", cidr_block = "10.0.4.0/24", availability_zone = "ap-northeast-2a" },
    { name = "public-2", cidr_block = "10.0.5.0/24", availability_zone = "ap-northeast-2b" },
    { name = "public-3", cidr_block = "10.0.6.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

# 프라이빗 서브넷 (3개 - 각각 다른 가용 영역)
module "private_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "private"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "private-1", cidr_block = "10.0.14.0/24", availability_zone = "ap-northeast-2a" },
    { name = "private-2", cidr_block = "10.0.15.0/24", availability_zone = "ap-northeast-2b" },
    { name = "private-3", cidr_block = "10.0.16.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.public_subnets.subnet_ids[0]
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}


// route 53
module "route53" {
  source        = "./modules/route53"         
  domain_name   = var.service_domain          
  common_prefix = local.common_prefix        
  common_tags   = local.common_tags          
}

//cloudfront
module "cloudfront" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = "placeholder.s3.amazonaws.com"  // 실제 s3 변수로 변경
  acm_certificate_arn = module.acm_frontend.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
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
  bucket_domain_name  = "placeholder.s3.amazonaws.com"  // 실제 s3 변수로 변경
  acm_certificate_arn = module.acm_image.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
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
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}


module "iam" {
  source = "./modules/iam"
  common_prefix  = local.common_prefix
  common_tags    = local.common_tags
}