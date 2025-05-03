resource "aws_lambda_function" "backend_album" {
  function_name = "backend_album"

  s3_bucket = var.lambda_deploy_bucket
  s3_key    = aws_s3_object.lambda_backend_album.key

  runtime       = "provided.al2023"
  handler       = "bootstrap"
  architectures = ["arm64"]
  memory_size   = 128
  timeout       = 15

  source_code_hash = data.archive_file.lambda_backend_album.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      ALBUM_BUCKET = var.bucket
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:177933569100:layer:AWS-Parameters-and-Secrets-Lambda-Extension-Arm64:12"
  ]
}

resource "aws_cloudwatch_log_group" "backend_album_lambda" {
  name = "/aws/lambda/${aws_lambda_function.backend_album.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name               = "backend_album"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_backend_album_policy.arn
}

resource "aws_iam_policy" "lambda_backend_album_policy" {
  name        = "lambda_album_backend"
  description = "Can read/write logs and get files from s3"
  policy      = data.aws_iam_policy_document.lambda_backend_album_policy_document.json
}

data "aws_caller_identity" "current" {}

# This is arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
# scoped to its specific logs plus limited access to the s3 album bucket
data "aws_iam_policy_document" "lambda_backend_album_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "s3:GetObject",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.bucket}/*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.backend_album_lambda.name}:*",
    ]
  }
}

data "archive_file" "lambda_backend_album" {
  type = "zip"

  source_dir  = "../lambda-builds"
  output_path = "../artifacts/api-album.zip"
  depends_on  = [null_resource.build_go_binary]
}

resource "aws_s3_object" "lambda_backend_album" {
  bucket      = var.lambda_deploy_bucket
  key         = "api-album.zip"
  source      = data.archive_file.lambda_backend_album.output_path
  source_hash = data.archive_file.lambda_backend_album.output_base64sha256

  depends_on = [null_resource.build_go_binary]
}

data "local_file" "lambda_source" {
  filename = "../../src/packages/backend-album/album.go"
}

resource "null_resource" "build_go_binary" {
  provisioner "local-exec" {
    command = "cd ../../src/packages/backend-album && GOOS=linux GOARCH=arm64 go build -o prepnode_arm64 -o ../../../infra/lambda-builds/album/bootstrap"
  }

  triggers = {
    source_code_hash = data.local_file.lambda_source.content_base64sha256
  }
}
