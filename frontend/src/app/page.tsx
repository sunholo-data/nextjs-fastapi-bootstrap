'use client'

import { useState } from 'react'
import WaitlistForm from './components/WaitlistForm'

export default function HomePage() {
  const [showSuccess, setShowSuccess] = useState(false)

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-16">
        <div className="text-center">
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
            Your Next Big Thing
            <br />
            <span className="text-blue-600">Starts Here</span>
          </h1>
          
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            Join our community and be the first to experience what we&apos;re building.
          </p>

          {/* Waitlist Form */}
          <div className="max-w-md mx-auto">
            {showSuccess ? (
              <div className="bg-green-50 border border-green-200 rounded-lg p-6 text-center">
                <svg className="w-12 h-12 text-green-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <h3 className="text-lg font-semibold text-green-900 mb-2">You&apos;re on the list!</h3>
                <p className="text-green-700">We&apos;ll notify you as soon as we launch.</p>
              </div>
            ) : (
              <>
                <h2 className="text-2xl font-bold mb-4">Join the waiting list</h2>
                <p className="text-gray-600 mb-6">
                  Be the first to know when we launch.
                </p>
                <WaitlistForm onSuccess={() => setShowSuccess(true)} />
              </>
            )}
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center text-gray-500">
            <p>© 2025 Your Company. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}