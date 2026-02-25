from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(
    title="User Management API",
    description="API for managing users with OpenAPI schema",
    version="1.0.0",
    servers=[
        {"url": "/", "description": "Default server"}
    ]
)

# Models
class User(BaseModel):
    id: int
    name: str
    email: str
    active: bool = True

class UserCreate(BaseModel):
    name: str
    email: str

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    active: Optional[bool] = None

# In-memory storage
users_db = {
    1: User(id=1, name="John Doe", email="john@example.com"),
    2: User(id=2, name="Jane Smith", email="jane@example.com"),
}
next_id = 3

@app.get("/", tags=["Health"])
def root():
    return {"message": "User Management API", "version": "1.0.0"}

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy"}

@app.get("/users", response_model=List[User], tags=["Users"])
def list_users():
    """Get all users"""
    return list(users_db.values())

@app.get("/users/{user_id}", response_model=User, tags=["Users"])
def get_user(user_id: int):
    """Get a specific user by ID"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    return users_db[user_id]

@app.post("/users", response_model=User, status_code=201, tags=["Users"])
def create_user(user: UserCreate):
    """Create a new user"""
    global next_id
    new_user = User(id=next_id, **user.dict())
    users_db[next_id] = new_user
    next_id += 1
    return new_user

@app.put("/users/{user_id}", response_model=User, tags=["Users"])
def update_user(user_id: int, user: UserUpdate):
    """Update an existing user"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    stored_user = users_db[user_id]
    update_data = user.dict(exclude_unset=True)
    updated_user = stored_user.copy(update=update_data)
    users_db[user_id] = updated_user
    return updated_user

@app.delete("/users/{user_id}", status_code=204, tags=["Users"])
def delete_user(user_id: int):
    """Delete a user"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    del users_db[user_id]
    return None
