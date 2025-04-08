output "eks_selfmanaged_node_sg_group_ids" {
  value = module.sg.eks_selfmanaged_node_sg_group_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}