data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "index.py"
  output_path = "index.zip"
}

resource "aws_lambda_function" "lanchonete_lambda_authorizer" {
  function_name    = "lanchonete_lambda_authorizer"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  depends_on       = [aws_cloudwatch_log_group.lambda_log_group]
  filename         = "index.zip"
  handler          = "index.lambda_handler"
  runtime          = "python3.10"
  environment {
    variables = {
      CLIENT_ID = aws_cognito_user_pool_client.lanchonete_user_pool_client.id
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "function_logging_policy" {
  name = "lambda-role-logging"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}
