output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "node_group_min_size" {
  value = var.node_min_size
}

output "node_group_desired_size" {
  value = var.node_desired_size
}

output "node_group_max_size" {
  value = var.node_max_size
}

output "ecr_repository_url" {
  value = var.enable_ecr ? aws_ecr_repository.applications[0].repository_url : null
}
