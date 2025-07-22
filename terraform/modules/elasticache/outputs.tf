
output "elasticache_cluster_id" {
  value = aws_elasticache_cluster.valkey_cluster.cluster_id
}

output "elasticache_cluster_endpoint" {
  value = aws_elasticache_cluster.valkey_cluster.cache_nodes[0].address
}
