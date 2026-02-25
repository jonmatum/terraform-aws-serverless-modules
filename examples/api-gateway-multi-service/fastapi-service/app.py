from fastapi import FastAPI

app = FastAPI()

@app.get("/api/fastapi")
def read_root():
    return {"service": "fastapi", "message": "Hello from FastAPI on ECS!"}

@app.get("/api/fastapi/health")
def health_check():
    return {"status": "healthy"}
