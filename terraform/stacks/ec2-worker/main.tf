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

module "sg" {
  source = "../../modules/sg"
  vpc_id = data.terraform_remote_state.ec2-master.outputs.vpc_id
}

data "terraform_remote_state" "ec2-master" {
  backend = "local"
  config = {
    path = "../ec2-master/terraform.tfstate"
  }
}

module "worker_node_01" {
  source            = "../../modules/ec2-worker"
  subnet_id         = data.terraform_remote_state.ec2-master.outputs.public_subnet_id
  availability_zone = data.terraform_remote_state.ec2-master.outputs.availability_zone_0
  key_name          = "k8s" # ec2-master에서 사용 중인 key
  workernodes_sg_group_id = [module.sg.workernodes_sg_group_ids]
  ami               = var.ami
  instance_type     = var.instance_type

  user_data = templatefile("${path.module}/../../scripts/worker-userdata.sh", {
    master_ip = data.terraform_remote_state.ec2-master.outputs.private_ip  
    tls_private_key = data.terraform_remote_state.ec2-master.outputs.k8s_private_key
})
}

module "worker_node_02" {
  source            = "../../modules/ec2-worker"
  subnet_id         = data.terraform_remote_state.ec2-master.outputs.public_subnet_id
  availability_zone = data.terraform_remote_state.ec2-master.outputs.availability_zone_0
  key_name          = "k8s" # ec2-master에서 사용 중인 key
  workernodes_sg_group_id = [module.sg.workernodes_sg_group_ids]
  ami               = var.ami
  instance_type     = var.instance_type

  user_data = templatefile("${path.module}/../../scripts/worker-userdata.sh", {
    master_ip = data.terraform_remote_state.ec2-master.outputs.private_ip
    tls_private_key = data.terraform_remote_state.ec2-master.outputs.k8s_private_key
})
}