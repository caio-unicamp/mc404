.data
    buf_output_in1: .space 12   # Esse buffer será usado tanto para leitura da primeira linha quanto para saída
    buf_input2: .space 20   # Buffer para a leitura da segunda linha

.text
.globl _start

_start:
    li t1, 0    # Fará mudança de str pra int
    li a5, 12    # Flag pra dizer em que linha está a partir do tamanho da leitura
    li a4, 1    # Flag pra dizer em que número
    la a3, buf_output_in1   # Ponteiro pra primeira leitura

read:
    # Leitura da primeira linha
    li a0, 0  # file descriptor = 0 (stdin)
    mv a1, a3 #  buffer to write the data
    mv a2, a5  # size (12 bytes - 1º; 20 bytes - 2º)
    li a7, 63 # syscall read (63)
    ecall

    beq a5, 20, str_to_int  # Se estiver lendo a segunda linha ignora números negativos
    
    lb t3, 0(a3)    # Salva o sinal do número
    addi a3, a3, 1  # Começa leitura dos dígitos
    beq t3, '-', negativo   # Se o número for negativo muda o sinal dele

    li t3, 1    # Se chegou até aqui o primeiro número lido é positivo

str_to_int:
    lb t0, 0(a3)    # Pega o caractere atual da string 
    beqz t0, prox_num    
    beq t0, '\n', prox_linha  # se for '\n' vai pra prox linha

    addi t0, t0, -'0'   # Muda de str pra int
    mul t0, t0, t3  # Sinal
    # t1 = 10*t1 + t0
    li t2, 10
    mul t1, t1, t2  
    add t1, t1, t0

    addi a3, a3, 1  # Segue no buffer da string
    j str_to_int    # Continua a passagem 

prox_num:
    addi a3, 1  # Segue para o próximo caractere

    mv s1, t1   # Salva o valor temporário em um registrador
    li t1, 0    # Reseta o valor que será salvo
    j str_to_int    # Volta para passar de str pra int

negativo:
    li t3, -1   # t3 diz o sinal
    j str_to_int    # Começa a passar de str pra int de acordo com o sinal

prox_linha:
    beq a5, 20, fim # Se foi pra próxima linha e o buffer é de tamanho 20 está no final

    li a5, 20   # Caso não seja, muda o tamanho para a próxima leitura
    la a3, buf_input2   # Carrega o buffer pro segundo input
print:
    la a3, buf_output_in1   # Carrega o buffer para o print
    mv s3, a3   # Movimenta o print byte a bytey

    li a5, 12   # Atualiza o tamanho do print

    li a0, 1  # file descriptor = 1 (stdout)
    mv a1, a3 #  buffer to write the data
    mv a2, a5  # size (12 bytes)
    li a7, 64 # syscall write (64)
    ecall
fim:    # Encerra o programa
    li a0, 0
    li a7, 93
    ecall