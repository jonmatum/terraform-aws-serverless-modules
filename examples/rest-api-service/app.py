from fastapi import FastAPI

app = FastAPI()

@app.get("/api/hello")
def read_root():
    return {"service": "rest-api", "message": "Hello from REST API Gateway!"}

@app.get("/api/health")
def health_check():
    return {"status": "healthy"}

@app.get("/api/info")
def info():
    return {
        "service": "rest-api",
        "version": "1.0.0",
        "api_type": "REST API (v1)"
    }
