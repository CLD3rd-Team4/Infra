variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cidr_block" {
  description = "Subnet CIDR block"
  type        = string
}

variable "availability_zone" {
  description = "AZ"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "퍼블릭 서브넷 여부"
  type        = bool
  default     = false
}

variable "name" {
  description = "서브넷 이름"
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