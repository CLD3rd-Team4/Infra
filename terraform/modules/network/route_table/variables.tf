variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "Route table name"
  type        = string
}

variable "default_route_target_id" {
  description = "Target ID for the default route (IGW or NAT Gateway)"
  type        = string
}

variable "target_type" {
  description = "Type of target for the default route (igw or natgw)"
  type        = string
  validation {
    condition     = contains(["igw", "natgw"], var.target_type)
    error_message = "Target type must be either 'igw' or 'natgw'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this route table"
  type        = list(string)
}

variable "common_prefix" {
  description = "Common prefix for all resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
