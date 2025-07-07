#include "gmp_wrapper.h"
#include <gmp.h>
#include <string.h>

int modexp_bytes(
    const uint8_t* base, size_t base_len,
    const uint8_t* exp, size_t exp_len,
    const uint8_t* mod, size_t mod_len,
    uint8_t* result, size_t* result_len)
{
    mpz_t mpz_base, mpz_exp, mpz_mod, mpz_result;
    size_t count;
    int ret = 0;
    
    /* Validate parameters */
    if (!base || !exp || !mod || !result || !result_len) {
        return -1;
    }
    
    if (*result_len < mod_len) {
        return -2;
    }
    
    /* Initialize GMP variables */
    mpz_init(mpz_base);
    mpz_init(mpz_exp);
    mpz_init(mpz_mod);
    mpz_init(mpz_result);
    
    /* Import byte arrays into GMP integers */
    if (base_len > 0) {
        mpz_import(mpz_base, base_len, 1, 1, 0, 0, base);
    }
    
    if (exp_len > 0) {
        mpz_import(mpz_exp, exp_len, 1, 1, 0, 0, exp);
    }
    
    if (mod_len > 0) {
        mpz_import(mpz_mod, mod_len, 1, 1, 0, 0, mod);
    }
    
    /* Check for zero modulus */
    if (mpz_sgn(mpz_mod) == 0) {
        ret = -1;
        goto cleanup;
    }
    
    /* Perform modular exponentiation */
    mpz_powm(mpz_result, mpz_base, mpz_exp, mpz_mod);
    
    /* Export result to byte array */
    if (mpz_sgn(mpz_result) == 0) {
        /* Handle zero result - return single zero byte */
        if (*result_len < 1) {
            ret = -2;
            goto cleanup;
        }
        result[0] = 0;
        *result_len = 1;
    } else {
        /* Calculate actual size needed */
        size_t actual_size = (mpz_sizeinbase(mpz_result, 2) + 7) / 8;
        
        if (actual_size > *result_len) {
            ret = -2;
            goto cleanup;
        }
        
        /* Export to buffer */
        mpz_export(result, &count, 1, 1, 0, 0, mpz_result);
        *result_len = count;
    }
    
cleanup:
    /* Clean up GMP variables */
    mpz_clear(mpz_base);
    mpz_clear(mpz_exp);
    mpz_clear(mpz_mod);
    mpz_clear(mpz_result);
    
    return ret;
}