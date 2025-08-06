output "cpu_alarm_names" {
  description = "Names of CPU utilization alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.db_cpu_high : k => v.alarm_name }
}

output "memory_alarm_names" {
  description = "Names of memory utilization alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.db_memory_low : k => v.alarm_name }
}

output "read_latency_alarm_names" {
  description = "Names of read latency alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.db_read_latency_high : k => v.alarm_name }
}

output "write_latency_alarm_names" {
  description = "Names of write latency alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.db_write_latency_high : k => v.alarm_name }
}
