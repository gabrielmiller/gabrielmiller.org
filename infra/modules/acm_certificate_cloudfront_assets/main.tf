terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.profile
}

resource "aws_acm_certificate" "certificate" {
  provider          = aws.virginia
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "acm_dns_validation" {
  zone_id = var.zone_id
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  value   = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value
  ttl     = 1
}

resource "aws_acm_certificate_validation" "validated_certificate" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  ]
  depends_on = [cloudflare_record.acm_dns_validation]
}
