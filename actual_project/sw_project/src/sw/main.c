/******************************************************************
 * This is the main file for the Software Sessions
 *
 */

#include <stdint.h>
#include <inttypes.h>

#include "common.h"
#include "mp_arith.h"
#include "montgomery.h"
#include "asm_func.h"
#include "asm_montgomery.h"
#include "asm_conditional_sub.h"
#include "tests.h"

//void print_arr(uint32_t* arr, uint32_t size) {
//	int32_t i;
//	xil_printf("0x");
//	for(i=size-1;i>=0;i--) {
//		xil_printf("%08x", arr[i]);
//	}
//	xil_printf("\r\n\r\n");
//}

int main()
{
    init_platform();
    init_performance_counters(1);

    xil_printf("Begin\n\r");

    test_montgomery();
    // Test assembly multiplication.
    if (test_asm_mul() != 0) {
    	xil_printf("Assembly multiplication tests failed.\r\n");
    }
    	
    // Test Montgomery algorithm.
//    if (test_montgomery() != 0) {
//    	xil_printf("Montgomery algorithm tests failed.\r\n");
//    }

	xil_printf("\r\nEnd\n\r");

    cleanup_platform();

    return 0;
}
