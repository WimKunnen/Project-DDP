#include <stdint.h>
#include "common.h"
#include "asm_montgomery.h"

// a and b of length SIZE and t of length 2*SIZE
void multiply_reference(uint32_t* a, uint32_t* b, uint32_t* t, uint32_t SIZE) {
	uint32_t i;
	uint32_t j;
	for(i=0;i<2*SIZE+1;i++){
		t[i] = 0;
	}
	for(i=0; i<SIZE; i++)
	{
		uint32_t c = 0;
		for(j=0;j<SIZE;j++){
			uint64_t sum = (uint64_t)t[i+j] + (uint64_t)a[j] * (uint64_t)b[i] + (uint64_t)c;
			uint32_t s = (uint32_t)sum;
			c = (uint32_t)(sum >> 32);
			t[i+j] = s;
		}
		t[i+SIZE] = c;
	}
}

void print_arr(uint32_t* arr, uint32_t size) {
	int32_t i;
	xil_printf("0x");
	for(i=size-1;i>=0;i--) {
		xil_printf("%08x", arr[i]);
	}
	xil_printf("\r\n\r\n");
}

int compare(uint32_t* cmp, uint32_t* expected, uint32_t size) {
	uint32_t i;
	for(i=0; i<size; i++) {
		if(cmp[i] != expected[i]) {
			xil_printf("Exp: ");
			print_arr(expected, size);
			xil_printf("Got: ");
			print_arr(cmp, size);
			return 1;
		}
	}
	return 0;
}

int test_asm_mul() {
	uint32_t result[8];
	uint32_t a[4] = {0x2c4f70b8, 0xacbfddee, 0x0e2b9e8a, 0xc29b1894};
	uint32_t b[4] = {0x7b02886a, 0x466bab9c, 0x93235825, 0x58a33b52};
	uint32_t expected[8] = {0xd6366c30, 0x1e1a880f, 0x0094f7ad, 0xce86f14d, 0x63a40ae9, 0x3bf760f5, 0x0f55f049, 0x4361664c};
	asm_mont_mul_loop(a, b, result, 4);

	if (compare(result, expected, 8) != 0) {
		xil_printf("First test failed.\r\n");
		return 1;
	}
	return 0;
}

void test() {
	xil_printf("Starting tests...\r\n");
	
	if (test_asm_mul() != 0) {
		xil_printf("Assembly multiplication tests failed.\r\n");
	}
}
