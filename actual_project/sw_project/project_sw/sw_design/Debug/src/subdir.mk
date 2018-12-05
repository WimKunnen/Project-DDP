################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/hw_accelerator.c \
../src/main.c \
../src/mp_arith.c \
../src/print_arr.c \
../src/testvector.c 

OBJS += \
./src/hw_accelerator.o \
./src/main.o \
./src/mp_arith.o \
./src/print_arr.o \
./src/testvector.o 

C_DEPS += \
./src/hw_accelerator.d \
./src/main.d \
./src/mp_arith.d \
./src/print_arr.d \
./src/testvector.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../hw_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


