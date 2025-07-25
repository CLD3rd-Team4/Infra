variable "team_members" {
  description = "List of team member names for client certificates"
  type        = list(string)
  default     = ["SYU", "YJM", "CSM", "HDY", "JSW", "PSY"]
}

variable "cert_path" {
  description = "Path to the VPN certificates directory"
  type        = string
  default     = "../vpn-certs/pki"
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
