# Aurora 모듈 출력 변수

# ------------------------------------------------------------------------------
# 생성된 Aurora 클러스터의 주요 정보를 출력합니다.
# - 다른 모듈이나 루트에서 이 값을 참조하여 사용할 수 있습니다.
# ------------------------------------------------------------------------------

output "aurora_cluster_endpoints" {
  description = "서비스별 Aurora DB 클러스터의 엔드포인트 주소 맵"
  value       = { for k, v in aws_rds_cluster.this : k => v.endpoint }
}

output "aurora_cluster_ports" {
  description = "서비스별 Aurora DB 클러스터의 포트 번호 맵"
  value       = { for k, v in aws_rds_cluster.this : k => v.port }
}

output "db_usernames" {
  description = "서비스별 데이터베이스 마스터 사용자 이름 맵"
  value       = { for k, v in aws_rds_cluster.this : k => v.master_username }
  sensitive   = true
}
