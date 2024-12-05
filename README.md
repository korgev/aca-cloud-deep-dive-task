## Task Scenario
Imagine the same retail notification system:
1. When a new product is added, the system:
    - Notifies the Marketing team via a queue that triggers a Lambda to log the message.
    - Updates the Inventory system via a queue that triggers a Lambda to log the message.
    - Informs the Analytics team via a queue that triggers a Lambda to log the message.
Your task is to build and deploy this system using AWS services.
Tasks
1. Create an SNS Topic
    - Create an SNS topic called NewProductTopic.
    - Use the AWS Management Console, CLI, or SDK to do this.
    - Note the ARN of the topic.
2. Create SQS Queues
    - Set up three SQS queues:
    - MarketingQueue
    - InventoryQueue
    - AnalyticsQueue
3. Subscribe SQS Queues to the SNS Topic
    - Subscribe all three SQS queues to the SNS topic.
    - Ensure permissions are set correctly so SNS can send messages to the queues.
4. Create Lambda Functions
    - Set up three Lambda functions, one for each queue:
        * MarketingProcessor: Logs messages from MarketingQueue.
        * InventoryProcessor: Logs messages from InventoryQueue.
        * AnalyticsProcessor: Logs messages from AnalyticsQueue.
    - Each Lambda function should simply log the message it receives to the console.
5. Configure SQS Triggers
    - Attach each Lambda function to its corresponding SQS queue as a trigger.
    - Ensure the triggers are configured so that the Lambda functions are invoked when new messages arrive.
6. Publish a Test Message
    - Simulate adding a new product by publishing a message to the NewProductTopic. Example: { "ProductID": "12345", "Name": "Wireless Headphones", "Category": "Electronics", "Price": 99.99 }
7. Verify the Output
    - Check the Lambda function logs in CloudWatch to ensure the messages were received and logged by each function.
Bonus Task (Optional)
    - Use Amazon CloudWatch to create a metric that tracks the number of times each Lambda function is triggered.
    - Create an alarm that notifies you if a Lambda function fails to process messages.