# SNS Topics for DB Alerts
resource "aws_sns_topic" "db_alerts" {
  for_each = var.db_services
  
  name = "${var.common_prefix}${each.key}-db-alerts"
  
  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-alerts"
    Service = each.key
  })
}
