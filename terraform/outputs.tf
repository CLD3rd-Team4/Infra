# 루트 모듈 출력 변수 (outputs.tf)

# ------------------------------------------------------------------------------
# Aurora DB 정보 출력
# - 모듈의 출력을 참조하여 필요한 정보를 노출합니다.
# ------------------------------------------------------------------------------
output "aurora_cluster_endpoint" {
  description = "Aurora DB 클러스터의 엔드포인트 주소"
  value       = module.aurora_db.cluster_endpoint
}

output "aurora_cluster_port" {
  description = "Aurora DB 클러스터의 포트 번호"
  value       = module.aurora_db.cluster_port
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
