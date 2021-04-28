# IAM role for Lambda function to access RDS Cluster & populate it with data
data "aws_iam_policy" "lambda_policy_vpc" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "lambda_policy_rds" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-setup-db"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    environment = var.env
    terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "lambda_attach_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.lambda_policy_vpc.arn
}

resource "aws_iam_role_policy_attachment" "lambda_attach_rds" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.lambda_policy_rds.arn
}

# IAM User to allow boto3 to make API calls. The keys for this user are passed to the container by the instance startup script.
resource "aws_iam_access_key" "boto3" {
  user = aws_iam_user.boto3.name
}

resource "aws_iam_user" "boto3" {
  name = "boto3-${var.env}"
  path = "/"

  tags = {
    environment = var.env
    terraform   = true
  }
}

resource "aws_iam_policy" "boto3" {
  name        = "boto3-${var.env}"
  path        = "/"
  description = "Allow boto3 access to enable functions on website"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "boto3" {
  user       = aws_iam_user.boto3.name
  policy_arn = aws_iam_policy.boto3.arn
}
