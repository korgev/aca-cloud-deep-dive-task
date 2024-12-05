# Output the ARN of the topic
output "sns_topic_arn_new_product_topic" {
  value = aws_sns_topic.new_product_topic.arn
}

# Output the queue URLs for reference
output "sqs_queue_urls" {
  value = {
    marketing_queue = aws_sqs_queue.marketing_queue.url
    inventory_queue = aws_sqs_queue.inventory_queue.url
    analytics_queue = aws_sqs_queue.analytics_queue.url
  }
}

output "alerts_topic_arn_alerts_topic" {
  value = aws_sns_topic.alerts_topic.arn
}