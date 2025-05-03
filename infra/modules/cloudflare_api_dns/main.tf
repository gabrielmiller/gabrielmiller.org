terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}
resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = var.domain
  value   = var.value
  proxied = false
  type    = "CNAME"
}
