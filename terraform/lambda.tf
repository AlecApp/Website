# Format Python code with the correct user, password, and database name to connect to the RDS cluster
# Note that Terraform will not recreate this resource unless it is tainted. This means that subsequent applies will skip this step and upload broken code to Lambda.
# A possible solution to this is formatting or updating the code in the build/deploy pipeline.
resource "null_resource" "setup_db" {
  provisioner "local-exec" {
    command = "sed -i -e 's/MASTER_USER/${aws_ssm_parameter.master_username.value}/g' -e 's/MASTER_PASSWORD/${aws_ssm_parameter.master_password.value}/g' -e 's/DATABASE_NAME/${aws_rds_cluster.db.database_name}/g' ../setup_db/setup_db.py"
  }
  provisioner "local-exec" {
      command = "cat ../setup_db/setup_db.py"
  }
  provisioner "local-exec" {
      command = "git clone https://github.com/jkehler/awslambda-psycopg2.git && cp -r awslambda-psycopg2/psycopg2-3.8 ../setup_db/psycopg2"
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
