output "id" {
  value = aws_subnet.this[0].id
  description = "ID of the first subnet (deprecated, use all_ids instead)"
}

output "all_ids" {
  value = aws_subnet.this[*].id
  description = "List of all subnet IDs in order of definition"
}

output "ids_by_name" {
  value = { for i, subnet in var.subnets : subnet.name => aws_subnet.this[i].id }
  description = "Map of subnet names to their IDs"
}

output "public" {
  value = [
    for i, subnet in var.subnets :
    aws_subnet.this[i].id if subnet.type == "public" || subnet.map_public_ip_on_launch
  ]
  description = "List of public subnet IDs"
}

output "private" {
  value = [
    for i, subnet in var.subnets :
    aws_subnet.this[i].id if subnet.type == "private" && !subnet.map_public_ip_on_launch
  ]
  description = "List of private subnet IDs"
}

output "public_subnet_ids" {
  value = [
    for i, subnet in var.subnets :
    aws_subnet.this[i].id if subnet.type == "public" || subnet.map_public_ip_on_launch
  ]
  description = "List of public subnet IDs (alias for public)"
}

output "private_subnet_ids" {
  value = [
    for i, subnet in var.subnets :
    aws_subnet.this[i].id if subnet.type == "private" && !subnet.map_public_ip_on_launch
  ]
  description = "List of private subnet IDs (alias for private)"
}

output "subnets" {
  value = aws_subnet.this
  description = "All subnet resources"
} 