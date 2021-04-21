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
  default     = true
  description = "Use the latest snapshot for DB recovery? (As opposed to a specific snapshot)"
}

variable "initial_startup" {
  type        = bool
  default     = true
  description = "Skip certain things (e.g. checking for an existing snapshot) if this is the initial run."
}

# Value stored in Terraform Cloud
variable "cidr_alec" {
  type        = string
  description = "Public IP for the approved user."
  sensitive   = true
}
