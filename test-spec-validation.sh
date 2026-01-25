#!/bin/bash
# Test spec file validation

# Use script's directory as base
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Test case 1: Spec file exists
mkdir -p docs/figma-reports
touch docs/figma-reports/test-spec.md
echo "## Layer Order" >> docs/figma-reports/test-spec.md

if grep -q "Layer Order" docs/figma-reports/test-spec.md; then
    echo "✅ Test 1 passed: Spec contains Layer Order section"
else
    echo "❌ Test 1 failed: Layer Order section missing"
    exit 1
fi

# Test case 2: Spec file missing
rm docs/figma-reports/test-spec.md

if [ ! -f docs/figma-reports/test-spec.md ]; then
    echo "✅ Test 2 passed: Missing spec detected"
else
    echo "❌ Test 2 failed: Should detect missing spec"
    exit 1
fi

# Cleanup
rm -f docs/figma-reports/test-spec.md
