output "arn" {
  value = aws_lambda_function.backend_entries.arn
}

output "invoke_arn" {
  value = aws_lambda_function.backend_entries.invoke_arn
}
