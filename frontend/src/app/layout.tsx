import type { Metadata, Viewport } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Your App - Modern Web Application',
  description: 'A modern web application built with Next.js and FastAPI',
  keywords: 'web application, react, nextjs, fastapi',
  authors: [{ name: 'Your Company' }],
  openGraph: {
    type: 'website',
    url: 'https://yourapp.com/',
    title: 'Your App - Modern Web Application',
    description: 'A modern web application built with Next.js and FastAPI',
    images: ['/og-image.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Your App - Modern Web Application',
    description: 'A modern web application built with Next.js and FastAPI',
    images: ['/og-image.png'],
  },
  robots: 'index, follow',
}

export const viewport: Viewport = {
  themeColor: '#2563eb',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" type="image/x-icon" href="/favicon_io/favicon.ico" />
        <link rel="apple-touch-icon" sizes="180x180" href="/favicon_io/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon_io/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon_io/favicon-16x16.png" />
        <link rel="manifest" href="/favicon_io/site.webmanifest" />
      </head>
      <body className="antialiased">
        {children}
      </body>
    </html>
  )
}