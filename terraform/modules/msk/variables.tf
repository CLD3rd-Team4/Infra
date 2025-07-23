variable "name_prefix" {
  description = "A prefix used for naming resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "The specific name for the MSK cluster"
  type        = string
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the MSK cluster"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for MSK broker nodes"
  type        = string
  default     = "kafka.t3.small"
}

variable "ebs_volume_size" {
  description = "EBS volume size (in GiB) per broker"
  type        = number
  default     = 100
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs for MSK"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for MSK"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}