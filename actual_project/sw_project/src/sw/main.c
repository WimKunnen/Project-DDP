#include "common.h"

#include "hw_accelerator.h"

// These variables are defined in the testvector.c
// that is created by the testvector generator python script
extern uint32_t N[32],		// modulus
                e[32],		// encryption exponent
                e_len,		// encryption exponent length
                d[32],		// decryption exponent
                d_len,		// decryption exponent length
                M[32],		// message
                R_1024[32],	// 2^1024 mod N
                R2_1024[32];// (2^1024)^2 mod N

int main()
{
    init_platform();
    init_performance_counters(1);

    xil_printf("Begin\n\r");

START_TIMING
    	xil_printf("Hello World\n\r");
STOP_TIMING

	xil_printf("If the FPGA is not programmed, the program will stuck here!\n\r");


    init_HW_access();
	xil_printf("It did not stuck and HW is initialized!\n\r");


    example_HW_accelerator();


    xil_printf("End\n\r");

    cleanup_platform();

    return 0;
}
