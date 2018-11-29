/*
 * mp_arith.c
 *
 */
#include <stdint.h>
// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
	uint32_t c = 0;
	uint32_t i = 0;
	for(i=0;i<size;i++) {
		uint64_t t = (uint64_t)a[i] + b[i] + c;
		res[i] = (uint32_t)t;
		if ((t >> 32) > 0) {
			c = 1;
		}
		else {
			c = 0;
		}

	}
	res[size] = c;
}

// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
	uint32_t c = 0;
	uint32_t i = 0;
	for(i=0;i<size;i++) {
		int64_t t = (int64_t)a[i] - b[i] - c;
		res[i] = (uint32_t)t;
		if ((t >> 32) > 0) {
			c = 0;
		}
		else {
			c = 1;
		}
	}
}

// Returns 1 if a is greater then or equal to b, returns 0 if a is smaller then b.
uint32_t mp_comp(int32_t *a, uint32_t *b, uint32_t size) {
	uint32_t i;
	if (a[size] != 0) {
		return 1;
	}
	for(i=size-1;i>=0;i--) {
		if (a[i] > b[i]) {
			return 1;
		} else if (a[i] < b[i]) {
			return 0;
		}
	}
	return 1;
}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t c = 0;
	uint32_t i = 0;
	for(i=0;i<size;i++) {
		uint64_t t = (uint64_t)a[i] + b[i] + c;
		res[i] = (uint32_t)t;
		if ((t >> 32) > 0) {
			c = 1;
		}
		else {
			c = 0;
		}
	}
	res[size] = c;
	if (mp_comp(res, N, size)) {
		mp_sub(res, N, res, size);
	}
}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{

}
