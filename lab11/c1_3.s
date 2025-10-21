.rodata
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
    lw a0, 0(t0)
    # Armazena int b = -2
    la t0, b
    lw a1, 0(t0)
    # Armazena short c = 3
    la t0, c
    lhu a2, 0(t0)
    # Armazena short d = -4
    la t0, d
    lh a3, 0(t0)
    # Armazena char e = 5
    la t0, e
    lb a4, 0(t0)
    # Armazena char f = -6
    la t0, f
    lb a5, 0(t0)
    # Armazena int g = 7
    la t0, g
    lw a6, 0(t0)
    # Armazena int h = -8
    la t0, h
    lw a7, 0(t0)
    # A partir daqui usa a pilha para os parâmetros de trás pra frente
    # Armazena int n = -14
    la t0, n
    lw t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena int m = 13
    la t0, m
    lw t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena short l = -12
    la t0, l
    lh t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena short k = 11
    la t0, k
    lhu t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena j = -10
    la t0, j
    lb t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena char i = 9
    la t0, i
    lbu t1, 0(t0)
    addi sp, sp, -4
    sw t1, 0(sp)
    # Armazena o ra antes de chamar outra função
    addi sp, sp, -4
    sw ra, 0(sp)

    jal mystery_function
    # Recupera o valor de ra e o desempilha, além de desempilhar todos os outros valores que não serão mais usados
    lw ra, 0(sp)
    addi sp, sp, 28
    # Como o a0 já armazenou o retorno da mystery_function basta retornar para onde a função operation foi chamada
    ret