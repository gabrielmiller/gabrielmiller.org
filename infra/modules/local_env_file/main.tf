resource "local_file" "environment" {
  content = <<-ENVFILE
  ALBUM_BUCKET="${var.album_bucket_name}"
  ALBUM_BUCKET_REGION="${var.album_bucket_region}"
  APEX_DOMAIN="${var.apex_domain}"
  APEX_DOMAIN_ORIGIN="https://${var.apex_domain}"
  AWS_PROFILE="${var.aws_profile}"
  CLOUDFRONT_CACHE_MAX_AGE="${var.cloudfront_cache_max_age}"
  ENVFILE

  filename = "../../.env.${var.environment_name}"
}
