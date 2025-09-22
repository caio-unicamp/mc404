.data
    buf_input_output: .space 1 # As leituras e impressões são feitas byte a byte 

.text
.globl _start

_start:
    li a3, 0    # Indicador pra saber em qual dígito na leitura está
    li a4, 0    # Indicador pra saber em qual linha está
read_linha_1:
    li a0, 0    # file descriptor stdin = 0
    la a1, buf_input_output # Buffer pra leitura
    li a2, 1    # Tamanho de cada leitura é de 1 byte
    li a7, 63   # Syscall read 63
    ecall

    li t0, '\n'
    beq a1, t0, prox_linha  # Se leu um \n vai pra próxima linha

    addi a3, a3, 1  # Indica em qual dígito de leitura está

    addi a1, a1, -'0'   # Mudança de str pra int

    li t0, 1
    beq a3, t0, salva_d1   # Se estiver no primeiro dígito salva d1

    li t0, 2
    beq a3, t0, salva_d2    # Se estiver no segundo dígito salva d2

    li t0, 3
    beq a3, t0, salva_d3    # Se estiver no terceiro dígito salva d3

    j salva_d4  # Se chegou até aqui está no último dígito

prox_linha:
    addi a4, 1  # Aumenta em qual linha está
    li t0, 1
    beq a4, t0, read_linha_1    # Se só tiver lido uma linha volta pra ler outra  

salva_d1:   # d1 está em s1
    mv s1, a3
salva_d2:   # d2 está em s2
    mv s2, a3
salva_d3:   # d3 está em s3
    mv s3, a3
salva_d4:   # d4 está em s4
    mv s4, a3