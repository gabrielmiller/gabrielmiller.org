terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "acm_certificate_cloudfront" {
  source = "../modules/acm_certificate_cloudfront"
  domain = var.apex_domain
  profile = var.aws_profile
  providers = {
    aws = aws.virginia
  }
}

module "acm_certificate_api_gateway" {
  source = "../modules/acm_certificate_api_gateway"
  domain = var.apex_domain
}

module "cloudflare_apex_dns" {
  source = "../modules/cloudflare_apex_dns"
  domain = var.apex_domain
  value = module.cloudfront_apex_website.domain_name
  zone_id = var.cloudflare_zone_id
}

module "cloudflare_www_dns" {
  source = "../modules/cloudflare_www_dns"
  value = module.cloudfront_www_website.domain_name
  zone_id = var.cloudflare_zone_id
}

module "s3_bucket_private" {
  source = "../modules/s3_bucket_private"
  bucket = var.private_bucket
}

module "s3_bucket_apex_website" {
  source = "../modules/s3_bucket_apex_website"
  bucket = var.apex_domain
}

module "s3_bucket_www_website" {
  source          = "../modules/s3_bucket_www_website"
  domain          = var.www_domain
  redirect_domain = var.apex_domain
}

module "cloudfront_apex_website" {
  source         = "../modules/cloudfront_apex_website"
  domain         = var.apex_domain
  region         = var.region
  certificate_id = module.acm_certificate_cloudfront.id
  cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" #CachingOptimized
}

module "cloudfront_www_website" {
  source         = "../modules/cloudfront_www_website"
  domain         = var.www_domain
  region         = var.region
  certificate_id = module.acm_certificate_cloudfront.id
  cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" #CachingOptimized
}