output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_private_id" {
  value = module.subnet_private.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_route_table_association_id" {
  value = aws_route_table_association.public.id
}

output "private_route_table_association_id" {
  value = aws_route_table_association.private.id
}

output "public_route_id" {
  value = aws_route.public_internet_access.id
}

output "private_route_id" {
  value = aws_route.private_natgw_access.id
}
