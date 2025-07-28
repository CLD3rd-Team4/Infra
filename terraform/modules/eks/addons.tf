resource "aws_eks_addon" "vpc_cni" {
  cluster_name     = aws_eks_cluster.this.name
  addon_name       = "vpc-cni"

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name     = aws_eks_cluster.this.name
  addon_name       = "coredns"

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name     = aws_eks_cluster.this.name
  addon_name       = "kube-proxy"

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-efs-csi-driver"
  service_account_role_arn = aws_iam_role.efs_csi_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}