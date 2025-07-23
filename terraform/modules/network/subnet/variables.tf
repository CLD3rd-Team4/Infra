variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name                  = string
    cidr_block            = string
    availability_zone     = string
    map_public_ip_on_launch = bool
    type                  = optional(string, "private") # 'public' or 'private', default is 'private'
  }))
}
variable "vpc_id" { type = string }
variable "common_prefix" { type = string }
variable "common_tags" { type = map(string) } 