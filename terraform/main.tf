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
  common_tags   = local.common_tags
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
  common_tags   = local.common_tags
  subnets       = local.private_subnet_config
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.public_subnets.subnet_ids[0]
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "public_route_table" {
  source                  = "./modules/network/route_table"
  vpc_id                  = module.vpc.vpc_id
  name                    = "public-rtb"
  default_route_target_id = module.igw.igw_id
  target_type             = "igw"
  subnet_ids              = module.public_subnets.subnet_ids
  common_prefix           = local.common_prefix
  common_tags             = local.common_tags
}

module "private_route_table" {
  source                  = "./modules/network/route_table"
  vpc_id                  = module.vpc.vpc_id
  name                    = "private-rtb"
  default_route_target_id = module.natgw.natgw_id
  target_type             = "natgw"
  subnet_ids              = module.private_subnets.subnet_ids
  common_prefix           = local.common_prefix
  common_tags             = local.common_tags
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "mapzip-${terraform.workspace}-eks"
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  subnet_ids          = module.private_subnets.subnet_ids
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
}

module "iam" {
  source        = "./modules/iam"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}


# ------------------------------------------------------------------------------
# PostgreSQL 공급자 설정 (루트 모듈)
# ------------------------------------------------------------------------------
provider "postgresql" {
  alias    = "aurora_root"
  host     = module.aurora_db.aurora_cluster_endpoint
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


module "aurora_db" {
  source = "./modules/aurora"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags   = local.common_tags

  # --- 네트워크 변수 전달 (network 모듈 출력값 사용) ---
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.private_subnets.subnet_ids
  availability_zones = [for s in local.private_subnet_config : s.availability_zone]

  # --- DB 사양 및 계정 정보 전달 (변수 사용) ---
  instance_class     = var.db_instance_class
  db_master_username = var.db_master_username
  db_master_password = var.db_master_password
  instance_count     = var.instance_count
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
  is_public  = true
}