resource "aws_instance" "master_node" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  availability_zone      = var.availability_zone
  vpc_security_group_ids        = var.masternode_sg_group_id
  associate_public_ip_address = true
  
  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = var.user_data

  tags = {
    Name = "master_nodes"
  }
}