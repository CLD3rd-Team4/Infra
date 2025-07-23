output "natgw_id" {
  value = aws_nat_gateway.this.id
}

output "eip_id" {
  value = aws_eip.this.id
} 