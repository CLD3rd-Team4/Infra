output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
  sensitive = true
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
  sensitive = true
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.alb_irsa.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns_irsa.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  value = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

output "cluster_autoscaler_irsa_role_arn" {
  value       = aws_iam_role.cluster_autoscaler_irsa.arn
}

output "eks_cluster_security_group_id" {
  value       = aws_security_group.eks_cluster.id
}

output "review_service_role_arn" {
  description = "ARN of the IAM role for Review service"
  value       = aws_iam_role.review_service_irsa.arn
}
