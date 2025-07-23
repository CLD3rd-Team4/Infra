locals {
  common_prefix = "mapzip-${terraform.workspace}-"
  common_tags = {
    Environment = terraform.workspace
    Project     = "mapzip"
    ManagedBy   = "Terraform"
  }
}

variable "service_name" {
  description = "The name of the service to be created in EKS"
  type        = string
  default     = "mapzip"
}

variable "service_domain" {
  description = "The domain name for the service"
  type        = string
  default     = "mapzip.shop"
}