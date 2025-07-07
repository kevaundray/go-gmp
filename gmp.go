package gmp

// Static linking with full GMP for maximum performance
// Build GMP first: ./build-static.sh

// #cgo CFLAGS: -I./gmp-static/include
// #cgo LDFLAGS: ${SRCDIR}/gmp-static/lib/libgmp.a
// #include <gmp.h>
// #include <stdlib.h>
// 
// static inline int mpz_sgn_wrapper(const mpz_t op) {
//     return mpz_sgn(op);
// }
import "C"
import (
	"runtime"
	"unsafe"
)

// Int represents a GMP integer
type Int struct {
	mpz C.mpz_t
}

// NewInt creates a new GMP integer
func NewInt() *Int {
	z := &Int{}
	C.mpz_init(&z.mpz[0])
	runtime.SetFinalizer(z, (*Int).destroy)
	return z
}

// destroy cleans up the GMP integer
func (z *Int) destroy() {
	C.mpz_clear(&z.mpz[0])
}

// SetString sets the integer from a string in the given base
func (z *Int) SetString(s string, base int) (*Int, bool) {
	cs := C.CString(s)
	defer C.free(unsafe.Pointer(cs))
	
	if C.mpz_set_str(&z.mpz[0], cs, C.int(base)) != 0 {
		return nil, false
	}
	return z, true
}

// ExpMod computes z = base^exp mod mod (modular exponentiation)
func (z *Int) ExpMod(base, exp, mod *Int) *Int {
	C.mpz_powm(&z.mpz[0], &base.mpz[0], &exp.mpz[0], &mod.mpz[0])
	return z
}

// SetBytes sets z to the value of buf interpreted as a big-endian unsigned integer
func (z *Int) SetBytes(buf []byte) *Int {
	if len(buf) == 0 {
		C.mpz_set_ui(&z.mpz[0], 0)
		return z
	}
	
	// Use GMP's import function for efficiency
	C.mpz_import(&z.mpz[0], C.size_t(len(buf)), 1, 1, 0, 0, unsafe.Pointer(&buf[0]))
	return z
}

// Bytes returns the absolute value of z as a big-endian byte slice
func (z *Int) Bytes() []byte {
	if z == nil {
		return nil
	}
	
	// Special case: zero returns empty slice (matching big.Int)
	if C.mpz_sgn_wrapper(&z.mpz[0]) == 0 {
		return []byte{}
	}
	
	// Get the number of bytes needed
	size := (C.mpz_sizeinbase(&z.mpz[0], 2) + 7) / 8
	
	// Allocate buffer
	buf := make([]byte, size)
	
	// Export to bytes
	var count C.size_t
	C.mpz_export(unsafe.Pointer(&buf[0]), &count, 1, 1, 0, 0, &z.mpz[0])
	
	// Trim if needed (shouldn't happen but just in case)
	if int(count) < len(buf) {
		buf = buf[:count]
	}
	
	return buf
}

// String returns the decimal representation of z
func (z *Int) String() string {
	if z == nil {
		return "<nil>"
	}
	
	// Get string from GMP
	cs := C.mpz_get_str(nil, 10, &z.mpz[0])
	defer C.free(unsafe.Pointer(cs))
	
	return C.GoString(cs)
}