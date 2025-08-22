output "lambda_function_arns" {
  description = "ARNs of the created Lambda functions"
  value       = { for k, v in aws_lambda_function.db_alert_notifier : k => v.arn }
}

output "lambda_function_names" {
  description = "Names of the created Lambda functions"
  value       = { for k, v in aws_lambda_function.db_alert_notifier : k => v.function_name }
}
