.text
.globl operation

operation:
    addi sp, sp, -32
    
    sw a5, 0(sp)    # Armazena f
    sw a4, 4(sp)    # Armazena e
    sw a3, 8(sp)    # Armazena d
    sw a2, 12(sp)   # Armazena c
    sw a1, 16(sp)   # Armazena b
    sw a0, 20(sp)   # Armazena a
    sw ra, 24(sp)   # Armazena o ra antes de pular para a chamada

    lw a0, 52(sp)   # Carrega em a0 o n
    lw a1, 48(sp)   # Carrega em a1 o m
    lw a2, 44(sp)   # Carrega em a2 o l
    lw a3, 40(sp)   # Carrega em a3 o k
    lw a4, 36(sp)   # Carrega em a4 o j
    lw a5, 32(sp)   # Carrega em a5 o i
    mv t0, a7   # Carrega em t0 o h
    mv a7, a6   # Carrega em a7 o g
    mv a6, t0   # Carrega em a6 o h


    jal mystery_function
    
    lw ra, 24(sp)    # Recupera o ra e o desempilha, além de desempilhar todos os outros valores que não serão mais usados
    addi sp, sp, 32

    # Em a0 já tem o retorno da função, basta retornar
    ret