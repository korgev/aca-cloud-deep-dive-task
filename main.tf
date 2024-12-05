# -------------------------------------------
# Section: SNS Topics
# This section defines the SNS topics for alerts and new product announcements.
# -------------------------------------------
resource "aws_sns_topic" "alerts_topic" {
  name = "LambdaAlertsTopic"
}

resource "aws_sns_topic" "new_product_topic" {
  name = "NewProductTopic"
}

# -------------------------------------------
# Section: IAM Role and Policies
# This section defines IAM roles and policies for Lambda functions to access SQS and SNS.
# -------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "LambdaSQSAccessPolicy"
  description = "IAM policy to allow Lambda access to SQS queues and SNS publish"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = [
          aws_sqs_queue.marketing_queue.arn,
          aws_sqs_queue.inventory_queue.arn,
          aws_sqs_queue.analytics_queue.arn
        ]
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.new_product_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# -------------------------------------------
# Section: Lambda Functions
# This section defines Lambda functions for processing different types of data.
# -------------------------------------------
resource "aws_lambda_function" "marketing_processor" {
  function_name = "MarketingProcessor"
  runtime       = "python3.9"
  handler       = "marketing_processor.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/marketing_processor.py")
  filename         = "lambda/marketing_processor.py.zip"
}

resource "aws_lambda_function" "inventory_processor" {
  function_name = "InventoryProcessor"
  runtime       = "python3.9"
  handler       = "inventory_processor.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/inventory_processor.py")
  filename         = "lambda/inventory_processor.py.zip"
}

resource "aws_lambda_function" "analytics_processor" {
  function_name = "AnalyticsProcessor"
  runtime       = "python3.9"
  handler       = "analytics_processor.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/analytics_processor.py")
  filename         = "lambda/analytics_processor.py.zip"
}

# -------------------------------------------
# Section: SQS Queues
# This section defines SQS queues for the Lambda processors.
# -------------------------------------------
resource "aws_sqs_queue" "marketing_queue" {
  name = "MarketingQueue"
}

resource "aws_sqs_queue" "inventory_queue" {
  name = "InventoryQueue"
}

resource "aws_sqs_queue" "analytics_queue" {
  name = "AnalyticsQueue"
}

# -------------------------------------------
# Section: SNS Subscriptions
# This section defines SNS subscriptions for SQS queues.
# -------------------------------------------
resource "aws_sns_topic_subscription" "marketing_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.marketing_queue.arn

  depends_on = [aws_sqs_queue.marketing_queue]
}

resource "aws_sns_topic_subscription" "inventory_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.inventory_queue.arn

  depends_on = [aws_sqs_queue.inventory_queue]
}

resource "aws_sns_topic_subscription" "analytics_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.analytics_queue.arn

  depends_on = [aws_sqs_queue.analytics_queue]
}

# -------------------------------------------
# Section: Lambda SQS Triggers
# This section defines event source mappings to trigger Lambda functions from SQS queues.
# -------------------------------------------
resource "aws_lambda_event_source_mapping" "marketing_trigger" {
  event_source_arn = aws_sqs_queue.marketing_queue.arn
  function_name    = aws_lambda_function.marketing_processor.arn
  batch_size       = 5
  enabled          = true
}

resource "aws_lambda_event_source_mapping" "inventory_trigger" {
  event_source_arn = aws_sqs_queue.inventory_queue.arn
  function_name    = aws_lambda_function.inventory_processor.arn
  batch_size       = 5
  enabled          = true
}

resource "aws_lambda_event_source_mapping" "analytics_trigger" {
  event_source_arn = aws_sqs_queue.analytics_queue.arn
  function_name    = aws_lambda_function.analytics_processor.arn
  batch_size       = 5
  enabled          = true
}

# -------------------------------------------
# Section: CloudWatch Alarms
# This section defines CloudWatch alarms to monitor Lambda failures and notify via the Alerts SNS topic.
# -------------------------------------------
resource "aws_cloudwatch_metric_alarm" "marketing_failure_alarm" {
  alarm_name          = "MarketingProcessorFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when MarketingProcessor Lambda fails."

  dimensions = {
    FunctionName = aws_lambda_function.marketing_processor.function_name
  }

  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "inventory_failure_alarm" {
  alarm_name          = "InventoryProcessorFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when InventoryProcessor Lambda fails."

  dimensions = {
    FunctionName = aws_lambda_function.inventory_processor.function_name
  }

  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "analytics_failure_alarm" {
  alarm_name          = "AnalyticsProcessorFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when AnalyticsProcessor Lambda fails."

  dimensions = {
    FunctionName = aws_lambda_function.analytics_processor.function_name
  }

  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

# -------------------------------------------
# Section: Test Resources
# This section defines a test resource to publish messages to the SNS topic for validation purposes.
# -------------------------------------------
resource "null_resource" "publish_test_message" {
  provisioner "local-exec" {
    command = <<EOT
aws sns publish \
  --topic-arn "${aws_sns_topic.new_product_topic.arn}" \
  --message '{"ProductID": "hello_world", "Name": "Hello_World Mugs", "Category": "Household", "Price": 10$}'
EOT
  }
}
