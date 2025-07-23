variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "subnet_type" {
  description = "Type of subnet (public or private)"
  type        = string
  validation {
    condition     = contains(["public", "private"], var.subnet_type)
    error_message = "Subnet type must be either 'public' or 'private'."
  }
}

variable "common_prefix" {
  description = "Common prefix for all resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
