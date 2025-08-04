# Next.js + FastAPI Bootstrap Template

A modern full-stack web application template featuring Next.js (React) frontend and FastAPI (Python) backend, with Firebase/Firestore integration and a working email waitlist example.

## Features

- **Frontend**: Next.js 14 with App Router, TypeScript, Tailwind CSS
- **Backend**: FastAPI with Python 3.11+, async/await support
- **Database**: Firebase/Firestore for NoSQL data storage
- **Authentication**: Google OAuth 2.0 integration (optional)
- **Email**: Mailgun integration for transactional emails
- **Testing**: Vitest (frontend) and Pytest (backend)
- **Deployment**: Google Cloud Run with Cloud Build CI/CD
- **Development**: Hot reload, type safety, linting, and formatting

## Quick Start

### Prerequisites

- Node.js 18+
- Python 3.11+
- [uv](https://github.com/astral-sh/uv) (Python package manager)
- Google Cloud account (for Firebase/Firestore)

### Backend Setup

```bash
cd backend

# Copy environment variables
cp .env.example .env
# Edit .env with your configuration

# Install dependencies
uv sync

# Run development server
uv run uvicorn main:app --reload
```

Backend will be available at http://localhost:8000

### Frontend Setup

```bash
cd frontend

# Copy environment variables  
cp .env.example .env
# Edit .env if needed

# Install dependencies
npm install

# Run development server
npm run dev
```

Frontend will be available at http://localhost:3000

## Project Structure

```
├── backend/
│   ├── app/
│   │   ├── api/           # API endpoints
│   │   ├── core/          # Core functionality (Firebase, auth)
│   │   ├── schemas/       # Pydantic models
│   │   └── services/      # Business logic
│   ├── tests/             # Backend tests
│   ├── main.py           # FastAPI application
│   └── pyproject.toml    # Python dependencies
│
├── frontend/
│   ├── src/
│   │   ├── app/          # Next.js App Router
│   │   │   ├── api/      # API proxy routes
│   │   │   ├── components/
│   │   │   └── services/ # API client
│   │   └── __tests__/    # Frontend tests
│   ├── package.json      # Node dependencies
│   └── next.config.mjs   # Next.js configuration
│
└── cloudbuild.yaml       # Google Cloud Build configuration
```

## Architecture

### API Proxy Pattern
The frontend uses Next.js API routes to proxy requests to the backend, eliminating CORS issues:

```typescript
// Frontend: /src/app/services/api.ts
fetch('/api/proxy', { 
  body: JSON.stringify({ 
    endpoint: '/api/waitlist', 
    email 
  }) 
})

// Proxy route forwards to backend
// Backend receives at: http://127.0.0.1:8000/api/waitlist
```

### Environment Variables

Both frontend and backend use `.env` files. Copy `.env.example` to `.env` and configure.

## Development Commands

### Frontend
```bash
npm run dev        # Start development server
npm run build      # Build for production
npm run lint       # Run ESLint
npm run type-check # TypeScript type checking
npm test          # Run tests
```

### Backend
```bash
uv run uvicorn main:app --reload  # Development server
uv run pytest                     # Run tests
uv run black .                    # Format code
uv run mypy .                     # Type checking
```

## Testing

The template includes a complete test setup:

- **Frontend**: Vitest with React Testing Library
- **Backend**: Pytest with async support

Run all tests before committing:
```bash
# Frontend
cd frontend && npm test

# Backend  
cd backend && uv run pytest
```

## Deployment

The included `cloudbuild.yaml` configures Google Cloud Build for automated deployment to Cloud Run.

### Prerequisites
1. Enable required Google Cloud APIs
2. Create service account with proper permissions
3. Set up Firebase project
4. Configure environment variables in Cloud Run

### Deploy
```bash
gcloud builds submit --config=cloudbuild.yaml
```

## Customization

1. **Remove Waitlist**: Delete waitlist-related files and update routes
2. **Add Authentication**: Uncomment Google OAuth code and configure
3. **Change Styling**: Modify Tailwind configuration and globals.css
4. **Add Features**: Follow the patterns in existing endpoints/components

## Common Tasks

### Adding a New API Endpoint
1. Create route in `/backend/app/api/endpoints/`
2. Add schemas in `/backend/app/schemas/`
3. Implement service in `/backend/app/services/`
4. Update frontend API client in `/frontend/src/app/services/api.ts`
5. Write tests for both frontend and backend

### Adding a New Page
1. Create component in `/frontend/src/app/[page-name]/page.tsx`
2. Add any needed components
3. Connect to API if needed
4. Write tests

## License

MIT - Use this template for any project!