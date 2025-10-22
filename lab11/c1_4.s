.text
.globl operation

operation:
    add a0, a1, a2  # a0 = b + c
    sub a0, a0, a5  # a0 = b + c - f
    add a0, a0, a7  # a0 = b + c - f + h

    lh t0, 8(sp)
    add a0, a0, t0  # a0 = b + c - f + h + k

    lw t0, 16(sp)
    sub a0, a0, t0  # a0 = b + c - f + h + k - m 

    ret 