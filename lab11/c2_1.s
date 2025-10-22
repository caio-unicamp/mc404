.text
.globl swap_int, swap_short, swap_char

swap_int:
    mv t0, a0
    mv a0, a1
    mv a1, t0
    ret

    
swap_short:

swap_char: