.data
    input_buffer: .space 1
    output_buffer: .space 5
.text
.globl _start

_start:
    la a5, head_node
    la a3, input_buffer
    la a6, output_buffer
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
    beq t0, t1, marca_neg

    # t3 = 10*t3 + t0
    addi t0, t0, -'0'   # str to int
    li t1, 10
    mul t3, t3, t1
    add t3, t3, t0

    j loop_leitura  # Vola a ler
marca_neg:
    li a4, -1
    j loop_leitura
    
num_final:
    mul s1, t3, a4  # Múltiplica pelo sinal do número e salva em s1

    li t4, 0    # Índice da linked-list começa em 0
    li s2, -1   # Índice caso ache val1 + val2 = input, caso não ache deve retornar -1
percorre_lista:
    lw t0, 0(a5)    # Val1
    lw t1, 4(a5)    # Val2
    lw t2, 8(a5)    # Next


    add t5, t0, t1  # Val1 + Val2    
    beq s1, t5, found   # Se achou um nó que a soma dos valores é meu input, encerra a busca

    beqz t2, confere_tamanho    # Null-pointer, encerra a busca caso não exista próximo

    addi t4, t4, 1 # Aumenta o índice
    mv a5, t2   # Segue para o próximo nó
    j percorre_lista
    
found:
    mv s2, t4   # Salva em qual índice achou
    j confere_tamanho

not_found:  # Se não achou nenhum índice válido printa -1
    li t0, '-'
    sb t0, 0(a6)

    li t0, '1'
    sb t0, 1(a6)

    li t0, '\n'
    sb t0, 2(a6)

    li s3, 3    # Size = 3
    j print

confere_tamanho:    # Confere o tamanho do meu índice pra printar corretamente
    blt s2, x0, not_found

    li t0, 999
    bgt s2, t0, milhar

    li t0, 99
    bgt s2, t0, centena

    li t0, 9
    bgt s2, t0, dezena

    # Número de 1 dígito
    addi s2, s2, '0'    # int to str
    sb s2, 0(a6)

    li t0, '\n'
    sb t0, 1(a6)
    
    li s3, 2    # Size
    j print

milhar:
    li t0, 1000
    div s1, s2, t0  # Primeiro dígito do índice
    rem s2, s2, t0  # Resto por 1000
    addi s1, s1, '0'    # int to str
    sb s1, 0(a6)

    li t0, 100
    div s1, s2, t0  # Segundo dígito do índice
    rem s2, s2, t0  # Resto por 100
    addi s1, s1, '0'    # int to str
    sb s1, 1(a6)

    li t0, 10 
    div s1, s2, t0  # Terceiro dígito do índice
    rem s2, s2, t0  # Resto por 10
    addi s1, s1, '0'    # int to str
    sb s1, 2(a6)

    addi s1, s2, '0'    # Último dígito do índice de int pra str
    sb s1, 3(a6)

    li t0, '\n' # Encerra com \n
    sb t0, 4(a6)

    li s3, 5    # Size
    j print
    
centena:
    li t0, 100
    div s1, s2, t0  # Primeiro dígito do índice
    rem s2, s2, t0  # Resto por 100
    addi s1, s1, '0'    # int to str
    sb s1, 0(a6)

    li t0, 10
    div s1, s2, t0  # Segundo dígito do índice
    rem s2, s2, t0  # Resto por 10
    addi s1, s1, '0'    # int to str
    sb s1, 1(a6)

    addi s1, s2, '0'    # Último dígito do índice de int pra str
    sb s1, 2(a6)

    li t0, '\n' # Encerra com \n
    sb t0, 3(a6)

    li s3, 4    # Size
    j print

dezena:
    li t0, 10
    div s1, s2, t0  # Primeiro dígito do índice
    rem s2, s2, t0  # Resto por 10
    addi s1, s1, '0'    # int to str
    sb s1, 0(a6)

    addi s1, s2, '0'    # Último dígito do índice de int pra str
    sb s1, 1(a6)

    li t0, '\n' # Encerra com \n
    sb t0, 2(a6)

    li s3, 3    # Size
    j print

print:
    li a0, 1    # fd = 1 (stdout)
    mv a1, a6
    mv a2, s3    # Size 
    li a7, 64   # Syscall write
    ecall

fim:
    li a0, 0
    li a7, 93   # Syscall exit
    ecall
    