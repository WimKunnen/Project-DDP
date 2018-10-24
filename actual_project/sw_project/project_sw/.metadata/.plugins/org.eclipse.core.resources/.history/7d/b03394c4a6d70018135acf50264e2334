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
	str	r8, [r6], #4
	add r8, r8, #1
	cmp r8, r5
	blt init_loop_mont
	mov r8, #0

end_init_loop_mont:

cmp r8, r5
bge end_first_outer_loop

first_outer_loop:
	mov r10, #0
	cmp r9, r5
	bge end_first_inner_loop

	first_inner_loop:

	end_first_inner_loop:

end_first_outer_loop:
mov r8, #0
.endfunc
