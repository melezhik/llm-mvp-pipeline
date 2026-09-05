#!/bin/bash
set -e

echo "Building MVP backend application..."

# Get database credentials from previous jobs
dict=$(get_state)

DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres123}"
DB_NAME="${DB_NAME:-mvp_db}"
DB_HOST="postgres"
DB_PORT="5432"

# Create a simple FastAPI application directory
echo "Creating FastAPI MVP application..."

mkdir -p /tmp/mvp-app
cd /tmp/mvp-app

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
psycopg2-binary==2.9.9
sqlalchemy==2.0.23
pydantic==2.5.0
python-dotenv==1.0.0
requests==2.31.0
aiohttp==3.9.1
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Create main FastAPI application
cat > main.py << 'APPEOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import httpx
import json
from typing import Optional, List

app = FastAPI(
    title="LLM MVP API",
    description="MVP backend with LLM integration",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")

# Models
class ChatRequest(BaseModel):
    message: str
    model: str = "mistral"
    stream: bool = False

class ChatResponse(BaseModel):
    response: str
    model: str

class ModelInfo(BaseModel):
    name: str
    size: Optional[str] = None

# Routes
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "LLM MVP Backend",
        "version": "1.0.0"
    }

@app.get("/models", response_model=List[str])
async def list_models():
    """List available LLM models"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(f"{OLLAMA_BASE_URL}/api/tags")
            data = response.json()
            models = [m["name"] for m in data.get("models", [])]
            return models
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Ollama service error: {str(e)}")

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Send a message to LLM and get response"""
    try:
        async with httpx.AsyncClient(timeout=300.0) as client:
            ollama_request = {
                "model": request.model,
                "prompt": request.message,
                "stream": False
            }
            response = await client.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json=ollama_request
            )
            data = response.json()
            return ChatResponse(
                response=data.get("response", ""),
                model=request.model
            )
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"LLM error: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "LLM MVP API",
        "description": "Minimal Viable Product with LLM integration",
        "docs_url": "/docs",
        "health_check": "/health",
        "available_endpoints": {
            "health": "GET /health",
            "list_models": "GET /models",
            "chat": "POST /chat"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
APPEOF

echo "FastAPI application created"

# Build Docker image
echo "Building Docker image..."
docker build -t mvp-backend:latest .

echo "MVP application build complete"
