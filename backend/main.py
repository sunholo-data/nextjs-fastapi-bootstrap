import sys
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

import logging
import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.endpoints import debug, waitlist

# Configure logging - worker-safe approach
# When running under Gunicorn, let Gunicorn handle the logging configuration
# Only configure logging if running directly (e.g., with uvicorn for development)
if __name__ == "__main__" or "gunicorn" not in os.environ.get("SERVER_SOFTWARE", ""):
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

load_dotenv()

# Log startup information
logger.info("=" * 50)
logger.info("🚀 STARTING API")
logger.info("=" * 50)
logger.info(f"PORT: {os.getenv('PORT', 8000)}")
logger.info(f"FIREBASE_PROJECT_ID: {os.getenv('FIREBASE_PROJECT_ID', 'not set')}")
logger.info(f"FIRESTORE_DATABASE_ID: {os.getenv('FIRESTORE_DATABASE_ID', 'not set')}")
logger.info(f"GOOGLE_CLOUD_PROJECT: {os.getenv('GOOGLE_CLOUD_PROJECT', 'not set')}")
logger.info(
    f"Environment: {os.getenv('NODE_ENV', os.getenv('ENVIRONMENT', 'unknown'))}"
)
logger.info(f"Python path: {sys.executable}")
logger.info(f"Working directory: {os.getcwd()}")
logger.info("=" * 50)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("✅ FastAPI application startup complete!")
    logger.info("🔥 Backend ready to accept requests")
    logger.info(f"🌐 Health check available at: /health")
    logger.info(f"📊 Available endpoints: /api/waitlist, /api/debug/logs")
    yield
    # Shutdown
    logger.info("🛑 Backend shutting down")


app = FastAPI(title="API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[os.getenv("FRONTEND_URL", "http://localhost:5173")],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(waitlist.router, prefix="/api")
app.include_router(debug.router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "Welcome to API"}


@app.get("/health")
async def health_check():
    import time

    return {
        "status": "healthy",
        "service": "backend",
        "timestamp": time.time(),
        "port": os.getenv("PORT", 8000),
        "firebase_project": os.getenv("FIREBASE_PROJECT_ID", "not set"),
        "firestore_database": os.getenv("FIRESTORE_DATABASE_ID", "not set"),
        "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        "working_directory": os.getcwd(),
        "message": "🚀 Backend is running!",
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8000)))
