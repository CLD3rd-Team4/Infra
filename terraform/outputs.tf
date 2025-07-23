output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_route_id" {
  value = aws_route.public_internet_access.id
}

output "private_route_id" {
  value = aws_route.private_natgw_access.id
}

output "subnet_public_1a_id" {
  value = module.subnet_public_1a.id
}
output "subnet_public_2c_id" {
  value = module.subnet_public_2c.id
}
output "subnet_private_1a_1_id" {
  value = module.subnet_private_1a_1.id
}
output "subnet_private_1a_2_id" {
  value = module.subnet_private_1a_2.id
}
output "subnet_private_2c_1_id" {
  value = module.subnet_private_2c_1.id
}
output "subnet_private_2c_2_id" {
  value = module.subnet_private_2c_2.id
}

output "public_route_table_association_1a_id" {
  value = aws_route_table_association.public_1a.id
}
output "public_route_table_association_2c_id" {
  value = aws_route_table_association.public_2c.id
}
output "private_route_table_association_1a_1_id" {
  value = aws_route_table_association.private_1a_1.id
}
output "private_route_table_association_1a_2_id" {
  value = aws_route_table_association.private_1a_2.id
}
output "private_route_table_association_2c_1_id" {
  value = aws_route_table_association.private_2c_1.id
}
output "private_route_table_association_2c_2_id" {
  value = aws_route_table_association.private_2c_2.id
}
