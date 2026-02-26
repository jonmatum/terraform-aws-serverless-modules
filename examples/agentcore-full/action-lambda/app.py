import json
import random
from datetime import datetime

def get_weather(location):
    """Simulate weather API call"""
    conditions = ["Sunny", "Cloudy", "Rainy", "Partly Cloudy", "Stormy"]
    return {
        "location": location,
        "temperature": random.randint(50, 90),
        "conditions": random.choice(conditions),
        "humidity": random.randint(30, 90),
        "timestamp": datetime.utcnow().isoformat()
    }

def query_database(query):
    """Simulate database query"""
    # In production, this would connect to actual database
    mock_data = [
        {"id": 1, "name": "Product A", "price": 29.99},
        {"id": 2, "name": "Product B", "price": 49.99},
        {"id": 3, "name": "Product C", "price": 19.99}
    ]
    
    return {
        "query": query,
        "results": mock_data,
        "count": len(mock_data),
        "timestamp": datetime.utcnow().isoformat()
    }

def handler(event, context):
    """
    Lambda handler for Bedrock Agent action group
    
    Event format from Bedrock Agent:
    {
        "messageVersion": "1.0",
        "agent": {...},
        "inputText": "...",
        "sessionId": "...",
        "actionGroup": "api-actions",
        "apiPath": "/weather",
        "httpMethod": "GET",
        "parameters": [...]
    }
    """
    try:
        print(f"Received event: {json.dumps(event)}")
        
        api_path = event.get("apiPath", "")
        http_method = event.get("httpMethod", "")
        parameters = event.get("parameters", [])
        
        # Convert parameters list to dict
        params = {p["name"]: p["value"] for p in parameters}
        
        # Route to appropriate handler
        if api_path == "/weather" and http_method == "GET":
            location = params.get("location", "Unknown")
            result = get_weather(location)
            
        elif api_path == "/database/query" and http_method == "POST":
            query = params.get("query", "")
            result = query_database(query)
            
        else:
            return {
                "messageVersion": "1.0",
                "response": {
                    "actionGroup": event.get("actionGroup"),
                    "apiPath": api_path,
                    "httpMethod": http_method,
                    "httpStatusCode": 404,
                    "responseBody": {
                        "application/json": {
                            "body": json.dumps({"error": "Unknown API path"})
                        }
                    }
                }
            }
        
        # Return response in Bedrock Agent format
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event.get("actionGroup"),
                "apiPath": api_path,
                "httpMethod": http_method,
                "httpStatusCode": 200,
                "responseBody": {
                    "application/json": {
                        "body": json.dumps(result)
                    }
                }
            }
        }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event.get("actionGroup", ""),
                "apiPath": event.get("apiPath", ""),
                "httpMethod": event.get("httpMethod", ""),
                "httpStatusCode": 500,
                "responseBody": {
                    "application/json": {
                        "body": json.dumps({"error": str(e)})
                    }
                }
            }
        }
