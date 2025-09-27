resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "check_inventory" {
  filename      = "../apps/check-inventory-item/deployment.zip"
  function_name = "${var.name}-check-inventory"
  role         = aws_iam_role.lambda_role.arn
  handler      = "main.handler"
  runtime      = "python3.9"

  environment {
    variables = {
      REDIS_HOST = var.redis_host
    }
  }
}

resource "aws_lambda_function" "save_inventory" {
  filename      = "../apps/save-inventory-item/deployment.zip"
  function_name = "${var.name}-save-inventory"
  role         = aws_iam_role.lambda_role.arn
  handler      = "main.handler"
  runtime      = "python3.9"

  environment {
    variables = {
      REDIS_HOST = var.redis_host
      SQS_QUEUE_URL = var.sqs_queue_url
    }
  }
}

resource "aws_lambda_function" "update_local_db" {
  filename      = "../apps/update-local-db/deployment.zip"
  function_name = "${var.name}-update-local-db"
  role         = aws_iam_role.lambda_role.arn
  handler      = "main.handler"
  runtime      = "python3.9"

  environment {
    variables = {
      DB_USER = var.db_user
      DB_PASSWORD = var.db_password
      DB_LOCAL_DSN = var.db_local_dsn
    }
  }
}

resource "aws_lambda_function" "update_central_db" {
  filename      = "../apps/update-central-db/deployment.zip"
  function_name = "${var.name}-update-central-db"
  role         = aws_iam_role.lambda_role.arn
  handler      = "main.handler"
  runtime      = "python3.9"

  environment {
    variables = {
      DB_USER = var.db_user
      DB_PASSWORD = var.db_password
      DB_CENTRAL_DSN = var.db_central_dsn
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger_local" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.update_local_db.arn
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "sqs_trigger_central" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.update_central_db.arn
  batch_size       = 1
}
