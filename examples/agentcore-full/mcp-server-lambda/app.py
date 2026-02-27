import json
import os

def handler(event, context):
    """MCP protocol handler for Lambda"""
    try:
        # Parse request
        if "requestContext" in event:
            body = json.loads(event.get("body", "{}"))
        else:
            body = event
        
        jsonrpc = body.get("jsonrpc", "2.0")
        method = body.get("method")
        params = body.get("params", {})
        request_id = body.get("id")
        
        # Handle MCP methods
        if method == "initialize":
            response = {
                "jsonrpc": jsonrpc,
                "id": request_id,
                "result": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {
                        "tools": {}
                    },
                    "serverInfo": {
                        "name": "lambda-mcp-server",
                        "version": "1.0.0"
                    }
                }
            }
        
        elif method == "tools/list":
            response = {
                "jsonrpc": jsonrpc,
                "id": request_id,
                "result": {
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
            }
        
        elif method == "tools/call":
            tool_name = params.get("name")
            arguments = params.get("arguments", {})
            
            if tool_name == "reverse_string":
                text = arguments.get("text", "")
                result = {
                    "content": [{
                        "type": "text",
                        "text": text[::-1]
                    }]
                }
            
            elif tool_name == "get_lambda_info":
                info = {
                    "function_name": os.environ.get("AWS_LAMBDA_FUNCTION_NAME"),
                    "memory_limit": os.environ.get("AWS_LAMBDA_FUNCTION_MEMORY_SIZE"),
                    "region": os.environ.get("AWS_REGION"),
                    "environment": os.environ.get("ENVIRONMENT")
                }
                result = {
                    "content": [{
                        "type": "text",
                        "text": json.dumps(info, indent=2)
                    }]
                }
            
            else:
                return error_response(jsonrpc, request_id, -32601, f"Unknown tool: {tool_name}")
            
            response = {
                "jsonrpc": jsonrpc,
                "id": request_id,
                "result": result
            }
        
        else:
            return error_response(jsonrpc, request_id, -32601, f"Method not found: {method}")
        
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(response)
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "jsonrpc": "2.0",
                "id": body.get("id") if 'body' in locals() else None,
                "error": {
                    "code": -32603,
                    "message": "Internal error",
                    "data": str(e)
                }
            })
        }

def error_response(jsonrpc, request_id, code, message):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "jsonrpc": jsonrpc,
            "id": request_id,
            "error": {
                "code": code,
                "message": message
            }
        })
    }
