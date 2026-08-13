variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "devops-lab"
}

variable "cluster_name" {
  type    = string
  default = "ci-cd-mastery-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["c7i-flex.large"]
}

variable "node_min_size" {
  type    = number
  default = 3
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_cluster_logs" {
  type    = bool
  default = true
}

variable "enable_ecr" {
  type    = bool
  default = true
}
