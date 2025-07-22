output "dynamodb_table_name" {
  description = "The name of the DynamoDB reviews table"
  value       = module.dynamodb.aws_dynamodb_table_this_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB reviews table"
  value       = module.dynamodb.aws_dynamodb_table_this_arn
}

output "elasticache_cluster_id" {
  description = "The ID of the ElastiCache cluster"
  value       = module.elasticache.aws_elasticache_cluster_this_id
}

output "elasticache_cluster_endpoint" {
  description = "The endpoint of the ElastiCache cluster"
  value       = module.elasticache.aws_elasticache_cluster_this_cache_nodes_0_address
}