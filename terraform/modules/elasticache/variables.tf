variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "The specific name for the ElastiCache cluster"
  type        = string
}

variable "elasticache_subnet_group_name" {
  description = "Subnet group name for ElastiCache"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for ElastiCache"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}