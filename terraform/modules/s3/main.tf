# S3 버킷 리소스 생성

# ------------------------------------------------------------------------------
# S3 버킷
# - 기본적으로 비공개(private)로 설정됩니다.
# - 서버 측 암호화(SSE-S3)를 사용합니다.
# - 버전 관리는 비활성화되어 있습니다.
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  # --- 네이밍 ---
  # 버킷 이름은 전역적으로 고유해야 하므로, 환경과 이름을 조합하여 생성합니다.
  bucket = "${var.common_prefix}${var.bucket_name}"
  force_destroy = true

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}${var.bucket_name}"
    }
  )
}

# ------------------------------------------------------------------------------
# S3 버킷 소유권 설정
# - ACL 비활성화를 위해 BucketOwnerEnforced 설정을 권장합니다.
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ------------------------------------------------------------------------------
# S3 버킷 공개 접근 차단
# - is_public 변수 값에 따라 모든 공개 접근을 차단하거나 허용합니다.
# - TODO: 추후 public 여부 논의 필요
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !var.is_public
  block_public_policy     = !var.is_public
  ignore_public_acls      = !var.is_public
  restrict_public_buckets = !var.is_public
}

# ------------------------------------------------------------------------------
# S3 버킷 서버 측 암호화 설정
# - 기본 암호화로 SSE-S3 (AES256)를 사용합니다.
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------------------------
# S3 버킷 버전 관리 설정
# - TODO: 추후 변경 가능성 있음
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# ------------------------------------------------------------------------------
# S3 정적 웹 호스팅
# ------------------------------------------------------------------------------
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
