output "msk_cluster_arn" {
  description = "The ARN of the MSK cluster"
  value       = aws_msk_cluster.this.arn
}

output "msk_cluster_bootstrap_brokers" {
  description = "A comma separated list of one or more DNS names and client ports that you can use to connect to the broker (plaintext)."
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "msk_cluster_bootstrap_brokers_tls" {
  description = "A comma separated list of one or more DNS names and client ports that you can use to connect to the broker for TLS encryption."
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "msk_cluster_zookeeper_connect_string" {
  description = "A comma separated list of one or more Zookeeper IP addresses and client ports that you can use to connect to the Zookeeper cluster."
  value       = aws_msk_cluster.this.zookeeper_connect_string
}