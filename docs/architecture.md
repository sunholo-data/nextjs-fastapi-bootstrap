# TagAssistant.ai Architecture

## Overview

TagAssistant.ai is a cloud-native application being built to automate Google Tag Manager and Analytics setup. Currently in early development phase focusing on waitlist collection and Google Analytics integration via MCP (Model Context Protocol).

## Current System Architecture

### Frontend
- **Technology**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Hosting**: Cloud Run (planned)
- **Current Features**:
  - Landing page (`/frontend/src/pages/LandingPage.tsx`)
  - Waitlist signup form (`/frontend/src/components/WaitlistForm.tsx`)
  - Firebase configuration (`/frontend/src/config/firebase.ts`)
  - API client (`/frontend/src/services/api.ts`)

### Backend
- **Technology**: Python FastAPI
- **Database**: Firebase/Firestore (database: "tagassistant")
- **Package Manager**: uv (modern Python package manager)
- **Hosting**: Cloud Run (planned)
- **Current Services**:
  - Waitlist management (`/backend/app/services/waitlist.py`) 
  - Google Analytics MCP integration (`/backend/app/services/google_analytics_mcp.py`)
  - Firebase connection (`/backend/app/core/firebase.py`)

### MCP Integration
- **MCP Server**: Custom Google Analytics MCP server (`/mcp-server-google-analytics/`)
- **Purpose**: Enables natural language queries to Google Analytics
- **Implementation**: ADK (Anthropic Development Kit) client
- **Location**: `/backend/app/services/google_analytics_mcp.py`

### Infrastructure (Current)
- **Dependencies**: uv for Python package management
- **Database**: Firestore with "tagassistant" database
- **Testing**: pytest with Firebase emulation
- **CI/CD**: Cloud Build configuration (`/cloudbuild.yaml`)

## Current Data Flow

### 1. Waitlist Collection
- User visits landing page
- Enters email in waitlist form
- Frontend calls `POST /api/waitlist`
- Backend validates and stores in Firestore "waitlist" collection
- Unique constraint prevents duplicates

### 2. Analytics Querying (MCP)
- Natural language query sent to `POST /api/analytics/query`
- Backend initializes MCP client connection
- Query processed by Google Analytics MCP server
- Structured analytics data returned to client

## File Structure

### Backend Structure
```
/backend/
├── app/
│   ├── api/endpoints/          # API route handlers
│   │   ├── waitlist.py        # Waitlist endpoints
│   │   ├── analytics.py       # Analytics/MCP endpoints
│   │   └── debug.py          # Debug endpoints
│   ├── core/
│   │   └── firebase.py       # Firebase/Firestore client
│   ├── schemas/              # Pydantic models
│   │   ├── waitlist.py       # Waitlist request/response
│   │   └── analytics.py      # Analytics query models
│   └── services/             # Business logic
│       ├── waitlist.py       # Waitlist operations
│       └── google_analytics_mcp.py  # MCP client
├── tests/                    # Test files
│   ├── conftest.py          # Test configuration
│   └── test_waitlist.py     # Waitlist tests
├── main.py                  # FastAPI application
└── pyproject.toml          # Dependencies (uv)
```

### Frontend Structure
```
/frontend/
├── src/
│   ├── pages/
│   │   └── LandingPage.tsx   # Main landing page
│   ├── components/
│   │   └── WaitlistForm.tsx  # Email signup form
│   ├── services/
│   │   └── api.ts           # Backend API client
│   └── config/
│       └── firebase.ts      # Firebase config
├── public/                  # Static assets
│   ├── logo.png            # Main logo
│   └── favicon_io/         # Favicon files
└── package.json            # Dependencies
```

## Database Schema (Firestore)

### waitlist Collection
```javascript
{
  email: string,           // Unique email address
  created_at: timestamp,   // When user joined
  user_agent: string,      // Browser info (optional)
  ip_address: string       // User IP (optional)
}
```

## Security Considerations (Current)

- Firebase service account with minimal required permissions
- Email validation on both frontend and backend
- Duplicate email prevention
- Environment variables for sensitive configuration
- CORS configured for frontend domain

## Testing Strategy

### Backend Tests (`/backend/tests/`)
- Firebase/Firestore integration tests
- Waitlist service tests with unique email generation
- API endpoint tests using TestClient
- Proper test isolation with Firebase app cleanup

### Frontend Tests (`/frontend/src/__tests__/`)
- Component rendering tests
- Form submission tests
- API integration tests

## Development Environment

### Required Tools
- Python 3.11+ with uv package manager
- Node.js 18.x (LTS)
- Firebase CLI for local development
- Google Cloud SDK for authentication

### Local Development Commands
```bash
# Backend
cd backend
uv sync                    # Install dependencies
uv run uvicorn main:app --reload

# Frontend
cd frontend
npm install                # Install dependencies
npm run dev               # Start development server
```

## Future Planned Features

The following components are planned but not yet implemented:

### Additional Backend Services
- Website scanning service (BeautifulSoup for parsing tracking scripts)
- Google Tag Manager API integration
- Google Analytics Admin API integration
- OAuth 2.0 authentication flow
- Scheduled monitoring jobs
- Email notification system (Mailgun)

### Additional Infrastructure
- Cloud Scheduler for periodic tasks
- Cloud Run Jobs for monitoring
- Email service integration
- SSL certificate management
- Domain configuration

### Enhanced Frontend
- Website scanning interface
- Tracking configuration wizard
- Real-time monitoring dashboard
- OAuth integration with Google
- Multi-step setup flow

## Scalability Considerations

### Current
- Firestore handles concurrent reads/writes efficiently
- uv provides fast dependency resolution
- Stateless FastAPI application ready for Cloud Run

### Planned
- Cloud Run auto-scaling based on traffic
- MCP server can handle concurrent analytics queries
- Monitoring jobs will run independently
- Mailgun handles email delivery at scale

## Implementation References

All current implementations include file path references:
- API endpoints: `/backend/app/api/endpoints/`
- Data models: `/backend/app/schemas/`
- Business logic: `/backend/app/services/`
- Frontend components: `/frontend/src/`
- Tests: `/backend/tests/` and `/frontend/src/__tests__/`

See `/mockups/` directory for UI mockups of planned features.