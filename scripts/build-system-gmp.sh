#!/bin/bash
set -e

# Build script for using system GMP library

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Building go-gmp with system GMP library..."

# Change to project root
cd "$PROJECT_ROOT"

# Create build directory if it doesn't exist
mkdir -p build

# Check if system GMP is installed
echo "Checking for GMP installation..."

# Try to find GMP header
GMP_INCLUDE=""
if pkg-config --exists gmp 2>/dev/null; then
    GMP_INCLUDE=$(pkg-config --cflags gmp)
    echo "Found GMP via pkg-config"
elif [ -f /usr/include/gmp.h ]; then
    GMP_INCLUDE="-I/usr/include"
    echo "Found GMP in /usr/include"
elif [ -f /usr/local/include/gmp.h ]; then
    GMP_INCLUDE="-I/usr/local/include"
    echo "Found GMP in /usr/local/include"
else
    echo "Error: GMP header (gmp.h) not found on system"
    echo "Please install GMP development package:"
    echo "  Ubuntu/Debian: sudo apt-get install libgmp-dev"
    echo "  Fedora/RHEL: sudo dnf install gmp-devel"
    echo "  macOS: brew install gmp"
    exit 1
fi

# Compile the C wrapper
echo "Compiling C wrapper..."
cd c
gcc -c -fPIC -O3 -Wall -Wextra $GMP_INCLUDE gmp_wrapper.c -o ../build/gmp_wrapper.o
cd ..

# Note: We don't need to create a static library for the wrapper when using system GMP
# The Go linker will handle linking both the wrapper object file and system GMP

echo "Build complete!"
echo "You can now use 'go build' or 'go test' commands."