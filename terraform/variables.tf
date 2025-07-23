locals {
  common_prefix = "mapzip-${terraform.workspace}-"
  common_tags = {
    Environment = terraform.workspace
    Project     = "mapzip"
    ManagedBy   = "Terraform"
  }

  private_subnet_config = [
    { name = "private-1", cidr_block = "10.0.14.0/24", availability_zone = "ap-northeast-2a" },
    { name = "private-2", cidr_block = "10.0.15.0/24", availability_zone = "ap-northeast-2b" },
    { name = "private-3", cidr_block = "10.0.16.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

variable "aws_region" {
  description = "리소스를 생성할 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}



variable "db_master_username" {
  description = "데이터베이스 마스터 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_master_password" {
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

variable "enable_db_creation" {
  description = "기능별 데이터베이스 및 사용자 생성 활성화 여부"
  type        = bool
  default     = false
}

variable "databases" {
  description = "생성할 기능별 데이터베이스와 사용자 정보"
  type = map(object({
    password = string
  }))
  default   = {}
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