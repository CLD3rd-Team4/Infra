variable "git_username" {
  description = "GitHub username for config server"
  type        = string
  sensitive   = true
}

variable "git_token" {
  description = "GitHub personal access token for config server"
  type        = string
  sensitive   = true
}

variable "encrypt_key" {
  description = "Encryption key for config server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
