
output "elasticache_cluster_id" {
  value = aws_elasticache_cluster.this.cluster_id
}

output "elasticache_cluster_endpoint" {
  value = aws_elasticache_cluster.this.cache_nodes[0].address
}
