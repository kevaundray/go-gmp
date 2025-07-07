package gmp

// #cgo CFLAGS: -I./c -I./build
// #cgo LDFLAGS: ${SRCDIR}/build/libgmp_wrapper.a ${SRCDIR}/gmp-static/lib/libgmp.a
// #include "gmp_wrapper.h"
import "C"
import (
	"errors"
	"unsafe"
)

// ModExpBytes performs modular exponentiation on byte arrays
// result = base^exp mod mod
func ModExpBytes(base, exp, mod []byte) ([]byte, error) {
	// Validate inputs
	if len(mod) == 0 {
		return nil, errors.New("modulus cannot be empty")
	}
	
	// Allocate result buffer (size of modulus is the max possible result)
	result := make([]byte, len(mod))
	resultLen := C.size_t(len(result))
	
	// Handle empty slices - pass a dummy non-nil pointer with length 0
	dummy := C.uint8_t(0)
	var basePtr, expPtr, modPtr *C.uint8_t = &dummy, &dummy, &dummy
	
	if len(base) > 0 {
		basePtr = (*C.uint8_t)(unsafe.Pointer(&base[0]))
	}
	if len(exp) > 0 {
		expPtr = (*C.uint8_t)(unsafe.Pointer(&exp[0]))
	}
	if len(mod) > 0 {
		modPtr = (*C.uint8_t)(unsafe.Pointer(&mod[0]))
	}
	
	// Call C function
	ret := C.modexp_bytes(
		basePtr, C.size_t(len(base)),
		expPtr, C.size_t(len(exp)),
		modPtr, C.size_t(len(mod)),
		(*C.uint8_t)(unsafe.Pointer(&result[0])), &resultLen,
	)
	
	// Check for errors
	switch ret {
	case 0:
		// Success - trim result to actual size
		return result[:resultLen], nil
	case -1:
		return nil, errors.New("invalid parameter or zero modulus")
	case -2:
		return nil, errors.New("result buffer too small")
	case -3:
		return nil, errors.New("memory allocation failure")
	default:
		return nil, errors.New("unknown error")
	}
}