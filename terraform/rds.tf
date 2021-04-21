# Create master credentials for database
resource "aws_ssm_parameter" "master_username" {
  name        = "/${var.env}/database/master/user"
  description = "The master username for the RDS Cluster"
  type        = "String"
  value       = "master"
  tags = {
    terraform   = "true"
    environment = var.env
  }
}

# Changing the values in the keepers map will trigger the recreation of this resource. The keys/values are arbitrary.
# RDS forbids the use of /, @, ", and ' ' (blank space) in passwords. I've disabled all special characters just to avoid further unforseen incompatibilities.
resource "random_password" "master_password" {
  length  = 32
  special = false
  keepers = {
    last_updated = "04_21_21"
  }
}

# Create master password using random string. Note that the unencrypted SecureString will be stored as plaintext in .tfstate!
# (This is one more reason why we should use Terraform Cloud to store the state!)
resource "aws_ssm_parameter" "master_password" {
  name        = "/${var.env}/database/master/password"
  description = "The master password for the RDS Cluster"
  type        = "SecureString"
  value       = random_password.master_password.result
  tags = {
    terraform   = "true"
    environment = var.env
  }
}

# Snapshot of Database
data "aws_db_cluster_snapshot" "snapshot" {
  # If we want to use the latest snapshot of our db, we use the following 2 lines:
  db_cluster_identifier = var.use_latest_snapshot ? "aurora-db-postgres-${var.env}" : null
  most_recent           = var.use_latest_snapshot ? true : false

  # If we want to use a specific snapshot, we use the following line instead:
  db_cluster_snapshot_identifier = var.use_latest_snapshot ? null : "snapshot-1"
  # If the snapshot was made from a database with a different name than the database we are deploying it to, we must use the snapshot's ARN instead of its name.
}

# Postgres Database on Aurora Serverless
resource "aws_rds_cluster" "db" {
  cluster_identifier      = "aurora-db-postgres-${var.env}"
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  db_subnet_group_name    = module.vpc.database_subnet_group
  vpc_security_group_ids  = [aws_security_group.allow_postgres.id]
  master_username         = aws_ssm_parameter.master_username.value
  master_password         = aws_ssm_parameter.master_password.value
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true
  database_name           = "demo"
  backup_retention_period = 1
  snapshot_identifier     = data.aws_db_cluster_snapshot.snapshot.id
  enable_http_endpoint    = true

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 4
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  lifecycle {
    # Prevents the TF state from being altered when we change snapshots. Changing snapshots won't affect an already deployed cluster.
    ignore_changes = [snapshot_identifier]
  }

  tags = {
    environment = "${var.env}"
    terraform   = "true"
  }
}
