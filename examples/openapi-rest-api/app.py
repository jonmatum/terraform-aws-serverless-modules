from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(
    title="Product Management API",
    description="API for managing products with OpenAPI schema",
    version="1.0.0",
    servers=[
        {"url": "/", "description": "Default server"}
    ]
)

# Models
class Product(BaseModel):
    id: int
    name: str
    price: float
    stock: int
    available: bool = True

class ProductCreate(BaseModel):
    name: str
    price: float
    stock: int = 0

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    stock: Optional[int] = None
    available: Optional[bool] = None

# In-memory storage
products_db = {
    1: Product(id=1, name="Widget", price=19.99, stock=100),
    2: Product(id=2, name="Gadget", price=29.99, stock=50),
}
next_id = 3

@app.get("/", tags=["Health"])
def root():
    return {"message": "Product Management API", "version": "1.0.0"}

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy"}

@app.get("/products", response_model=List[Product], tags=["Products"])
def list_products():
    """Get all products"""
    return list(products_db.values())

@app.get("/products/{product_id}", response_model=Product, tags=["Products"])
def get_product(product_id: int):
    """Get a specific product by ID"""
    if product_id not in products_db:
        raise HTTPException(status_code=404, detail="Product not found")
    return products_db[product_id]

@app.post("/products", response_model=Product, status_code=201, tags=["Products"])
def create_product(product: ProductCreate):
    """Create a new product"""
    global next_id
    new_product = Product(id=next_id, **product.dict())
    products_db[next_id] = new_product
    next_id += 1
    return new_product

@app.put("/products/{product_id}", response_model=Product, tags=["Products"])
def update_product(product_id: int, product: ProductUpdate):
    """Update an existing product"""
    if product_id not in products_db:
        raise HTTPException(status_code=404, detail="Product not found")
    
    stored_product = products_db[product_id]
    update_data = product.dict(exclude_unset=True)
    updated_product = stored_product.copy(update=update_data)
    products_db[product_id] = updated_product
    return updated_product

@app.delete("/products/{product_id}", status_code=204, tags=["Products"])
def delete_product(product_id: int):
    """Delete a product"""
    if product_id not in products_db:
        raise HTTPException(status_code=404, detail="Product not found")
    del products_db[product_id]
    return None
