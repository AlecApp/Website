
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "website_key" {
  algorithm = "RSA"
}

module "website_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "website_key"
  public_key = tls_private_key.website_key.public_key_openssh
}

resource "aws_ssm_parameter" "website_private_key" {
  name  = "website_private_key"
  type  = "SecureString"
  value = tls_private_key.website_key.private_key_pem
}

module "website_instance" {
  source          = "cloudposse/ec2-instance/aws"
  version         = ">= 0.30.4"
  instance_type   = "t2.micro"
  vpc_id          = module.vpc.vpc_id
  ssh_key_pair    = module.website_key_pair.this_key_pair_key_name
  security_groups = [aws_security_group.website.id]
  subnet          = module.vpc.public_subnets[0]
  name            = "website"
  user_data       = "../user_data.yml"
  tags = {
    environment = var.env
    terraform   = true
  }
}
