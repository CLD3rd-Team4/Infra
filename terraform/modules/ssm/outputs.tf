output "github_username_parameter_name" {
  description = "Name of the GitHub username SSM parameter"
  value       = aws_ssm_parameter.github_username.name
}

output "github_token_parameter_name" {
  description = "Name of the GitHub token SSM parameter"
  value       = aws_ssm_parameter.github_token.name
}

output "encrypt_key_parameter_name" {
  description = "Name of the encrypt key SSM parameter"
  value       = length(aws_ssm_parameter.encrypt_key) > 0 ? aws_ssm_parameter.encrypt_key[0].name : null
}
