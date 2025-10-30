.rodata
    hex: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

.text
.set base, 0xFFFF0100
.set write, 0x0
.set written_byte, 0x1
.set read, 0x2
.set read_byte, 0x3

.globl _start
_start:
    li s0, base # Salva a memória da base em s0
    li t0, 1
    sb t0, read(s0) # Começa a leitura
    li s1, 0    # Tamanho da string a ser printada
    li a0, 0
    mv s2, a0   # O a0 vai ser usado para salvar uma string de caractéres numéricos avançando byte a byte, então s2 armazena o início dessa string

leitura:
    jal ra, espera_leitura
    lbu t1, read_byte(s0)    # Salva o caractere do número referente à operação lida em t1

    li t0, 1
    sb t0, read(s0) # Ignora o primeiro \n
    jal ra, espera_leitura

    li t0, '1'
    beq t0, t1, operacao_1

    li t0, '2'
    beq t0, t1, operacao_2

    li t0, '3'
    beq t0, t1, operacao_3
# Se não for nenhum dos anteriores é a operação 4   
operacao_4: # Printa uma operação entre 2 números 
    li t0, 1
    sb t0, read(s0) # Dá trigger para ler o próximo caractére
    jal ra, espera_leitura

    lbu t1, read_byte(s0)   # Armazena o caractére lido em t1
    sb t1, 0(a0)    # Armazena o caractére atual em a0 que irá salvar a string do número
    addi a0, a0, 1  # Avança para salvar o próximo caractére

    li t0, ' '
    beq t0, t1, operador  # Enquanto não ler um espaço (primeiro número) continua a leitura

    li t0, '\n'
    beq t0, t1, fim_op4  # Enquanto não ler uma quebra de linha (segundo número) continua a leitura
    
    j operacao_4
    
    operador:
        # O primeiro número é encerrado por um ' ', mas atoi funciona ignorando whitespace e encerrando em \n, então insere um \n no fim antes de passar para a próxima rotina
        li t0, '\n'
        sb t0, 0(a0)

        mv a0, s2   # Recupera o início da string

        addi sp, sp, -4
        sw ra, 0(sp)    # Salva o ra antes de pular para outra rotina
        jal atoi    # Pula para a função que transforma uma string para inteiro decimal retornando o mesmo em a0

        mv s3, a0   # Salva o primeiro número em s3 

        li t0, 1
        sb t0, read(s0) # Dá trigger para ler qual o operador
        jal ra, espera_leitura

        lbu s4, read_byte(s0)   # Armazena o operador em s4 

        li t0, 1
        sb t0, read(s0) # Dá trigger para ignorar o espaço entre o operador e o próximo número
        jal ra, espera_leitura

        li a0, 0    # Reseta o buffer

        j operacao_4    # Volta para ler o próximo número

    fim_op4:
        mv a0, s2   # Recupera o início da string

        addi sp, sp, -4
        sw ra, 0(sp)    # Salva o ra antes de pular para outra rotina
        jal atoi    # Pula para a função que transforma uma string para inteiro decimal retornando o mesmo em a0

        mv s5, a0   # Salva o segundo número em s5

        li t0, '+'
        beq s4, t0, soma

        li t0, '-'
        beq s4, t0, subtrai

        li t0, '/'
        beq s4, t0, divide

        li t0, '*'
        beq s4, t0, multiplica

        soma:
            add a0, s3, s5  # a0 = s3 + s5

            j transforma_num_op4
        subtrai:
            sub a0, s3, s5  # a0 = s3 - s5

            j transforma_num_op4
        divide:
            div a0, s3, s5  # a0 = s3 / s5

            j transforma_num_op4

        multiplica:
            mul a0, s3, s5  # a0 = s3 * s5

            j transforma_num_op4

        transforma_num_op4:
            li a2, 10
            addi sp, sp, -4
            sw ra, 0(sp)    # Armazena o ra antes de chamar uma rotina

            jal itoa    # Pula para a função que transforma um inteiro para uma string e retorna isso em a0


            lw ra, 0(sp)    # Recupera o ra e o desempilha
            addi sp, sp, 4

        loop_print_op4:
            lbu t1, 0(a0)   # Carrega o dígito atual em t1
            sb t1, written_byte(s0) # Armazena qual dígito deve ser printado
            li t0, 1
            sb t0, write(s0)    # Dá trigger pra printar o próximo caractére
            jal ra, espera_escrita
            
            addi a0, a0, 1
            li t2, '\n'
            bne t1, t2, loop_print_op4  # Enquanto não tiver printado a quebra de linha, continua

    j exit
operacao_1: # Printa a própria string
    li t0, 1
    sb t0, read(s0) # Dá trigger para ler o próximo caractére
    jal ra, espera_leitura
    lbu t1, read_byte(s0)   # Armazena o caractére lido em t1

    sb t1, written_byte(s0) # Armazena qual caractére deve ser printado
    li t0, 1
    sb t0, write(s0)    # Dá trigger pra printar o próximo caractére
    jal ra, espera_escrita

    li t0, '\n'
    bne t0, t1, operacao_1  # Enquanto não ler uma quebra de linha continua a leitura

    j exit  # Se leu a quebra de linha simplesmente sai pois já printou tudo

operacao_2: # Printa a string invertida
    li t0, 1
    sb t0, read(s0) # Dá trigger para ler o próximo caractére
    jal ra, espera_leitura
    lbu t1, read_byte(s0)   # Armazena o caractére lido em t1
    li t0, '\n'
    beq t0, t1, loop_print_op2  # Caso leia uma quebra de linha finaliza a leitura e inicia o print
    addi sp, sp, -1 

    # Senão, armazena o caractere lido no stack pointer
    sb t1, 0(sp)
    addi s1, s1, 1  # Aumenta o tamanho da string

    j operacao_2

    loop_print_op2:
        lbu t1, 0(sp)   # Carrega o caractére lido de trás pra frente do stack pointer
        sb t1, written_byte(s0) # Armazena qual caractére deve ser printado
        li t0, 1
        sb t0, write(s0)    # Dá trigger pra printar o próximo caractére
        jal ra, espera_escrita
        
        addi s1, s1, -1 # Diminui o quanto ainda precisa ser printado da string
        addi sp, sp, 1  # Desempilha o caractére lido

        bnez s1, loop_print_op2  # Enquanto s1 for maior que 0 continua o print
    # Printa o \n final
    li t0, '\n'
    sb t0, written_byte(s0)
    li t0, 1
    sb t0, write(s0)
    jal ra, espera_escrita
        
    j exit  # Se leu a quebra de linha simplesmente sai pois já printou tudo

operacao_3: # Printa o número lido convertendo pra hexa
    li t0, 1
    sb t0, read(s0) # Dá trigger para ler o próximo caractére
    jal ra, espera_leitura

    lbu t1, read_byte(s0)   # Armazena o caractére lido em t1
    sb t1, 0(a0)    # Armazena o caractére atual em a0 que irá salvar a string do número
    addi a0, a0, 1  # Avança para salvar o próximo caractére

    li t0, '\n'
    bne t0, t1, operacao_3  # Enquanto não ler uma quebra de linha continua a leitura

    mv a0, s2   # Recupera o início da string

    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de pular para outra rotina
    jal atoi    # Pula para a função que transforma uma string para inteiro decimal retornando o mesmo em a0

    lw ra, 0(sp)    # Recupera o ra e o desempilha
    addi sp, sp, 4  

    li a2, 16   # Base hexadecimal

    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de pular para outra rotina
    jal itoa    # Pula para a função que transforma um inteiro para uma string alterando a base dele para hexadecimal e retornando isso em a0

    lw ra, 0(sp)    # Recupera o ra e o desempilha
    addi sp, sp, 4

    loop_print_op3:
        lbu t1, 0(a0)   # Carrega o dígito atual em t1
        sb t1, written_byte(s0) # Armazena qual dígito deve ser printado
        li t0, 1
        sb t0, write(s0)    # Dá trigger pra printar o próximo caractére
        jal ra, espera_escrita
        
        addi a0, a0, 1
        li t2, '\n'
        bne t1, t2, loop_print_op3  # Enquanto não tiver printado a quebra de linha, continua

    j exit  # Se leu a quebra de linha simplesmente sai pois já printou tudo

exit:
    li a0, 0    # fd = 0
    li a7, 93   # exit syscall
    ecall 

espera_escrita:    
    lbu t3, write(s0)
    bnez t3, espera_escrita # Aguarda até printar
    ret

espera_leitura:
    lbu t3, read(s0)
    bnez t3, espera_leitura
    ret

atoi:
    li a4, 1    # Flag para saber se o número é negativo
    li a5, 0    # Acumulador para número que será retornado

    loop_atoi:
        lbu t0, 0(a0)
        li t1, '\n'
        beq t0, t1, termina_atoi   # Encerra em \n

        # Ignora whitespace
        li t1, ' '
        beq t0, t1, ignora_whitespace_atoi

        li t1, '-'
        beq t0, t1, marca_neg_atoi
        # Se chegou até aqui, leu um dígito
        addi t0, t0, -'0'   # Transforma de str pra int
        li t1, 10
        mul a5, a5, t1
        add a5, a5, t0

        addi a0, a0, 1  # Avança no ponteiro da string para seguir na leitura
        j loop_atoi

    marca_neg_atoi:
        li a4, -1
        addi a0, a0, 1  # Pula para o próximo byte de leitura
        j loop_atoi

    termina_atoi:
        mul a0, a5, a4  # Múltiplica pelo sinal do número
        ret # Retorna pra onde foi chamada

    ignora_whitespace_atoi:
        addi a0, a0, 1  # Segue para o próximo número ignorando whitespace
        j loop_atoi

itoa:
    mv a3, a1   # Salva o começo da string em a3
    li a4, 0    # Salva quantos bytes vão ser armazenados em a3 para recuperar de sp

    li t0, 10
    beq a2, t0, confere_neg_itoa
    # Se não for base 10, será base hexadecimal
    la a5, hex  # Vetor dos caracteres de hexadecimal
    li a6, 28   # Shift inicial
    li a7, 0    # Flag para indicar se já começou a colocar os números na base hexa
    j base_16_itoa

    confere_neg_itoa:
        bge a0, x0, base_10_itoa

    marca_neg_itoa: # Marca que o número é negativo
        li t0, '-'
        sb t0, 0(a1)
        addi a1, a1, 1

        sub a0, x0, a0  # Transforma o valor em positivo

    base_10_itoa:
        li t1, 10
        rem t0, a0, t1  # Checa o resto da divisão de a0 por 10
        addi t0, t0, '0'    # Transforma de int pra str

        addi sp, sp, -1 # Usa sp para armazenar os bytes de dígitos em a1
        sb t0, 0(sp)    # Armazena o dígito atual em sp

        addi a4, a4, 1  # Marca que salvou mais um dígito
        div a0, a0, t1  # Divide o valor de a0 por 10 para ler o próximo dígito

        bnez a0, base_10_itoa   # Continua enquanto a0 > 0

        j armazena_itoa # Se a0 for 0 termina o loop

    base_16_itoa:
        bltz a6, termina_itoa   # Se o shift for < 0, encerra

        srl t0, a0, a6  # t0 = a0 >> a6(shift)
        andi t0, t0, 0xF # Pega apenas os 4 bits da direita

        bnez t0, coloca_itoa_hex    # Se t0 != 0 coloca no buffer
        beqz a6, coloca_itoa_hex # Se o shift for 0 coloca no buffer
        bnez a7, coloca_itoa_hex    # Se já começou a colocar no buffer
        j prox_itoa

        coloca_itoa_hex:
            add t1, a5, t0  # Acha o endereço do caractére equivalente em hexadecimal
            lb t1, 0(t1)    # Carrega esse caractére
            sb t1, 0(a1)    # Armazena o caractére em hexadecimal na string
            addi a4, a4, 1  # Avança em qual caractére foi inserido
            li a7, 1    # Marca que já começou a alocação dos bytes dessa base
            addi a1, a1, 1  # Avança na string

        prox_itoa:
            addi a6, a6, -4 # Shift de 4 em 4 bits para leitura de hexadecimal em loop
            j base_16_itoa

    armazena_itoa:
        beqz a4, termina_itoa
        # Carrega o dígito a ser inserio na string e o desempilha
        lb t0, 0(sp)
        addi sp, sp, 1
        # Armazena o dígito na string e passa para a próxima posição
        sb t0, 0(a1)
        addi a1, a1, 1

        addi a4, a4, -1 # Diminui a quantidade de dígitos que devem ser colocados na string
        j armazena_itoa

    termina_itoa:
        li t0, '\n'
        sb t0, 0(a1)    # Armazena o \n para indicar que acabou a string
        mv a0, a3   # Recupera o início da string para retorná-lo
        ret # Retorna pra quem a chamou