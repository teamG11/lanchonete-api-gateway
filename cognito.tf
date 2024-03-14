
resource "aws_cognito_user_pool" "lanchonete_user_pool" {
  name = "lanchoneteUserPool"

  username_attributes      = ["email"]
  auto_verified_attributes = []

  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 8
      max_length = 128
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "lanchonete_user_pool_client" {
  name                = "lanchoneteUserPoolClient"
  generate_secret     = false
  explicit_auth_flows = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  user_pool_id = aws_cognito_user_pool.lanchonete_user_pool.id
}
