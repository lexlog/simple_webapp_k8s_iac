variable "cluster-name" {
  description = "Name of the EKS cluster"
  default     = "simple-eks-cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  default     = "eu-west-1"
  type        = string
}
