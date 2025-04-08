output "private_ip" {
  value = aws_instance.master_node.private_ip
}

output "public_ip" {
  value = aws_instance.master_node.public_ip
}
