# 전역 변수 정의 (variables.tf)

# ------------------------------------------------------------------------------
# AWS 리전
# ------------------------------------------------------------------------------
variable "aws_region" {
  description = "리소스를 생성할 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# ------------------------------------------------------------------------------
# 네트워크 관련 변수
# - 이 값들은 환경별 .tfvars 파일을 통해 주입되어야 합니다.
# ------------------------------------------------------------------------------
variable "vpc_id" {
  description = "인프라가 구성될 VPC의 ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "DB 등 내부 리소스가 위치할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "ALB 등 외부 공개 리소스가 위치할 퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "availability_zones" {
  description = "리소스를 배치할 가용 영역(AZ) 목록"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# 보안 그룹 관련 변수
# ------------------------------------------------------------------------------
variable "db_security_group_id" {
  description = "Aurora DB 클러스터에 적용할 보안 그룹 ID"
  type        = string
}

# ------------------------------------------------------------------------------
# Aurora DB 계정 정보 관련 변수
# - TODO: SecretsManager 연동 시 제거될 수 있습니다.
# - 민감한 정보이므로 .tfvars 파일 또는 환경 변수로 전달해야 합니다.
# ------------------------------------------------------------------------------
variable "db_name" {
  description = "생성할 데이터베이스의 이름"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "데이터베이스 마스터 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "데이터베이스 마스터 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "DB 인스턴스의 클래스"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "생성할 DB 인스턴스의 개수"
  type        = number
  default     = 1
}

variable "service_name" {
  description = "The name of the service to be created in EKS"
  type        = string
  default     = "mapzip"
}

variable "service_domain" {
  description = "The domain name for the service"
  type        = string
  default     = "mapzip.shop"
}
