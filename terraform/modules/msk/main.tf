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