# S3 모듈 변수 정의

# ------------------------------------------------------------------------------
# 공통 변수
# ------------------------------------------------------------------------------


variable "common_tags" {
  description = "모든 리소스에 적용될 공통 태그"
  type        = map(string)
  default     = {}
}

variable "common_prefix" {
  description = "리소스 이름에 사용할 공통 접두사"
  type        = string
}
variable "bucket_name" {
  description = "생성할 S3 버킷의 이름 (prefix 제외)"
  type        = string
}

variable "is_public" {
  description = "버킷의 Public 접근 허용 여부"
  type        = bool
  default     = false # 기본적으로 비공개
}

variable "versioning_enabled" {
  description = "버킷의 버전 관리 활성화 여부"
  type        = bool
  default     = false # 기본적으로 비활성화
}
