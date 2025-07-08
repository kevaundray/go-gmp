#!/bin/bash

# Clean all build artifacts and generated files
# Usage: ./clean.sh

set -euo pipefail

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"


echo "Cleaning build artifacts..."

# Clean build directories
DIRS_TO_CLEAN=(
    "${PROJECT_ROOT}/build"
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

# The --all flag is no longer needed since we don't download archives

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
echo ""
echo "To rebuild:"
echo "  cd scripts && ./build-system-gmp.sh"
echo "========================================="