resource "aws_instance" "simple-instance" {
  count                       = var.total_instance_to_create
  ami                         = var.default_ami 
  instance_type               = var.instance_type 
  
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group
  
  associate_public_ip_address = var.set_public_ip_address
  
  key_name                    = var.key_name
  user_data                   = var.user_data
  
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = false
    encrypted             = true
  }

  tags = {
    Name = "${var.instance_name}"
  }
}