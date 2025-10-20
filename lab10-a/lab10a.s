.data
    buffer: .space 1

.text
.globl _start

_start:

ler:    # Ler o input referente ao índice do caso teste
    li a0, 1    # fd = 1 (stdin)
    mv a1, a3   # Buffer que lê o índice do caso teste
    li a2, 1    # size = 1 
    li a7, 63   # syscall read
    ecall   

puts:
    li a2, 1    # Sempre vai printar byte a byte, economiza linhas

    loop_puts:  # Analisa até achar um \0 e printa byte a byte
        lbu t0, 0(a0)   # byte atual da string
        beqz t0, termina_puts

        # Salva o ponteiro da minha string para não perdê-la ao printar
        addi sp, sp, -4
        sw a0, 0(sp)
        
        li a0, 0    # fd = 0 (stdout)
        la a1, buffer   # Buffer de print
        li a7, 64   # Syscall write
        ecall
        # Recupera o ponteiro da string e desempilha ele
        lw a0, 0(sp)    
        addi sp, sp, 4

        j loop_puts # Lê-se em loop

    termina_puts:
        li a4, '\n' # Adiciona a quebra de linha ao final da string

        li a0, 0    # fd = 0 (stdout)
        la a1, buffer   # Buffer de print
        li a7, 64   # Syscall write
        ecall

        ret # Retorna para onde foi chamado

gets:
    li a2, 1    # Sempre lê byte a byte, economiza linhas
    mv a3, a0   # Salva o começo da string a ser retornada 
    la a4, buffer

    loop_gets:  # Analisa até achar um \n 
        # Salva o ponteiro da string para não perdê-la ao ler os inputs
        addi sp, sp, -1
        sb a0, 0(sp)

        li a0, 1    # fd = 1 (stdin)
        mv a1, a4   # Buffer de input
        li a7, 63   # Syscall read
        ecall
        # Caso leia um \n encerra
        lbu t0, 0(a4)
        li t1, '\n'
        beq t0, t1, termina_gets
        # Recupera o valor da string e desempilha ele
        lb a0, 0(sp)
        addi sp, sp, 1
        # Salva o caractere lido na string e avança 1 byte para ler o próximo
        sb t0, 0(a0)
        addi a0, a0, 1 

        j loop_gets

    termina_gets: 
        sb x0, 0(a0)    # Salva o byte nulo correspondente a \0 no final da string     
        mv a0, a3   # Volta pro começo da string
        ret # Retorna para onde foi chamada
atoi:

itoa:

exit:

linked_list_search_node:    # Implementação da função linked_list_search_node
    inicializacao:
        li t4, 0    # Índice da linked-list começa em 0

    percorre_lista:
        lw t0, 0(a0)    # Val1
        lw t1, 4(a0)    # Val2
        lw t2, 8(a0)    # Next

        add t5, t0, t1  # Val1 + Val2    
        beq s1, t5, found   # Se achou um nó que a soma dos valores é meu input, encerra a busca

        beqz t2, not_found    # Null-pointer, encerra a busca caso não exista próximo

        addi t4, t4, 1 # Aumenta o índice
        mv a0, t2   # Segue para o próximo nó
        j percorre_lista
        
    found:
        mv a0, t4   # Salva em qual índice achou e retorna ele
        ret

    not_found:  # Se não achou nenhum índice que contenha a soma retorna -1
        li a0, -1
        ret