
output "elasticache_cluster_id" {
  value = aws_elasticache_replication_group.this.replication_group_id
}

output "elasticache_cluster_endpoint" {
  value = aws_elasticache_replication_group.this.configuration_endpoint_address != null ? aws_elasticache_replication_group.this.configuration_endpoint_address : aws_elasticache_replication_group.this.primary_endpoint_address
  sensitive = true
}
