terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }
  }
  required_version = "~> 1.12.0"
}

provider "aws" {
  region = "ap-northeast-2"
}
