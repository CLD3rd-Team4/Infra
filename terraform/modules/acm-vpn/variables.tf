variable "server_cert_body" {
  description = "VPN server certificate body (PEM format)"
  type        = string
  sensitive   = true
}

variable "server_private_key" {
  description = "VPN server private key (PEM format)"
  type        = string
  sensitive   = true
}

variable "ca_cert_body" {
  description = "CA certificate body (PEM format)"
  type        = string
  sensitive   = true
}

variable "ca_private_key" {
  description = "CA private key (PEM format)"
  type        = string
  sensitive   = true
}

variable "client_certs" {
  description = "Map of client certificates by team member name"
  type = map(object({
    cert_body   = string
    private_key = string
  }))
  sensitive = true
  default   = {}
}

variable "common_prefix" {
  description = "Common prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
