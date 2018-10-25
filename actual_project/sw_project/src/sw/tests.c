#include <stdint.h>

// a and b of length SIZE and t of length 2*SIZE+1
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

void test_reference() {

}

void test() {

}
