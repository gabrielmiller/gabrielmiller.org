provider "aws" {
  alias   = "virginia"
  region  = var.region
  profile = var.profile
}


resource "aws_apigatewayv2_api" "backend" {
  description   = "Album API gateway"
  name          = "album-api"
  protocol_type = "HTTP"
  version       = 1


  cors_configuration {
    allow_credentials = true
    allow_headers     = ["authorization", "content-type"]
    allow_methods     = ["GET"]
    allow_origins     = [var.allowed_cors_origin]
    expose_headers    = ["authorization"]
  }
}

resource "aws_apigatewayv2_domain_name" "backend" {
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = var.cert_arn

    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "backend" {
  api_id      = aws_apigatewayv2_api.backend.id
  domain_name = aws_apigatewayv2_domain_name.backend.id
  stage       = aws_apigatewayv2_stage.backend.id
}

resource "aws_apigatewayv2_stage" "backend" {
  api_id      = aws_apigatewayv2_api.backend.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_api_gateway.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "album_backend" {
  api_id = aws_apigatewayv2_api.backend.id

  integration_uri    = var.lambda_function_album_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "entries_backend" {
  api_id = aws_apigatewayv2_api.backend.id

  integration_uri    = var.lambda_function_entries_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_album" {
  api_id = aws_apigatewayv2_api.backend.id

  route_key = "GET /album"
  target    = "integrations/${aws_apigatewayv2_integration.album_backend.id}"
}

resource "aws_apigatewayv2_route" "api_entries" {
  api_id = aws_apigatewayv2_api.backend.id

  route_key = "GET /entries"
  target    = "integrations/${aws_apigatewayv2_integration.entries_backend.id}"
}

resource "aws_cloudwatch_log_group" "api_api_gateway" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.backend.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw_album" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_album_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.backend.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_entries" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_entries_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.backend.execution_arn}/*/*"
}
