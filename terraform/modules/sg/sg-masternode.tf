module "masternode_sg" {
    source  = "terraform-aws-modules/security-group/aws"
    name = "masternode_sg"
    vpc_id = var.vpc_id
    ingress_rules = ["all-all"]
    ingress_cidr_blocks = ["0.0.0.0/0"]
    egress_rules = ["all-all"]
}
