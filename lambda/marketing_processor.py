import json

def lambda_handler(event, context):
    """
    Lambda function to process messages from the MarketingQueue.
    """
    for record in event['Records']:
        message_body = record['body']
        print(f"MarketingProcessor received message: {message_body}")

    return {
        "statusCode": 200,
        "body": json.dumps("MarketingProcessor executed successfully!")
    }
