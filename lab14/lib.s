.text
.globl _start, main

_start: # Inicializa sp, seta interrupções e chama a função main
    
    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de chamar a main
    jal main


