import json

def lambda_handler(event, context):
    """
    Lambda function to process messages from the InventoryQueue.
    """
    for record in event['Records']:
        message_body = record['body']
        print(f"InventoryProcessor received message: {message_body}")

    return {
        "statusCode": 200,
        "body": json.dumps("InventoryProcessor executed successfully!")
    }
