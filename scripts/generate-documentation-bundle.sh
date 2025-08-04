#!/bin/bash

# Documentation Bundle Generator for Aitana AI Assistant
# Generates comprehensive text file with all documentation for AI assistant access
# Complements the codebase documentation with complete feature and usage docs

set -e

echo "📚 Starting comprehensive documentation bundle generation..."

# Output file
OUTPUT_FILE="aitana-documentation-complete.txt"

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Remove existing output file
rm -f "$OUTPUT_FILE"

echo "📋 Generating comprehensive documentation bundle..."

# Start building the comprehensive documentation
cat > "$OUTPUT_FILE" << EOF
# AITANA AI ASSISTANT - COMPLETE DOCUMENTATION BUNDLE
# Generated automatically for AI assistant reference
# Last updated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## DOCUMENTATION OVERVIEW

This is the complete documentation bundle for the Aitana AI Assistant platform.
This documentation is automatically generated and uploaded alongside the codebase
to provide AI assistants with comprehensive context about features, usage, and implementation.

### Documentation Structure
- **Development Docs**: Setup, building, testing, and deployment guides
- **Feature Docs**: Comprehensive feature documentation and usage guides  
- **Testing Docs**: Testing strategies, frameworks, and best practices
- **Troubleshooting Docs**: Common issues, fixes, and debugging guides

### Companion Files
- **Codebase**: aitana-codebase-complete.txt (complete source code)
- **Documentation**: aitana-documentation-complete.txt (this file)

### Access Information
- **Storage**: Google Cloud Storage bucket (${_CONFIG_BUCKET:-aitana-config})
- **Path**: /aitana-assistant-docs/
- **Update Frequency**: Every deployment/build
- **Consistency**: Same filenames ensure predictable AI assistant access

---

EOF

# Function to add a documentation file with proper formatting
add_doc_file() {
    local file_path="$1"
    local display_path="$2"
    
    if [ -f "$file_path" ]; then
        echo "📄 Adding: $display_path"
        
        # Add file header
        cat >> "$OUTPUT_FILE" << EOF

## FILE: $display_path

\`\`\`markdown
EOF
        # Add file content
        cat "$file_path" >> "$OUTPUT_FILE"
        
        # Close code block
        cat >> "$OUTPUT_FILE" << EOF
\`\`\`

---

EOF
    else
        echo "⚠️  Warning: File not found: $file_path"
    fi
}

# Check if docs directory exists
if [ ! -d "docs" ]; then
    echo "❌ Error: docs/ directory not found. Are you running from the project root?"
    exit 1
fi

echo "📁 Processing documentation files..."

# Add main README
if [ -f "README.md" ]; then
    add_doc_file "README.md" "README.md"
fi

# Add CLAUDE.md if it exists
if [ -f "CLAUDE.md" ]; then
    add_doc_file "CLAUDE.md" "CLAUDE.md"
fi

# Add docs/README.md
add_doc_file "docs/README.md" "docs/README.md"

# Process development documentation
echo "🔧 Processing development documentation..."
for file in docs/development/*.md; do
    if [ -f "$file" ]; then
        add_doc_file "$file" "${file#./}"
    fi
done

# Process feature documentation
echo "🚀 Processing feature documentation..."
for file in docs/features/*.md; do
    if [ -f "$file" ]; then
        add_doc_file "$file" "${file#./}"
    fi
done

# Process testing documentation
echo "🧪 Processing testing documentation..."
for file in docs/testing/*.md; do
    if [ -f "$file" ]; then
        add_doc_file "$file" "${file#./}"
    fi
done

# Process troubleshooting documentation
echo "🛠️ Processing troubleshooting documentation..."
for file in docs/troubleshooting/*.md; do
    if [ -f "$file" ]; then
        add_doc_file "$file" "${file#./}"
    fi
done

# Add documentation summary
cat >> "$OUTPUT_FILE" << EOF

## DOCUMENTATION BUNDLE SUMMARY

### Statistics
- **Total Documentation Files**: $(find docs/ -name "*.md" -type f | wc -l)
- **Development Docs**: $(find docs/development/ -name "*.md" -type f 2>/dev/null | wc -l)
- **Feature Docs**: $(find docs/features/ -name "*.md" -type f 2>/dev/null | wc -l)
- **Testing Docs**: $(find docs/testing/ -name "*.md" -type f 2>/dev/null | wc -l)
- **Troubleshooting Docs**: $(find docs/troubleshooting/ -name "*.md" -type f 2>/dev/null | wc -l)

### File Structure
\`\`\`
docs/
├── README.md
├── development/
$(find docs/development/ -name "*.md" -type f 2>/dev/null | sed 's|^|│   ├── |' | sed 's|docs/development/||' || echo "│   └── (no files)")
├── features/
$(find docs/features/ -name "*.md" -type f 2>/dev/null | sed 's|^|│   ├── |' | sed 's|docs/features/||' || echo "│   └── (no files)")
├── testing/
$(find docs/testing/ -name "*.md" -type f 2>/dev/null | sed 's|^|│   ├── |' | sed 's|docs/testing/||' || echo "│   └── (no files)")
└── troubleshooting/
$(find docs/troubleshooting/ -name "*.md" -type f 2>/dev/null | sed 's|^|    ├── |' | sed 's|docs/troubleshooting/||' || echo "    └── (no files)")
\`\`\`

### Usage for AI Assistants

This documentation bundle provides comprehensive context for AI assistants to:

1. **Understand the Platform**: Complete feature overview and capabilities
2. **Assist with Development**: Development setup, testing, and deployment guides
3. **Help Users**: Feature usage guides and troubleshooting information
4. **Support Debugging**: Troubleshooting guides and common issue resolution
5. **Guide Implementation**: Technical implementation details and best practices

### Companion Resources

- **Complete Codebase**: \`aitana-codebase-complete.txt\`
- **API Documentation**: Included in development docs
- **Configuration Guides**: Included in development docs
- **Testing Framework**: Included in testing docs
- **Deployment Guides**: Included in development docs

### Access Pattern

AI assistants can reference this documentation to provide accurate, up-to-date
assistance with the Aitana platform. The documentation is automatically regenerated
on every deployment to ensure consistency with the current codebase.

---

# END OF DOCUMENTATION BUNDLE
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# Total Size: $(wc -c < "$OUTPUT_FILE" 2>/dev/null || echo "unknown") bytes

EOF

# Calculate final file size and statistics
if [ -f "$OUTPUT_FILE" ]; then
    file_size=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo "0")
    file_size_mb=$((file_size / 1024 / 1024))
    line_count=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")
    doc_count=$(find docs/ -name "*.md" -type f | wc -l)
    
    echo ""
    echo "✅ Documentation bundle generated successfully!"
    echo "📊 Statistics:"
    echo "  • File: $OUTPUT_FILE"
    echo "  • Size: ${file_size} bytes (~${file_size_mb}MB)"
    echo "  • Lines: ${line_count}"
    echo "  • Documentation Files: ${doc_count}"
    echo "  • Generated: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    echo "🎯 Ready for upload to Google Cloud Storage alongside codebase documentation."
else
    echo "❌ Error: Documentation bundle generation failed"
    exit 1
fi

echo "📋 Documentation bundle generation complete!"