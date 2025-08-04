# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a full-stack web application template using Next.js (React) for the frontend and FastAPI (Python) for the backend. It includes Firebase/Firestore integration, email capabilities via Mailgun, and a working waitlist example to demonstrate the architecture.

## First-Time Setup Guide

When a user asks you to "set up this project" or similar, follow these steps:

1. **Install Backend Dependencies:**
   ```bash
   cd backend
   uv sync
   ```

2. **Install Frontend Dependencies:**
   ```bash
   cd frontend
   npm install
   ```

3. **Set up Environment Variables:**
   ```bash
   # Copy example files
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env
   ```
   Then help them configure:
   - FIREBASE_PROJECT_ID (their GCP project ID)
   - Other optional services as needed

4. **Firebase Setup:**
   - Guide them to set up a Firebase project at console.firebase.google.com
   - Help them enable Firestore
   - Ensure they have `gcloud auth application-default login` for local development

5. **Start Development Servers:**
   ```bash
   # Terminal 1 - Backend
   cd backend && uv run uvicorn main:app --reload
   
   # Terminal 2 - Frontend  
   cd frontend && npm run dev
   ```

6. **Verify Setup:**
   - Check http://localhost:3000 (frontend)
   - Check http://localhost:8000/health (backend)
   - Test the waitlist form

## Quick Commands Reference

For common user requests:

- **"Run tests"**: `cd backend && uv run pytest && cd ../frontend && npm test`
- **"Check linting"**: `cd backend && uv run black . --check && uv run mypy . && cd ../frontend && npm run lint`
- **"Start servers"**: Use the commands from step 5 above
- **"Deploy"**: Guide them through Cloud Build setup with `gcloud builds submit`

## Development Commands

### Frontend (Next.js + TypeScript)
```bash
cd frontend
npm install              # Install dependencies
npm run dev             # Start development server (http://localhost:3000)
npm run build           # Build for production
npm run start           # Start production server
npm run lint            # Run ESLint
npm run type-check      # Run TypeScript type checking
npm test                # Run tests with Vitest
```

### Backend (Python + FastAPI)
```bash
cd backend
uv sync                               # Sync dependencies from pyproject.toml
uv add package-name                   # Add new package
uv run uvicorn main:app --reload      # Start development server (http://localhost:8000)
uv run pytest                         # Run tests
uv run black .                        # Format code
uv run isort .                        # Sort imports
uv run mypy .                         # Type checking
```

### Why uv?
- **Fast**: 10-100x faster than pip
- **Reliable**: Better dependency resolution  
- **Project Management**: Manages dependencies via pyproject.toml
- **Efficient**: Built-in virtual environment handling

### Cloud Build Deployment
```bash
gcloud builds submit --config=cloudbuild.yaml  # Deploy using Cloud Build
```

## Architecture

### Frontend Structure (Next.js App Router)
- `/frontend/src/app/` - Next.js App Router directory
- `/frontend/src/app/page.tsx` - Main landing page
- `/frontend/src/app/layout.tsx` - Root layout with metadata
- `/frontend/src/app/components/` - Reusable UI components
- `/frontend/src/app/services/` - API client using proxy pattern
- `/frontend/src/app/api/proxy/` - API proxy route for backend communication
- `/frontend/src/__tests__/` - Test files
- `/frontend/public/` - Static assets

### Backend Structure
- `/backend/app/api/` - API endpoints organized by feature
- `/backend/app/models/` - Firestore document models
- `/backend/app/schemas/` - Pydantic models for request/response
- `/backend/app/services/` - Business logic and external integrations
- `/backend/app/core/` - Core functionality (auth, config, firebase)
- `/backend/tests/` - Test files mirroring app structure

### Key Features
1. **Waitlist System**: Example implementation of email collection
2. **Firebase/Firestore**: NoSQL database integration
3. **Google OAuth**: Authentication setup (optional)
4. **Email Service**: Mailgun integration for transactional emails
5. **API Proxy**: Next.js routes proxy to FastAPI backend
6. **Testing**: Comprehensive test setup for both frontend and backend

### Next.js Proxy Architecture
The frontend uses Next.js API routes to proxy requests to the backend, eliminating CORS issues:

- **Frontend calls**: `fetch('/api/proxy', { body: { endpoint: '/api/waitlist', email } })`
- **Proxy route**: `/frontend/src/app/api/proxy/route.ts` handles the request
- **Backend communication**: Proxy forwards to `http://127.0.0.1:8000/api/waitlist`
- **Response**: Backend response is returned to frontend

## API Endpoints

- `POST /api/waitlist` - Add email to waitlist
- `GET /api/debug/logs` - Get recent logs (debug endpoint)
- `GET /health` - Health check endpoint

## Testing Requirements

**CRITICAL: ALL TESTS MUST PASS BEFORE COMMITTING**

### Pre-Change Verification
```bash
# Backend
cd backend
uv run black . --check
uv run isort . --check
uv run mypy .
uv run pytest

# Frontend
cd frontend
npm run lint
npm run type-check
npm test
```

### Post-Change Verification
```bash
# Backend
cd backend
uv run black .
uv run isort .
uv run pytest

# Frontend
cd frontend
npm run lint
npm run type-check
npm test
```

## Environment Setup

### Frontend `.env`
```
NEXT_PUBLIC_BACKEND_URL=http://127.0.0.1:8000
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-client-id  # Optional
```

### Backend `.env`
```
PORT=8000
FRONTEND_URL=http://localhost:3000
SECRET_KEY=your-secret-key
FIREBASE_PROJECT_ID=your-project-id
FIRESTORE_DATABASE_ID=(default)
GOOGLE_CLOUD_PROJECT=your-project-id
MAILGUN_API_KEY=your-key  # Optional
GOOGLE_CLIENT_ID=your-id  # Optional
```

## Common Tasks

### Adding a new API endpoint
1. Create route in `/backend/app/api/endpoints/`
2. Add Pydantic schemas in `/backend/app/schemas/`
3. Implement service logic in `/backend/app/services/`
4. Write tests in `/backend/tests/`
5. Update frontend API client in `/frontend/src/app/services/api.ts`
6. Write frontend tests

### Adding a new page
1. Create page in `/frontend/src/app/[page-name]/page.tsx`
2. Add components in `/frontend/src/app/components/`
3. Connect to API using the proxy pattern
4. Write tests

### Firestore changes
1. Update document models in `/backend/app/models/`
2. No migrations needed - Firestore is schemaless
3. Update affected endpoints and services

## Required IAM Permissions

For Google Cloud deployment:
- **Service Account**: Create with Firestore access
- **Required Role**: `roles/datastore.user`
- **APIs**: Enable Firestore, Cloud Run, Cloud Build

## Important Notes

1. **Testing**: Always run full test suite before committing
2. **Code Style**: Use provided formatters (black, prettier)
3. **Type Safety**: Maintain TypeScript and Python type hints
4. **Error Handling**: Implement proper error responses
5. **Logging**: Use structured logging for debugging
6. **Security**: Never commit secrets or API keys

## Customization Guide

To adapt this template for your project:

1. **Update Branding**: 
   - Change metadata in `/frontend/src/app/layout.tsx`
   - Update landing page in `/frontend/src/app/page.tsx`
   - Replace favicon and logos in `/frontend/public/`

2. **Remove Waitlist** (if not needed):
   - Delete `/backend/app/api/endpoints/waitlist.py`
   - Delete `/backend/app/services/waitlist.py`
   - Delete `/frontend/src/app/components/WaitlistForm.tsx`
   - Update `/backend/main.py` to remove waitlist router

3. **Add Authentication**:
   - Implement auth endpoints in backend
   - Add auth context in frontend
   - Protect routes as needed

4. **Configure Services**:
   - Set up Firebase project
   - Configure Mailgun (if using email)
   - Set up Google OAuth (if using)

## Helpful Prompts for Users

Suggest these prompts to users:

### Getting Started
- "Set up this project for local development"
- "Help me understand the project structure"
- "Run all tests and fix any issues"

### Development
- "Create a new API endpoint for [feature]"
- "Add a new page for [feature]"
- "Help me add authentication"
- "Create a new Firestore collection for [data]"

### Deployment
- "Help me deploy to Google Cloud Run"
- "Set up CI/CD with GitHub Actions"
- "Configure production environment variables"

### Debugging
- "Debug why [specific issue] is happening"
- "Fix the TypeScript errors"
- "Help me troubleshoot the Firebase connection"

Remember: This is a starting template. Modify it to fit your specific needs!