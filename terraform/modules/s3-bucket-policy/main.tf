# S3 버킷 정책
resource "aws_s3_bucket_policy" "this" {
  count = var.cloudfront_oai_arn != null ? 1 : 0
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.cloudfront_oai_arn
        }
        Action    = "s3:GetObject"
        Resource  = "${var.bucket_arn}/*"
      }
    ]
  })

}
