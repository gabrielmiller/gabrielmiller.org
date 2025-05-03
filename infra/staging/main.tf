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

locals {
  domain_api                = "api.${var.apex_domain}"
  domain_apex_with_protocol = "https://${var.apex_domain}"
}

module "acm_certificate_cloudfront" {
  source  = "../modules/acm_certificate_cloudfront"
  domain  = var.apex_domain
  profile = var.aws_profile
  zone_id = var.cloudflare_zone_id
}

module "acm_certificate_api_gateway" {
  source  = "../modules/acm_certificate_api_gateway"
  domain  = local.domain_api
  profile = var.aws_profile
  region  = var.region
  zone_id = var.cloudflare_zone_id
}

module "cloudflare_api_dns" {
  source  = "../modules/cloudflare_api_dns"
  zone_id = var.cloudflare_zone_id
  value   = module.api_gateway_backend.domain
}

module "cloudflare_apex_dns" {
  source  = "../modules/cloudflare_apex_dns"
  domain  = var.apex_domain
  value   = module.cloudfront_apex_website.domain_name
  zone_id = var.cloudflare_zone_id
}

module "cloudflare_www_dns" {
  source  = "../modules/cloudflare_www_dns"
  value   = module.cloudfront_www_website.domain_name
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
  source          = "../modules/cloudfront_apex_website"
  cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #CachingDisabled
  certificate_id  = module.acm_certificate_cloudfront.id
  domain          = var.apex_domain
  region          = var.region
}

module "cloudfront_www_website" {
  source          = "../modules/cloudfront_www_website"
  domain          = var.www_domain
  cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #CachingDisabled
  certificate_id  = module.acm_certificate_cloudfront.id
  region          = var.region
}

module "local_env_file" {
  source                   = "../modules/local_env_file"
  album_bucket_name        = var.private_bucket
  album_bucket_region      = var.region
  apex_domain              = var.apex_domain
  aws_profile              = var.aws_profile
  cloudfront_cache_max_age = "0"
  environment_name         = var.environment_name
}

module "s3_bucket_lambda" {
  source = "../modules/s3_bucket_lambda"
  bucket = "lambda.${var.apex_domain}"
}

module "lambda_album" {
  source               = "../modules/lambda_album"
  lambda_deploy_bucket = module.s3_bucket_lambda.id
  bucket               = var.private_bucket
  aws_region           = var.region
}

module "lambda_entries" {
  source               = "../modules/lambda_entries"
  lambda_deploy_bucket = module.s3_bucket_lambda.id
  bucket               = var.private_bucket
  aws_region           = var.region
}

module "api_gateway_backend" {
  source                             = "../modules/api_gateway_backend"
  allowed_cors_origin                = local.domain_apex_with_protocol
  cert_arn                           = module.acm_certificate_api_gateway.id
  domain                             = local.domain_api
  lambda_function_album_invoke_arn   = module.lambda_album.invoke_arn
  lambda_function_album_name         = module.lambda_album.arn
  lambda_function_entries_invoke_arn = module.lambda_entries.invoke_arn
  lambda_function_entries_name       = module.lambda_entries.arn
  region                             = var.region
  profile                            = var.aws_profile
}

