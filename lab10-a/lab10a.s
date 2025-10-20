.data
    input_buffer: .space 1
    output_buffer: .space 1
.text
.globl _start

_start:
    la a3, input_buffer # Buffer que irá retornar o índice referente ao caso teste
    la a4, output_buffer    # Buffer dos outputs

ler:    # Ler o input referente ao índice do caso teste
    li a0, 1    # fd = 1 (stdin)
    mv a1, a3   # Buffer que lê o índice do caso teste
    li a2, 1    # size = 1 
    li a7, 63   # syscall read
    ecall   

puts:
    loop_puts:  # Analisa até achar um \0 e printa byte a byte
        lbu t0, 0(a0)   # byte atual da string
        beqz t0, termina_puts

        # Salva o ponteiro da minha string para não perdê-la ao printar
        addi sp, sp, -4
        sw a0, 0(sp)
        
        li a0, 0    # fd = 0 (stdout)
        mv a1, a4   # Buffer de print
        li a2, 1    # Printa byte a byte
        li a7, 64   # Syscall write
        ecall
        # Recupera o ponteiro da string e desempilha ele
        lw a0, 0(sp)    
        addi sp, sp, 4

        j loop_puts # Lê-se em loop

    termina_puts:
        li a4, '\n' # Adiciona a quebra de linha ao final da string

        li a0, 0    # fd = 0 (stdout)
        mv a1, a4   # Buffer de print
        li a2, 1    # Printa byte a byte
        li a7, 64   # Syscall write
        ecall

        ret # Retorna para onde foi chamado

gets:

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