# Aurora 모듈 출력 변수

# ------------------------------------------------------------------------------
# 생성된 Aurora 클러스터의 주요 정보를 출력합니다.
# - 다른 모듈이나 루트에서 이 값을 참조하여 사용할 수 있습니다.
# ------------------------------------------------------------------------------

output "cluster_endpoint" {
  description = "Aurora DB 클러스터의 엔드포인트 주소"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "cluster_port" {
  description = "Aurora DB 클러스터의 포트 번호"
  value       = aws_rds_cluster.aurora_cluster.port
}

output "db_name" {
  description = "생성된 데이터베이스 이름"
  value       = aws_rds_cluster.aurora_cluster.database_name
  sensitive   = true
}

output "db_username" {
  description = "데이터베이스 마스터 사용자 이름"
  value       = aws_rds_cluster.aurora_cluster.master_username
  sensitive   = true
}
