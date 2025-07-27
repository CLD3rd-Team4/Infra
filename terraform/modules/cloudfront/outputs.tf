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
