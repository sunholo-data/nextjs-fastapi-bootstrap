/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    NEXT_PUBLIC_BACKEND_URL: process.env.NEXT_PUBLIC_BACKEND_URL || 'http://127.0.0.1:8000',
  },
  // Ensure all static assets work properly
  assetPrefix: '',
  trailingSlash: false,
  // Optimize for production builds
  compress: true,
  poweredByHeader: false,
  generateEtags: false,
  // Handle API routes properly
  async rewrites() {
    return [
      // Don't rewrite API routes, they should be handled by the API route handler
    ]
  },
}

export default nextConfig