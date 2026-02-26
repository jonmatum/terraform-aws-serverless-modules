import json
import os
from datetime import datetime

def handler(event, context):
    """
    Lambda function handler for HTTP requests via Function URL
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    log_level = os.environ.get('LOG_LEVEL', 'info')
    
    # Parse request
    http_method = event.get('requestContext', {}).get('http', {}).get('method', 'UNKNOWN')
    path = event.get('rawPath', '/')
    
    # Route handling
    if path == '/health':
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'status': 'healthy',
                'timestamp': datetime.utcnow().isoformat()
            })
        }
    
    if path == '/info':
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'function_name': context.function_name,
                'function_version': context.function_version,
                'memory_limit': context.memory_limit_in_mb,
                'environment': environment,
                'log_level': log_level,
                'request_id': context.request_id
            })
        }
    
    # Default response
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'message': 'Hello from containerized Lambda!',
            'method': http_method,
            'path': path,
            'timestamp': datetime.utcnow().isoformat()
        })
    }
