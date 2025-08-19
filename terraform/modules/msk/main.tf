# MSK 설정 추가
resource "aws_msk_configuration" "message_size_config" {
  kafka_versions = ["2.8.1"]  # 기존 버전 유지
  name           = "${var.name_prefix}${var.cluster_name}-message-config"
  description    = "MSK configuration for larger message size"

  server_properties = <<PROPERTIES
# 메시지 크기 제한을 5MB로 증가
message.max.bytes=5242880
replica.fetch.max.bytes=5242880

# 기존 설정 유지 (변경 최소화)
log.retention.hours=168
log.segment.bytes=1073741824
PROPERTIES
}

# 기존 MSK 클러스터에 설정 적용
resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.name_prefix}${var.cluster_name}"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type = var.instance_type
    client_subnets = var.vpc_subnet_ids
    security_groups = var.security_group_ids

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
  }

  # 새 설정 적용
  configuration_info {
    arn      = aws_msk_configuration.message_size_config.arn
    revision = aws_msk_configuration.message_size_config.latest_revision
  }

  lifecycle {
    ignore_changes = [
      client_authentication,
      encryption_info,
      open_monitoring
    ]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.cluster_name}"
    }
  )
}