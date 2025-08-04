# API Reference

## Base URL
```
Production: https://api.tagassistant.ai
Development: http://localhost:8000
```

## Current Implementation Status

⚠️ **Note**: TagAssistant.ai is currently in early development. The documentation below reflects the currently implemented features. Additional features (website scanning, GTM deployment, monitoring) are planned for future releases.

## Endpoints

### Waitlist Management

#### POST /api/waitlist
Add an email to the waiting list.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Successfully joined the waiting list!",
  "email": "user@example.com",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

**Response (400) - Duplicate Email:**
```json
{
  "detail": "Email user@example.com is already registered for the waiting list"
}
```

**Implementation:** `/backend/app/api/endpoints/waitlist.py:13`

#### GET /api/waitlist/count
Get the total number of waitlist entries.

**Response:**
```json
{
  "count": 42
}
```

**Implementation:** `/backend/app/api/endpoints/waitlist.py:41`

### Google Analytics (via MCP)

#### POST /api/analytics/query
Process a natural language query about Google Analytics data using MCP server.

**Request Body:**
```json
{
  "query": "How many sessions did we have last week from users in the United States?"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "sessions": 1234,
    "period": "last_week",
    "country": "United States"
  },
  "message": "Query processed successfully"
}
```

**Implementation:** `/backend/app/api/endpoints/analytics.py:28`

#### GET /api/analytics/health
Health check for Google Analytics MCP integration.

**Response:**
```json
{
  "status": "healthy",
  "message": "Google Analytics MCP client is operational",
  "mcp_server_path": "/path/to/mcp/server"
}
```

**Implementation:** `/backend/app/api/endpoints/analytics.py:64`

### Debug Endpoints

#### GET /api/debug/firebase
Test Firebase/Firestore connectivity (development only).

**Response:**
```json
{
  "firebase_connection": {
    "status": "healthy",
    "can_read": true,
    "can_write": true
  },
  "environment": {
    "FIREBASE_PROJECT_ID": "multivac-internal-dev",
    "FIREBASE_CREDENTIALS_SET": true
  }
}
```

**Implementation:** `/backend/app/api/endpoints/debug.py:13`

#### GET /api/debug/waitlist
Test waitlist service functionality (development only).

**Response:**
```json
{
  "service_initialized": true,
  "collection_name": "waitlist",
  "current_count": 42,
  "read_access": true
}
```

**Implementation:** `/backend/app/api/endpoints/debug.py:36`

#### POST /api/debug/test-email
Test adding an email to waitlist (development only).

**Query Parameters:**
- `test_email`: Email to test (default: "test@debug.local")

**Implementation:** `/backend/app/api/endpoints/debug.py:65`

## Data Models

### WaitlistEntry (Request)
```python
{
  "email": str  # Valid email address
}
```
**Implementation:** `/backend/app/schemas/waitlist.py`

### WaitlistResponse
```python
{
  "message": str,
  "email": str,
  "timestamp": datetime
}
```
**Implementation:** `/backend/app/schemas/waitlist.py`

### UserQuery (Analytics Request)
```python
{
  "query": str  # Natural language query
}
```
**Implementation:** `/backend/app/schemas/analytics.py`

### AnalyticsResponse
```python
{
  "success": bool,
  "data": Optional[Dict[str, Any]],
  "message": str,
  "error": Optional[str]
}
```
**Implementation:** `/backend/app/schemas/analytics.py`

## Error Responses

All endpoints return standard error format:
```json
{
  "detail": "Human readable error message"
}
```

Common HTTP status codes:
- `200`: Success
- `400`: Bad Request (validation error, duplicate email)
- `422`: Unprocessable Entity (invalid request format)
- `500`: Internal Server Error
- `503`: Service Unavailable (MCP server issues)

## Interactive API Documentation

Visit http://localhost:8000/docs for Swagger UI documentation when running locally.

## Testing the API

### Quick Health Check
```bash
# Test backend is running
curl http://localhost:8000/health
```

### Waitlist Testing
```bash
# Add email to waitlist
curl -X POST http://localhost:8000/api/waitlist \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Get current waitlist count
curl http://localhost:8000/api/waitlist/count

# Try adding duplicate email (should return 400)
curl -X POST http://localhost:8000/api/waitlist \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

### Analytics Testing
```bash
# Test MCP server health
curl http://localhost:8000/api/analytics/health

# Test natural language query
curl -X POST http://localhost:8000/api/analytics/query \
  -H "Content-Type: application/json" \
  -d '{"query": "How many sessions did we have last week?"}'
```

### Debug Endpoints (Development Only)
```bash
# Test Firebase connectivity
curl http://localhost:8000/api/debug/firebase

# Test waitlist service
curl http://localhost:8000/api/debug/waitlist

# Test adding email via debug endpoint
curl -X POST "http://localhost:8000/api/debug/test-email?test_email=debug@test.com"
```

## Future Features (Planned)

The following endpoints are planned but not yet implemented:
- Website scanning (`POST /api/scan`)
- GTM/GA deployment (`POST /api/tracking/deploy`)
- Authentication (`GET /api/auth/google`)
- Monitoring (`GET /api/monitoring/{site_id}`)

See `/mockups/` directory for UI mockups of planned features.