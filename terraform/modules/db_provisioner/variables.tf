variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_user" {
  description = "The name of the role to create."
  type        = string
}

variable "db_password" {
  description = "The password for the role."
  type        = string
  sensitive   = true
}
