variable "domain_name" {
  type = string
}

variable "common_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "route53_zone_id" {
  type = string
}

