#ifndef ASM_MONT_H_
#define ASM_MONT_H_

#include <stdint.h>
#include "asm_mont_add.h"
#include "asm_conditional_sub.h"
void asm_mont_reduce_loop(uint32_t* t, uint32_t* res, uint32_t* n0, uint32_t* n, uint32_t SIZE);
void asm_mont_mul_loop(uint32_t *a, uint32_t *b, uint32_t *t, uint32_t SIZE);
#endif
