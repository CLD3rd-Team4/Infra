variable "vpc_id" {
  description = "VPC ID"
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