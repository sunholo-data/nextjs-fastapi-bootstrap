#!/bin/bash

# Upload Codebase Documentation to _CONFIG_BUCKET
# Uploads the comprehensive codebase documentation for AI assistant access

set -e

# Configuration
SOURCE_FILE="codebase-complete.txt"
TARGET_FOLDER="docs_tagassistant"
TARGET_FILENAME="codebase-complete.txt"

# Validate required environment variables
if [ -z "$_CONFIG_BUCKET" ]; then
    echo "❌ Error: _CONFIG_BUCKET environment variable is required"
    echo "This should be set from cloudbuild.yaml substitutions"
    exit 1
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ Error: Source file '$SOURCE_FILE' not found"
    echo "Run ./scripts/generate-codebase-docs.sh first"
    exit 1
fi

echo "🚀 Starting upload of codebase documentation..."
echo "📁 Source file: $SOURCE_FILE"
echo "🪣 Target bucket: $_CONFIG_BUCKET"
echo "📂 Target folder: $TARGET_FOLDER"
echo "📄 Target filename: $TARGET_FILENAME"

# Get file size
file_size=$(stat -f%z "$SOURCE_FILE" 2>/dev/null || stat -c%s "$SOURCE_FILE" 2>/dev/null || echo 0)
file_size_mb=$((file_size / 1024 / 1024))

echo "📊 File size: $file_size bytes (~${file_size_mb}MB)"

# Full target path
FULL_TARGET="gs://$_CONFIG_BUCKET/$TARGET_FOLDER/$TARGET_FILENAME"

echo "🔄 Uploading to: $FULL_TARGET"

# Upload with proper content type and metadata
gsutil -h "Content-Type:text/plain; charset=utf-8" \
       -h "Cache-Control:public, max-age=3600" \
       -h "X-Goog-Meta-Generated:$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       -h "X-Goog-Meta-Purpose:Aitana AI Assistant Codebase Reference" \
       -h "X-Goog-Meta-Version:comprehensive" \
       cp "$SOURCE_FILE" "$FULL_TARGET"

# Verify upload succeeded
if gsutil ls "$FULL_TARGET" >/dev/null 2>&1; then
    echo "✅ Upload successful!"
    
    # Get object details
    echo "📋 Object details:"
    gsutil ls -L "$FULL_TARGET" | grep -E "(Creation time|Size|Content-Type|Cache-Control)"
    
    # Construct public URL
    PUBLIC_URL="https://storage.googleapis.com/$_CONFIG_BUCKET/$TARGET_FOLDER/$TARGET_FILENAME"
    
    echo ""
    echo "🌐 Public access URL:"
    echo "$PUBLIC_URL"
    echo ""
    echo "🤖 AI Assistant Integration:"
    echo "This URL provides static access to the complete Aitana codebase for AI assistants."
    echo "The file is automatically updated with every deployment using the same filename."
    echo ""
    echo "📑 Content includes:"
    echo "  • Complete project file tree"
    echo "  • All source code files (Python, TypeScript, JavaScript, etc.)"
    echo "  • Configuration files and build scripts"
    echo "  • Documentation and README files"
    echo "  • Excludes: tests, virtual environments, lock files, secrets"
    echo ""
    echo "🔄 Update frequency: Every deployment (automatic via CI/CD)"
    echo "📝 Consistent naming: Same filename for predictable access"
    
    # Test public accessibility (optional)
    echo ""
    echo "🧪 Testing public accessibility..."
    if curl -s -f -I "$PUBLIC_URL" >/dev/null 2>&1; then
        echo "✅ Public URL is accessible"
    else
        echo "⚠️  Warning: Public URL test failed (may need time to propagate)"
    fi
    
else
    echo "❌ Upload failed! Object not found in bucket."
    exit 1
fi

echo ""
echo "🎉 Codebase documentation upload complete!"
echo "AI assistants can now access the comprehensive codebase at:"
echo "$PUBLIC_URL"