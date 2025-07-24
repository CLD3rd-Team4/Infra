

# ------------------------------------------------------------------------------
# VPC 데이터 소스
# - VPC ID를 사용하여 VPC의 상세 정보(예: CIDR 블록)를 가져옵니다.
# ------------------------------------------------------------------------------
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# ------------------------------------------------------------------------------
# Locals
# - 서비스와 인스턴스 인덱스를 조합한 맵을 생성합니다.
# ------------------------------------------------------------------------------
locals {
  service_instances = flatten([
    for service in toset(var.aurora_service_names) : [
      for i in range(var.instances_per_cluster) : {
        service_name = service
        instance_idx = i
      }
    ]
  ])
}

# ------------------------------------------------------------------------------
# Aurora DB 클러스터용 보안 그룹
# - DB 클러스터에 대한 네트워크 접근을 제어합니다.
# ------------------------------------------------------------------------------
resource "aws_security_group" "this" {
  for_each    = toset(var.aurora_service_names)
  name        = "${var.common_prefix}${each.key}-db-sg"
  description = "Security group for the ${each.key} Aurora DB cluster"
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
      Name    = "${var.common_prefix}${each.key}-db-sg"
      Service = each.key
    }
  )
}


# ------------------------------------------------------------------------------
# Aurora (PostgreSQL) 클러스터 생성
# ------------------------------------------------------------------------------
resource "aws_rds_cluster" "this" {
  for_each                = toset(var.aurora_service_names)
  # --- 기본 설정 ---
  cluster_identifier      = "${var.common_prefix}${each.key}-db"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  port                    = 5432

  # --- 네트워크 및 보안 ---
  db_subnet_group_name    = aws_db_subnet_group.this[each.key].name
  vpc_security_group_ids  = [aws_security_group.this[each.key].id]

  # --- 운영 및 관리 ---
  availability_zones      = var.availability_zones
  skip_final_snapshot     = true
  deletion_protection     = true

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name    = "${var.common_prefix}${each.key}-db-cluster"
      Service = each.key
    }
  )
}

resource "aws_rds_cluster_instance" "this" {
  for_each            = { for inst in local.service_instances : "${inst.service_name}-${inst.instance_idx}" => inst }
  identifier          = "${var.common_prefix}${each.value.service_name}-db-instance-${each.value.instance_idx}"
  cluster_identifier  = aws_rds_cluster.this[each.value.service_name].id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this[each.value.service_name].engine
  engine_version      = aws_rds_cluster.this[each.value.service_name].engine_version

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.common_prefix}${each.value.service_name}-db-instance"
      Service = each.value.service_name
    }
  )
}

resource "aws_db_subnet_group" "this" {
  for_each   = toset(var.aurora_service_names)
  name       = "${var.common_prefix}${each.key}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "${var.common_prefix}${each.key}-db-subnet-group"
    Service = each.key
  }
}
