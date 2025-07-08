# Use Ubuntu as base image to match CI environment
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libgmp-dev \
    pkg-config \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go
ENV GO_VERSION=1.23.0
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Build the C wrapper
RUN cd scripts && ./build-system-gmp.sh

# Run tests
CMD ["go", "test", "-v", "./..."]