# CPU 사용률 알람
resource "aws_cloudwatch_metric_alarm" "db_cpu_high" {
  for_each = var.db_services

  alarm_name          = "${var.common_prefix}${each.key}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors ${each.key} DB CPU utilization"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    DBClusterIdentifier = each.value.cluster_identifier
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-cpu-high"
    Service = each.key
  })
}

# 메모리 사용률 알람 (FreeableMemory 기준)
resource "aws_cloudwatch_metric_alarm" "db_memory_low" {
  for_each = var.db_services

  alarm_name          = "${var.common_prefix}${each.key}-db-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold # bytes (예: 1GB = 1073741824)
  alarm_description   = "This metric monitors ${each.key} DB available memory"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    DBClusterIdentifier = each.value.cluster_identifier
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-memory-low"
    Service = each.key
  })
}

# 읽기 지연시간 알람
resource "aws_cloudwatch_metric_alarm" "db_read_latency_high" {
  for_each = var.db_services

  alarm_name          = "${var.common_prefix}${each.key}-db-read-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.read_latency_threshold # seconds (예: 0.1 = 100ms)
  alarm_description   = "This metric monitors ${each.key} DB read latency"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    DBClusterIdentifier = each.value.cluster_identifier
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-read-latency-high"
    Service = each.key
  })
}

# 쓰기 지연시간 알람
resource "aws_cloudwatch_metric_alarm" "db_write_latency_high" {
  for_each = var.db_services

  alarm_name          = "${var.common_prefix}${each.key}-db-write-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.write_latency_threshold # seconds (예: 0.1 = 100ms)
  alarm_description   = "This metric monitors ${each.key} DB write latency"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    DBClusterIdentifier = each.value.cluster_identifier
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-write-latency-high"
    Service = each.key
  })
}
