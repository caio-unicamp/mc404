.data
    buf: .space 1
    buf_out: .space 5
.text
.globl _start

_start:
    li t3, 0    # número que será lido, inicializa em 0 para salvar byte a byte
    li a3, ' '    # Indicador para saber se está no meio da string ou no final
    
    la s2, buf_out  # Início do print 
    mv s3, s2
loop_leitura:
    li t4, 10    # número para iterações da raiz

    li a0, 0  # file descriptor = 0 (stdin)
    la a1, buf #  buffer to write the data
    li a2, 1  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

    lbu t0, buf # Caractere lido em t0

    li t1, '\n' # Se leu \n deve salvar pela última vez o valor e encerrar a leitura
    li t7, '\n'    # Chegou ao fim, então quando printar o número final, deve encerrar o código
    beq t0, t1, salva_s1

    li t1, ' '  # Ao achar um espaço, salva o valor atual para o registrador s1
    beq t0, t1, salva_s1; 

    addi t0, t0, -'0'   # Transformando caractere em número

    # t3 = t3*10 + t0
    mul t3, t3, 10  
    add t3, t3, t0 

    j loop_leitura

# Salva no registrador com o valor do número atual e pula para efetuar o algoritmo da raíz
salva_s1:
    mv s1, t3 
    li t2, 2
    div t3, s1, t2  # Inicializa o auxiliar como o número dividido por 2, t3 = k = num/2
    j raiz

raiz:   # Calcula a raiz quadrada usando método babilônico
    div t6, s1, t3  # Divide num por k
    addi t3, t3, t6 # Soma k com (num/k)
    div t3, t3, t2  # t3 = (k + (num/k))/2, agora t3 é novamente meu aux

    mv s1, t3   # k = aux
    
    li t5, 0
    sub t4, t4, 1 # Subtrai o contador de iterações

    mv a1, s3
    beq t4, t5, printar    # Quando t4 = 0 fez 10 iterações printa a raiz e volta a ler os números

    j raiz  # Enquanto o t4 não for zero, volta a aplicar o algoritmo

printar:
    li t6, 1000 
    div t4, s1, t6  # Pega o primeiro dígito e salva no t4
    rem t6, s1, t6  # Resto da divisão por 1000
    mv s1, t6   # Salva o resto da divisão por 1000

    add t4, t4, '0' # Transforma dígito em string
    sb t4, 0(a1)    # Coloca no primeiro byte

    li t6, 100 
    div t4, s1, t6  # Pega o segundo dígito e salva no t4
    rem t6, s1, t6  # Resto da divisão por 100
    mv s1, t6   # Salva o resto da divisão por 100

    add t4, t4, '0' # Transforma dígito em string
    sb t4, 1(a1)    # Coloca no segundo byte
    
    li t6, 10
    div t4, s1, t6  # Pega o terceiro dígito e salva no t4 
    rem t6, s1, t6  # Resto da divisão por 10
    mv s1, t6   # Salva o resto da divisão por 10

    add t4, t4, '0' # Transforma dígito em string
    sb t4, 2(a1)    # Coloca no terceiro byte
    
    add s1, s1, '0' # Transforma o último dígito em string
    sb s1, 3(a1)    # Coloca no quarto byte

    sb t7, 4(a1)    # Coloca no quinto byte, ou um espaço ou um \n

    li a0, 1            # file descriptor = 1 (stdout)
    la a1, s2           # buffer
    li a2, 5            # size
    li a7, 64           # syscall write (64)
    ecall

    li t4, '\n'
    bne t7, t4, loop_leitura    # Enquanto eu não leio um \n continua fazendo a leitura

fim:
    # Após ler os 4 números deve printar e finalizar 
    li a0, 0 
    li a7, 93
    ecall

