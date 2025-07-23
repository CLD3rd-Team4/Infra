variable "vpc_id" {
  description = "연결할 VPC ID"
  type        = string
}

variable "customer_gateway_id" {
  description = "온프레미스 Customer Gateway ID"
  type        = string
}

variable "static_routes_only" {
  description = "정적 라우팅만 사용할지 여부"
  type        = bool
  default     = true
}

variable "common_prefix" {
  description = "공통 prefix"
  type        = string
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
} 