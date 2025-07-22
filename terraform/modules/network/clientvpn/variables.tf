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
  description = "클라이언트 인증 루트 CA ARN"
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

variable "common_prefix" {
  description = "공통 prefix"
  type        = string
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
} 