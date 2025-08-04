'use client'

import { useState } from 'react'
import { joinWaitlist } from '../services/api'

interface WaitlistFormProps {
  onSuccess: () => void
}

export default function WaitlistForm({ onSuccess }: WaitlistFormProps) {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [consented, setConsented] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!consented) {
      setError('Please consent to our data storage policy to join the waitlist.')
      return
    }

    setLoading(true)

    try {
      await joinWaitlist(email)
      onSuccess()
    } catch (err) {
      // Show the actual error message from the API
      if (err instanceof Error) {
        // Make the error message more user-friendly
        if (err.message.toLowerCase().includes('already registered')) {
          setError('This email is already on the waitlist!')
        } else {
          setError(err.message)
        }
      } else {
        setError('Something went wrong. Please try again.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="flex flex-col sm:flex-row gap-3">
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Enter your email"
          className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          required
          disabled={loading}
        />
        <button
          type="submit"
          disabled={loading || !consented}
          className="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {loading ? 'Joining...' : 'Join Waitlist'}
        </button>
      </div>
      
      {/* GDPR Consent Checkbox */}
      <div className="flex items-start space-x-2">
        <input
          type="checkbox"
          id="consent"
          checked={consented}
          onChange={(e) => setConsented(e.target.checked)}
          className="mt-0.5 h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          required
        />
        <label htmlFor="consent" className="text-xs text-gray-600 leading-relaxed">
          I consent to storing my email address to notify me when the service launches. 
          You can unsubscribe at any time by emailing{' '}
          <span 
            onClick={() => {
              const email = 'hello' + '@' + 'example.com';
              window.location.href = `mailto:${email}?subject=Unsubscribe from Waitlist`;
            }}
            className="text-blue-600 underline hover:text-blue-800 cursor-pointer"
            role="button"
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                const email = 'hello' + '@' + 'example.com';
                window.location.href = `mailto:${email}?subject=Unsubscribe from Waitlist`;
              }
            }}
          >
            hello{'@'}example.com
          </span>
          .
        </label>
      </div>
      
      {error && (
        <p className="text-red-600 text-sm">{error}</p>
      )}
      
      <p className="text-xs text-gray-500 text-center">
        We only use your email to notify you when we launch. No spam, ever.
      </p>
    </form>
  )
}