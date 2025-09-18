.data
    buf_input: .space 1 # Leituras são feitas byte a byte
    buf_out: .space 5 # Prints são feitos a cada 4 bytes
.text
.globl _start

_start:
    li a3, 0    # Indicador para saber em qual número está
    li t3, 0    # número que pede-se a raiz inicializa em 0 
    
    la s2, buf_out  # Ponteiro para o início do que será printado
    mv s3, s2   # Movimenta o print byte a byte

loop_leitura:
    li a4, 10    # número para iterações da raiz

    li a0, 0  # file descriptor = 0 (stdin)
    la a1, buf_input #  buffer to write the data
    li a2, 1  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

    lbu t0, buf_input # Caractere lido em t0

    mv a5, s3

    li t1, '\n' # Se leu \n deve salvar pela última vez o valor e encerrar a leitura
    sb t1, 4(a5)    # Caso seja \n ele vai salvar no último byte para printar
    beq t0, t1, salva_s1

    li t1, ' '  # Ao achar um espaço, salva o valor atual para o registrador s1
    sb t1, 4(a5)    # Caso seja ' ' salva no último byte do número a ser printado
    beq t0, t1, salva_s1; 

    addi t0, t0, -'0'   # Transformando caractere em número

    # t3 = t3*10 + t0
    li t2, 10
    mul t3, t3, t2  
    add t3, t3, t0 

    j loop_leitura  # Se não chegou ao final de um número volta a ler um byte

# Salva no registrador com o valor do número atual e pula para efetuar o algoritmo da raíz
salva_s1:
    mv s1, t3   # Salva o auxiliar no registrador s1

    li t3, 1
    add a3, a3, t3 # a3 += 1 para saber em qual número está

    li t3, 2    # t3 = 2
    div t2, s1, t3  # Inicializa o auxiliar como o número dividido por 2, t2 = k = num/2

# Calcula a raiz quadrada usando método babilônico
raiz:   
    div t0, s1, t2  # Divide num por k, t0 = num/k
    add t0, t2, t0 # Soma k com (num/k), t0 = k + (num/k)
    div t2, t0, t3  # Divide por 2, t2 = (k + (num/k))/2 = aux

    mv s1, t2   # k = aux
    
    addi a4, a4, -1 # Subtrai o contador de iterações: 10 >= a4 >=1

    li t4, 1
    beq a4, t4, printar    # Quando a4 = 1 fez 10 iterações printa a raiz e volta a ler os números se ainda houver

    j raiz  # Enquanto o t4 não for zero, volta a aplicar o algoritmo

printar:
    li t0, 1000 
    div t1, s1, t0  # Pega o primeiro dígito e salva no t1
    rem t2, s1, t0  # Pega o resto da divisão por 1000 e salva em t2
    mv s1, t2   # Salva o resto da divisão por 1000 em s1

    add t1, t1, '0' # Transforma dígito em string
    sb t1, 0(a5)    # Coloca no primeiro byte de a5

    li t0, 100 
    div t1, s1, t0  # Pega o segundo dígito e salva no t1
    rem t2, s1, t0  # Pega o resto da divisão por 100 e salva em t2
    mv s1, t2   # Salva o resto da divisão por 100 em s1

    add t1, t1, '0' # Transforma dígito em string
    sb t1, 1(a5)    # Coloca no segundo byte de a5
    
    li t0, 10
    div t1, s1, t0  # Pega o terceiro dígito e salva no t1 
    rem t2, s1, t0  # Pega o resto da divisão por 10 e salva no t2
    mv s1, t2   # Salva o resto da divisão por 10 em s1

    add t1, t1, '0' # Transforma dígito em string
    sb t1, 2(a5)    # Coloca no terceiro byte de a5
    
    add s1, s1, '0' # Transforma o último dígito em string
    sb s1, 3(a5)    # Coloca no quarto byte

    # O 5º byte já foi armazenado quando foi perguntado se ele era \n ou ' '

    li a0, 1            # file descriptor = 1 (stdout)
    mv a1, s2           # buffer
    li a2, 5            # size
    li a7, 64           # syscall write (64)
    ecall

    # addi s3, s3, 5  # Move o ponteiro

    li t0, 4
    # li t3, 0    # Reseta o valor do registrador t3 para 0 para realizar a nova leitura  
    bne a3, t0, loop_leitura # Enquanto não for o último número continua a leitura

# Caso tenha sido o último número segue para o fim da função
fim:
    # Após ler os 4 números serem printados deve finalizar 
    li a0, 0 
    li a7, 93
    ecall