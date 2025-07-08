# Go-GMP: Wrapper for the GMP ModExp

A Go wrapper for GMP's modular exponentiation. The GMP library is statically linked and must be compiled.

## Installation

1. Build GMP static library:
```bash
cd scripts && ./build-static.sh
```

> NOTE: Since this doesn't use system GMP, the best way to use this library would be to include it as github sub-module instead and run the scripts locally.

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

## Building from Source

Requirements:
- Go 1.21+
- GCC
- wget (For downloading GMP and M4)

Build GMP:
```bash
cd scripts
./build-static.sh    # Downloads and builds GMP 6.3.0
./build_wrapper.sh   # Builds the C wrapper
```

Run tests:
```bash
go test -v
```

## License

This code is MIT/APACHE licensed. GMP is licensed under LGPL.