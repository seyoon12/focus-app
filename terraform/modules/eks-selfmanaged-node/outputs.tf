output "name" {
  value = "${var.eks_cluster_name}-${local.node_group_name}"
}

output "role_arn" {
  value = aws_iam_role.eks_self_managed_node_group.arn
}

output "ami_id" {
  value = data.aws_ami.selected_eks_optimized_ami.id
}

output "ami_name" {
  value = data.aws_ami.selected_eks_optimized_ami.name
}

output "ami_description" {
  value = data.aws_ami.selected_eks_optimized_ami.description
}

output "ami_creation_date" {
  value = data.aws_ami.selected_eks_optimized_ami.creation_date
}

output "kubecost_irsa_role_arn" {
  value = var.enable_kubecost_irsa ? aws_iam_role.kubecost_irsa[0].arn : null #irsa true 일 때만 output
}

output "ebs_csi_irsa_role_arn" {
  value = length(aws_iam_role.ebs_csi_irsa) > 0 ? aws_iam_role.ebs_csi_irsa[0].arn : null
}