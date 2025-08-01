# Config Server GitHub 사용자명
resource "aws_ssm_parameter" "github_username" {
  name        = "/mapzip/config-server/github-username"
  description = "GitHub username for config server"
  type        = "String"
  value       = var.git_username
  overwrite   = true

  tags = var.common_tags
}

# Config Server GitHub 토큰
resource "aws_ssm_parameter" "github_token" {
  name        = "/mapzip/config-server/github-token"
  description = "GitHub personal access token for config server"
  type        = "SecureString"
  value       = var.git_token
  overwrite   = true

  tags = var.common_tags
}

# Config Server 암호화 키 (선택적)
resource "aws_ssm_parameter" "encrypt_key" {
  count = var.encrypt_key != "" ? 1 : 0
  
  name        = "/mapzip/config-server/encrypt-key"
  description = "Encryption key for config server"
  type        = "SecureString"
  value       = var.encrypt_key
  overwrite   = true

  tags = var.common_tags
}

# Google Cloud Vision API 키 (Review 서비스용)
resource "aws_ssm_parameter" "google_vision_api_key" {
  count = var.google_vision_api_key != "" ? 1 : 0
  
  name        = "/mapzip/review/google-vision-api-key"
  description = "Google Cloud Vision API key for review service"
  type        = "SecureString"
  value       = var.google_vision_api_key
  overwrite   = true

  tags = var.common_tags
}
