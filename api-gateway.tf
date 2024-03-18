resource "aws_api_gateway_rest_api" "lanchonete_rest_api" {
  name        = "lanchonete_rest_api"
  description = "API da lanchonete do time G11"
}

resource "aws_api_gateway_resource" "lanchonete_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.lanchonete_rest_api.id
  parent_id   = aws_api_gateway_rest_api.lanchonete_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "lanchonete_api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method = "ANY"

  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lanchonete_lambda_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_authorizer" "lanchonete_lambda_authorizer" {
  name                   = "lanchonete_lambda_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.lanchonete_rest_api.id
  type                   = "REQUEST"
  authorizer_uri         = aws_lambda_function.lanchonete_lambda_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.apigw_lambda_role.arn
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on  = [aws_api_gateway_integration.lanchonete_integration_any]
  rest_api_id = aws_api_gateway_rest_api.lanchonete_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.lanchonete_rest_api.body,
      aws_api_gateway_rest_api.lanchonete_rest_api.root_resource_id,
      aws_api_gateway_method.lanchonete_api_proxy.id,
      aws_api_gateway_integration.lanchonete_integration_any.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  stage_name    = "test"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.auth_apigw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "auth_apigw" {
  name              = "/aws/auth_apigw"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.main.arn
}

resource "aws_iam_role" "main" {
  name = "api-gateway-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_integration" "lanchonete_integration_any" {
  rest_api_id             = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id             = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method             = aws_api_gateway_method.lanchonete_api_proxy.http_method
  type                    = "HTTP_PROXY"
  uri                     = var.target_endpoint
  integration_http_method = "ANY"

  cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lanchonete_lambda_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.lanchonete_rest_api.execution_arn}/*/*/*"
}

data "aws_iam_policy_document" "apigw_lambda_role_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "apigw_lambda_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = [aws_lambda_function.lanchonete_lambda_authorizer.arn]
    sid       = "ApiGatewayInvokeLambda"
  }
}

resource "aws_iam_role" "apigw_lambda_role" {
  name               = "apigw_lambda_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.apigw_lambda_role_assume.json
}

resource "aws_iam_role_policy" "apigw_lambda" {
  name   = "apigw-lambda-policy"
  role   = aws_iam_role.apigw_lambda_role.id
  policy = data.aws_iam_policy_document.apigw_lambda_policy.json
}
