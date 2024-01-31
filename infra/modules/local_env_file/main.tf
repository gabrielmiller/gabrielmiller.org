resource "local_file" "environment" {
  content = <<-ENVFILE
  ALBUM_BUCKET="${var.album_bucket_name}"
  ALBUM_BUCKET_REGION="${var.album_bucket_region}"
  APEX_BUCKET_NAME="${var.apex_bucket_name}"
  APEX_DOMAIN="https://${var.apex_domain}"
  CLOUDFRONT_CACHE_MAX_AGE="${var.cloudfront_cache_max_age}"
  ENVFILE

  filename = "../../.env.${var.environment_name}"
}