output "domain_name" {
  description = "CloudFront 도메인"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "zone_id" {
  description = "CloudFront zone ID (A 레코드 연결용)"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "oai_iam_arn" {
  description = "CloudFront Origin Access Identity IAM ARN"
  value       = aws_cloudfront_origin_access_identity.this.iam_arn
}
