output "ca_arn" {
  value = aws_acmpca_certificate_authority.this.arn
}

output "server_certificate_arn" {
  value = aws_acmpca_certificate.vpn_server.arn
}

# Client VPN에서 사용할 기본 인증서 (JSW)
output "client_certificate_arn" {
  value = aws_acmpca_certificate.vpn_client["JSW"].arn
}

# 팀원별 개별 클라이언트 인증서 ARN
output "client_certificate_arn_JSW" {
  value = aws_acmpca_certificate.vpn_client["JSW"].arn
}

output "client_certificate_arn_YJM" {
  value = aws_acmpca_certificate.vpn_client["YJM"].arn
}

output "client_certificate_arn_PSY" {
  value = aws_acmpca_certificate.vpn_client["PSY"].arn
}

output "client_certificate_arn_SYU" {
  value = aws_acmpca_certificate.vpn_client["SYU"].arn
}

output "client_certificate_arn_CSM" {
  value = aws_acmpca_certificate.vpn_client["CSM"].arn
}

output "client_certificate_arn_HDY" {
  value = aws_acmpca_certificate.vpn_client["HDY"].arn
}

# 팀원별 클라이언트 인증서 내용 (민감 정보)
output "client_certificate_JSW" {
  value = aws_acmpca_certificate.vpn_client["JSW"].certificate
  sensitive = true
}

output "client_certificate_YJM" {
  value = aws_acmpca_certificate.vpn_client["YJM"].certificate
  sensitive = true
}

output "client_certificate_PSY" {
  value = aws_acmpca_certificate.vpn_client["PSY"].certificate
  sensitive = true
}

output "client_certificate_SYU" {
  value = aws_acmpca_certificate.vpn_client["SYU"].certificate
  sensitive = true
}

output "client_certificate_CSM" {
  value = aws_acmpca_certificate.vpn_client["CSM"].certificate
  sensitive = true
}

output "client_certificate_HDY" {
  value = aws_acmpca_certificate.vpn_client["HDY"].certificate
  sensitive = true
}
