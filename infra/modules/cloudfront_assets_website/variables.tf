
variable "default_cache_ttl" {
  type    = number
  default = 60
}

variable "domain" {
  type = string
}

variable "region" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "cache_policy_id" {
  type = string
}
