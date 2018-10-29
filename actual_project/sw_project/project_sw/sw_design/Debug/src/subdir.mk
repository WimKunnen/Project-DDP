################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/hw_accelerator.c \
../src/main.c \
../src/montgomery.c \
../src/mp_arith.c \
../src/tests.c \
../src/testvector.c 

S_UPPER_SRCS += \
../src/asm_conditional_sub.S \
../src/asm_func.S \
../src/asm_mont.S \
../src/asm_mont_add.S \
../src/asm_montgomery.S 

OBJS += \
./src/asm_conditional_sub.o \
./src/asm_func.o \
./src/asm_mont.o \
./src/asm_mont_add.o \
./src/asm_montgomery.o \
./src/hw_accelerator.o \
./src/main.o \
./src/montgomery.o \
./src/mp_arith.o \
./src/tests.o \
./src/testvector.o 

S_UPPER_DEPS += \
./src/asm_conditional_sub.d \
./src/asm_func.d \
./src/asm_mont.d \
./src/asm_mont_add.d \
./src/asm_montgomery.d 

C_DEPS += \
./src/hw_accelerator.d \
./src/main.d \
./src/montgomery.d \
./src/mp_arith.d \
./src/tests.d \
./src/testvector.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../hw_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../hw_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


