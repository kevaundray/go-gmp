#!/bin/bash

# Build GMP as a static library for better performance
# Usage: ./build-static.sh [version]
# Default version: 6.3.0

set -euo pipefail

GMP_VERSION="${1:-6.3.0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_PREFIX="${PROJECT_ROOT}/gmp-static"
BUILD_DIR="${PROJECT_ROOT}/build-gmp-tmp"

# Check if GMP is already built
if [ -f "${INSTALL_PREFIX}/lib/libgmp.a" ]; then
    echo "GMP ${GMP_VERSION} already built at ${INSTALL_PREFIX}"
    echo "To rebuild, run: rm -rf ${INSTALL_PREFIX}"
    exit 0
fi

echo "Building GMP ${GMP_VERSION} as static library..."

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Download GMP source if not already present
GMP_TARBALL="gmp-${GMP_VERSION}.tar.xz"
if [ ! -f "${GMP_TARBALL}" ]; then
    echo "Downloading GMP ${GMP_VERSION} source..."
    # Try primary mirror first, then GNU mirror
    for url in \
        "https://gmplib.org/download/gmp/${GMP_TARBALL}" \
        "https://ftp.gnu.org/gnu/gmp/${GMP_TARBALL}"; do
        if wget -q --timeout=30 "$url"; then
            echo "Downloaded from: $url"
            break
        fi
    done
    
    if [ ! -f "${GMP_TARBALL}" ]; then
        echo "Error: Failed to download GMP source from all mirrors"
        exit 1
    fi
fi

# Extract source
echo "Extracting GMP source..."
tar -xf "gmp-${GMP_VERSION}.tar.xz"
cd "gmp-${GMP_VERSION}"

# Check for m4 (GMP requires m4)
if ! command -v m4 &> /dev/null; then
    echo "m4 not found. Building it locally..."
    M4_VERSION="1.4.19"
    M4_TARBALL="m4-${M4_VERSION}.tar.gz"
    M4_PREFIX="${PROJECT_ROOT}/m4-local"
    
    cd ..
    if [ ! -f "${M4_TARBALL}" ]; then
        echo "Downloading m4 ${M4_VERSION}..."
        wget -q --timeout=30 "https://ftp.gnu.org/gnu/m4/${M4_TARBALL}" || {
            echo "Error: Failed to download m4"
            exit 1
        }
    fi
    
    tar -xzf "${M4_TARBALL}"
    cd "m4-${M4_VERSION}"
    
    ./configure --prefix="${M4_PREFIX}" --disable-dependency-tracking
    make -j${JOBS} >/dev/null 2>&1
    make install >/dev/null 2>&1
    
    cd "../gmp-${GMP_VERSION}"
    export PATH="${M4_PREFIX}/bin:$PATH"
    echo "Built m4 locally at ${M4_PREFIX}"
fi

# Configure for static library
echo "Configuring GMP for static build..."

# Use optimization flags
# Note: You can uncomment the aggressive flags below for better performance on your specific CPU
# export CFLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -funroll-loops -fPIC"
export CFLAGS="-O3 -fPIC"
export CPPFLAGS="-DNDEBUG"

CONFIGURE_OPTS=(
    "--prefix=${INSTALL_PREFIX}"
    "--enable-static"
    "--disable-shared"
    "--enable-fat"
    "--disable-dependency-tracking"
)

echo "Using optimization flags:"
echo "  CFLAGS: ${CFLAGS}"
echo "  CPPFLAGS: ${CPPFLAGS}"

./configure "${CONFIGURE_OPTS[@]}"

# Get number of cores, but limit to avoid OOM on systems with many cores
if command -v nproc &> /dev/null; then
    JOBS=$(nproc)
elif command -v sysctl &> /dev/null; then
    # macOS
    JOBS=$(sysctl -n hw.ncpu)
else
    # Fallback
    JOBS=4
fi

if [ "$JOBS" -gt 8 ]; then
    JOBS=8
fi

# Build
echo "Building GMP with ${JOBS} parallel jobs..."
make -j${JOBS}

echo "Installing GMP..."
make install

cd "${PROJECT_ROOT}"

# Clean up build directory
echo "Cleaning up build files..."
rm -rf "${BUILD_DIR}"

# Also clean up m4 if we built it
if [ -d "${PROJECT_ROOT}/m4-local" ]; then
    rm -rf "${PROJECT_ROOT}/m4-local"
fi

# Verify installation
if [ ! -f "${INSTALL_PREFIX}/lib/libgmp.a" ]; then
    echo "Error: GMP library was not built correctly"
    exit 1
fi

# Get library size
LIBSIZE=$(du -h "${INSTALL_PREFIX}/lib/libgmp.a" | cut -f1)

# Display summary
echo ""
echo "========================================="
echo "✓ GMP ${GMP_VERSION} static build complete!"
echo "Installation path: ${INSTALL_PREFIX}"
echo "Static library size: ${LIBSIZE}"
echo ""
echo "Next steps:"
echo "1. Build wrapper: cd scripts && ./build_wrapper.sh"
echo "2. Run tests: go test -v"
echo "========================================="