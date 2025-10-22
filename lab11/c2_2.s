.text
.globl middle_value_int, middle_value_short, middle_value_char, value_matrix

middle_value_int:
    mv t1, a1
    li t2, 2
    div t1, t1, t2  # t1 = middle = n/2
    # O array é de ints, o endereço avança de 4 em 4
    li t2, 4
    mul t1, t1, t2
    add t0, a0, t1

    lw a0, (t0)
    ret

middle_value_short: 
    mv t1, a1
    li t2, 2
    div t1, t1, t2  # t1 = middle = n/2
    # O array é de shorts, o endereço avança de 2 em 2
    li t2, 2
    mul t1, t1, t2
    add t0, a0, t1

    lw a0, (t0)
    ret
middle_value_char:
    mv t1, a1
    li t2, 2
    div t1, t1, t2  # t1 = middle = n/2
    add t0, a0, t1

    lw a0, (t0)

    ret
value_matrix:
    ret