.text
.globl fill_array_int, fill_array_short, fill_array_char

fill_array_int:
    addi sp, sp, -416
    mv a0, sp
    li t1, 0
    li t2, 100

    loop_fai:
        sw t1, 0(sp)    # array[i] = i
        addi t1, t1, 1  # i++
        addi sp, sp, 4
        blt t1, t2, loop_fai    # for int i = 0; i < 100

    sw ra, 0(sp)  # Salva o ra antes de chamar outra rotina
    mv sp, a0
    jal mystery_function_int
    lw ra, 400(sp)    # Recupera o ra
    addi sp, sp, 416
    ret # Já tem o retorno correto em a0

fill_array_short:
    addi sp, sp, -216
    mv a0, sp
    li t1, 0
    li t2, 100

    loop_fas:
        sh t1, 0(sp)    # array[i] = i
        addi t1, t1, 1  # i++
        addi sp, sp, 2
        blt t1, t2, loop_fas    # for int i = 0; i < 100

    sw ra, 0(sp)  # Salva o ra antes de chamar outra rotina
    mv sp, a0
    jal mystery_function_short
    lw ra, 200(sp)    # Recupera o ra
    addi sp, sp, 216
    ret # Já tem o retorno correto em a0

fill_array_char:
    addi sp, sp, -116
    mv a0, sp
    li t1, 0
    li t2, 100

    loop_fac:
        sb t1, 0(sp)    # array[i] = i
        addi t1, t1, 1  # i++
        addi sp, sp, 1
        blt t1, t2, loop_fac    # for int i = 0; i < 100

    sw ra, 0(sp)  # Salva o ra antes de chamar outra rotina
    mv sp, a0
    jal mystery_function_char
    lw ra, 100(sp)    # Recupera o ra
    addi sp, sp, 116
    ret # Já tem o retorno correto em a0
