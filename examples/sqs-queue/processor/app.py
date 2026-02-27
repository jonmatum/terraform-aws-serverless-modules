import json
import os

def handler(event, context):
    """Process SQS messages"""
    print(f"Processing {len(event['Records'])} messages")
    
    for record in event['Records']:
        try:
            # Parse message
            body = json.loads(record['body'])
            message_id = record['messageId']
            
            print(f"Processing message {message_id}: {body}")
            
            # Process based on queue type
            if 'orderId' in body:
                process_order(body)
            elif 'transactionId' in body:
                process_transaction(body)
            else:
                print(f"Unknown message type: {body}")
            
        except Exception as e:
            print(f"Error processing message: {e}")
            raise  # Re-raise to send to DLQ
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {len(event["Records"])} messages')
    }

def process_order(order):
    """Process order message"""
    print(f"Processing order: {order['orderId']}, amount: ${order['amount']}")
    # Add your order processing logic here

def process_transaction(transaction):
    """Process transaction message"""
    print(f"Processing transaction: {transaction['transactionId']}, amount: ${transaction['amount']}")
    # Add your transaction processing logic here
