# VPN 서버 인증서 ACM 업로드
resource "aws_acm_certificate" "vpn_server" {
  certificate_body  = file("${var.cert_path}/issued/server.crt")
  private_key       = file("${var.cert_path}/private/server.key")
  certificate_chain = file("${var.cert_path}/ca.crt")

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-server-cert"
    }
  )
}

# VPN CA 인증서 ACM 업로드 (클라이언트 인증 체인용)
resource "aws_acm_certificate" "vpn_ca" {
  certificate_body = file("${var.cert_path}/ca.crt")
  private_key      = file("${var.cert_path}/private/ca.key")

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-ca-cert"
    }
  )
}

# 팀원별 클라이언트 인증서 ACM 업로드
resource "aws_acm_certificate" "vpn_client" {
  for_each = toset(var.team_members)
  
  certificate_body  = file("${var.cert_path}/issued/${each.key}.crt")
  private_key       = file("${var.cert_path}/private/${each.key}.key")
  certificate_chain = file("${var.cert_path}/ca.crt")

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}vpn-client-${each.key}-cert"
    }
  )
}
