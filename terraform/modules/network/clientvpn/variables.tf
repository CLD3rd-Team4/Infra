variable "description" {
  description = "Client VPN 설명"
  type        = string
  default     = "Mapzip Client VPN"
}

variable "server_certificate_arn" {
  description = "서버 인증서 ARN"
  type        = string
}

variable "root_certificate_chain_arn" {
  description = "클라이언트 인증서 ARN"
  type        = string
}

variable "client_cidr_block" {
  description = "클라이언트 VPN에 할당할 CIDR"
  type        = string
}

variable "vpc_id" {
  description = "연결할 VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "subnet_ids" {
  description = "Client VPN과 연결할 서브넷 ID 목록"
  type        = list(string)
}

variable "common_prefix" {
  description = "공통 prefix"
  type        = string
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}
