resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "S3-${var.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }
  aliases = var.aliases

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_domain_name}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      //query_string = true  # S3 업로드 시 query string 필요
      //headers      = ["Authorization", "Content-Type", "Content-MD5", "x-amz-*"]  # S3 업로드 헤더 전달
      cookies {
        forward = "none"
      }
    }

  
    //min_ttl                = 0
    //default_ttl            = 86400   # 1일 (GET 요청용)
    //max_ttl                = 31536000 # 1년
  }

  dynamic "custom_error_response" {
    for_each = var.is_website ? [403, 404] : []
    content {
      error_code         = custom_error_response.value
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}cloudfront"
    }
  )
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Access Identity for CloudFront to S3"
}
