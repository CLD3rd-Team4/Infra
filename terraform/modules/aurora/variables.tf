# Aurora 모듈 변수 정의

# ------------------------------------------------------------------------------
# 공통 변수
# - 루트 모듈에서 terraform.workspace와 공통 태그를 주입받습니다.
# ------------------------------------------------------------------------------


variable "common_tags" {
  description = "모든 리소스에 적용될 공통 태그"
  type        = map(string)
  default     = {}
}

variable "common_prefix" {
  description = "리소스 이름에 사용할 공통 접두사"
  type        = string
}

# ------------------------------------------------------------------------------
# 네트워크 관련 변수
# - VPC, 서브넷, 보안 그룹 ID는 외부에서 주입받아 사용합니다.
# ------------------------------------------------------------------------------
variable "vpc_id" {
  description = "DB 클러스터가 위치할 VPC의 ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "DB 클러스터가 사용할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "DB 클러스터에 적용할 보안 그룹 ID"
  type        = string
}

variable "availability_zones" {
  description = "DB 클러스터를 배치할 가용 영역(AZ) 목록"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# DB 인스턴스 사양 관련 변수
# ------------------------------------------------------------------------------
variable "instance_class" {
  description = "DB 인스턴스의 클래스 (e.g., db.t3.medium)"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "생성할 DB 인스턴스의 개수"
  type        = number
  default     = 1
}

# ------------------------------------------------------------------------------
# DB 정보 관련 변수
# - TODO: 추후 SecretsManager와 연동하여 관리해야 합니다.
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
