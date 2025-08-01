resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = compact([
      var.cloudfront_oai_arn != null && var.cloudfront_oai_arn != "" ? {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.cloudfront_oai_arn
        }
        Action    = "s3:GetObject"
        Resource  = "${var.bucket_arn}/*"
      } : null
    ])
  })
}
