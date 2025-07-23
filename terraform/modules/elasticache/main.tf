resource "aws_elasticache_cluster" "this" {
  # --- 네이밍 ---
  cluster_id           = "mapzip-${var.environment}-${var.cluster_name}"

  engine               = "redis"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = var.elasticache_subnet_group_name
  security_group_ids   = var.security_group_ids

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "mapzip-${var.environment}-${var.cluster_name}"
    }
  )
}