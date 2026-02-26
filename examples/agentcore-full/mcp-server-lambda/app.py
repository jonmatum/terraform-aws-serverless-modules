import json
import os
from datetime import datetime

def list_tools():
    return {
        "tools": [
            {
                "name": "reverse_string",
                "description": "Reverse a string",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "text": {
                            "type": "string",
                            "description": "Text to reverse"
                        }
                    },
                    "required": ["text"]
                }
            },
            {
                "name": "get_lambda_info",
                "description": "Get Lambda function information",
                "inputSchema": {
                    "type": "object",
                    "properties": {}
                }
            }
        ]
    }

def call_tool(name, arguments):
    if name == "reverse_string":
        text = arguments.get("text", "")
        return {
            "content": [{
                "type": "text",
                "text": text[::-1]
            }]
        }
    
    elif name == "get_lambda_info":
        return {
            "content": [{
                "type": "text",
                "text": json.dumps({
                    "function_name": os.environ.get("AWS_LAMBDA_FUNCTION_NAME"),
                    "memory_limit": os.environ.get("AWS_LAMBDA_FUNCTION_MEMORY_SIZE"),
                    "region": os.environ.get("AWS_REGION"),
                    "environment": os.environ.get("ENVIRONMENT"),
                    "timestamp": datetime.utcnow().isoformat()
                }, indent=2)
            }]
        }
    
    else:
        raise ValueError(f"Unknown tool: {name}")

def handler(event, context):
    try:
        # Handle Function URL invocation
        if "requestContext" in event:
            body = json.loads(event.get("body", "{}"))
        else:
            body = event
        
        method = body.get("method")
        
        if method == "tools/list":
            response = list_tools()
        elif method == "tools/call":
            params = body.get("params", {})
            response = call_tool(params.get("name"), params.get("arguments", {}))
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": f"Unknown method: {method}"})
            }
        
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(response)
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
