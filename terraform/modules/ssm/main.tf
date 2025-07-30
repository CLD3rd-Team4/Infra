# Config Server GitHub 사용자명
resource "aws_ssm_parameter" "github_username" {
  name        = "/mapzip/config-server/github-username"
  description = "GitHub username for config server"
  type        = "String"
  value       = var.git_username

  tags = var.common_tags
}

# Config Server GitHub 토큰
resource "aws_ssm_parameter" "github_token" {
  name        = "/mapzip/config-server/github-token"
  description = "GitHub personal access token for config server"
  type        = "SecureString"
  value       = var.git_token

  tags = var.common_tags
}

# Config Server 암호화 키 (선택적)
resource "aws_ssm_parameter" "encrypt_key" {
  count = var.encrypt_key != "" ? 1 : 0
  
  name        = "/mapzip/config-server/encrypt-key"
  description = "Encryption key for config server"
  type        = "SecureString"
  value       = var.encrypt_key

  tags = var.common_tags
}
