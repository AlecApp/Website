# Primary VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name             = "vpc-${var.env}"
  cidr             = "10.0.0.0/16"
  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway                   = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

# Security group to allow Postgres traffic between RDS, Lambda, and Bastion Host
resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow Postgres inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "postgres_in" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_postgres.id
  self              = true
}

resource "aws_security_group_rule" "postgres_out" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_postgres.id
  self              = true
}

# Security group to allow HTTP/HTTPS/SSH traffic to website instance
resource "aws_security_group" "website" {
  name        = "website"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_out" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = [var.cidr_alec]
}

resource "aws_security_group_rule" "ssh_out" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.website.id
  cidr_blocks       = [var.cidr_alec]
}
