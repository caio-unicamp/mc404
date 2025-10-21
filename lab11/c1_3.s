.data
    a: .word 1
    b: .word -2
    c: .half 3
    d: .half -4
    e: .byte 5
    f: .byte -6
    g: .word 7
    h: .word -8
    i: .byte 9
    j: .byte -10
    k: .half 11
    l: .half -12
    m: .word 13
    n: .word -14

.text
.globl operation

operation:
    # Armazena int a = 1
    la t0, a
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena int b = -2
    la t0, b
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena short c = 3
    la t0, a
    lh t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena short d = -4
    la t0, a
    lh t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena char e = 5
    la t0, a
    lb t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena char f = -6
    la t0, a
    lb t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena int g = 7
    la t0, a
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena int h = -8
    la t0, a
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena char i = 9
    la t0, a
    lb t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena j = -10
    la t0, a
    lb t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena short k = 11
    la t0, a
    lh t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena short l = -12
    la t0, a
    lh t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena int m = 13
    la t0, a
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)
    # Armazena n = -14
    la t0, a
    lw t1, 0(t0)
    addi sp, sp -4
    sw t1, 0(sp)

    ret