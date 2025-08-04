#!/bin/bash

# Upload Documentation Bundle to Google Cloud Storage
# Uploads the complete documentation bundle alongside the codebase documentation
# Ensures AI assistants have access to both code and documentation context

set -e

echo "🚀 Starting documentation bundle upload to Google Cloud Storage..."

# Configuration
_SERVICE_NAME="tagassistant"
DOC_FILE="documentation-complete.txt"
GCS_PATH="gs://${_CONFIG_BUCKET}/docs_${_SERVICE_NAME}/"
PUBLIC_URL="https://storage.googleapis.com/${_CONFIG_BUCKET}/docs_${_SERVICE_NAME}/"

# Verify documentation file exists
if [ ! -f "$DOC_FILE" ]; then
    echo "❌ Error: Documentation bundle not found: $DOC_FILE"
    echo "Please run generate-documentation-bundle.sh first"
    exit 1
fi

# Verify _CONFIG_BUCKET is set
if [ -z "${_CONFIG_BUCKET}" ]; then
    echo "❌ Error: _CONFIG_BUCKET environment variable not set"
    exit 1
fi

# Get file information
file_size=$(stat -c%s "$DOC_FILE" 2>/dev/null || stat -f%z "$DOC_FILE" 2>/dev/null || echo "0")
file_size_mb=$((file_size / 1024 / 1024))

echo "📋 Upload Details:"
echo "  • Source File: $DOC_FILE"
echo "  • File Size: ${file_size} bytes (~${file_size_mb}MB)"
echo "  • Destination: ${GCS_PATH}${DOC_FILE}"
echo "  • Public URL: ${PUBLIC_URL}${DOC_FILE}"

# Upload to Google Cloud Storage with proper metadata
echo "📤 Uploading documentation bundle..."

gsutil -h "Content-Type:text/plain" \
       -h "Cache-Control:no-cache" \
       -h "Content-Disposition:inline" \
       cp "$DOC_FILE" "${GCS_PATH}${DOC_FILE}"

# Verify upload success
if gsutil ls "${GCS_PATH}${DOC_FILE}" >/dev/null 2>&1; then
    echo ""
    echo "🎉 DOCUMENTATION BUNDLE UPLOADED SUCCESSFULLY!"
    echo "================================================================================"
    echo "📚 AI Assistant Documentation Access:"
    echo ""
    echo "🔗 Documentation Bundle URL:"
    echo "${PUBLIC_URL}${DOC_FILE}"
    echo ""
    echo "🔗 Companion Codebase URL:"
    echo "${PUBLIC_URL}codebase-complete.txt"
    echo ""
    echo "📋 Bundle Contents:"
    echo "  • Complete feature documentation"
    echo "  • Development and setup guides"
    echo "  • Testing documentation and best practices"
    echo "  • Troubleshooting guides and common fixes"
    echo "  • API documentation and usage examples"
    echo ""
    echo "🔄 Auto-Update: Documentation regenerated and uploaded on every deployment"
    echo "🤖 AI Integration: Provides comprehensive context for AI assistant responses"
    echo "📝 Consistent Access: Same filename ensures predictable URL for AI assistants"
    echo "================================================================================"
else
    echo "❌ Error: Upload verification failed"
    exit 1
fi

# Optional: Set public read permissions (if needed)
# gsutil acl ch -u AllUsers:R "${GCS_PATH}${DOC_FILE}"

echo "📚 Documentation bundle upload complete!"