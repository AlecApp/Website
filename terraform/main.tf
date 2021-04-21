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

# Security group to allow Postgres traffic in VPC
resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow Postgres inbound traffic"
  vpc_id      = module.vpc.vpc_id
}
