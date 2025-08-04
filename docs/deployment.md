# Deployment Guide

## Current Deployment Status

⚠️ **Note**: TagAssistant.ai is currently in early development. This deployment guide covers the current implementation (waitlist + analytics MCP integration).

## Prerequisites

- Google Cloud Project with billing enabled
- gcloud CLI installed and configured
- Firebase project with Firestore enabled
- Domain name (optional for development)

## Cloud Build Configuration

The project uses Cloud Build for CI/CD. Configuration is in `/cloudbuild.yaml`.

### Current Build Steps

1. **Backend Tests**
   - Code formatting check (`uv run black . --check`)
   - Import sorting check (`uv run isort . --check`) 
   - Type checking (`uv run mypy .`)
   - Unit tests (`uv run pytest`)

2. **Frontend Tests**
   - Linting (`npm run lint`)
   - Type checking (`npm run type-check`)
   - Unit tests (`npm test`)

3. **Build and Deploy** (planned)
   - Docker container builds
   - Cloud Run deployment

## Firebase Setup

### 1. Create Firebase Project
```bash
# Create or select existing project
firebase projects:list
firebase use your-project-id
```

### 2. Enable Firestore
```bash
# Enable Firestore with named database
gcloud firestore databases create --database=tagassistant --location=us-central1
```

### 3. Configure Authentication
```bash
# For local development
gcloud auth application-default login

# For production (service account)
gcloud iam service-accounts create tagassistant-backend
gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:tagassistant-backend@your-project-id.iam.gserviceaccount.com" \
  --role="roles/datastore.user"
```

## Environment Configuration

### Backend (.env)
```env
# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIRESTORE_DATABASE_ID=tagassistant

# For production
USE_APPLICATION_DEFAULT_CREDENTIALS=true

# For local development with service account  
FIREBASE_CREDENTIALS=./credentials/firebase-service-account.json

# API Configuration
PORT=8000
FRONTEND_URL=http://localhost:5173
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:8000
```

## Local Development Deployment

### 1. Setup Dependencies
```bash
# Backend
cd backend
uv sync

# Frontend  
cd frontend
npm install
```

### 2. Start Services
```bash
# Terminal 1: Backend
cd backend
uv run uvicorn main:app --reload

# Terminal 2: Frontend
cd frontend
npm run dev
```

### 3. Verify Deployment
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Test endpoint: http://localhost:8000/api/debug/firebase

## Production Deployment (Planned)

### Cloud Run Configuration

```yaml
# backend-service.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: tagassistant-backend
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
      - image: gcr.io/PROJECT_ID/tagassistant-backend
        ports:
        - containerPort: 8080
        env:
        - name: FIREBASE_PROJECT_ID
          value: "PROJECT_ID"
        - name: USE_APPLICATION_DEFAULT_CREDENTIALS
          value: "true"
```

### Deployment Commands
```bash
# Build and deploy backend
gcloud builds submit --config=cloudbuild.yaml

# Deploy to Cloud Run (when implemented)
gcloud run deploy tagassistant-backend \
  --image=gcr.io/PROJECT_ID/tagassistant-backend \
  --region=us-central1 \
  --allow-unauthenticated
```

## Testing Deployment

### Local Development Testing
```bash
# Backend health check
curl http://localhost:8000/health

# Firebase connectivity
curl http://localhost:8000/api/debug/firebase

# Waitlist service
curl http://localhost:8000/api/debug/waitlist

# Analytics MCP health  
curl http://localhost:8000/api/analytics/health

# Test waitlist functionality
curl -X POST http://localhost:8000/api/waitlist \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Get waitlist count
curl http://localhost:8000/api/waitlist/count
```

### Production Deployment Testing

Replace `https://your-service-url` with your actual Cloud Run service URL:

```bash
# Test backend health through nginx proxy
curl https://your-service-url/backend-health

# Test direct backend health (should show environment info)
curl https://your-service-url/health

# Test waitlist functionality
curl -X POST https://your-service-url/api/waitlist \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Test waitlist count
curl https://your-service-url/api/waitlist/count

# Test API documentation is accessible
curl https://your-service-url/docs

# Test debug endpoints (if needed for troubleshooting)
curl https://your-service-url/api/debug/firebase
curl https://your-service-url/api/debug/waitlist
```

### Expected Responses

**Healthy backend (`/health`):**
```json
{
  "status": "healthy",
  "service": "tagassistant-backend",
  "port": "8000",
  "firebase_project": "your-project-id",
  "firestore_database": "tagassistant"
}
```

**Successful waitlist signup:**
```json
{
  "message": "Successfully joined the waiting list!",
  "email": "test@example.com",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

**Waitlist count:**
```json
{
  "count": 42
}
```

### Frontend Functionality
- Landing page loads correctly
- Waitlist form submits successfully
- All API endpoints respond properly

## Current Limitations

### Not Yet Implemented
- Production Docker containers
- SSL certificate provisioning
- Domain configuration
- Monitoring and alerting
- Analytics MCP server deployment
- OAuth authentication
- Email notifications

### Development Only
- Debug endpoints (`/api/debug/*`)
- Local MCP server integration
- Basic error handling

## Troubleshooting

### Common Issues

**Backend won't start:**
- Check Python version (3.11+)
- Verify uv installation: `uv --version`
- Check Firebase credentials
- Verify environment variables

**Cloud Run "Could not import module" error:**
- Ensure `main.py` is copied to Docker container
- Verify uvicorn command uses correct module path: `main:app` (not `app.main:app`)
- Check all required files are copied in Dockerfile

**502 Bad Gateway / Connection Refused error:**
- Backend container not starting properly
- Check Cloud Run logs for backend startup errors
- Verify nginx upstream configuration points to `127.0.0.1:8000`
- Test backend health: `/backend-health` endpoint
- Ensure both containers are in same Cloud Run service

**Frontend build fails:**
- Check Node.js version (18.x LTS)
- Clear node_modules: `rm -rf node_modules && npm install`
- Verify API URL in .env

**Firestore connection fails:**
- Verify project ID matches
- Check database name ("tagassistant")
- Ensure proper authentication
- Verify Firestore is enabled

**Tests fail in CI/CD:**
- Ensure all formatting passes locally first
- Run complete test suite: `uv run black . && uv run isort . && uv run mypy . && uv run pytest`
- Check for environment-specific issues

## Security Considerations

### Current
- Environment variables for sensitive configuration
- Firebase security rules (basic)
- CORS configured for development

### Planned
- Service account with minimal permissions
- Firestore security rules for production
- Rate limiting
- Input validation and sanitization

## Monitoring (Current)

### Available Endpoints
- `/health` - Backend service health with environment info
- `/backend-health` - Nginx proxy health check for backend
- `/api/debug/firebase` - Firebase connectivity (debug)
- `/api/debug/waitlist` - Waitlist service health (debug)
- `/api/analytics/health` - MCP server health
- `/docs` - Interactive API documentation

### Planned
- Application Performance Monitoring
- Error tracking and alerting
- Usage analytics
- Uptime monitoring

## References

- Cloud Build config: `/cloudbuild.yaml`
- Backend entry point: `/backend/main.py`
- Frontend entry point: `/frontend/src/main.tsx`
- Environment examples: `.env.example` files
- Test configuration: `/backend/tests/conftest.py`