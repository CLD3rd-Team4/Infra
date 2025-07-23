resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "S3-${var.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_domain_name}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
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
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
