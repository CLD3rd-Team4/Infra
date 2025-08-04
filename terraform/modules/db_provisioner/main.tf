terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
            version = "1.22.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 기능별 데이터베이스 및 역할 생성
# ------------------------------------------------------------------------------
resource "postgresql_database" "db" {
  name  = var.db_name
  owner = postgresql_role.user.name
}

resource "postgresql_role" "user" {
  name     = var.db_user
  login    = true
  password = var.db_password
}
