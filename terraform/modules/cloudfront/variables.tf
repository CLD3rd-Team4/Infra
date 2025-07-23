variable "bucket_domain_name" {
  description = "정적 파일이 업로드된 S3 버킷의 도메인"
  type        = string
}

variable "acm_certificate_arn" {
  description = "HTTPS용 ACM 인증서 ARN"
  type        = string
}

variable "common_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

