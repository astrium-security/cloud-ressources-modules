module "create_instance" {
  source                     = "../standalone_resources/ec2_instance"
  count                      = length(var.public_subnets)

  total_instance_to_create   = 1

  instance_name              = "cf-tunnel-${count.index}"
  
  default_ami                = "ami-0f06e9c59c95f3773"
  instance_type              = "t2.micro"

  subnet_id                  = var.public_subnets[count.index].id 
  security_group             = [module.security_groups.id]
  set_public_ip_address      = true

  key_name                   = "sacha"
  user_data                   = <<EOF
#!/bin/bash -xe
sleep 10
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb && 
sudo cloudflared service install ${var.cloudflare_token_64}
EOF

  volume_size                = 8
  root_volume_type           = "gp2"  
}

module "security_groups" {
  source                = "../standalone_resources/security_group"
  prefix                = var.prefix
  resource_name         = "cf-tunnel"
  environment           = var.infra_environment
  vpc_id                = var.vpc_id

  ingress_protocol      = "-1"
  ingress_from_port     = 0
  ingress_to_port       = 0
  ingress_cidr_blocks   = ["0.0.0.0/0"]

  egress_protocol       = "-1"
  egress_from_port      = 0
  egress_to_port        = 0
  egress_cidr_blocks    = ["0.0.0.0/0"]
}