variable "common_prefix" {
  description = "Common prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "db_services" {
  description = "Map of database services with their configurations"
  type = map(object({
    cluster_identifier = string
    slack_channel      = string
    webhook_url        = string
  }))
}

variable "sns_topic_arns" {
  description = "Map of SNS topic ARNs for each service"
  type        = map(string)
}

# 임계값 설정
variable "cpu_threshold" {
  description = "CPU utilization threshold (percentage)"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Free memory threshold (bytes) - 1GB = 1073741824"
  type        = number
  default     = 1073741824 # 1GB
}

variable "read_latency_threshold" {
  description = "Read latency threshold (seconds) - 0.1 = 100ms"
  type        = number
  default     = 0.1
}

variable "write_latency_threshold" {
  description = "Write latency threshold (seconds) - 0.1 = 100ms"
  type        = number
  default     = 0.1
}

# =============================================================================
# DynamoDB 모니터링 변수
# =============================================================================

variable "dynamodb_tables" {
  description = "Map of DynamoDB tables with their configurations"
  type = map(object({
    table_name = string
  }))
  default = {}
}

variable "dynamodb_throttle_threshold" {
  description = "DynamoDB throttle requests threshold (count)"
  type        = number
  default     = 5
}

variable "dynamodb_error_threshold" {
  description = "DynamoDB error threshold (count)"
  type        = number
  default     = 10
}

# =============================================================================
# ElastiCache 모니터링 변수
# =============================================================================

variable "elasticache_clusters" {
  description = "Map of ElastiCache clusters with their configurations"
  type = map(object({
    cluster_id = string
  }))
  default = {}
}

variable "elasticache_cpu_threshold" {
  description = "ElastiCache CPU utilization threshold (percentage)"
  type        = number
  default     = 80
}

variable "elasticache_memory_threshold" {
  description = "ElastiCache memory usage threshold (percentage)"
  type        = number
  default     = 80
}

variable "elasticache_connections_threshold" {
  description = "ElastiCache current connections threshold (count)"
  type        = number
  default     = 100
}

variable "elasticache_hit_rate_threshold" {
  description = "ElastiCache cache hit rate threshold (percentage)"
  type        = number
  default     = 80
}
