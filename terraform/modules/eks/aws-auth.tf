# aws-auth ConfigMap 관리
# GitHub Actions OIDC 역할을 EKS 클러스터에 추가

resource "null_resource" "aws_auth" {
  triggers = {
    cluster_name = aws_eks_cluster.this.name
    node_role_arn = var.node_group_role_arn
    github_role_arn = var.github_actions_role_arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      # EKS 클러스터 kubeconfig 설정
      aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}
      
      # 기존 aws-auth ConfigMap이 있는지 확인하고 패치
      if kubectl get configmap aws-auth -n kube-system >/dev/null 2>&1; then
        echo "Patching existing aws-auth ConfigMap..."
        kubectl patch configmap aws-auth -n kube-system --patch '
data:
  mapRoles: |
    - rolearn: ${var.node_group_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
      - system:bootstrappers
      - system:nodes
    - rolearn: ${var.github_actions_role_arn}
      username: github-actions
      groups:
      - system:masters
'
      else
        echo "Creating new aws-auth ConfigMap..."
        kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${var.node_group_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
      - system:bootstrappers
      - system:nodes
    - rolearn: ${var.github_actions_role_arn}
      username: github-actions
      groups:
      - system:masters
EOF
      fi
    EOT
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}
