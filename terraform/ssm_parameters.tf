# SSM Parameter Store for Config Server Secrets
# 이 파일은 Config Server가 사용하는 중요한 값들을 SSM Parameter Store에 저장합니다.

resource "aws_ssm_parameter" "config_server_github_username" {
  name        = "/mapzip/config-server/github-username"
  description = "GitHub username for Config Server repository access"
  type        = "String"
  value       = var.config_server_github_username

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.common_prefix}config-server-github-username"
      Component   = "config-server"
      SecretType  = "github-credentials"
    }
  )
}

resource "aws_ssm_parameter" "config_server_github_token" {
  name        = "/mapzip/config-server/github-token"
  description = "GitHub Personal Access Token for Config Server repository access"
  type        = "SecureString"
  value       = var.config_server_github_token

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.common_prefix}config-server-github-token"
      Component   = "config-server"
      SecretType  = "github-credentials"
    }
  )
}

# ENCRYPT_KEY는 선택적으로 관리 (팀원 요청에 따라 제거 가능)
resource "aws_ssm_parameter" "config_server_encrypt_key" {
  count = var.enable_config_server_encrypt_key ? 1 : 0
  
  name        = "/mapzip/config-server/encrypt-key"
  description = "Encryption key for Config Server property encryption"
  type        = "SecureString"
  value       = var.config_server_encrypt_key != "" ? var.config_server_encrypt_key : random_password.config_encrypt_key[0].result

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.common_prefix}config-server-encrypt-key"
      Component   = "config-server"
      SecretType  = "encryption-key"
    }
  )
}

# ENCRYPT_KEY가 제공되지 않은 경우 자동 생성
resource "random_password" "config_encrypt_key" {
  count   = var.enable_config_server_encrypt_key && var.config_server_encrypt_key == "" ? 1 : 0
  length  = 32
  special = true
}
