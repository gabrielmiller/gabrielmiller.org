resource "aws_cloudfront_distribution" "www_website" {
  enabled         = true
  aliases         = [var.domain]
  is_ipv6_enabled = true
  origin {
    domain_name = "${var.domain}.s3-website.${var.region}.amazonaws.com"
    origin_id   = "${var.domain}.s3-website.${var.region}.amazonaws.com"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
  default_cache_behavior {
    cache_policy_id        = var.cache_policy_id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "${var.domain}.s3-website.${var.region}.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
  }
  viewer_certificate {
    acm_certificate_arn      = var.certificate_id
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}