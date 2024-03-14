resource "aws_api_gateway_rest_api" "lanchonete_rest_api" {
  name        = "lanchonete_rest_api"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "lanchonete_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.lanchonete_rest_api.id
  parent_id   = aws_api_gateway_rest_api.lanchonete_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  provider_arns = [aws_cognito_user_pool.lanchonete_user_pool.arn]
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on  = [aws_api_gateway_integration.lanchonete_integration_get]
  rest_api_id = aws_api_gateway_rest_api.lanchonete_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.lanchonete_rest_api.body,
      aws_api_gateway_rest_api.lanchonete_rest_api.root_resource_id,
      aws_api_gateway_method.lanchonete_api_get.id,
      aws_api_gateway_integration.lanchonete_integration_get.id,
      aws_api_gateway_method.lanchonete_api_post.id,
      aws_api_gateway_integration.lanchonete_integration_post.id,
      aws_api_gateway_method.lanchonete_api_put.id,
      aws_api_gateway_integration.lanchonete_integration_put.id,
      aws_api_gateway_method.lanchonete_api_delete.id,
      aws_api_gateway_integration.lanchonete_integration_delete.id,
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
}

resource "aws_api_gateway_method" "lanchonete_api_get" {
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id   = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "lanchonete_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id             = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method             = aws_api_gateway_method.lanchonete_api_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = var.target_endpoint
  integration_http_method = "GET"

  cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method" "lanchonete_api_post" {
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id   = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "lanchonete_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id             = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method             = aws_api_gateway_method.lanchonete_api_post.http_method
  type                    = "HTTP_PROXY"
  uri                     = var.target_endpoint
  integration_http_method = "POST"

  cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method" "lanchonete_api_put" {
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id   = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "lanchonete_integration_put" {
  rest_api_id             = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id             = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method             = aws_api_gateway_method.lanchonete_api_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = var.target_endpoint
  integration_http_method = "PUT"

  cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method" "lanchonete_api_delete" {
  rest_api_id   = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id   = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "lanchonete_integration_delete" {
  rest_api_id             = aws_api_gateway_rest_api.lanchonete_rest_api.id
  resource_id             = aws_api_gateway_resource.lanchonete_api_resource.id
  http_method             = aws_api_gateway_method.lanchonete_api_delete.http_method
  type                    = "HTTP_PROXY"
  uri                     = var.target_endpoint
  integration_http_method = "DELETE"

  cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
