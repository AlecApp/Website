variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region we're deploying to."
}

# Value stored in Terraform Cloud
variable "access_key" {
  type        = string
  description = "Access key for the Terraform user in our environment."
  sensitive   = true
}

# Value stored in Terraform Cloud
variable "secret_key" {
  type        = string
  description = "Secret key for the Terraform user in our environment."
  sensitive   = true
}

variable "env" {
  type        = string
  default     = "demo"
  description = "The environment we're deploying to e.g. dev, prod, staging"
}

variable "use_latest_snapshot" {
  type        = bool
  default     = false
  description = "Build the database from the latest snapshot?"
}

# Value stored in Terraform Cloud
variable "cidr_alec" {
  type        = string
  description = "Public IP for the approved user."
  sensitive   = true
}
