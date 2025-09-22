.data
    buf_input: .space 1 # Leitura feita byte a byte
    buf_output: .space 8  # O print máximo será de 8 bytes (contando o \n)

.text
.globl _start

_start:
    li a3, 0    # Indicador pra saber em qual dígito na leitura está
    li a5, 0    # Indicador pra saber em qual linha está
    la a4, buf_output # Buffer pro primeiro print

read_linha_1:
    li a0, 0    # file descriptor stdin = 0
    la a1, buf_input    # Buffer pra leitura
    li a2, 1    # Tamanho de cada leitura é de 1 byte
    li a7, 63   # Syscall read 63
    ecall

    lbu t1, buf_input   # Caractere lido em t1

    li t0, '\n'
    beq t1, t0, parity  # Se leu um \n começa a conferir a paridade dos bits

    addi a3, a3, 1  # Indica em qual dígito de leitura está

    addi t1, t1, -'0'   # Mudança de str pra int

    li t0, 1
    beq a3, t0, salva_d1   # Se estiver no primeiro dígito salva d1

    li t0, 2
    beq a3, t0, salva_d2    # Se estiver no segundo dígito salva d2

    li t0, 3
    beq a3, t0, salva_d3    # Se estiver no terceiro dígito salva d3

    j salva_d4  # Se chegou até aqui está no último dígito

salva_d1:   # d1 está em s1
    mv s1, t1

    li t0, 1
    beq a5, t0, read_linha_2
    
    j read_linha_1
salva_d2:   # d2 está em s2
    mv s2, t1
    
    li t0, 1
    beq a5, t0, read_linha_2

    j read_linha_1
salva_d3:   # d3 está em s3
    mv s3, t1
    
    li t0, 1
    beq a5, t0, read_linha_2

    j read_linha_1
salva_d4:   # d4 está em s4
    mv s4, t1
    
    li t0, 1
    beq a5, t0, read_linha_2

    j read_linha_1

parity: # Salva o bit de paridade sendo 1 caso a soma dos dígitos referentes for ímpar e 0 caso contrário
    # s5 salva p1 correto
    xor t0, s2, s4  # Analisa d2 xor d4
    xor s5, s1, t0  # Analisa d1 xor (d2 xor d4)
    # s6 salva p2 correto
    xor t0, s3, s4  # Analisa d3 xor d4
    xor s6, s1, t0  # Analisa d1 xor (d3 xor d4)
    # s7 salva p3 correto
    xor t0, s3, s4  # Analisa d3 xor d4
    xor s7, s2, t0  # Analisa d2 xor (d3 xor d4)

    li t0, 1
    beq a5, t0, confere_paridade   # Se já está na segunda linha (0-indexado) parte para a conferência de paridade 
    # Caso contrário printa a primeira linha

print_linha_1:  
    # Transforma todos os bits em strings
    addi s1, s1, '0'
    addi s2, s2, '0'
    addi s3, s3, '0'
    addi s4, s4, '0'
    addi s5, s5, '0'
    addi s6, s6, '0'
    addi s7, s7, '0'
    # Armazena os bytes pro print
    sb s5, 0(a4)    #p1
    sb s6, 1(a4)    #p2
    sb s1, 2(a4)    #d1
    sb s7, 3(a4)    #p3
    sb s2, 4(a4)    #d2 
    sb s3, 5(a4)    #d3
    sb s4, 6(a4)    #d4
    li t0, '\n'
    sb t0, 7(a4)

    li a0, 1    # file descriptor stdout = 1
    mv a1, a4   # Buffer pro primeiro print
    li a2, 11    # Tamanho do print são 8 bytes
    li a7, 64   # Syscall write 64
    ecall

    addi a5, a5, 1  # Fala que vai ler a segunda linha
    li a3, 0    # Reinicia o ordenal do dígito para a leitura da segunda linha

read_linha_2:
    li a0, 0    # file descriptor stdin = 0
    la a1, buf_input    # Buffer pra leitura
    li a2, 1    # Tamanho de cada leitura é de 1 byte
    li a7, 63   # Syscall read 63
    ecall

    lbu t1, buf_input   # Caractere lido em t1

    li t0, '\n'
    beq t1, t0, parity  # Se leu um \n começa a conferir as paridades dos bits

    addi a3, a3, 1  # Indica em qual dígito de leitura está

    addi t1, t1, -'0'   # Mudança de str pra int

    li t0, 1
    beq a3, t0, salva_p1    # Se estiver no primeiro dígito salva p1

    li t0, 2
    beq a3, t0, salva_p2    # Se estiver no segundo dígito salva p2

    li t0, 3
    beq a3, t0, salva_d1    # Se estiver no terceiro dígito salva d1

    li t0, 4
    beq a3, t0, salva_p3    # Se estiver no quarto dígito salva p3

    li t0, 5
    beq a3, t0, salva_d2    # Se estiver no quinto dígito salva d2

    li t0, 6
    beq a3, t0, salva_d3    # Se estiver no sexto dígito salva d3

    li t0, 7
    beq a3, t0, salva_d4    # Se estiver no sétimo dígito salva d4

salva_p1:   # Salva o valor escrito de p1 em s8
    mv s8, t1
    j read_linha_2

salva_p2:   # Salva o valor escrito de p2 em s9
    mv s9, t1
    j read_linha_2

salva_p3:   # Salva o valor escrito de p3 em s10
    mv s10, t1
    j read_linha_2

confere_paridade:
    li s11, 1   # Inicializa que está errado a paridade na decodificação
    # Abaixo é analisado se o bit de paridade lido está de acordo com o que deveria ser 
    bne s8, s5, print_linha_2

    bne s9, s6, print_linha_2

    bne s10, s7, print_linha_2

    li s11, 0   # Se chegou até aqui não há erro de decodificação

print_linha_2:
    sb s1, 0(a4)    #d1
    sb s2, 1(a4)    #d2
    sb s3, 2(a4)    #d3
    sb s4, 3(a4)    #d4
    # Quebra de linha entre a segunda linha e a primeira
    li t0, '\n'
    sb t0, 4(a4)
    # Bit que indica se houve erro
    sb s11, 5(a4)
    # Quebra de linha final
    sb t0, 6(a4)

    li a0, 1    # file descriptor stdout = 1
    mv a1, a4   # Buffer pros últimos prints
    li a2, 7    # Tamanho do print são 7 bytes
    li a7, 64   # Syscall write 64
    ecall

fim:
    li a0, 0
    li a7, 93   # Syscall exit
    ecall
