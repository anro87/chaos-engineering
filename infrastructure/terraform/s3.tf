// ###############################
// Define AWS Lambda Bucket
// ###############################
resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "cecs-lambda-bucket"
  acl           = "private"
  force_destroy = true
  tags = {
    Owner = "anro"
  }
}

data "archive_file" "get_projects_s3" {
  type = "zip"

  source_dir  = "${path.module}/../lambdas/getProjectsS3"
  output_path = "${path.module}/../get_projects_s3.zip"
}

resource "aws_s3_bucket_object" "get_projects_s3" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "get_projects_s3.zip"
  source = data.archive_file.get_projects_s3.output_path

  etag = filemd5(data.archive_file.get_projects_s3.output_path)
}


// ###############################
// Define Project Storage Bucket
// ###############################
resource "aws_s3_bucket" "projects_bucket" {
  bucket        = "cecs-s3-bucket"
  acl           = "private"
  force_destroy = true
  tags = {
    Owner = "anro"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.projects_bucket.id
  key    = "project_list.json"
  acl    = "private"
  source = "data/s3/projects.json"
  etag = filemd5("data/s3/projects.json")
}