#!/bin/bash
set -e

echo "Building Docker image..."
docker build -t go-gmp-test .

echo ""
echo "Running tests in Docker container..."
docker run --rm go-gmp-test

echo ""
echo "Running benchmarks..."
docker run --rm go-gmp-test go test -bench=. -benchmem -run=^$

echo ""
echo "Test completed successfully!"