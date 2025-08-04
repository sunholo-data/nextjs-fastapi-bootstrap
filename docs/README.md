# TagAssistant.ai Documentation

## Current Implementation Status

⚠️ **Early Development**: TagAssistant.ai is currently in early development phase. The documentation reflects the current implementation (waitlist collection + Google Analytics MCP integration).

## Documentation Overview

### Core Documentation

- **[API Reference](api-reference.md)** - Current API endpoints with file references
  - Waitlist management (`POST /api/waitlist`, `GET /api/waitlist/count`)
  - Google Analytics MCP integration (`POST /api/analytics/query`)
  - Debug endpoints for development

- **[Architecture](architecture.md)** - Current system architecture and file structure
  - Frontend: React + TypeScript + Vite
  - Backend: Python FastAPI + Firestore + MCP
  - File structure and implementation references

- **[Development Setup](development-setup.md)** - Local development environment setup
  - Prerequisites and tool installation
  - Firebase configuration with "tagassistant" database
  - Mandatory testing requirements (zero tolerance policy)

- **[Deployment](deployment.md)** - Deployment guide for current features
  - Cloud Build configuration
  - Firebase setup
  - Local and production deployment

### Implementation References

All documentation includes specific file path references to current implementations:

- **Backend API**: `/backend/app/api/endpoints/`
  - `waitlist.py` - Waitlist endpoints
  - `analytics.py` - Analytics/MCP endpoints  
  - `debug.py` - Debug endpoints

- **Backend Services**: `/backend/app/services/`
  - `waitlist.py` - Waitlist business logic
  - `google_analytics_mcp.py` - MCP client integration

- **Frontend Components**: `/frontend/src/`
  - `pages/LandingPage.tsx` - Main landing page
  - `components/WaitlistForm.tsx` - Email signup form

- **Data Models**: `/backend/app/schemas/`
  - `waitlist.py` - Waitlist request/response models
  - `analytics.py` - Analytics query models

## Current Features

### ✅ Implemented
- Waitlist email collection with Firestore storage
- Google Analytics natural language querying via MCP
- Firebase/Firestore integration with "tagassistant" database
- React landing page with waitlist form
- FastAPI backend with proper error handling
- Comprehensive test suite with CI/CD integration

### 🚧 Planned Features
- Website scanning for existing tracking scripts
- Google Tag Manager API integration
- Google Analytics Admin API integration  
- OAuth 2.0 authentication flow
- Automated GTM/GA deployment
- Continuous monitoring and alerting
- Email notifications via Mailgun

## File Structure

```
/
├── docs/                    # This documentation
├── backend/                 # Python FastAPI backend
│   ├── app/api/endpoints/  # API route handlers
│   ├── app/services/       # Business logic
│   ├── app/schemas/        # Pydantic models
│   └── tests/              # Test files
├── frontend/               # React TypeScript frontend
│   ├── src/pages/         # Page components
│   ├── src/components/    # Reusable components
│   └── src/services/      # API client
├── mcp-server-google-analytics/  # Custom MCP server
└── mockups/               # UI mockups for planned features
```

## Development Workflow

1. **Setup**: Follow [Development Setup](development-setup.md)
2. **Development**: Make changes with proper file references
3. **Testing**: Run complete test suite (mandatory)
4. **Documentation**: Update docs with new file references
5. **Commit**: Only after all tests pass locally

## Testing Requirements

**CRITICAL**: Zero tolerance policy for test failures:

- All formatting, linting, type checking, and unit tests must pass locally
- CI/CD will run the same tests - they must pass there too  
- No commits allowed with failing tests
- See [Development Setup](development-setup.md) for complete test commands

## Contributing

When adding new features:

1. Implement the feature with proper error handling
2. Add comprehensive tests
3. Update relevant documentation with file path references
4. Ensure all tests pass locally before committing
5. Include implementation details in documentation

## Visual References

- **UI Mockups**: See `/mockups/` for planned feature designs
- **Logo**: Current logo at `/frontend/public/logo.png`
- **Architecture Diagrams**: Planned for future documentation updates

## Contact

- **Development**: Follow patterns in existing codebase
- **Questions**: Reference file paths in `/backend/` and `/frontend/`
- **Issues**: Ensure reproducible with specific file references