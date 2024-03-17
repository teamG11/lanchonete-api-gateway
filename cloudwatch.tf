
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lanchonete_lambda_authorizer"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
