resource "aws_elasticache_replication_group" "this" {
  count                       = var.use_serverless_cache ? 0 : 1

  # --- 단일 샤드 ---
  replication_group_id         = "${var.name_prefix}${var.cluster_name}"
  description                  = "ElastiCache replication group for ${var.name_prefix}${var.cluster_name}"

  engine                       = "valkey"
  node_type                    = var.node_type
  num_cache_clusters           = var.num_cache_nodes
  parameter_group_name         = var.parameter_group_name
  port                         = 6379
  subnet_group_name            = var.elasticache_subnet_group_name
  security_group_ids           = var.security_group_ids

  # --- prod 환경에서는 클러스터 개수가 2개 이상이어야 함 (복제본 추가) ---
  automatic_failover_enabled   = terraform.workspace == "prod" ? true : false
  multi_az_enabled             = terraform.workspace == "prod" ? true : false

  snapshot_retention_limit     = var.snapshot_retention_limit
  snapshot_window              = "03:00-04:00"
  maintenance_window            = "sun:05:00-sun:06:00"

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.cluster_name}"
    }
  )
}

resource "aws_elasticache_serverless_cache" "this" {
  count  = var.use_serverless_cache ? 1 : 0
  engine = "valkey"
  name   = "${var.name_prefix}${var.cluster_name}-serverless"
  cache_usage_limits {
    data_storage {
      maximum = var.serverless_cache_data_storage_maximum
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "${var.name_prefix}${var.cluster_name}-serverless-cache-valkey"
  major_engine_version     = "8"
  snapshot_retention_limit = var.snapshot_retention_limit
  security_group_ids       = var.security_group_ids
  subnet_ids               = var.subnet_ids
}
