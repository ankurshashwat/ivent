resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.user_pool_name}-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.test_username
  password     = var.test_password
  
  attributes = {
    email          = "${var.test_username}@gmail.com"
    email_verified = "true"
  }
}