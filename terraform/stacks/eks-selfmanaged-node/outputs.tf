output "k8s_private_key" {
  value     = module.keypair.k8s_private_key
  sensitive = true
}

output "kubecost_irsa_role_arn" {
  value = module.eks_self_managed_node_group.kubecost_irsa_role_arn
}

output "ebs_csi_irsa_role_arn" {
  value = module.eks_self_managed_node_group.ebs_csi_irsa_role_arn
}