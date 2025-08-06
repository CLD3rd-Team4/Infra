output "sns_topic_arns" {
  description = "ARNs of the created SNS topics"
  value       = { for k, v in aws_sns_topic.db_alerts : k => v.arn }
}

output "sns_topic_names" {
  description = "Names of the created SNS topics"
  value       = { for k, v in aws_sns_topic.db_alerts : k => v.name }
}
