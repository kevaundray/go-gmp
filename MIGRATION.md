# Migration Guide: From Static GMP to System GMP

This branch modifies go-gmp to use the system-installed GMP library instead of compiling GMP from source.

## Changes Made

1. **Modified CGO directives** in `gmp_wrapper.go`:
   - Changed from linking static libraries to linking system GMP
   - Now uses `-lgmp` flag to link against system library

2. **Created new build script** `scripts/build-system-gmp.sh`:
   - Only compiles the C wrapper
   - Checks for system GMP installation
   - No longer downloads or compiles GMP from source

3. **Updated README.md**:
   - Added prerequisites section for system GMP installation
   - Removed GMP compilation instructions
   - Simplified installation process

## Benefits

- **Faster builds**: No need to compile GMP from source
- **Smaller repository**: No GMP source code or build artifacts
- **System integration**: Uses OS-maintained GMP library
- **Security updates**: Automatically gets system GMP security updates

## Prerequisites

Before using this version, install GMP development libraries:

- **Ubuntu/Debian**: `sudo apt-get install libgmp-dev`
- **Fedora/RHEL**: `sudo dnf install gmp-devel`
- **macOS**: `brew install gmp`

## Building

```bash
cd scripts
./build-system-gmp.sh
```

## Testing

After building, run tests as usual:
```bash
go test -v
```