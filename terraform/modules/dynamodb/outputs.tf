
output "dynamodb_table_name" {
  value = aws_dynamodb_table.this.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "pending_review_table_name" {
  value = aws_dynamodb_table.pending_review.name
}

output "pending_review_table_arn" {
  value = aws_dynamodb_table.pending_review.arn
}
