variable "subnet_id" {
  description = "NAT Gateway가 위치할 퍼블릭 서브넷 ID"
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