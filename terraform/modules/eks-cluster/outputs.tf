output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy
}

output "kubernetes_version" {
  value = var.kubernetes_version
}

output "eks_cluster_endpoint" {
  value = data.aws_eks_cluster.selected.endpoint
}

output "eks_cluster_ca" {
  value = data.aws_eks_cluster.selected.certificate_authority[0].data
}

output "eks_cluster_token" {
  value = data.aws_eks_cluster_auth.selected.token
}