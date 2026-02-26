from fastapi import FastAPI

app = FastAPI(root_path="/api/fastapi")

@app.get("/")
def read_root():
    return {"service": "fastapi", "message": "Hello from FastAPI on ECS!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
