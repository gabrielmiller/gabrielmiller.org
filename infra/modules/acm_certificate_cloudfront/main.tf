terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.profile
}

resource "aws_acm_certificate" "wildcard" {
  provider = aws.virginia
  domain_name = var.domain
}