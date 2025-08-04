import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { vi } from 'vitest'
import HomePage from '../app/page'

// Mock the API module
vi.mock('../app/services/api', () => ({
  joinWaitlist: vi.fn()
}))

describe('HomePage', () => {
  it('renders the landing page with key elements', () => {
    render(<HomePage />)
    
    // Check main heading
    expect(screen.getByText(/Your Next Big Thing/i)).toBeInTheDocument()
    expect(screen.getByText(/Starts Here/i)).toBeInTheDocument()
    
    // Check waitlist form is present
    expect(screen.getByPlaceholderText(/Enter your email/i)).toBeInTheDocument()
    expect(screen.getByText(/Join Waitlist/i)).toBeInTheDocument()
  })

  it('shows success message after joining waitlist', async () => {
    const { joinWaitlist } = await import('../app/services/api')
    vi.mocked(joinWaitlist).mockResolvedValueOnce(undefined)
    
    render(<HomePage />)
    
    const emailInput = screen.getByPlaceholderText(/Enter your email/i)
    const consentCheckbox = screen.getByRole('checkbox')
    const submitButton = screen.getByText(/Join Waitlist/i)
    
    fireEvent.change(emailInput, { target: { value: 'test@example.com' } })
    fireEvent.click(consentCheckbox)
    fireEvent.click(submitButton)
    
    await waitFor(() => {
      expect(screen.getByText(/You're on the list!/i)).toBeInTheDocument()
    })
  })
})