variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "node_group_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "common_prefix" {
  type        = string
}

variable "common_tags" {
  type        = map(string)
}

variable "vpc_id" {
  type        = string
}

variable "public_access_cidrs" {
  type        = list(string)
}

variable "ami_id" {
  type        = string
}

variable "eks_key_pair" {
  type        = string
}
