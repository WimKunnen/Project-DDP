.text

.global asm_mont_add
.func asm_mont_add, asm_mont_add
.type asm_mont_add, %function

asm_mont_add:

cmp r2, #0
beq end_add_loop
add_loop:
	ldr r3, [r0, r1, lsl #2]
	push {r4}
	adds r4, r2, r3
	mov r2, #0
	movcs r2, #1
	str r4, [r0, r1, lsl #2]
	pop {r4}
	add r1, r1, #1
	cmp r2, #0
	bne add_loop
end_add_loop:
bx lr
.endfunc


.text

.global asm_cond_sub
.func asm_cond_sub, asm_cond_sub
.type asm_cond_sub, %function

// initial params
// r0: u
// r1: n
// r2: size
// r3: t
// r4: index
// r5: u[index]
// r6: n[index]
// r7: b
asm_cond_sub:

push {r4,r5,r6,r7}
mov r4, #0
mov r7, #0
cmp r4, r2
bgt end_init_loop

init_loop:
	str	#0, [r3], #4
	add r4, #1
	cmp r4, r2
	blt init_loop
mov r4, #0

end_init_loop:
cmp r4, r2
bge end_sub_loop

sub_loop:
	ldr r5, [r0, r4, lsl #2]
	ldr r6, [r1, r4, lsl #2]
	sub r8, r5, r6
	sub r8, r8, r6
	add r6, r6, r7
	cmp r5, r6
	blt first_else

	first_if:
		mov r7, #0
		bl end_first_if

	first_else:
		mov r7, #1

	end_first_if:
	str r8, [r3, r4, lsl #2]
	cmp r4, r2
	blt sub_loop

end_sub_loop:
	ldr r5, [r0, r3, lsl #2]
	sub r6, r5, r7
	cmp r5, r7
	blt second_else

	second_if:
		mov r7, #0
		bl end_second_if

	second_else:
		mov r7, #1

	end_second_if:
	str r6, [r3, r2, lsl #2]

	comp r7, #0
	bne end
	mov r4, #0
	cmp r4, r2
	bgt end

	final_loop:
		ldr r5, [r3, r4, lsl #2]
		str r5, [r0, r4, lsl #2]
		add r4, #1
		cmp r4, r2
		ble final_loop

end:
pop {r4,r5,r6,r7}
bx lr
.endfunc


.text

.global asm_mont
.func asm_mont, asm_mont
.type asm_mont, %function

// initial params:
// r0: a
// r1: b
// r2: n
// r3: n0
// r4: res
// r5: size
// r6: t
// r7: 2*size+1
// r8: i
// r9: j
// r10: c
asm_mont:
// Push previous registers?
pop {r6, r5, r4}
push {r7, r8, r9,r10}
lsr r7, r5, #1
add r7, r7, #1
mov r8, #0
mov r9, #0
cmp r8, r5
bge end_init_loop_mont

init_loop_mont:
	str	#0, [r6], #4
	add r8, r8, #1
	cmp r8, r5
	blt init_loop_mont
	mov r8, #0

end_init_loop_mont:

comp r8, r5
bge end_first_outer_loop

first_outer_loop:
	mov r10, #0
	cmp r9, r5
	bge end_first_inner_loop

	first_inner_loop:


end_first_outer_loop:
mov r8, #0
.endfunc
