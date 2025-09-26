.data
    input_buffer: .space 1
.text
.globl _start

_start:
    la a3, input_buffer
    li a4, 1    # Flag pra indicar se o número é negativo
    li t3, 0    # Acumulador do valor

loop_leitura:
    li a0, 0    # fd = 0 stdin
    mv a1, a3   # Buffer de leitura
    li a2, 1    # Lê-se byte a byte
    li a7, 63   # Syscall read
    ecall

    lbu t0, 0(a3)

    li t1, '\n'
    beq t1, t0, num_final # Encerra a leitura quando ler o \n

    li t1, '-'
    jal ra, negativo
    # t3 = 10*t3 + t0
    li t1, 10
    mul t3, t1
    add t3, t3, t0

    j loop_leitura  # Vola a ler
is_negativo:
    beq t0, t1, marca_neg
    ret
marca_neg:
    li a4, -1
    
num_final:
    mul s1, t3, a4  # Múltiplica pelo sinal do número e salva em s1