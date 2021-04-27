
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

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.txt"
    content      = data.template_file.user_data.rendered
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata.txt"
    content      = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    docker login ghcr.io -u AlecApp -p ${var.github_pat}
    sudo yum install jq -y
    TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/iam/security-credentials/website-${var.env} > credentials.json
    AWS_ACCESS_KEY_ID=$(cat credentials.json | jq .AccessKeyId)
    AWS_SECRET_ACCESS_KEY=$(cat credentials.json | jq .SecretAccessKey)
    AWS_SESSION_TOKEN=$(cat credentials.json | jq .Token)
    docker pull ghcr.io/alecapp/website:latest
    docker run -p 80:80 -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -d ghcr.io/alecapp/website:latest
    echo $AWS_ACCESS_KEY_ID > /tmp/output.txt
    EOF
  }
}

resource "aws_eip" "website_eip" {
  instance = module.website_instance.id
  vpc      = true
  tags = {
    environment = var.env
    terraform   = true
  }
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
  assign_eip_address            = false
  name                          = "website-${var.env}"
  user_data                     = data.template_cloudinit_config.config.rendered
  tags = {
    environment = var.env
    terraform   = true
  }
}
