resource "aws_s3_bucket" "assets_website" {
  bucket = var.bucket

  depends_on = [
    aws_s3_bucket_ownership_controls.assets_website,
    aws_s3_bucket_public_access_block.assets_website
  ]
}

resource "aws_s3_bucket_ownership_controls" "assets_website" {
  bucket = var.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "assets_website" {
  bucket = var.bucket
  policy = data.aws_iam_policy_document.assets_website.json
}

data "aws_iam_policy_document" "assets_website" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket}/*"]
    effect    = "Allow"
    sid       = "PublicReadGetObject"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "assets_website" {
  bucket = var.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "assets_website" {
  bucket                  = var.bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
