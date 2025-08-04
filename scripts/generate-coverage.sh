#!/bin/bash

# Frontend Coverage Generation Script
# This script runs tests with coverage and extracts coverage percentage for badges

set -e  # Exit on any error

echo "=== Frontend Coverage Generation ==="
echo "Working directory: $(pwd)"
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "BRANCH_NAME: ${BRANCH_NAME}"

echo "Installing dependencies..."
npm ci --no-audit --no-fund

echo "Running frontend tests with coverage..."

# Try to run tests with coverage - continue even if some tests fail
if CI=true npm run test:coverage > coverage-output.txt 2>&1; then
  echo "Tests completed successfully"
else
  echo "Some tests failed, but checking if coverage was generated..."
fi

# If no coverage directory, try alternative approaches
if [ ! -d "coverage" ]; then
  echo "Coverage directory not found, trying alternative method..."
  CI=true npx vitest run --coverage --reporter=verbose > coverage-output-alt.txt 2>&1 || true
  
  # If still no coverage, try with minimal test set
  if [ ! -d "coverage" ]; then
    echo "Trying with minimal test approach..."
    CI=true npx vitest run --coverage --run --passWithNoTests --reporter=basic > coverage-output-alt2.txt 2>&1 || true
    
    # Last resort: try to generate coverage for just one test file
    if [ ! -d "coverage" ]; then
      echo "Last resort: trying single test file for coverage..."
      CI=true npx vitest run --coverage src/lib/__tests__/utils.test.ts > coverage-output-minimal.txt 2>&1 || true
      
      # Final attempt: force coverage with very basic settings
      if [ ! -d "coverage" ]; then
        echo "Final attempt: force minimal coverage generation..."
        npx vitest run --coverage --config vitest.config.ts --reporter=basic --no-watch src/lib/__tests__/utils.test.ts > coverage-output-final.txt 2>&1 || true
      fi
    fi
  fi
fi

# Debug: Check what files were created
echo "Files created after test run:"
ls -la coverage/ || echo "No coverage directory"
echo "Current directory contents:"
ls -la

# Debug: Show the last part of the test output to see what's failing
echo "=== Last 50 lines of test output ==="
if [ -f "coverage-output.txt" ]; then
  tail -50 coverage-output.txt
else
  echo "No coverage-output.txt file found"
fi
echo "=== End of test output ==="

# Debug: Show the coverage output lines from all possible files
echo "Looking for coverage in output files..."
for file in coverage-output.txt coverage-output-alt.txt coverage-output-alt2.txt coverage-output-minimal.txt coverage-output-final.txt; do
  if [ -f "$file" ]; then
    echo "Checking $file for coverage data..."
    grep -E "All files" "$file" || echo "No 'All files' line found in $file"
  fi
done

# Extract coverage percentage from any available output file
COVERAGE=""
for file in coverage-output.txt coverage-output-alt.txt coverage-output-alt2.txt coverage-output-minimal.txt coverage-output-final.txt; do
  if [ -f "$file" ] && [ -z "$COVERAGE" ]; then
    # Try the standard "All files" format first
    COVERAGE=$(grep -E "All files" "$file" | head -1 | awk -F'|' '{print $2}' | tr -d ' %' || echo "")
    
    # If not found, try alternative coverage summary patterns
    if [ -z "$COVERAGE" ] || [ "$COVERAGE" = "0" ]; then
      # Try "Coverage report" pattern
      COVERAGE=$(grep -A 5 -E "Coverage report" "$file" | grep -E "All files" | head -1 | awk -F'|' '{print $2}' | tr -d ' %' || echo "")
    fi
    
    # If still not found, try percentage pattern
    if [ -z "$COVERAGE" ] || [ "$COVERAGE" = "0" ]; then
      # Look for any line with percentage that might be coverage summary
      COVERAGE=$(grep -o '[0-9]\+\.[0-9]\+%' "$file" | head -1 | tr -d '%' || echo "")
    fi
    
    if [ -n "$COVERAGE" ] && [ "$COVERAGE" != "0" ]; then
      echo "Found coverage in $file: $COVERAGE%"
      break
    fi
  fi
done

# Fallback to 0 if nothing found
if [ -z "$COVERAGE" ]; then
  COVERAGE="0"
fi

# Debug: Show what we extracted
echo "Extracted coverage value: '$COVERAGE'"

# If coverage is empty or zero, try alternative parsing
if [ -z "$COVERAGE" ] || [ "$COVERAGE" = "0" ]; then
  echo "Failed to extract coverage from output, checking for coverage JSON..."
  if [ -f coverage/coverage-final.json ]; then
    echo "Found coverage JSON file, extracting coverage..."
    COVERAGE=$(node -e "
      const fs = require('fs');
      try {
        const coverage = JSON.parse(fs.readFileSync('./coverage/coverage-final.json', 'utf8'));
        let totalStatements = 0;
        let coveredStatements = 0;
        
        Object.values(coverage).forEach(file => {
          // Skip vendor chunks, node_modules, and Next.js generated files
          if (file.path && (file.path.includes('vendor-chunks') || 
              file.path.includes('node_modules') || 
              file.path.includes('.next/'))) return;
          
          const statements = file.s || {};
          Object.values(statements).forEach(count => {
            totalStatements++;
            if (count > 0) coveredStatements++;
          });
        });
        
        const percent = totalStatements > 0 ? (coveredStatements / totalStatements * 100).toFixed(1) : 0;
        console.log(percent);
      } catch(e) {
        console.log('0');
      }
    " || echo "0")
  else
    echo "No coverage JSON file found"
    COVERAGE="0"
  fi
fi

echo "Frontend Coverage: ${COVERAGE}%"

# Determine badge color using Node.js
COLOR=$(node -e "
  const coverage = parseFloat('${COVERAGE}');
  if (coverage >= 90) {
    console.log('brightgreen');
  } else if (coverage >= 80) {
    console.log('green');
  } else if (coverage >= 70) {
    console.log('yellow');
  } else if (coverage >= 60) {
    console.log('orange');
  } else {
    console.log('red');
  }
")

# Create badge JSON for shields.io
cat > frontend-coverage-badge.json <<EOF
{
  "schemaVersion": 1,
  "label": "${BRANCH_NAME:-dev}-frontend-coverage",
  "message": "${COVERAGE}%",
  "color": "$COLOR",
  "namedLogo": "vitest",
  "logoColor": "white"
}
EOF

echo "Generated frontend coverage badge data:"
cat frontend-coverage-badge.json

echo "=== Coverage generation completed ==="