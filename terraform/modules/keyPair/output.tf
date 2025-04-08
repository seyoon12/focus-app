output "k8s_keyname" {
    value = aws_key_pair.k8s.key_name
}

output "k8s_private_key" {
  value     = tls_private_key.tls_private_key.private_key_pem
  sensitive = true
}
