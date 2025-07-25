resource "aws_launch_template" "eks_lt" {
  name_prefix   = "${var.common_prefix}lt-"
  image_id      = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.eks_key_pair

  vpc_security_group_ids = [aws_security_group.aws_eks_node_group.id]

  tag_specifications {
    resource_type = "instance"
    tags = var.common_tags
  }
}