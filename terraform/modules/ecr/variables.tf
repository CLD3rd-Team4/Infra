variable "repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "common_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
