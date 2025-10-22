.text
.globl my_function

my_function:
    add t0, a0, a1  # t0 = SUM 1 = a + b
    # Armazena o a0 na pilha para não perdê-lo
    addi sp, sp, -4
    sw a0, 0(sp)
    # Armazena o a1 na pilha para não perdê-lo
    addi sp, sp, -4
    sw a1, 0(sp)
    # Armazena o ra na pilha para não perdê-lo
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a1, a0   # O Segundo parâmetro é o primeiro parâmetro original
    mv a0, t0   # O primeiro parâmetro é SUM 1

    jal mystery_function
    # Recupera o valor de ra e o desempilha
    lw ra, 0(sp)
    addi sp, sp, 4
    # Recupera o valor de a1 e o desempilha
    lw a1, 0(sp)

    sub t0, a1, a0  # t0 = DIFF 1 = b - mystery_function(a+b, a)

    addi sp, sp, 4
    # Recupera o valor de a0 e o desempilha
    lw a0, 0(sp)
    addi sp, sp, 4

    add t0, t0, a2  # t0 = SUM 2 = aux = b - mystery_function(a+b, a) + c
    # Armazena o t0 na pilha para não perdê-lo na chamada da mystery_function
    addi sp, sp, -4
    sw t0, 0(sp)
    # Armazena o a0 na pilha para não perdê-lo
    addi sp, sp, -4
    sw a0, 0(sp)
    # Armazena o a1 na pilha para não perdê-lo
    addi sp, sp, -4
    sw a1, 0(sp)
    # Armazena o ra na pilha para não perdê-lo
    addi sp, sp, -4
    sw ra, 0(sp)

    # O Segundo parâmetro é o mesmo a1
    mv a0, t0   # O primeiro parâmetro é SUM 2

    jal mystery_function
    # Recupera o valor de ra e o desempilha
    lw ra, 0(sp)
    addi sp, sp, 4
    # Recupera o valor de a1 e o desempilha
    lw a1, 0(sp)

    sub t1, a2, a0  # t1 = DIFF 2 = c - mystery_function(aux, b)

    addi sp, sp, 4
    # Recupera o valor de a0 e o desempilha
    lw a0, 0(sp)
    addi sp, sp, 4
    # Recupera o valor de t0 e o desempilha
    lw t0, 0(sp)
    addi sp, sp, 4

    add a0, t1, t0  # Return c - mystery_function(aux,b) + aux
    ret