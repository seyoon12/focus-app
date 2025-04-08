provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "eks_cluster" {
  source             = "../../modules/eks-cluster"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.sg.eks_cluster_sg_ids]
}