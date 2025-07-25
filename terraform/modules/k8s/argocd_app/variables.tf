variable "app_name" {
  description = "The name of the ArgoCD application"
  type        = string
}

variable "destination_namespace" {
  description = "The namespace where the application will be deployed"
  type        = string
}

variable "source_path" {
  description = "The path to the application source"
  type        = string
}

variable "repo_url" {
  description = "The Git repository URL"
  type        = string
  default     = "https://github.com/CLD3rd-Team4/Infra"
}
