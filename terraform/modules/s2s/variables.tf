variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "on_prem_cidr_block" {
  type = string
}

variable "on_prem_public_ip" {
  type = string
}

variable "on_prem_bgp_asn" {
  type    = number
  default = 65000
}



variable "common_prefix" {
  description = "Prefix for resource naming"
  type        = string
}


variable "route_table_id" {
  type = string
}

variable "s2s_vpn_tags" {
  description = "All tags used for s2s-vpn related resources"
  type        = map(string)
}