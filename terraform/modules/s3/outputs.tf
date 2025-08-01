# S3 모듈 출력 변수

# ------------------------------------------------------------------------------
# 생성된 S3 버킷의 주요 정보를 출력합니다.
# ------------------------------------------------------------------------------

output "bucket_name" {
  description = "생성된 S3 버킷의 전체 이름"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "생성된 S3 버킷의 ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "S3 버킷의 도메인 이름"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_id" {
  description = "S3 버킷의 ID"
  value       = aws_s3_bucket.this.id
}
