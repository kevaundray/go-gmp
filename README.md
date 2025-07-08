# Go-GMP: Wrapper for the GMP ModExp

A Go wrapper for GMP's modular exponentiation. This version uses the system-installed GMP library.

## Prerequisites

You need to have GMP development libraries installed on your system:

- **Ubuntu/Debian**: `sudo apt-get install libgmp-dev`
- **Fedora/RHEL**: `sudo dnf install gmp-devel`
- **macOS**: `brew install gmp`

## Installation

1. Build the C wrapper:
```bash
cd scripts && ./build-system-gmp.sh
```

2. Install the Go package:
```bash
go get github.com/kevaundray/go-gmp
```

## Usage

### Direct GMP Interface

This wraps the GMP interface and allows for more flexibility.

```go
import "github.com/kevaundray/go-gmp"

// Create numbers
base := gmp.NewInt()
base.SetString("123456789", 10)

exp := gmp.NewInt()
exp.SetString("987654321", 10)

mod := gmp.NewInt()
mod.SetString("1000000007", 10)

// Compute base^exp mod mod
result := gmp.NewInt()
result.ExpMod(base, exp, mod)

fmt.Printf("Result: %s\n", result)
```

### Simple Byte-oriented ModExp Wrapper

This is a more restricted interface and only allows for modexp.

```go
// For simple one-off calculations with byte arrays
base := []byte{0xDE, 0xAD, 0xBE, 0xEF}
exp := []byte{0x01, 0x00, 0x01}  // 65537
mod := []byte{...} // your modulus

result, err := gmp.ModExpBytes(base, exp, mod)
if err != nil {
    log.Fatal(err)
}
// result is []byte
```

## Running Tests

### Local Testing
```bash
go test -v
```

### Docker Testing
Test in a fresh container without installing dependencies locally:

```bash
# Using the test script
./scripts/test-docker.sh

# Or manually with Docker
docker build -t go-gmp-test .
docker run --rm go-gmp-test

# Run benchmarks
docker run --rm go-gmp-test go test -bench=. -benchmem -run=^$
```

## License

This code is MIT/APACHE licensed. GMP is licensed under LGPL.