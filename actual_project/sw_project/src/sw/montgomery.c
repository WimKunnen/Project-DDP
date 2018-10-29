/*
 * montgomery.c
 *
 */

#include "montgomery.h"
#include "asm_montgomery.h"
#include "tests.h"

void mont(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n0, uint32_t *res, uint32_t SIZE)
{
	uint32_t t[2*SIZE+1];

	asm_mont_mul_loop(a, b, t, SIZE);

	//asm_mont_reduce_loop(t, res, n0, n, SIZE);
	asm_mont_reduction(t, res, n0, n);
	print_arr(res, 32);

	// sub_cond(res,n,SIZE);
	asm_cond_sub(res, n, SIZE);
}

void mont_add(uint32_t* t, uint32_t index, uint32_t c) {
	while(c != 0) {
		uint64_t sum = (uint64_t)c + (uint64_t)t[index];
		uint32_t s = (uint32_t)sum;
		c = (uint32_t)(sum >> 32);
		t[index] = s;
		index++;
	}
}

// Subtracts n from u if u >= n, result is stored in u.
void sub_cond(uint32_t* u, uint32_t* n, uint32_t size) {
	uint32_t b = 0;
	uint32_t index = 0;
	uint32_t t[size + 1];
	for(index=0;index<=size;index++) {
		t[index] = 0;
	}

	for(index=0;index<size;index++) {
		uint32_t sub = u[index] - n[index] - b;
		if (u[index] >= (uint64_t) n[index] + b) {
			b = 0;
		} else {
			b = 1;
		}
		t[index] = sub;
	}

	if (b == 0) {
		for(index=0;index<size;index++) {
			u[index] = t[index];
		}
	}
}
