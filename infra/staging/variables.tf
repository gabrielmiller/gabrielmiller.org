variable "apex_domain" {
  default = "gabebook.com"
  type    = string
}

variable "www_domain" {
  default = "www.gabebook.com"
  type    = string
}

variable "region" {
  default = "us-east-2"
  type    = string
}

variable "private_bucket" {
  default = "lgm-albums-staging"
  type    = string
}

variable "aws_profile" {
  default = "staging"
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