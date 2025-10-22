.text

.globl node_creation

node_creation:
    addi sp, sp, -16
    mv a0, sp   # Salva o começo do sp como parâmetro

    li t0, 30
    sw t0, 0(sp)

    li t0, 25
    sb t0, 4(sp)

    li t0, 64
    sb t0, 5(sp)

    li t0, -12
    sh t0, 6(sp)

    sw ra, 8(sp)    # Armazena o ra para não perdê-lo na mystery_function
    jal mystery_function
    lw ra, 8(sp)    # Recupera o ra

    addi sp, sp, 16 # Desempilha tudo

    ret