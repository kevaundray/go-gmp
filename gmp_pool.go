package gmp

// #include <gmp.h>
import "C"
import (
	"errors"
	"sync"
)

// IntPool provides a pool of reusable GMP Int objects to reduce allocations
type IntPool struct {
	pool sync.Pool
}

// NewIntPool creates a new pool for GMP Int objects
func NewIntPool() *IntPool {
	return &IntPool{
		pool: sync.Pool{
			New: func() interface{} {
				return NewInt()
			},
		},
	}
}

// Get retrieves an Int from the pool
func (p *IntPool) Get() *Int {
	return p.pool.Get().(*Int)
}

// Put returns an Int to the pool after clearing it
func (p *IntPool) Put(i *Int) {
	// Clear the Int to avoid keeping large numbers in memory
	i.SetUint64(0)
	p.pool.Put(i)
}

// ExpModPooled performs modular exponentiation using pooled Int objects
// This is useful for high-throughput scenarios where you want to minimize allocations
func ExpModPooled(pool *IntPool, base, exp, mod []byte) []byte {
	// Get Ints from pool
	baseInt := pool.Get()
	expInt := pool.Get()
	modInt := pool.Get()
	resultInt := pool.Get()
	
	// Ensure we return Ints to pool when done
	defer func() {
		pool.Put(baseInt)
		pool.Put(expInt)
		pool.Put(modInt)
		pool.Put(resultInt)
	}()
	
	// Set values
	baseInt.SetBytes(base)
	expInt.SetBytes(exp)
	modInt.SetBytes(mod)
	
	// Perform modular exponentiation
	resultInt.ExpMod(baseInt, expInt, modInt)
	
	// Get result bytes (this allocates, but much less than creating new Ints)
	return resultInt.Bytes()
}

// ModExpBytesPooled is a convenience function that creates a pool and uses it for a single operation
// For better performance, create a pool once and reuse it with ExpModPooled
func ModExpBytesPooled(base, exp, mod []byte) ([]byte, error) {
	// Validate inputs
	if len(mod) == 0 {
		return nil, ErrEmptyModulus
	}
	
	pool := NewIntPool()
	result := ExpModPooled(pool, base, exp, mod)
	return result, nil
}

// SetUint64 sets z to the value of x
func (z *Int) SetUint64(x uint64) *Int {
	C.mpz_set_ui(&z.mpz[0], C.ulong(x))
	return z
}


// PreallocatedExpMod performs modular exponentiation with pre-allocated Int objects
// This gives the caller full control over object lifecycle
func PreallocatedExpMod(result, base, exp, mod *Int) {
	result.ExpMod(base, exp, mod)
}

// Errors
var (
	ErrEmptyModulus = errors.New("modulus cannot be empty")
)