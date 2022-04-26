resource "aws_cognito_user_pool" "pool" {
  name = "cecs_user_pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "cecs_external_api"
  user_pool_id = aws_cognito_user_pool.pool.id
  access_token_validity = 2
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}