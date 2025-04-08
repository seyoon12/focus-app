terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    profile = "default"
    region  = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
}

module "keypair" {
  source = "../../modules/keyPair"
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2-regular" {
  source            = "../../modules/ec2-regular"
  subnet_id         = module.vpc.public_subnet_id   
  availability_zone = module.vpc.availability_zone_0
  key_name          = module.keypair.k8s_keyname
  workernodes_sg_group_id = [module.sg.workernodes_sg_group_ids]
  ami               = var.ami
  instance_type     = var.instance_type
}
