# ------------------------------------------------------------------------------
# Aurora DB 정보 출력
# ------------------------------------------------------------------------------
output "aurora_cluster_endpoints" {
  description = "서비스별 Aurora DB 클러스터의 엔드포인트 주소 맵"
  value       = module.aurora_dbs.aurora_cluster_endpoints
}

output "aurora_cluster_ports" {
  description = "서비스별 Aurora DB 클러스터의 포트 번호 맵"
  value       = module.aurora_dbs.aurora_cluster_ports
}

# ------------------------------------------------------------------------------
# S3 버킷 정보 출력
# ------------------------------------------------------------------------------
output "s3_image_bucket_name" {
  description = "이미지 저장용 S3 버킷의 전체 이름"
  value       = module.s3_image_bucket.bucket_name
}

output "s3_image_bucket_arn" {
  description = "이미지 저장용 S3 버킷의 ARN"
  value       = module.s3_image_bucket.bucket_arn
}

output "s3_website_bucket_name" {
  description = "웹사이트 리소스용 S3 버킷의 전체 이름"
  value       = module.s3_website_bucket.bucket_name
}

output "s3_website_bucket_arn" {
  description = "웹사이트 리소스용 S3 버킷의 ARN"
  value       = module.s3_website_bucket.bucket_arn
}

# ------------------------------------------------------------------------------
# 네트워크 정보 출력
# ------------------------------------------------------------------------------

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# Public Subnets
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.public_subnets.subnet_ids
}

output "public_subnet_ids_by_az" {
  description = "Public subnet IDs grouped by availability zone"
  value       = module.public_subnets.subnet_ids_by_az
}

output "public_subnet_ids_by_name" {
  description = "Public subnet IDs mapped by subnet name"
  value       = module.public_subnets.subnet_ids_by_name
}

# Private Subnets
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.private_subnets.subnet_ids
}

output "private_subnet_ids_by_az" {
  description = "Private subnet IDs grouped by availability zone"
  value       = module.private_subnets.subnet_ids_by_az
}

output "private_subnet_ids_by_name" {
  description = "Private subnet IDs mapped by subnet name"
  value       = module.private_subnets.subnet_ids_by_name
}

# Internet Gateway
output "igw_id" {
  description = "Internet Gateway ID"
  value       = module.igw.igw_id
}

# NAT Gateway
output "natgw_id" {
  description = "NAT Gateway ID"
  value       = module.natgw.natgw_id
}

# Route Tables
output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.public_route_table.route_table_id
}

output "public_route_id" {
  description = "Public route ID"
  value       = module.public_route_table.route_id
}

output "public_route_table_associations" {
  description = "Public route table associations"
  value       = module.public_route_table.route_table_associations
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = module.private_route_table.route_table_id
}

output "private_route_id" {
  description = "Private route ID"
  value       = module.private_route_table.route_id
}

output "private_route_table_associations" {
  description = "Private route table associations"
  value       = module.private_route_table.route_table_associations
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB reviews table"
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB reviews table"
  value       = module.dynamodb.dynamodb_table_arn
}

output "elasticache_auth_cluster_id" {
  description = "The ID of the ElastiCache cluster for authentication"
  value       = module.elasticache_auth.elasticache_cluster_id
}

output "elasticache_auth_cluster_endpoint" {
  description = "The endpoint of the ElastiCache cluster for authentication"
  value       = module.elasticache_auth.elasticache_cluster_endpoint
}

output "elasticache_recommend_cluster_id" {
  description = "The ID of the ElastiCache cluster for recommendation"
  value       = module.elasticache_recommend.elasticache_cluster_id
}

output "elasticache_recommend_cluster_endpoint" {
  description = "The endpoint of the ElastiCache cluster for recommendation"
  value       = module.elasticache_recommend.elasticache_cluster_endpoint
}

# ------------------------------------------------------------------------------
# EKS 관련 정보 출력
# ------------------------------------------------------------------------------
output "review_service_role_arn" {
  description = "ARN of the IAM role for Review service IRSA"
  value       = module.eks.review_service_role_arn
}