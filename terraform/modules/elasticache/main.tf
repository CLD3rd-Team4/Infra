resource "aws_elasticache_cluster" "this" {
  # --- 네이밍 ---
  cluster_id           = "${var.name_prefix}${var.cluster_name}"

  engine               = "valkey"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = 6379
  subnet_group_name    = var.elasticache_subnet_group_name
  security_group_ids   = var.security_group_ids

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.cluster_name}"
    }
  )
}
