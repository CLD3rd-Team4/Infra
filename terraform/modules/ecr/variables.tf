variable "name" {
  description = "ECR repository name suffix (e.g., backend, frontend)"
  type        = string
}

variable "common_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
