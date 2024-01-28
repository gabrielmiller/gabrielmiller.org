resource "aws_s3_bucket" "www_website" {
  bucket = var.domain
}

resource "aws_s3_bucket_website_configuration" "www_website" {
  bucket = var.domain
  redirect_all_requests_to {
    host_name = var.redirect_domain
    protocol  = "https"
  }
}