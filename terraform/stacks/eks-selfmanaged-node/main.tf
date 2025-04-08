data "terraform_remote_state" "eks_cluster" {
  backend = "local"

  config = {
    path = "../eks-cluster/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.selected.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.selected.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.selected.token
}

module "keypair" {
  source = "../../modules/keyPair"
}

data "aws_eks_cluster" "selected" {
  name = "kubernetes"
}

data "aws_eks_cluster_auth" "selected" {
  name = "kubernetes"
}

data "aws_caller_identity" "current" {}

locals {
  oidc_url = replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "") # EKS CLUSTER에서 OIDC URL 가져옴
  oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}" #해당 URL과 함께 OIDC ARN 호출
  kubecost_s3_bucket_name = "finops-cost-reports"
  kubecost_s3_bucket_arn  = "arn:aws:s3:::${local.kubecost_s3_bucket_name}"
}

module "eks_self_managed_node_group" {
  source = "../../modules/eks-selfmanaged-node"
  # KUBECOST IRSA FOR S3
  enable_kubecost_irsa    = true
  kubecost_service_account = "kubecost"
  kubecost_namespace       = "kubecost"
  oidc_provider_url         = local.oidc_url
  oidc_provider_arn         = local.oidc_arn
  kubecost_s3_bucket_arn    = local.kubecost_s3_bucket_arn
  # KUBECOST IAM FOR EBS CSI
  enable_ebs_csi_irsa     = true
  # DEFAULT SET
  key_name               = module.keypair.k8s_keyname
  security_group_ids    = [data.terraform_remote_state.eks_cluster.outputs.eks_selfmanaged_node_sg_group_ids]
  eks_cluster_endpoint   = data.aws_eks_cluster.selected.endpoint
  eks_cluster_ca         = data.aws_eks_cluster.selected.certificate_authority[0].data
  eks_cluster_token      = data.aws_eks_cluster_auth.selected.token
  subnets                = data.terraform_remote_state.eks_cluster.outputs.public_subnet_ids
  eks_cluster_name       = "kubernetes"
  instance_type          = "t3.medium"
  desired_capacity       = 1
  min_size               = 1
  max_size               = 1

  node_labels = {
    "node.kubernetes.io/node-group" = "test-node"
  }
}