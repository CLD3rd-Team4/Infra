variable "domain_name" {
  description = "The domain name to create the hosted zone for"
  type        = string
}

variable "common_prefix" {
  description = "Prefix for naming resources (e.g. mapzip-dev-)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
