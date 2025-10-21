.text
.globl operation

operation:
    add a0, a1, a2  # a0 = b + c
    sub a0, a0, a6  # a0 = b + c - f
    add a0, a0, a7  # a0 = b + c - f + h

    addi sp, sp, 8
    lw t0, 0(sp) # Pega o valor de m 
    sub a0, a0, t0  # a0 = b + c - f + h - m

    addi sp, sp, 8
    lw t0, 0(sp)    # Pega o valor de k
    add a0, a0, t0  # a0 = b + c - f + h + k - m

    addi sp, sp, -16    # Volta sp para onde estava
    ret 
    