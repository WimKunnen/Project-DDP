#include "common.h"
#include "print_arr.h"
#include "hw_accelerator.h"
#include "xpseudo_asm_gcc.h"

// These variables are defined in the testvectors.c
extern uint32_t N_1[32], e_1[32], e_len_1, d_1[32], d_len_1, M_1[32], R_N_1[32], R2_N_1[32];
extern uint32_t N_2[32], e_2[32], e_len_2, d_2[32], d_len_2, M_2[32], R_N_2[32], R2_N_2[32];
extern uint32_t N_3[32], e_3[32], e_len_3, d_3[32], d_len_3, M_3[32], R_N_3[32], R2_N_3[32];
extern uint32_t N_4[32], e_4[32], e_len_4, d_4[32], d_len_4, M_4[32], R_N_4[32], R2_N_4[32];
extern uint32_t N_5[32], e_5[32], e_len_5, d_5[32], d_len_5, M_5[32], R_N_5[32], R2_N_5[32];

// These functions are defined at the bottom of this file.
void test_2018_1();
void test_2018_2();
void test_2018_3();
void test_2018_4();
void test_2018_5();

int main()
{
    init_platform();
    init_performance_counters(1);

    xil_printf("Begin\n\r");
	xil_printf("If the FPGA is not programmed, the program will stuck here!\n\r");

    init_HW_access();
	xil_printf("It did not stuck and HW is initialized!\n\r");

	test_2018_1();
	test_2018_2();
	getchar();
	test_2018_3();
	getchar();
	test_2018_4();
	getchar();
	test_2018_5();
	xil_printf("Finished running all tests.\n\r");

    xil_printf("End\n\r");

    cleanup_platform();

    return 0;
}

void test_2018_1() {
	xil_printf("######################\r\n");
	xil_printf("# Seed 2018.1 tests: #\r\n");
	xil_printf("######################\r\n");
	uint32_t result[32];
	uint32_t i;
	for(i=0;i<32;i++) {
		result[i] = 0;
	}

	//Encrypt
	xil_printf("Encryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(e_1, M_1, R_N_1, R2_N_1, N_1, result, e_len_1);
	dmb();
	dsb();
	isb();
	STOP_TIMING
	xil_printf(" -> Encrypted cipher text:\r\n");
	print_arr(result, 32);

    //Decrypt
	xil_printf("Decryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(d_1, result, R_N_1, R2_N_1, N_1, result, d_len_1);
    dmb();
    dsb();
    isb();
    STOP_TIMING

    xil_printf(" -> Decrypted result:\r\n");
    print_arr(result, 32);

    // Compare original and result
    if (compare_arr(M_1, result, 32) == 1)
    	xil_printf("SUCCESS: Decrypted message is equal to original message!\r\n");
    else
    	xil_printf("FAILURE: Decrypted message is not equal to original message!\r\n");

    dmb();
    dsb();
    isb();
    xil_printf("Send any character to run next test. (e.g. press a + enter) \r\n");
    getchar();
}

void test_2018_2() {
	xil_printf("######################\r\n");
	xil_printf("# Seed 2018.2 tests: #\r\n");
	xil_printf("######################\r\n");
	uint32_t result[32];
	uint32_t i;
	for(i=0;i<32;i++) {
		result[i] = 0;
	}

	//Encrypt
	xil_printf("Encryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(e_2, M_2, R_N_2, R2_N_2, N_2, result, e_len_2);
	dmb();
	dsb();
	isb();
	STOP_TIMING
	xil_printf(" -> Encrypted cipher text:\r\n");
	print_arr(result, 32);

    //Decrypt
	xil_printf("Decryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(d_2, result, R_N_2, R2_N_2, N_2, result, d_len_2);
    dmb();
    dsb();
    isb();
    STOP_TIMING

    xil_printf(" -> Decrypted result:\r\n");
    print_arr(result, 32);

    // Compare original and result
    if (compare_arr(M_2, result, 32) == 1)
    	xil_printf("SUCCESS: Decrypted message is equal to original message!\r\n");
    else
    	xil_printf("FAILURE: Decrypted message is not equal to original message!\r\n");

    dmb();
    dsb();
    isb();
    xil_printf("Send any character to run next test. (e.g. press a + enter) \r\n");
    getchar();
}

void test_2018_3() {
	xil_printf("######################\r\n");
	xil_printf("# Seed 2018.3 tests: #\r\n");
	xil_printf("######################\r\n");
	uint32_t result[32];
	uint32_t i;
	for(i=0;i<32;i++) {
		result[i] = 0;
	}

	//Encrypt
	xil_printf("Encryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(e_3, M_3, R_N_3, R2_N_3, N_3, result, e_len_3);
	dmb();
	dsb();
	isb();
	STOP_TIMING
	xil_printf(" -> Encrypted cipher text:\r\n");
	print_arr(result, 32);

    //Decrypt
	xil_printf("Decryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(d_3, result, R_N_3, R2_N_3, N_3, result, d_len_3);
    dmb();
    dsb();
    isb();
    STOP_TIMING

    xil_printf(" -> Decrypted result:\r\n");
    print_arr(result, 32);

    // Compare original and result
    if (compare_arr(M_3, result, 32) == 1)
    	xil_printf("SUCCESS: Decrypted message is equal to original message!\r\n");
    else
    	xil_printf("FAILURE: Decrypted message is not equal to original message!\r\n");

    dmb();
    dsb();
    isb();
    xil_printf("Send any character to run next test. (e.g. press a + enter) \r\n");
    getchar();
}

void test_2018_4() {
	xil_printf("######################\r\n");
	xil_printf("# Seed 2018.4 tests: #\r\n");
	xil_printf("######################\r\n");
	uint32_t result[32];
	uint32_t i;
	for(i=0;i<32;i++) {
		result[i] = 0;
	}

	//Encrypt
	xil_printf("Encryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(e_4, M_4, R_N_4, R2_N_4, N_4, result, e_len_4);
	dmb();
	dsb();
	isb();
	STOP_TIMING
	xil_printf(" -> Encrypted cipher text:\r\n");
	print_arr(result, 32);

    //Decrypt
	xil_printf("Decryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(d_4, result, R_N_4, R2_N_4, N_4, result, d_len_4);
    dmb();
    dsb();
    isb();
    STOP_TIMING

    xil_printf(" -> Decrypted result:\r\n");
    print_arr(result, 32);

    // Compare original and result
    if (compare_arr(M_4, result, 32) == 1)
    	xil_printf("SUCCESS: Decrypted message is equal to original message!\r\n");
    else
    	xil_printf("FAILURE: Decrypted message is not equal to original message!\r\n");

    dmb();
    dsb();
    isb();
    xil_printf("Send any character to run next test. (e.g. press a + enter) \r\n");
    getchar();
}

void test_2018_5() {
	xil_printf("######################\r\n");
	xil_printf("# Seed 2018.5 tests: #\r\n");
	xil_printf("######################\r\n");
	uint32_t result[32];
	uint32_t i;
	for(i=0;i<32;i++) {
		result[i] = 0;
	}

	//Encrypt
	xil_printf("Encryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(e_5, M_5, R_N_5, R2_N_5, N_5, result, e_len_5);
	dmb();
	dsb();
	isb();
	STOP_TIMING
	xil_printf(" -> Encrypted cipher text:\r\n");
	print_arr(result, 32);

    //Decrypt
	xil_printf("Decryption:\r\n");
	dmb();
	dsb();
	isb();
	START_TIMING
    HW_accelerator(d_5, result, R_N_5, R2_N_5, N_5, result, d_len_5);
    dmb();
    dsb();
    isb();
    STOP_TIMING

    xil_printf(" -> Decrypted result:\r\n");
    print_arr(result, 32);

    // Compare original and result
    if (compare_arr(M_5, result, 32) == 1)
    	xil_printf("SUCCESS: Decrypted message is equal to original message!\r\n");
    else
    	xil_printf("FAILURE: Decrypted message is not equal to original message!\r\n");

    dmb();
    dsb();
    isb();
    xil_printf("Send any character to run next test. (e.g. press a + enter) \r\n");
    getchar();
}
