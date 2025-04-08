output "k8s_private_key" {
  value     = module.keypair.k8s_private_key
  sensitive = true
}