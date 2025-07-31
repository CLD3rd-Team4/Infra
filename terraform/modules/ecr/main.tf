resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.repository_names)
  name     = "${var.common_prefix}ecr-${each.value}"
  # force_delete = true # 내부에 이미지가 있어도 삭제됨
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.common_prefix}ecr-${each.value}"
  })
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
