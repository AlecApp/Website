# Format Python code with the correct user, password, and database name to connect to the RDS cluster
resource "null_resource" "setup_db" {
  provisioner "local-exec" {
    command = "sed -e s/MASTER_USER/${aws_ssm_parameter.master_username.value}/g -e s/MASTER_PASSWORD/${aws_ssm_parameter.master_password.value}/g -e s/MASTER_USER/${aws_rds_cluster.db.database_name}/g ../setup_db/setup_db.py"
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "setup-db-${var.env}"
  description   = "Create initial database values"
  handler       = "setup_db.lambda_handler"
  runtime       = "python3.8"

  source_path = "../setup_db"

  depends_on = [null_resource.setup_db]

  tags = {
    name        = "setup-db-${var.env}"
    terraform   = true
    environment = var.env
  }
}
