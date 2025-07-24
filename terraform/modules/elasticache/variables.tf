variable "name_prefix" {
  description = "A prefix used for naming resources"
  type        = string
}

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

variable "node_type" {
  description = "The node type for the ElastiCache cluster"
  type        = string
  default     = "cache.t3.medium"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the ElastiCache cluster"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "The parameter group for the ElastiCache cluster"
  type        = string
  default     = "default.redis7"
}
