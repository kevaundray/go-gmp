#ifndef GMP_WRAPPER_H
#define GMP_WRAPPER_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Perform modular exponentiation: result = base^exp mod mod
 * 
 * @param base     Base number as big-endian byte array
 * @param base_len Length of base array
 * @param exp      Exponent as big-endian byte array
 * @param exp_len  Length of exponent array
 * @param mod      Modulus as big-endian byte array
 * @param mod_len  Length of modulus array
 * @param result   Output buffer for result (must be at least mod_len bytes)
 * @param result_len On input: size of result buffer
 *                   On output: actual length of result
 * 
 * @return 0 on success, negative error code on failure
 *         -1: Invalid parameter (NULL pointer or zero modulus)
 *         -2: Result buffer too small
 *         -3: Memory allocation failure
 */
int modexp_bytes(
    const uint8_t* base, size_t base_len,
    const uint8_t* exp, size_t exp_len,
    const uint8_t* mod, size_t mod_len,
    uint8_t* result, size_t* result_len
);

#ifdef __cplusplus
}
#endif

#endif /* GMP_WRAPPER_H */
