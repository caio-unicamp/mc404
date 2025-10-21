.data
    my_var: .word 10

.text
.globl increment_my_var

increment_my_var:
    la t0, my_var   # Carrega o endereço da variável global
    lw t1, 0(t0)    # Carrega o valor da variável
    addi t1, t1, 1  # Adiciona 1 nesse valor
    sw t1, 0(t0)    # Salva novamente no endereço dela