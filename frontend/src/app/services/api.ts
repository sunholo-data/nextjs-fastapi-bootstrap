export async function joinWaitlist(email: string): Promise<void> {
  const response = await fetch('/api/proxy', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ 
      endpoint: '/api/waitlist',
      email 
    }),
  })

  if (!response.ok) {
    // Try to get the error message from the response
    let errorMessage = 'Failed to join waitlist'
    try {
      const errorData = await response.json()
      errorMessage = errorData.detail || errorMessage
    } catch (e) {
      // If parsing fails, use the default message
    }
    throw new Error(errorMessage)
  }
}