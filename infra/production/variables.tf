variable "apex_domain" {
  default = "gabrielmiller.org"
  type    = string
}

variable "www_domain" {
  default = "www.gabrielmiller.org"
  type    = string
}

variable "region" {
  default = "us-east-2"
  type    = string
}

variable "private_bucket" {
  default = "lgm-albums"
  type    = string
}

variable "aws_profile" {
  default = "production"
  type    = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}