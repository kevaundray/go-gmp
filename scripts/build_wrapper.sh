#!/bin/bash

# Build the GMP wrapper library
# This wrapper provides a simple C interface for modular exponentiation

set -euo pipefail

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GMP_STATIC_DIR="${PROJECT_ROOT}/gmp-static"
BUILD_DIR="${PROJECT_ROOT}/build"
C_DIR="${PROJECT_ROOT}/c"

echo "Building GMP wrapper library..."

# Check if wrapper is already built
if [ -f "${BUILD_DIR}/libgmp_wrapper.a" ] && [ -f "${BUILD_DIR}/gmp_wrapper.h" ]; then
    echo "Wrapper already built at ${BUILD_DIR}"
    echo "To rebuild, run: rm -rf ${BUILD_DIR}"
    exit 0
fi

# Ensure GMP is built first
if [ ! -f "${GMP_STATIC_DIR}/lib/libgmp.a" ]; then
    echo "GMP static library not found. Building it first..."
    "${SCRIPT_DIR}/build-static.sh" || {
        echo "Error: Failed to build GMP"
        exit 1
    }
fi

# Verify source files exist
if [ ! -f "${C_DIR}/gmp_wrapper.c" ] || [ ! -f "${C_DIR}/gmp_wrapper.h" ]; then
    echo "Error: C wrapper source files not found in ${C_DIR}"
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Detect compiler
if command -v clang >/dev/null 2>&1; then
    CC="clang"
elif command -v gcc >/dev/null 2>&1; then
    CC="gcc"
else
    echo "Error: No C compiler found (gcc or clang required)"
    exit 1
fi

echo "Using compiler: ${CC}"

# Compile the wrapper
echo "Compiling gmp_wrapper.c..."
CFLAGS=(
    "-c"
    "-O3"
    "-Wall"
    "-Wextra"
    "-Werror"
    "-std=c89"
    "-pedantic"
    "-fPIC"
    "-I${GMP_STATIC_DIR}/include"
)

"${CC}" "${CFLAGS[@]}" "${C_DIR}/gmp_wrapper.c" -o "${BUILD_DIR}/gmp_wrapper.o" || {
    echo "Error: Compilation failed"
    exit 1
}

# Create static library
echo "Creating static library..."
ar rcs "${BUILD_DIR}/libgmp_wrapper.a" "${BUILD_DIR}/gmp_wrapper.o" || {
    echo "Error: Failed to create static library"
    exit 1
}

# Copy header to build directory
cp "${C_DIR}/gmp_wrapper.h" "${BUILD_DIR}/" || {
    echo "Error: Failed to copy header file"
    exit 1
}

# Clean up object file
rm -f "${BUILD_DIR}/gmp_wrapper.o"

# Verify the library was created correctly
if [ ! -f "${BUILD_DIR}/libgmp_wrapper.a" ]; then
    echo "Error: Library was not created successfully"
    exit 1
fi

# Get library size
LIBSIZE=$(du -h "${BUILD_DIR}/libgmp_wrapper.a" | cut -f1)

# Display summary
echo ""
echo "========================================="
echo "✓ GMP wrapper library built successfully!"
echo ""
echo "Build output:"
echo "  Library: ${BUILD_DIR}/libgmp_wrapper.a (${LIBSIZE})"
echo "  Header:  ${BUILD_DIR}/gmp_wrapper.h"
echo ""
echo "Compiler flags used:"
echo "  ${CC} ${CFLAGS[*]}"
echo ""
echo "To use in Go:"
echo "  The wrapper is automatically linked by gmp_wrapper.go"
echo ""
echo "Next step: go test -v"
echo "========================================="