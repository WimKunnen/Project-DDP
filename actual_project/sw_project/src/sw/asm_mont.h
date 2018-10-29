#ifndef ASM_MONT_H_
#define ASM_MONT_H_

#include <stdint.h>
void asm_mont(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n0, uint32_t *res, uint32_t SIZE);
void asm_multiplication(uint32_t *a, uint32_t* b, uint32_t* t, uint32_t size);
void asm_mont_reduction(uint32_t* t, uint32_t* res, uint32_t* n0, uint32_t* n);
#endif
