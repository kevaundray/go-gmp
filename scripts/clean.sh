#!/bin/bash

# Clean all build artifacts and generated files
# Usage: ./clean.sh [--all]
#   --all: Also removes downloaded source archives

set -euo pipefail

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Parse arguments
CLEAN_ALL=false
if [ $# -gt 0 ] && [ "$1" = "--all" ]; then
    CLEAN_ALL=true
fi

echo "Cleaning build artifacts..."

# Clean build directories
DIRS_TO_CLEAN=(
    "${PROJECT_ROOT}/gmp-static"
    "${PROJECT_ROOT}/build"
    "${PROJECT_ROOT}/build-gmp-tmp"
    "${PROJECT_ROOT}/m4-local"
)

for dir in "${DIRS_TO_CLEAN[@]}"; do
    if [ -d "$dir" ]; then
        echo "  Removing: $dir"
        rm -rf "$dir"
    fi
done

# Clean Go cache for this module
echo "  Cleaning Go build cache..."
cd "${PROJECT_ROOT}"
go clean -cache -testcache 2>/dev/null || true

# If --all flag is set, also remove downloaded archives
if [ "$CLEAN_ALL" = true ]; then
    echo "  Removing downloaded archives..."
    # Remove any GMP archives
    find "${PROJECT_ROOT}" -name "gmp-*.tar.xz" -type f -delete 2>/dev/null || true
    # Remove any m4 archives
    find "${PROJECT_ROOT}" -name "m4-*.tar.gz" -type f -delete 2>/dev/null || true
fi

# Count what was cleaned
CLEANED_COUNT=0
for dir in "${DIRS_TO_CLEAN[@]}"; do
    if [ ! -d "$dir" ]; then
        ((CLEANED_COUNT++)) || true
    fi
done

echo ""
echo "========================================="
echo "✓ Clean complete!"
echo "  Removed ${CLEANED_COUNT} directories"
if [ "$CLEAN_ALL" = true ]; then
    echo "  Removed downloaded archives"
fi
echo ""
echo "To rebuild:"
echo "  1. cd scripts && ./build-static.sh"
echo "  2. cd scripts && ./build_wrapper.sh"
echo "  3. go test -v"
echo "========================================="