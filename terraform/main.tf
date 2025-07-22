# 루트 모듈 (main.tf)

# ------------------------------------------------------------------------------
# 로컬 변수 정의
# - 공통으로 사용될 이름 접두사(prefix)와 태그를 정의합니다.
# - terraform.workspace를 사용하여 현재 작업 환경을 동적으로 참조합니다.
# ------------------------------------------------------------------------------
locals {
  # 리소스 이름에 공통으로 사용할 접두사 (e.g., mapzip-dev-)
  common_prefix = "mapzip-${terraform.workspace}-"

  # 모든 리소스에 공통으로 적용할 태그
  common_tags = {
    Environment = terraform.workspace
    Project     = "mapzip"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# Aurora (PostgreSQL) 모듈 호출
# - modules/aurora 디렉토리의 모듈을 사용하여 DB 클러스터를 생성합니다.
# - 네트워크 정보 및 DB 계정 정보는 변수를 통해 주입합니다.
# ------------------------------------------------------------------------------
module "aurora_db" {
  source = "./modules/aurora"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags = local.common_tags

  # --- 네트워크 변수 전달 (외부에서 값 주입 필요) ---
  vpc_id                      = var.vpc_id
  private_subnet_ids          = var.private_subnet_ids
  allowed_security_group_id   = var.db_security_group_id
  availability_zones          = var.availability_zones

  # --- DB 사양 및 계정 정보 전달 (외부에서 값 주입 필요) ---
  instance_class = var.db_instance_class
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  instance_count = var.instance_count
}

# ------------------------------------------------------------------------------
# S3 버킷 모듈 호출 (이미지 저장용)
# - modules/s3 디렉토리의 모듈을 사용하여 이미지 저장용 버킷을 생성합니다.
# ------------------------------------------------------------------------------
module "s3_image_bucket" {
  source = "./modules/s3"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags = local.common_tags

  # --- S3 버킷 설정 ---
  bucket_name = "image" # "mapzip-{env}-image" 형태로 생성됨
  # is_public, versioning_enabled는 모듈의 기본값(false) 사용
}

# ------------------------------------------------------------------------------
# S3 버킷 모듈 호출 (웹사이트 리소스용)
# - modules/s3 디렉토리의 모듈을 사용하여 웹사이트 리소스용 버킷을 생성합니다.
# ------------------------------------------------------------------------------
module "s3_website_bucket" {
  source = "./modules/s3"

  # --- 공통 변수 전달 ---
  common_prefix = local.common_prefix
  common_tags = local.common_tags

  # --- S3 버킷 설정 ---
  bucket_name = "website" # "mapzip-{env}-website" 형태로 생성됨
  is_public   = true
}