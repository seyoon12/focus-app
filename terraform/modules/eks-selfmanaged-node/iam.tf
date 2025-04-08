
resource "aws_iam_role" "eks_self_managed_node_group" {
  name               = "${var.eks_cluster_name}-${local.node_group_name}-role"
  assume_role_policy = file("${path.module}/iam_ec2_assume_role_policy.json")
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_self_managed_node_group.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_self_managed_node_group.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_self_managed_node_group.name
}

resource "aws_iam_instance_profile" "eks_self_managed_node_group" {
  name = "${var.eks_cluster_name}-${local.node_group_name}-instance-profile"
  role = aws_iam_role.eks_self_managed_node_group.name
  tags = var.tags
}

#---test---

resource "aws_iam_policy" "eks_master_access" {
  name = "${var.eks_cluster_name}-${local.node_group_name}-eks-master-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*", # 전체 액세스 (테스트용)
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_master_access" {
  role       = aws_iam_role.eks_self_managed_node_group.name
  policy_arn = aws_iam_policy.eks_master_access.arn
}

# --- IRSA for eks-node ---

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

locals {
  oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_provider_arn = replace(local.oidc_provider_url, "https://", "")
}

resource "aws_iam_role" "aws_node_irsa_role" {
  name = "aws-node-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_arn}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${local.oidc_provider_arn}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "aws_node_irsa_attach" {
  role       = aws_iam_role.aws_node_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}