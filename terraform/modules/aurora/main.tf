# Aurora (PostgreSQL) 클러스터 생성

# ------------------------------------------------------------------------------
# RDS 클러스터
# - aurora-postgresql 엔진 사용
# - 다중 AZ(Multi-AZ) 활성화로 가용성 확보
# - 삭제 방지(deletion_protection) 활성화로 운영 안정성 확보
# ------------------------------------------------------------------------------
resource "aws_rds_cluster" "aurora_cluster" {
  # --- 기본 설정 ---
  cluster_identifier      = "mapzip-${var.environment}-db"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password # TODO: SecretsManager 연동 예정
  port                    = 5432

  # --- 네트워크 및 보안 ---
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [var.allowed_security_group_id]

  # --- 운영 및 관리 ---
  availability_zones      = var.availability_zones
  skip_final_snapshot     = true # 실 운영에서는 false 권장
  deletion_protection     = true

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "mapzip-${var.environment}-db-cluster"
    }
  )
}

# ------------------------------------------------------------------------------
# RDS 클러스터 인스턴스
# - 지정된 인스턴스 클래스 사용
# ------------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "aurora_instance" {
  count               = 1 # 필요에 따라 인스턴스 개수 조절
  identifier          = "mapzip-${var.environment}-db-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "mapzip-${var.environment}-db-instance"
    }
  )
}

# ------------------------------------------------------------------------------
# DB 서브넷 그룹
# - 지정된 프라이빗 서브넷에 DB 클러스터를 배치
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "mapzip-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "mapzip-${var.environment}-db-subnet-group"
  }
}
