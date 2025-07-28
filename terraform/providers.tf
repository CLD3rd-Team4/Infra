terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
  }
  required_version = "~> 1.12.0"
}

provider "aws" {
  region = "ap-northeast-2"
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

