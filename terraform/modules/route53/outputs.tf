output "zone_id" {
  description = "The ID of the created hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "List of Route53 name servers"
  value       = aws_route53_zone.this.name_servers
}
