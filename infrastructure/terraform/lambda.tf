resource "aws_lambda_function" "get_projects_s3" {
  function_name = "GetProjectsS3"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.get_projects_s3.key

  runtime = "nodejs12.x"
  handler = "getProjectsS3.handler"

  source_code_hash = data.archive_file.get_projects_s3.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  tags = {
    Owner = "Andreas.Rotaru"
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.get_projects_s3.function_name}"
  
  retention_in_days = 1
  tags = {
    Owner = "Andreas.Rotaru"
  }
}

# Make sure lambda can uplevel permissions by assumerole policy
resource "aws_iam_role" "lambda_exec" {
  name = "iam_role_lambda_get_projects_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = {
    Owner = "Andreas.Rotaru"
  }
}

#Define inline policy
resource "aws_iam_role_policy" "read_s3_lambda_policy" {
  role = aws_iam_role.lambda_exec.name
  name = "S3ReadAccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "s3:*",
      ],
      "Resource" : "arn:aws:s3:::*"
      }
    ]
  })
}

# Attach AWS Policy to Lambda
resource "aws_iam_role_policy_attachment" "read_s3_lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}