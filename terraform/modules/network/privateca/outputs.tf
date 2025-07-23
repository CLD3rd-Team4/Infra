output "ca_arn" {
  value = aws_acmpca_certificate_authority.this.arn
}

output "server_certificate_arn" {
  value = aws_acmpca_certificate.vpn_server.arn
}

output "client_certificate_arn" {
  value = aws_acmpca_certificate.vpn_client.arn
}
