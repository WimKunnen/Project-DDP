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
