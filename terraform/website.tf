
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "tls_private_key" "website_key" {
  algorithm = "RSA"
}

module "website_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "website-${var.env}"
  public_key = tls_private_key.website_key.public_key_openssh
}

resource "aws_ssm_parameter" "website_private_key" {
  name        = "/${var.env}/website/private-key"
  description = "The private key for the Website"
  type        = "SecureString"
  value       = tls_private_key.website_key.private_key_pem
  tags = {
    terraform   = "true"
    environment = var.env
  }
}

data "template_file" "user_data" {
  template = file("../user_data.yml")
}

module "website_instance" {
  source                        = "cloudposse/ec2-instance/aws"
  version                       = ">= 0.30.4"
  instance_type                 = "t2.micro"
  ami                           = data.aws_ami.amazon_linux_2.image_id
  ami_owner                     = "amazon"
  vpc_id                        = module.vpc.vpc_id
  ssh_key_pair                  = module.website_key_pair.key_pair_key_name
  security_groups               = [aws_security_group.website.id]
  create_default_security_group = false
  subnet                        = module.vpc.public_subnets[0]
  associate_public_ip_address   = true
  name                          = "website-${var.env}"
  user_data                     = data.template_file.user_data.rendered
  tags = {
    environment = var.env
    terraform   = true
  }
}
