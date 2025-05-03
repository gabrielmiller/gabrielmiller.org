output "arn" {
  value = aws_lambda_function.backend_album.arn
}

output "invoke_arn" {
  value = aws_lambda_function.backend_album.invoke_arn
}
