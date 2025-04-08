output "k8s_private_key" {
  value     = module.keypair.k8s_private_key
  sensitive = true
}

output "private_ip" {
  value = module.master_node.private_ip
}

output "public_ip" {
  value = module.master_node.public_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "availability_zone_0" {
  value = module.vpc.availability_zone_0
}