#ifndef TESTS_H_
#define TESTS_H_

uint32_t test_montgomery();
uint32_t test_asm_mul();
void print_arr(uint32_t* arr, uint32_t size);
uint32_t compare(uint32_t* cmp, uint32_t* expected, uint32_t size);
#endif
