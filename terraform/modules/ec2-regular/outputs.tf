output "private_ip" {
  value = aws_instance.ec2-regular.private_ip
}

output "public_ip" {
  value = aws_instance.ec2-regular.public_ip
}
