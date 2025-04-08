output "private_ip" {
  value = aws_instance.worker_node.private_ip
}

output "public_ip" {
  value = aws_instance.worker_node.public_ip
}
