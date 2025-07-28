resource "aws_launch_template" "eks_lt" {
  name_prefix   = "${var.common_prefix}lt-"
  image_id      = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.eks_key_pair

  vpc_security_group_ids = [aws_security_group.aws_eks_node_group.id]

  user_data = base64encode(<<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: "${var.cluster_name}"
    apiServerEndpoint: "${aws_eks_cluster.this.endpoint}"
    certificateAuthority: "${aws_eks_cluster.this.certificate_authority[0].data}"
    cidr: "172.20.0.0/16"

--BOUNDARY--
EOF
)

  tag_specifications {
    resource_type = "instance"
    tags = var.common_tags
  }
}