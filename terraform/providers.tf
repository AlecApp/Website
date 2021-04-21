# Connect to our already existing workspace in Terraform Cloud
terraform {
  backend "remote" {
    organization = "AlecApp"
    workspaces {
      name = "Website"
    }
  }
}

provider "aws" {
  version    = "~> 3.0"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
