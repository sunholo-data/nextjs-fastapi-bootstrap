// src/app/api/proxy/route.ts
import { NextResponse } from 'next/server';

const BACKEND_BASE_URL = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://127.0.0.1:8000';
const REQUEST_TIMEOUT = 30000;  // 30 seconds for TagAssistant API requests

// Log the backend URL on startup
console.log(`[PROXY-INIT] Backend URL configured as: ${BACKEND_BASE_URL}`);

interface ProxyError extends Error {
  status?: number;
}

interface NetworkError extends Error {
  code?: string;
  errno?: number;
  syscall?: string;
  address?: string;
  port?: number;
}

const logWithTimestamp = (requestId: string, message: string, data?: unknown) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}][${requestId}] ${message}`, data ? data : '');
};

// Simple fetch with timeout
const fetchWithTimeout = async (
  url: string,
  options: RequestInit,
  timeout: number,
  requestId: string
): Promise<Response> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    logWithTimestamp(requestId, `Fetching ${options.method} ${url}`);
    
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      const error = new Error(`HTTP ${response.status}`) as ProxyError;
      error.status = response.status;
      throw error;
    }

    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error instanceof Error && error.name === 'AbortError') {
      const timeoutError = new Error('Request timeout') as ProxyError;
      timeoutError.status = 504;
      throw timeoutError;
    }
    
    throw error;
  }
};

export async function POST(req: Request) {
  const requestId = req.headers.get('X-Request-ID') || 
                   Math.random().toString(36).substring(7);
  
  logWithTimestamp(requestId, 'TagAssistant proxy request received');

  let endpoint = '';
  let method = 'POST';
  let body: Record<string, unknown> = {};
  let backendUrl = '';

  try {
    const requestData = await req.json();
    endpoint = requestData.endpoint;
    method = requestData.method || 'POST';
    body = requestData;
    delete body.endpoint;
    delete body.method;

    if (!endpoint) {
      return NextResponse.json(
        { error: 'Missing endpoint parameter' },
        { status: 400 }
      );
    }

    backendUrl = `${BACKEND_BASE_URL}${endpoint}`;
    logWithTimestamp(requestId, `Proxying to: ${backendUrl}`);

    // Handle health check requests specifically
    if (endpoint === '/health') {
      try {
        logWithTimestamp(requestId, `Health check to: ${BACKEND_BASE_URL}/health`);
        
        const healthResponse = await fetchWithTimeout(
          `${BACKEND_BASE_URL}/health`,
          {
            method: 'GET',
            headers: { 
              'Content-Type': 'application/json',
              'X-Request-ID': requestId
            }
          },
          REQUEST_TIMEOUT,
          requestId
        );
        
        const healthData = await healthResponse.json();
        logWithTimestamp(requestId, 'Health check successful', { status: healthResponse.status });
        
        return NextResponse.json({ 
          status: healthResponse.status,
          ok: healthResponse.ok,
          data: healthData,
          timestamp: new Date().toISOString(),
          backendUrl: `${BACKEND_BASE_URL}/health`
        });
      } catch (error) {
        const errorDetails = {
          message: error instanceof Error ? error.message : 'Unknown error',
          name: error instanceof Error ? error.name : 'UnknownError',
          code: (error as NetworkError)?.code,
          backendUrl: `${BACKEND_BASE_URL}/health`
        };
        
        logWithTimestamp(requestId, 'Health check failed:', errorDetails);
        
        return NextResponse.json({
          error: 'Backend health check failed',
          details: error instanceof Error ? error.message : 'Unknown error',
          backendUrl: `${BACKEND_BASE_URL}/health`,
          errorCode: (error as NetworkError)?.code
        }, { status: 503 });
      }
    }

    // Forward relevant headers from the client request
    const forwardedHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      'X-Request-ID': requestId
    };
    
    const response = await fetch(backendUrl, {
      method,
      headers: forwardedHeaders,
      ...(method === 'POST' ? { body: JSON.stringify(body) } : {}),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT)
    });

    const data = await response.json();
    
    if (response.ok) {
      logWithTimestamp(requestId, `Successful response from ${endpoint}`);
      return NextResponse.json(data);
    } else {
      // Handle HTTP errors (400, 500, etc.) by forwarding the error response
      logWithTimestamp(requestId, `Backend error ${response.status} from ${endpoint}:`, data);
      return NextResponse.json(data, { status: response.status });
    }
    
  } catch (error) {
    const errorDetails = {
      message: error instanceof Error ? error.message : 'Unknown error',
      name: error instanceof Error ? error.name : 'UnknownError',
      code: (error as NetworkError)?.code,
      errno: (error as NetworkError)?.errno,
      syscall: (error as NetworkError)?.syscall,
      address: (error as NetworkError)?.address,
      port: (error as NetworkError)?.port,
      status: (error as ProxyError).status || 500,
      stack: error instanceof Error ? error.stack : undefined,
      backendUrl: backendUrl,
      requestBody: method === 'POST' ? JSON.stringify(body) : undefined
    };

    logWithTimestamp(requestId, 'Detailed proxy error:', errorDetails);

    return NextResponse.json({
      error: 'Backend request failed',
      details: error instanceof Error ? error.message : 'Unknown error occurred',
      errorCode: (error as NetworkError)?.code,
      backendUrl: backendUrl,
      retry: (error as ProxyError).status !== 400
    }, { 
      status: (error as ProxyError).status || 500
    });
  }
}

// Handle GET requests for health checks and debugging
export async function GET(req: Request) {
  const requestId = req.headers.get('X-Request-ID') || 
                   Math.random().toString(36).substring(7);
  
  const url = new URL(req.url);
  const endpoint = url.searchParams.get('endpoint') || '/health';
  const backendUrl = `${BACKEND_BASE_URL}${endpoint}`;

  logWithTimestamp(requestId, `GET proxy request for ${endpoint}`);

  try {
    
    const response = await fetchWithTimeout(
      backendUrl,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'X-Request-ID': requestId
        }
      },
      REQUEST_TIMEOUT,
      requestId
    );

    const data = await response.json();
    return NextResponse.json(data);
    
  } catch (error) {
    const errorDetails = {
      message: error instanceof Error ? error.message : 'Unknown error',
      name: error instanceof Error ? error.name : 'UnknownError',
      code: (error as NetworkError)?.code,
      errno: (error as NetworkError)?.errno,
      syscall: (error as NetworkError)?.syscall,
      address: (error as NetworkError)?.address,
      port: (error as NetworkError)?.port,
      status: (error as ProxyError).status || 500,
      stack: error instanceof Error ? error.stack : undefined,
      backendUrl: backendUrl
    };

    logWithTimestamp(requestId, 'Detailed GET proxy error:', errorDetails);

    return NextResponse.json({
      error: 'Backend request failed',
      details: error instanceof Error ? error.message : 'Unknown error occurred',
      errorCode: (error as NetworkError)?.code,
      backendUrl: backendUrl
    }, { 
      status: (error as ProxyError).status || 500
    });
  }
}