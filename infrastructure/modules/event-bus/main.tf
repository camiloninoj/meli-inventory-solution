resource "aws_sqs_queue" "main" {
  name = var.name
  delay_seconds             = 0
  max_message_size         = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        Resource = aws_sqs_queue.main.arn
      }
    ]
  })
}
