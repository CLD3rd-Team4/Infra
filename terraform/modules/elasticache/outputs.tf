
output "elasticache_cluster_id" {
  value = length(aws_elasticache_replication_group.this) > 0 ?aws_elasticache_replication_group.this[0].replication_group_id : null
}

output "elasticache_cluster_endpoint" {
  value = length(aws_elasticache_replication_group.this) > 0 ?(aws_elasticache_replication_group.this[0].configuration_endpoint_address != null ? aws_elasticache_replication_group.this[0].configuration_endpoint_address : aws_elasticache_replication_group.this[0].primary_endpoint_address) : null
  sensitive = true
}

output "valkey_serverless_endpoint" {
  value     = length(aws_elasticache_serverless_cache.this) > 0 ?aws_elasticache_serverless_cache.this[0].endpoint : null
  sensitive = true
}