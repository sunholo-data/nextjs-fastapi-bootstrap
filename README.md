# Next.js + FastAPI Bootstrap Template

A modern full-stack web application template featuring Next.js (React) frontend and FastAPI (Python) backend, with Firebase/Firestore integration and a working email waitlist example.

## Quick Start with Claude

If you're using Claude (claude.ai/code), here's the fastest way to get started:

```bash
# 1. Clone and setup your new project
git clone https://github.com/sunholo-data/nextjs-fastapi-bootstrap.git my-awesome-app
cd my-awesome-app
rm -rf .git && git init  # Start fresh git history

# 2. Tell Claude to set up the project
# Just say: "Please set up this project for local development"
# Claude will:
# - Install all dependencies
# - Copy .env.example files
# - Help you configure Firebase
# - Start both frontend and backend

# 3. Start building!
# Say: "Help me create a new API endpoint for [your feature]"
# Or: "Add a new page for [your feature]"
```

### Claude-Specific Commands

When working with Claude, you can use these helpful prompts:

- **"Set up the project"** - Claude will handle all initialization
- **"Run all tests"** - Claude will run both frontend and backend tests
- **"Add a new feature for X"** - Claude will create endpoints, pages, and tests
- **"Deploy to Google Cloud Run"** - Claude will guide you through deployment
- **"Fix any linting errors"** - Claude will clean up code formatting

The `CLAUDE.md` file contains detailed instructions that help Claude understand the codebase structure and best practices.

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

## Working with Claude

### Initial Setup Walkthrough

If you're using Claude for the first time with this template:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sunholo-data/nextjs-fastapi-bootstrap.git my-project
   cd my-project
   ```

2. **Open in Claude:**
   ```bash
   claude my-project
   ```

3. **Ask Claude to set up the project:**
   ```
   "Please set up this project for local development. I need:
   1. All dependencies installed
   2. Environment variables configured
   3. Firebase project connected (my project ID is: YOUR_PROJECT_ID)
   4. Both frontend and backend running"
   ```

4. **Claude will automatically:**
   - Run `npm install` in frontend
   - Run `uv sync` in backend
   - Copy `.env.example` files
   - Help you configure Firebase
   - Start development servers

### Common Claude Prompts

```
# Development
"Start the development servers"
"Run all tests and fix any failures"
"Check for linting errors and fix them"

# Adding Features
"Create a new API endpoint for user profiles with CRUD operations"
"Add a dashboard page that shows user statistics"
"Implement authentication with Google OAuth"

# Database
"Add a new Firestore collection for products"
"Create a data model for blog posts"

# Deployment
"Help me deploy this to Google Cloud Run"
"Set up GitHub Actions for CI/CD"
"Configure environment variables for production"

# Debugging
"Debug why the API call is failing"
"Fix the TypeScript error in [file]"
"Why is my Firebase connection not working?"
```

### Tips for Working with Claude

1. **Be specific**: Instead of "add authentication", say "add Google OAuth authentication with a login button on the homepage"

2. **Use the todo list**: Say "Create a todo list for implementing a shopping cart feature" to help Claude plan complex features

3. **Test as you go**: After each feature, ask "Run all tests" to ensure nothing breaks

4. **Review changes**: Say "Show me what files you changed" to understand modifications

5. **Use CLAUDE.md**: The CLAUDE.md file helps Claude understand the project structure. You can update it with project-specific conventions.

## License

MIT - Use this template for any project!