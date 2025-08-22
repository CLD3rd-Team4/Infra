output "route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.this.id
}

output "route_id" {
  description = "Default route ID"
  value       = aws_route.default.id
}

output "route_table_associations" {
  description = "List of route table association IDs"
  value       = aws_route_table_association.subnet_associations[*].id
}
