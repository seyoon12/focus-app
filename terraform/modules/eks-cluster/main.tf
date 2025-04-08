resource "aws_eks_cluster" "kubernetes" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

data "aws_eks_cluster" "selected" {
  name = aws_eks_cluster.kubernetes.name
  depends_on = [aws_eks_cluster.kubernetes]
}

data "aws_eks_cluster_auth" "selected" {
  name = aws_eks_cluster.kubernetes.name
  depends_on = [aws_eks_cluster.kubernetes]
}