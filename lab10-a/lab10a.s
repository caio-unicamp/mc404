.data
    input_buffer: .space 1
    output_buffer: .space 5
.text
.globl _start

_start:
    la a3, input_buffer # Buffer que irá retornar o índice referente ao caso teste

ler:    # Ler o input referente ao índice do caso teste
    li a0, 1    # fd = stdin
    mv a1, a3   # Buffer que lê o índice do caso teste
    li a2, 1    # size = 1 
    li a7, 63   # syscall read
    ecall   

puts:

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