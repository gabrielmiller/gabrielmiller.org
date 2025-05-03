output "domain" {
  value = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
}
