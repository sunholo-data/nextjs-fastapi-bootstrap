# Development Setup Guide

## Current Implementation Status

⚠️ **Note**: This guide covers setup for the current implementation (waitlist + Google Analytics MCP integration). Additional features are planned for future releases.

## Prerequisites

### Required Software
- Python 3.11+ (verified with 3.12.8)
- Node.js 18.x (LTS version - avoid odd-numbered versions like 19.x)
- uv (Python package manager) - faster than pip, manages virtual environments
- Git
- Google Cloud SDK (for Firebase authentication)
- Firebase CLI (optional, for advanced Firebase operations)

### Install uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Local Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/sunholo/tagassistant.ai.git
cd tagassistant.ai
```

### 2. Backend Setup

```bash
cd backend

# Sync dependencies from pyproject.toml (creates venv automatically)
uv sync

# Copy environment file
cp .env.example .env
```

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env
```

### 4. Firebase Setup

#### Option A: Application Default Credentials (Recommended for Local Development)

1. Create a Firebase project
2. Enable Firestore with named database:
   ```bash
   gcloud firestore databases create --database=tagassistant --location=us-central1
   ```
3. Authenticate with your Google account:
   ```bash
   gcloud auth login
   gcloud config set project your-firebase-project-id
   gcloud auth application-default login
   ```
4. Update `.env`:
   ```env
   FIREBASE_PROJECT_ID=your-firebase-project-id
   FIRESTORE_DATABASE_ID=tagassistant
   ```

#### Option B: Service Account (Production/CI)

1. Download service account key from Firebase Console
2. Place in `backend/credentials/firebase-service-account.json`
3. Update `.env`:
   ```env
   FIREBASE_CREDENTIALS=./credentials/firebase-service-account.json
   FIREBASE_PROJECT_ID=your-firebase-project-id
   ```

### 5. Google API Setup

1. Create a Google Cloud project
2. Enable APIs:
   - Google Tag Manager API
   - Google Analytics Admin API
   - Google Analytics Data API
3. Create OAuth 2.0 credentials
4. Add to `.env`:
   - GOOGLE_CLIENT_ID
   - GOOGLE_CLIENT_SECRET

### 6. Mailgun Setup

1. Create Mailgun account
2. Verify domain
3. Get API key
4. Add to `.env`:
   - MAILGUN_API_KEY
   - MAILGUN_DOMAIN

## Running Locally

### Start Backend
```bash
cd backend
uv run uvicorn main:app --reload
```

Backend runs at: http://localhost:8000

### Start Frontend
```bash
cd frontend
npm run dev
```

Frontend runs at: http://localhost:5173

## Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Follow the structure:
- Frontend components in `frontend/src/`
- Backend endpoints in `backend/app/api/`
- Tests alongside code

### 3. Write Tests

Backend test example:
```python
# backend/tests/test_scan.py
def test_scan_website():
    response = client.post("/api/scan", json={"url": "https://example.com"})
    assert response.status_code == 200
    assert "tracking_found" in response.json()
```

Frontend test example:
```typescript
// frontend/src/components/ScanForm.test.tsx
test('renders scan form', () => {
  render(<ScanForm />);
  expect(screen.getByPlaceholderText(/enter your domain/i)).toBeInTheDocument();
});
```

### 4. Run Tests (MANDATORY before committing)

**CRITICAL**: Always run the complete test suite locally before any commit:

```bash
# Backend - MUST all pass before committing
cd backend
uv run black .                 # Auto-format code (required)
uv run isort .                 # Auto-sort imports (required)
uv run black . --check         # Verify formatting (must pass)
uv run isort . --check         # Verify import sorting (must pass)
uv run mypy .                  # Type check (must pass)
uv run pytest                  # Run tests (must pass)

# Frontend - MUST all pass before committing
cd frontend
npm run lint                   # Lint code (must pass)
npm run type-check            # Type check (must pass)
npm test                      # Run tests (must pass)
```

**Zero Tolerance Policy**: If any test fails locally, fix it before committing. This prevents CI/CD failures and wasted build time.

### 5. Commit Changes

```bash
git add .
git commit -m "feat: add website scanning feature"
```

## Common Development Tasks

### Add Python Package
```bash
cd backend
uv add package-name  # Automatically updates pyproject.toml
```

### Add NPM Package
```bash
cd frontend
npm install package-name
```

### Run Database Migrations
No migrations needed - Firestore is schemaless!

### View API Documentation
Visit http://localhost:8000/docs for interactive API docs

## Debugging

### Backend Debugging

Add breakpoints in VS Code or use:
```python
import pdb; pdb.set_trace()
```

### Frontend Debugging

Use React Developer Tools and browser console.

### View Logs
```bash
# Backend logs in terminal
# Frontend logs in browser console
```

## Testing with External Services

### Mock Google APIs
Use environment variable to enable mocks:
```bash
MOCK_EXTERNAL_APIS=true
```

### Test Mailgun Locally
Use Mailgun sandbox domain for testing.

### Test OAuth Flow
Use Google OAuth playground for testing tokens.

## Code Style

### Python
- Follow PEP 8
- Use type hints
- Docstrings for all functions
- Black for formatting

### TypeScript
- Use functional components
- Props interfaces for all components
- Avoid `any` type
- ESLint rules enforced

## Troubleshooting

### Backend Won't Start
- Check Python version: `python --version`
- Verify venv activated
- Check all dependencies installed
- Verify .env file exists

### Frontend Build Errors
- Clear node_modules: `rm -rf node_modules && npm install`
- Check Node version: `node --version`
- Verify all env variables set

### Firebase Connection Issues
- Check service account path
- Verify project ID correct
- Ensure Firestore enabled

### Google API Errors
- Verify API enabled in console
- Check OAuth credentials
- Ensure redirect URI matches

## Getting Help

- Check existing issues on GitHub
- Ask in development Slack channel
- Review documentation in `/docs`
- Contact tech lead for access issues