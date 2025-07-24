resource "aws_acmpca_certificate_authority" "this" {
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "${var.common_prefix}-vpn-ca"
    }
  }

  permanent_deletion_time_in_days = 7
  type                           = "ROOT"
  tags                           = merge(var.common_tags, { Name = "${var.common_prefix}-vpn-ca" })
}

# Root CA 인증서 생성
resource "aws_acmpca_certificate" "root" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.this.arn
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request
  signing_algorithm          = "SHA512WITHRSA"

  template_arn = "arn:aws:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "MONTHS"
    value = 2
  }
}

# Root CA 활성화
resource "aws_acmpca_certificate_authority_certificate" "root" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn
  certificate              = aws_acmpca_certificate.root.certificate
  certificate_chain        = aws_acmpca_certificate.root.certificate_chain
}

# VPN 서버 인증서
resource "aws_acmpca_certificate" "vpn_server" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.this.arn
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request
  signing_algorithm          = "SHA512WITHRSA"

  template_arn = "arn:aws:acm-pca:::template/EndEntityCertificate/V1"

  validity {
    type  = "MONTHS"
    value = 2
  }
}

# VPN 클라이언트 인증서 (팀원별 6개)
resource "aws_acmpca_certificate" "vpn_client" {
  for_each = toset(["JSW", "YJM", "PSY", "SYU", "CSM", "HDY"])
  
  certificate_authority_arn   = aws_acmpca_certificate_authority.this.arn
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request
  signing_algorithm          = "SHA512WITHRSA"

  template_arn = "arn:aws:acm-pca:::template/EndEntityCertificate/V1"

  validity {
    type  = "MONTHS"
    value = 2
  }
}
