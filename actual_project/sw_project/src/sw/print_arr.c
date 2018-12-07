#include "common.h"


void print_arr(uint32_t* arr, uint32_t size) {
	int32_t i;
	xil_printf("0x");
	for(i=size-1;i>=0;i--) {
		xil_printf("%08x", arr[i]);
	}
	xil_printf("\r\n\r\n");
}

int compare_arr(uint32_t* first, uint32_t* second, uint32_t size) {
	int32_t i;
	for(i=0;i<size;i++) {
		if (first[i] != second[i])
			return 0;
	}
	return 1;
}
