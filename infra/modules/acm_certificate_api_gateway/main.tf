terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

resource "aws_acm_certificate" "wildcard" {
  domain_name = var.domain
}