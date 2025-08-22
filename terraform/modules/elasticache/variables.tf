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
  default     = ""
}

variable "snapshot_retention_limit" {
  description = "The number of days to retain snapshots"
  type        = number
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
  default     = "default.valkey8"
}

variable "use_serverless_cache" {
  description = "Whether to create a serverless cache"
  type        = bool
  default     = false
}

variable "serverless_cache_data_storage_maximum" {
  description = "Maximum data storage for the serverless cache in GB"
  type        = number
  default     = 10
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache serverless cache"
  type        = list(string)
  default     = []  
}