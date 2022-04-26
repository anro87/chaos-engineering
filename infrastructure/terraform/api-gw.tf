# Define API
resource "aws_apigatewayv2_api" "api_gw" {
  name          = "cecs_lambda_gw"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["content-type","Authorization"]
  }
  tags = {
    Owner = "anro"
  }
}

# Define API-Authorization with Cognito JWT Token
resource "aws_apigatewayv2_authorizer" "api_gw_auth" {
  name             = "cecs_lambda_gw_auth"
  api_id           = aws_apigatewayv2_api.api_gw.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

########################################
# AWS EC2 Get-Projects Integration
########################################

# Define API-Stage
resource "aws_apigatewayv2_stage" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id
  name        = "crm"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_log_group.arn

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

# Define AWS Integration between API-GW and Lambda
resource "aws_apigatewayv2_integration" "get_projects_s3" {
  api_id = aws_apigatewayv2_api.api_gw.id

  integration_uri    = aws_lambda_function.get_projects_s3.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Define API-Endpoint
resource "aws_apigatewayv2_route" "get_projects_s3" {
  api_id = aws_apigatewayv2_api.api_gw.id

  route_key = "GET /projects"
  target    = "integrations/${aws_apigatewayv2_integration.get_projects_s3.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.api_gw_auth.id
}

# Define API-GW specific CloudWatch Log-Group
resource "aws_cloudwatch_log_group" "api_gw_log_group" {
  name              = "/aws/api_gw/lambda_api_gw"
  retention_in_days = 1
  tags = {
    Owner = "anro"
  }
}

# Give API-Gateway permission to call lambda
resource "aws_lambda_permission" "api_gw_lambda_get_projects_s3" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_projects_s3.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gw.execution_arn}/*/*"
}

##########################################################
# AWS EC2 / VPC Link for the Get Customers Integration
##########################################################

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "cecs-vpclink"
  security_group_ids = [aws_security_group.cecs_sg.id]
  subnet_ids         = [aws_subnet.private_subnet_cecs.id]
  tags = {
    Owner = "anro"
  }
}

# Create a new load balancer
resource "aws_alb" "cecs_alb" {
  name            = "cecs-ec2-alb"
  security_groups = [aws_security_group.cecs_sg.id]
  subnets         = [aws_subnet.private_subnet_cecs.id,aws_subnet.public_subnet_cecs.id]
  internal        = "true"
  tags = {
    Owner = "anro"
  }
}

resource "aws_alb_target_group" "cecs_ec2" {
  name     = "cecs-ec2-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.cecs.id
}

resource "aws_lb_target_group_attachment" "cecs_ec2" {
  target_group_arn = aws_alb_target_group.cecs_ec2.arn
  target_id        = aws_instance.app_server.id
  port             = 8080
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.cecs_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.cecs_ec2.arn
    type             = "forward"
  }
}

resource "aws_apigatewayv2_integration" "ec2_api_integration" {
  api_id             = aws_apigatewayv2_api.api_gw.id
  integration_type   = "HTTP_PROXY"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id
  connection_type    = "VPC_LINK"
  description        = "VPC integration"
  integration_method = "ANY"
  integration_uri    = aws_alb_listener.listener_http.arn
}

resource "aws_apigatewayv2_route" "get_customers" {
  api_id    =  aws_apigatewayv2_api.api_gw.id
  route_key = "GET /customers"
  target    = "integrations/${aws_apigatewayv2_integration.ec2_api_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.api_gw_auth.id
}

resource "aws_apigatewayv2_route" "get_sales_leads" {
  api_id    =  aws_apigatewayv2_api.api_gw.id
  route_key = "GET /salesLeads"
  target    = "integrations/${aws_apigatewayv2_integration.ec2_api_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.api_gw_auth.id
}