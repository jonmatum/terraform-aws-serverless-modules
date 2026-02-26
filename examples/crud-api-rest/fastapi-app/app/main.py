from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional
import boto3
from boto3.dynamodb.conditions import Key
import os
import uuid
from datetime import datetime
from decimal import Decimal

# Initialize FastAPI
app = FastAPI(
    title="Items CRUD API",
    description="RESTful API for managing items with DynamoDB",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    root_path="/prod"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name=os.getenv('AWS_REGION', 'us-east-1'))
table_name = os.getenv('DYNAMODB_TABLE_NAME', 'items')
table = dynamodb.Table(table_name)

# Helper function to convert Decimal to float
def decimal_to_float(obj):
    if isinstance(obj, list):
        return [decimal_to_float(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: decimal_to_float(v) for k, v in obj.items()}
    elif isinstance(obj, Decimal):
        return float(obj)
    return obj

# Pydantic models
class ItemBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="Item name")
    description: Optional[str] = Field(None, max_length=500, description="Item description")
    price: float = Field(..., gt=0, description="Item price")
    quantity: int = Field(..., ge=0, description="Item quantity")

class ItemCreate(ItemBase):
    pass

class ItemUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: Optional[float] = Field(None, gt=0)
    quantity: Optional[int] = Field(None, ge=0)

class Item(ItemBase):
    id: str = Field(..., description="Item ID")
    created_at: str = Field(..., description="Creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "name": "Sample Item",
                "description": "This is a sample item",
                "price": 29.99,
                "quantity": 100,
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-01T00:00:00Z"
            }
        }

# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint"""
    try:
        # Test DynamoDB connection
        table.table_status
        return {"status": "healthy", "service": "items-api", "dynamodb": "connected"}
    except Exception as e:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"status": "unhealthy", "error": str(e)}
        )

# Create item
@app.post("/items", response_model=Item, status_code=status.HTTP_201_CREATED, tags=["Items"])
async def create_item(item: ItemCreate):
    """Create a new item"""
    try:
        item_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat() + "Z"

        item_data = {
            "id": item_id,
            **item.model_dump(),
            "created_at": timestamp,
            "updated_at": timestamp
        }

        # Convert float to Decimal for DynamoDB
        item_data["price"] = Decimal(str(item_data["price"]))

        table.put_item(Item=item_data)

        # Convert back to float for response
        item_data["price"] = float(item_data["price"])
        return Item(**item_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create item: {str(e)}"
        )

# Get all items
@app.get("/items", response_model=List[Item], tags=["Items"])
async def list_items(limit: int = 100, last_key: Optional[str] = None):
    """List all items with pagination"""
    try:
        scan_kwargs = {"Limit": min(limit, 100)}

        if last_key:
            scan_kwargs["ExclusiveStartKey"] = {"id": last_key}

        response = table.scan(**scan_kwargs)
        items = [Item(**decimal_to_float(item)) for item in response.get('Items', [])]

        return items
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list items: {str(e)}"
        )

# Get item by ID
@app.get("/items/{item_id}", response_model=Item, tags=["Items"])
async def get_item(item_id: str):
    """Get a specific item by ID"""
    try:
        response = table.get_item(Key={"id": item_id})

        if 'Item' not in response:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with id {item_id} not found"
            )

        return Item(**decimal_to_float(response['Item']))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get item: {str(e)}"
        )

# Update item
@app.put("/items/{item_id}", response_model=Item, tags=["Items"])
async def update_item(item_id: str, item_update: ItemUpdate):
    """Update an existing item"""
    try:
        # Check if item exists
        response = table.get_item(Key={"id": item_id})
        if 'Item' not in response:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with id {item_id} not found"
            )

        # Build update expression
        update_data = {k: v for k, v in item_update.model_dump().items() if v is not None}
        if not update_data:
            return Item(**decimal_to_float(response['Item']))

        update_data["updated_at"] = datetime.utcnow().isoformat() + "Z"

        # Convert float to Decimal for DynamoDB
        if "price" in update_data:
            update_data["price"] = Decimal(str(update_data["price"]))

        update_expression = "SET " + ", ".join([f"#{k} = :{k}" for k in update_data.keys()])
        expression_attribute_names = {f"#{k}": k for k in update_data.keys()}
        expression_attribute_values = {f":{k}": v for k, v in update_data.items()}

        response = table.update_item(
            Key={"id": item_id},
            UpdateExpression=update_expression,
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="ALL_NEW"
        )

        return Item(**decimal_to_float(response['Attributes']))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update item: {str(e)}"
        )

# Delete item
@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Items"])
async def delete_item(item_id: str):
    """Delete an item"""
    try:
        # Check if item exists
        response = table.get_item(Key={"id": item_id})
        if 'Item' not in response:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with id {item_id} not found"
            )

        table.delete_item(Key={"id": item_id})
        return None
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete item: {str(e)}"
        )

# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """API root endpoint"""
    return {
        "message": "Items CRUD API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }
