# S3 버킷 모듈
# - 기본적으로 비공개(private)로 설정됩니다.
# - 서버 측 암호화(SSE-S3)를 사용합니다.
# - 버전 관리는 비활성화되어 있습니다.
resource "aws_s3_bucket" "this" {
  bucket = "${var.common_prefix}${var.bucket_name}"
  force_destroy = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}${var.bucket_name}"
    }
  )
}

# S3 버킷 소유권 설정
# - ACL 비활성화를 위해 BucketOwnerEnforced 설정을 권장합니다.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 버킷 공개 접근 차단
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !var.is_public
  block_public_policy     = !var.is_public
  ignore_public_acls      = !var.is_public
  restrict_public_buckets = !var.is_public
}

# S3 버킷 서버 측 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# S3 정적 웹 호스팅
resource "aws_s3_bucket_website_configuration" "this" {
  count = var.is_public ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


# S3 버킷 정책
resource "aws_s3_bucket_policy" "this" {
  for_each = var.cloudfront_oai_arn != null ? { "enabled" = var.cloudfront_oai_arn } : {}
  bucket = aws_s3_bucket.this.id

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
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}
