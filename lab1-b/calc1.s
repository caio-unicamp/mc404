	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"calc1.c"
	.globl	main
	.p2align	2
	.type	main,@function
main:
	addi	sp, sp, -48
	sw	ra, 44(sp)
	sw	s0, 40(sp)
	addi	s0, sp, 48
	li	a0, 0
	sw	a0, -36(s0)
	sw	a0, -12(s0)
	lui	a1, %hi(input_buffer)
	sw	a1, -44(s0)
	addi	a1, a1, %lo(input_buffer)
	sw	a1, -40(s0)
	li	a2, 10
	call	read
	lw	a2, -44(s0)
	lw	a1, -40(s0)
	mv	a3, a0
	lw	a0, -36(s0)
	sw	a3, -16(s0)
	lbu	a2, %lo(input_buffer)(a2)
	addi	a2, a2, -48
	sw	a2, -20(s0)
	lb	a2, 2(a1)
	sb	a2, -21(s0)
	lbu	a1, 4(a1)
	addi	a1, a1, -48
	sw	a1, -28(s0)
	sw	a0, -32(s0)
	lbu	a0, -21(s0)
	li	a1, 43
	bne	a0, a1, .LBB0_2
	j	.LBB0_1
.LBB0_1:
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	add	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB0_8
.LBB0_2:
	lbu	a0, -21(s0)
	li	a1, 45
	bne	a0, a1, .LBB0_4
	j	.LBB0_3
.LBB0_3:
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	sub	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB0_7
.LBB0_4:
	lbu	a0, -21(s0)
	li	a1, 42
	bne	a0, a1, .LBB0_6
	j	.LBB0_5
.LBB0_5:
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	mul	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB0_6
.LBB0_6:
	j	.LBB0_7
.LBB0_7:
	j	.LBB0_8
.LBB0_8:
	lw	a1, -32(s0)
	lui	a0, 419430
	addi	a0, a0, 1639
	mulh	a0, a1, a0
	srli	a2, a0, 31
	srli	a0, a0, 2
	add	a2, a0, a2
	li	a0, 10
	mul	a2, a2, a0
	sub	a1, a1, a2
	addi	a2, a1, 48
	lui	a1, %hi(output_buffer)
	sb	a2, %lo(output_buffer)(a1)
	addi	a1, a1, %lo(output_buffer)
	sb	a0, 1(a1)
	li	a0, 1
	li	a2, 2
	call	write
	li	a0, 0
	lw	ra, 44(sp)
	lw	s0, 40(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main

	.type	input_buffer,@object
	.section	.sbss,"aw",@nobits
	.globl	input_buffer
input_buffer:
	.zero	6
	.size	input_buffer, 6

	.type	output_buffer,@object
	.globl	output_buffer
output_buffer:
	.zero	2
	.size	output_buffer, 2

	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym input_buffer
	.addrsig_sym output_buffer
