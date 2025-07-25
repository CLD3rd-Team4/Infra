# VPN 서버 인증서 ACM 업로드
resource "aws_acm_certificate" "vpn_server" {
  certificate_body  = var.server_cert_body
  private_key       = var.server_private_key
  certificate_chain = var.ca_cert_body

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-server-cert"
    }
  )
}

# VPN CA 인증서 ACM 업로드 (클라이언트 인증 체인용)
resource "aws_acm_certificate" "vpn_ca" {
  certificate_body = var.ca_cert_body
  private_key      = var.ca_private_key

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-ca-cert"
    }
  )
}

# 팀원별 클라이언트 인증서 ACM 업로드
resource "aws_acm_certificate" "vpn_client" {
  for_each = nonsensitive(var.client_certs)
  
  certificate_body  = each.value.cert_body
  private_key       = each.value.private_key
  certificate_chain = var.ca_cert_body

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-client-${each.key}-cert"
    }
  )
}
