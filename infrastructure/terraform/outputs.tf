# Output value definitions

output "aws_region" {
  description = "Deployed to AWS region"
  value = var.aws_region
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Name of the Lambda function that read all projects from S3."
  value = aws_lambda_function.get_projects_s3.function_name
}

output "api-gateway" {
  description = "Url of API Gateway."
  value = aws_apigatewayv2_stage.api_gw.invoke_url
}

output "cognito-user-pool-id" {
  description = "Id of cognito user pool"
  value = aws_cognito_user_pool.pool.id
}

output "cognito-app-client-id" {
  description = "Id of the app client"
  value = aws_cognito_user_pool_client.client.id
}

output "bastion-public-ip" {
  description = "Public-Elastic-IP of the EC2 Bastion Instance"
  value = aws_eip_association.bastion_host_eip_assoc.public_ip
}

output "toxiproxy-public-ip" {
  description = "Public-Elastic-IP of the EC2 Toxiproxy Instance"
  value = aws_eip_association.toxiproxy_eip_assoc.public_ip
}

output "appserver-private-ip" {
  description = "Private-Elastic-IP of the EC2 Appserver Instance"
  value = aws_instance.app_server.private_ip
}

output "ec2-appserver-id" {
  description = "EC2-Instance Id of Appserver"
  value = aws_instance.app_server.id
}

output "database-endpoint" {
  description = "MySQL Database Endpoint"
  value = aws_db_instance.cecs_db.address
}