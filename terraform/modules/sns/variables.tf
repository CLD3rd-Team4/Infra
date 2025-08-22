variable "common_prefix" {
  description = "Common prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "db_services" {
  description = "Map of database services to create SNS topics for"
  type = map(object({
    cluster_identifier = string
    slack_channel      = string
    webhook_url        = string
  }))
}
