variable "database_user" {
  default = ""
}

variable "database_password" {
  default = ""
}

locals {
    aws_region = "eu-central-1"
}

module "aws_cecs_infra" {
  source = "./terraform/"
  aws_region = local.aws_region
  database_user = var.database_user
  database_password = var.database_password
}

output "aws_region"{
  description = "Deployed to AWS region."
  value = "${module.aws_cecs_infra.aws_region}"
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = "${module.aws_cecs_infra.lambda_bucket_name}"
}

output "function_name" {
  description = "Name of the Lambda function that reads projects from S3."
  value = "${module.aws_cecs_infra.function_name}"
}

output "api-gateway" {
  description = "Url of API Gateway."
  value = "${module.aws_cecs_infra.api-gateway}"
}

output "cognito-user-pool-id" {
  description = "Cognito UserPool Id."
  value = "${module.aws_cecs_infra.cognito-user-pool-id}"
}

output "cognito-app-client-id" {
  description = "Id of the app client"
  value = "${module.aws_cecs_infra.cognito-app-client-id}"
}

output "bastion-public-ip" {
  description = "Public-Elastic-IP of the EC2 Bastion Instance"
  value = module.aws_cecs_infra.bastion-public-ip
}

output "toxiproxy-public-ip" {
  description = "Public-Elastic-IP of the EC2 Toxiproxy Instance"
  value = module.aws_cecs_infra.toxiproxy-public-ip
}

output "appserver-private-ip" {
  description = "Private-Elastic-IP of the EC2 Appserver Instance"
  value = module.aws_cecs_infra.appserver-private-ip
}

output "ec2-appserver-id" {
  description = "EC2-Instance Id of Appserver"
  value = module.aws_cecs_infra.ec2-appserver-id
}

output "database-endpoint" {
  description = "MySQL Database Endpoint"
  value = module.aws_cecs_infra.database-endpoint
}