#!/bin/bash

# Build everything: GMP static library and wrapper
# Usage: ./build-all.sh [gmp-version]

set -euo pipefail

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building all components..."
echo ""

# Build GMP static library
"${SCRIPT_DIR}/build-static.sh" "$@"
echo ""

# Build wrapper
"${SCRIPT_DIR}/build_wrapper.sh"
echo ""

# Run tests
echo "Running tests..."
cd "${SCRIPT_DIR}/.."
if go test -v; then
    echo ""
    echo "========================================="
    echo "✓ All components built and tested successfully!"
    echo "========================================="
else
    echo ""
    echo "========================================="
    echo "✗ Tests failed!"
    echo "========================================="
    exit 1
fi