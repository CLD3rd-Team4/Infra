output "server_certificate_arn" {
  description = "ARN of the VPN server certificate"
  value       = aws_acm_certificate.vpn_server.arn
}

output "ca_certificate_arn" {
  description = "ARN of the VPN CA certificate"
  value       = aws_acm_certificate.vpn_ca.arn
}

output "client_certificate_arns" {
  description = "Map of client certificate ARNs by team member name"
  value       = { for k, v in aws_acm_certificate.vpn_client : k => v.arn }
}

output "server_certificate_id" {
  description = "ID of the VPN server certificate"
  value       = aws_acm_certificate.vpn_server.id
}

output "ca_certificate_id" {
  description = "ID of the VPN CA certificate"
  value       = aws_acm_certificate.vpn_ca.id
}
