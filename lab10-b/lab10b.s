.data
    buffer: .space 1    # Tanto os buffers de leitura quanto de impressão são necessários apenas byte a byte
.rodata
    hex: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'

.text
.globl puts, gets, atoi, itoa, exit, recursive_tree_search

puts:
    li a2, 1    # Sempre vai printar byte a byte, economiza linhas

    loop_puts:  # Analisa até achar um \0 e printa byte a byte
        lbu t0, 0(a0)   # byte atual da string
        beqz t0, termina_puts

        # Salva o ponteiro da string para não perdê-la ao printar
        mv t1, a0

        li a0, 1    # fd = 1 (stdout)
        la a1, buffer   # Buffer de print
        sb t0, 0(a1)    # Armazena o caractére de t0 no buffer
        li a7, 64   # Syscall write
        ecall
        # Recupera o ponteiro da string
        mv a0, t1

        addi a0, a0, 1  # Segue para o próximo byte da string a ser printada
        j loop_puts

    termina_puts:
        la a1, buffer   # Buffer de print
        li a4, '\n' # Adiciona a quebra de linha ao final da string
        sb a4, 0(a1)
        li a0, 1    # fd = 1 (stdout)
        li a7, 64   # Syscall write
        ecall

        ret # Retorna para onde foi chamado

gets:
    li a2, 1    # Sempre lê byte a byte, economiza linhas
    mv a3, a0   # Salva o começo da string a ser retornada
    la a4, buffer

    loop_gets:  # Analisa até achar um \n
        # Salva o ponteiro da string para não perdê-la ao ler os inputs
        mv t2, a0

        li a0, 0    # fd = 0 (stdin)
        mv a1, a4   # Buffer de input
        li a7, 63   # Syscall read
        ecall
        # Recupera o ponteiro da string
        mv a0, t2
        # Caso leia um \n encerra
        lbu t0, 0(a4)
        li t1, '\n'
        beq t0, t1, termina_gets
        # Salva o caractere lido na string e avança 1 byte para ler o próximo
        sb t0, 0(a0)
        addi a0, a0, 1

        j loop_gets

    termina_gets:
        sb x0, 0(a0)    # Salva o byte nulo correspondente a \0 no final da string
        mv a0, a3   # Volta pro começo da string
        ret # Retorna para onde foi chamada

atoi:
    li a4, 1    # Flag para saber se o número é negativo
    li a5, 0    # Acumulador para número que será retornado

    loop_atoi:
        lbu t0, 0(a0)
        beqz t0, termina_atoi   # Encerra em \0

        # Ignora whitespaces
        li t1, ' '
        beq t0, t1, loop_atoi

        li t1, '\t'
        beq t0, t1, loop_atoi

        li t1, '\n'
        beq t0, t1, loop_atoi

        li t1, '\v'
        beq t0, t1, loop_atoi

        li t1, '\f'
        beq t0, t1, loop_atoi

        li t1, '\r'
        beq t0, t1, loop_atoi
        # Se for negativo, marca
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
        bltz a6, termina_itoa   # Se o shift for 0, encerra

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
        sb x0, 0(a1)    # Armazena o \0 para indicar que acabou a string
        mv a0, a3   # Recupera o início da string para retorná-lo
        ret # Retorna pra quem a chamou

exit:   # a0 já possui o fd relativo ao código
    li a7, 93   # Syscall exit
    ecall

recursive_tree_search:    # Implementação da função linked_list_search
    li t4, 1    # Profundidade da árvore começa em 1
    li t5, 0    # Flag pra dizer se achou o valor

    # Salva o ra na pilha para conseguir chamar recursivamente
    addi sp, sp, -4
    sw ra, 0(sp)
    # Busca recursiva
    jal percorre_arvore
    # Recupera o valor de ra e o desempilha
    lw ra, 0(sp)
    addi sp, sp, 4

    beqz t5, not_found  # Se não achou, vai retornar 0
    mv a0, t6   # Se achou, recupera do registrador que tem o valor correto
    ret

    not_found:  # Se não achou em nenhuma profundidade o valor procurado, retorna 0
        li a0, 0
        ret

    percorre_arvore:
        lw t0, 0(a0)    # Val
        lw t1, 4(a0)    # Left
        lw t2, 8(a0)    # Right

        beq a1, t0, found   # Se achou um nó que tem o valor do input, encerra a busca

        # Armazena o valor de t0 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t0, 0(sp)
        # Armazena o valor de t1 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t1, 0(sp)
        # Armazena o valor de t2 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t2, 0(sp)

        # Salva o ra na pilha para conseguir chamar recursivamente
        addi sp, sp, -4
        sw ra, 0(sp)
        # Busca no nó à direita
        jal direita

        # Recupera o valor de ra e o desempilha
        lw ra, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t2 e o desempilha
        lw t2, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t1 e o desempilha
        lw t1, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t0 e o desempilha
        lw t0, 0(sp)
        addi sp, sp, 4
        
        bnez t5, termina_dfs    # Se já achou, encerra a função
        # Senão, segue para a busca no outro lado

        # Armazena o valor de t0 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t0, 0(sp)
        # Armazena o valor de t1 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t1, 0(sp)
        # Armazena o valor de t2 na pilha para não perdê-lo
        addi sp, sp, -4
        sw t2, 0(sp)

        # Salva o ra na pilha para conseguir chamar recursivamente
        addi sp, sp, -4
        sw ra, 0(sp)
        # Busca no nó à esquerda
        jal esquerda
        # Recupera o valor de ra e o desempilha
        lw ra, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t2 e o desempilha
        lw t2, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t1 e o desempilha
        lw t1, 0(sp)
        addi sp, sp, 4
        # Recupera o valor de t0 e o desempilha
        lw t0, 0(sp)
        addi sp, sp, 4
        
    termina_dfs:
        ret
        
    direita:
        beqz t2, null_pointer # Se for um ponteiro nulo, não aumenta a profundidade e só retorna 

        addi t4, t4, 1  # Senão, aumenta a profundidade e continua a busca
        
        mv t3, a0   # Salva o ponteiro atual 
        mv a0, t2   # Passa para o nó da direita
        # Salva o ra na pilha para conseguir chamar recursivamente
        addi sp, sp, -4
        sw ra, 0(sp)
        # Busca recursiva
        jal percorre_arvore
        # Recupera o valor de ra e o desempilha
        lw ra, 0(sp)
        addi sp, sp, 4

        bnez t5, termina_dfs    # Se achou, encerra
        # Senão, volta para a profundidade anterior
        addi t4, t4, -1
        mv a0, t3   # Recupera o ponteiro do nó anterior
        
        ret

    esquerda:
        beqz t1, null_pointer # Se for um ponteiro nulo, não aumenta a profundidade e só retorna

        addi t4, t4, 1  # Senão, aumenta a profundidade e continua a busca
        
        mv t3, a0   # Salva o ponteiro atual
        mv a0, t1   # Passa para o nó da esquerda
        # Salva o ra na pilha para conseguir chamar recursivamente
        addi sp, sp, -4
        sw ra, 0(sp)
        # Busca recursiva
        jal percorre_arvore
        # Recupera o valor de ra e o desempilha
        lw ra, 0(sp)
        addi sp, sp, 4

        bnez t5, termina_dfs    # Se achou, encerra
        # Senão, volta para a profundidade anterior
        addi t4, t4, -1
        mv a0, t3   # Recupera o ponteiro do nó anterior

        ret

    null_pointer:
        ret
        
    found:
        mv t6, t4   # Salva em qual profundidade achou em um registrador temporário para não sujar o a0
        li t5, 1    # Avisa que achou
        ret

