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

void print_arr(uint32_t* arr, uint32_t size) {
	int32_t i;
	xil_printf("0x");
	for(i=size-1;i>=0;i--) {
		xil_printf("%08x", arr[i]);
	}
	xil_printf("\r\n\r\n");
}

int main()
{
    init_platform();
    init_performance_counters(1);

    xil_printf("Begin\n\r");

    uint32_t a[32] = {0xf484e847, 0x4ae251f1, 0xedfa617d, 0x58ab6bf4, 0x46bf4848, 0xf67c1061, 0x8811c17a, 0x578fde16, 0x493ee595, 0x1eafc4c3, 0xc4f11a2e, 0x8cb6fba7, 0x724c03a4, 0x2e6c1dbd, 0x57ebc43d, 0x3e6ee260, 0x4089c050, 0xf0384e03, 0x7357f72c, 0x87acb658, 0x7ea2490e, 0x61069112, 0x42e3f8b9, 0x9e778cef, 0x5cdf77c7, 0x10bce41c, 0x1121beec, 0x3db59a36, 0xc34620c5, 0xc6b030ae, 0xe8fc5934, 0x63a0a0cb};
    uint32_t b[32] = {0xfeb1b9f4, 0xe91d3bec, 0xfb09354d, 0x07f21d6d, 0x9ece9e1b, 0x18def18b, 0x4119e1e9, 0x55c85f24, 0x60ef0e23, 0x10e8ab54, 0x1e95cdcc, 0x4373912f, 0x6f42204d, 0x7126650d, 0xb61c1c8d, 0x98af9011, 0xa42c03b4, 0xd29e0870, 0x7923cb60, 0xdf87cfe5, 0xde4fffa0, 0x3ce537ca, 0x201040c6, 0x6e54b058, 0x814c53dc, 0xf16243f0, 0x57decf64, 0x8d0d4f37, 0x9b6d93e5, 0x45396d71, 0x615213c4, 0x65f89f9f};
    uint32_t N[32] = {0x4aeeb107, 0x5d78aa98, 0x6c55dd05, 0x6f5326c9, 0xf93f738c, 0xc10fa093, 0x20478120, 0x099d6d70, 0x833d9b82, 0x1248f3ed, 0xa43ed737, 0xc1c1da45, 0x9f23e5c7, 0xb17c3598, 0xe8938df6, 0x7ae59036, 0x9f84d87b, 0xc8710dc6, 0x249ee0f8, 0x46eeae2f, 0x66a3bb9b, 0xfeef4c6b, 0xc7b55eae, 0x7951dd0c, 0x0b4391e8, 0x141ad586, 0x1a568588, 0x908293dd, 0x472c0bea, 0x8d00abfe, 0xed17377f, 0x83a01efe};
    uint32_t n_prime[32] = {0xe7d41349, 0x0c828dcd, 0x2dc06d90, 0x318f87bf, 0x1992ba09, 0x4b1bef10, 0x011ba664, 0xe3a7d9cf, 0x44449fbd, 0x89714d34, 0x6cd49cc4, 0x49c5b99d, 0xf90435b1, 0x38f037b7, 0xba9720db, 0x9641b106, 0xbca01d2a, 0xfdb82893, 0xbd7ce9c7, 0x372823e1, 0x4901cdde, 0xaa28d457, 0xe9f78c94, 0xb6e1e5b3, 0x5a79f7a6, 0xf5212a83, 0x2b1aab45, 0xa3924b69, 0x3c63a8af, 0x12fa121d, 0x7500bea0, 0xe58878e7};
    uint32_t res[33];
START_TIMING
	mont(a,b, N,n_prime, res,32);
STOP_TIMING
	print_arr(res, 33);

	xil_printf("\r\nEnd\n\r");

    cleanup_platform();

    return 0;
}
