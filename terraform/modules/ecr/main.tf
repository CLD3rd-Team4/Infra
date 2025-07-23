resource "aws_ecr_repository" "this" {
  name = "${var.common_prefix}ecr-${var.name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.common_prefix}ecr-${var.name}"
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
