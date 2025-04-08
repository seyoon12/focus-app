output "masternode_sg_group_ids" {
  value = module.masternode_sg.security_group_id
}

output "masternode_sg_group_name" {
  value = module.masternode_sg.security_group_name
}

output "workernodes_sg_group_name" {
  value = module.workernodes_sg.security_group_name
}

output "workernodes_sg_group_ids" {
  value = module.workernodes_sg.security_group_id
}

output "bastion_sg_group_ids" {
  value = module.bastion_sg.security_group_id
}

output "bastion_sg_group_name" {
  value = module.bastion_sg.security_group_name
}

output "eks_selfmanaged_node_sg_group_ids" {
  value = module.eks-selfmanaged-node_sg.security_group_id
}

output "eks_selfmanaged_node_sg_name" {
  value = module.eks-selfmanaged-node_sg.security_group_name
}

output "eks_cluster_sg_ids" {
  value = module.eks_cluster_sg.security_group_id
}

output "eks_cluster_sg_name" {
  value = module.eks_cluster_sg.security_group_name
}