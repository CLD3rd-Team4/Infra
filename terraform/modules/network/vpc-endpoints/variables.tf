variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "route_table_ids" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "services" {
  type = list(object({
    name                = string   # 예: "dynamodb", "s3", "ssm"
    type                = string   # "Gateway" or "Interface"
    private_dns_enabled = optional(bool)
  }))
}
variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "common_prefix" {
  type    = string
}