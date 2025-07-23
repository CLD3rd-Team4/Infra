

# ------------------------------------------------------------------------------
# VPC 데이터 소스
# - VPC ID를 사용하여 VPC의 상세 정보(예: CIDR 블록)를 가져옵니다.
# ------------------------------------------------------------------------------
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# ------------------------------------------------------------------------------
# Aurora DB 클러스터용 보안 그룹
# - DB 클러스터에 대한 네트워크 접근을 제어합니다.
# ------------------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.common_prefix}db-sg"
  description = "Security group for the Aurora DB cluster"
  vpc_id      = var.vpc_id

  # 인바운드 규칙: VPC 내부에서 PostgreSQL(5432) 포트로의 접근 허용
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
    description = "Allow PostgreSQL access from within the VPC"
  }

  # 아웃바운드 규칙: 모든 외부 통신 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}db-sg"
    }
  )
}


# ------------------------------------------------------------------------------
# Aurora (PostgreSQL) 클러스터 생성
# ------------------------------------------------------------------------------
resource "aws_rds_cluster" "this" {
  # --- 기본 설정 ---
  cluster_identifier      = "${var.common_prefix}db"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  port                    = 5432

  # --- 네트워크 및 보안 ---
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.this.id]

  # --- 운영 및 관리 ---
  availability_zones      = var.availability_zones
  skip_final_snapshot     = true
  deletion_protection     = true

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}db-cluster"
    }
  )
}

resource "aws_rds_cluster_instance" "this" {
  count               = var.instance_count
  identifier          = "${var.common_prefix}db-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}db-instance"
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.common_prefix}db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.common_prefix}db-subnet-group"
  }
}