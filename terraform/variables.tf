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

variable "on_prem_cidr_block" {
  type        = string
  description = "온프레미스 내부 CIDR 대역 "
}

variable "on_prem_public_ip" {
  type        = string
  description = "온프레미스 라우터의 공인 IP"
}

variable "on_prem_bgp_asn" {
  type        = number
  description = "온프레미스 라우터의 BGP ASN"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "mapzip-dev-cluster"
}

variable "region" {
  description = "The AWS region where the EKS cluster will be created"
  type        = string
  default     = "ap-northeast-2"
}

variable "prometheus_retention" {
  description = "The retention period for Prometheus data"
  type        = string
}

variable "tracing_sampling_percentage" {
  description = "The percentage of requests to trace (100 = all requests, 50 = half, 1 = 1%)"
  type        = number
  default     = 1
  }

variable "is_crd_dependent_phase" {
  description = "CRD에 종속되는 리소스 배포 단계인지 여부"
  type        = bool
  default     = false
}

# VPN 인증서 변수들
variable "vpn_server_certificate_arn" {
  description = "ARN of the server certificate for the VPN"
  type        = string
}

variable "vpn_root_ca_certificate_arn" {
  description = "ARN of the root CA certificate for the VPN"
  type        = string
  default     = null
}

variable "eks_key_pair" {
  description = "SSH key pair name to use for EC2/EKS nodes"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EKS worker nodes"
  type        = string
}
