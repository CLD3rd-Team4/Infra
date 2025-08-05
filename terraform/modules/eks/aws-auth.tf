# aws-auth ConfigMap 관리
# GitHub Actions OIDC 역할을 EKS 클러스터에 추가

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      # EKS Node Group 역할 (기본)
      {
        rolearn  = var.node_group_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      # GitHub Actions OIDC 역할 추가
      {
        rolearn  = var.github_actions_role_arn
        username = "github-actions"
        groups = [
          "system:masters"
        ]
      }
    ])
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}
