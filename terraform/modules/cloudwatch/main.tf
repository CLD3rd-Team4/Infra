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

# =============================================================================
# DynamoDB 모니터링 알람
# =============================================================================

# DynamoDB 읽기 스로틀 알람
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttled_requests" {
  for_each = var.dynamodb_tables

  alarm_name          = "${var.common_prefix}${each.key}-dynamodb-read-throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.dynamodb_throttle_threshold
  alarm_description   = "This metric monitors ${each.key} DynamoDB read throttling"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    TableName = each.value.table_name
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-dynamodb-read-throttled"
    Service = each.key
  })
}

# DynamoDB 쓰기 스로틀 알람
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttled_requests" {
  for_each = var.dynamodb_tables

  alarm_name          = "${var.common_prefix}${each.key}-dynamodb-write-throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.dynamodb_throttle_threshold
  alarm_description   = "This metric monitors ${each.key} DynamoDB write throttling"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    TableName = each.value.table_name
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-dynamodb-write-throttled"
    Service = each.key
  })
}

# DynamoDB 시스템 에러 알람
resource "aws_cloudwatch_metric_alarm" "dynamodb_system_errors" {
  for_each = var.dynamodb_tables

  alarm_name          = "${var.common_prefix}${each.key}-dynamodb-system-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.dynamodb_error_threshold
  alarm_description   = "This metric monitors ${each.key} DynamoDB system errors"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    TableName = each.value.table_name
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-dynamodb-system-errors"
    Service = each.key
  })
}

# DynamoDB 사용자 에러 알람
resource "aws_cloudwatch_metric_alarm" "dynamodb_user_errors" {
  for_each = var.dynamodb_tables

  alarm_name          = "${var.common_prefix}${each.key}-dynamodb-user-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.dynamodb_error_threshold
  alarm_description   = "This metric monitors ${each.key} DynamoDB user errors"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    TableName = each.value.table_name
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-dynamodb-user-errors"
    Service = each.key
  })
}

# =============================================================================
# ElastiCache 모니터링 알람
# =============================================================================

# ElastiCache CPU 사용률 알람
resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_high" {
  for_each = var.elasticache_clusters

  alarm_name          = "${var.common_prefix}${each.key}-elasticache-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.elasticache_cpu_threshold
  alarm_description   = "This metric monitors ${each.key} ElastiCache CPU utilization"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    CacheClusterId = each.value.cluster_id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-elasticache-cpu-high"
    Service = each.key
  })
}

# ElastiCache 메모리 사용률 알람
resource "aws_cloudwatch_metric_alarm" "elasticache_memory_high" {
  for_each = var.elasticache_clusters

  alarm_name          = "${var.common_prefix}${each.key}-elasticache-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.elasticache_memory_threshold
  alarm_description   = "This metric monitors ${each.key} ElastiCache memory usage"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    CacheClusterId = each.value.cluster_id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-elasticache-memory-high"
    Service = each.key
  })
}

# ElastiCache 연결 수 알람
resource "aws_cloudwatch_metric_alarm" "elasticache_connections_high" {
  for_each = var.elasticache_clusters

  alarm_name          = "${var.common_prefix}${each.key}-elasticache-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.elasticache_connections_threshold
  alarm_description   = "This metric monitors ${each.key} ElastiCache current connections"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    CacheClusterId = each.value.cluster_id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-elasticache-connections-high"
    Service = each.key
  })
}

# ElastiCache 캐시 히트율 알람 (낮을 때)
resource "aws_cloudwatch_metric_alarm" "elasticache_cache_hit_rate_low" {
  for_each = var.elasticache_clusters

  alarm_name          = "${var.common_prefix}${each.key}-elasticache-cache-hit-rate-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CacheHitRate"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = var.elasticache_hit_rate_threshold
  alarm_description   = "This metric monitors ${each.key} ElastiCache cache hit rate"
  alarm_actions       = [var.sns_topic_arns[each.key]]
  ok_actions          = [var.sns_topic_arns[each.key]]

  dimensions = {
    CacheClusterId = each.value.cluster_id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-elasticache-cache-hit-rate-low"
    Service = each.key
  })
}
