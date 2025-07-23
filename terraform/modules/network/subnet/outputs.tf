output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.this[*].id
}

output "subnet_ids_by_az" {
  description = "Map of subnet IDs by availability zone"
  value = {
    for subnet in aws_subnet.this :
    subnet.availability_zone => subnet.id...
  }
}

output "subnet_ids_by_name" {
  description = "Map of subnet IDs by subnet name"
  value = {
    for i, subnet in aws_subnet.this :
    var.subnets[i].name => subnet.id
  }
}
