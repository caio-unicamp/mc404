.data
    _system_time: .word 0 
.bss 
    .align 4
    stack_pointer: .space 1024 
    isr_stack: .space 1024
isr_stack_end:  # Base da pilha de ISR


.text
.set base_gpt, 0xFFFF0100
.set read_sys_time, 0x0
.set tempo, 0x4
.set temp_interromper, 0x8

.set base_synthesizer, 0xFFFF0300
.set chanel, 0x0
.set intrument_ID, 0x02
.set nota, 0x04
.set vel_nota, 0x05
.set dur_nota, 0x06

.globl _start, play_note, _system_time

_start: # Inicializa sp, seta interrupções e chama a função main
    la sp, stack_pointer    # Inicializa o final da stack pointer
    addi sp, sp, 1024   # Vai para o topo da pilha

    li s0, base_gpt # Memória base do GPT está em s0
    li s1, base_synthesizer # Memória base do synthesizer está em s1
    la s2, _system_time # Carrega o tempo em s2
    
    # Setando interrupções
    # Registrando a ISR por direct mode
    la t0, main_isr # Carrega o endereço da main_isr em mtvec
    csrw mtvec, t0 

    # Configura mscratch com o topo da pilha das ISRs.
    la t0, isr_stack_end # t0 <= base da pilha
    csrw mscratch, t0 # mscratch <= t0

    # Configura GPT
    li t0, 100
    sw t0, temp_interromper(s0) # Interrompe a cada 100ms

    # Habilita interrupções externas
    csrr t1, mie # Seta o bit 11 (MEIE)
    li t2, 0x800 # do registrador mie
    or t1, t1, t2
    csrw mie, t1
    # Habilita interrupções globais
    csrr t1, mstatus # Seta o bit 3 (MIE)
    ori t1, t1, 0x8 # do registrador mstatus
    csrw mstatus, t1
        
    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de chamar a main
    jal main

exit:   # Encerra o programa
    li a0, 0    # fd = 0 
    li a7, 93   # Exit syscall
    ecall


play_note:  # void play_note(int ch, int inst, int note, int vel, int dur)
    sh a1, intrument_ID(s1) # Armazena o short referente ao ID do instrumento
    sb a2, nota(s1) # Armazena o byte referente à nota a ser tocada
    sb a3, vel_nota(s1) # Armazena o byte referente à velocidade da nota
    sh a4, dur_nota(s1) # Armazena o short referente à duração da nota

    sb a0, chanel(s1)   # Armazena o byte referente ao canal em que será tocada a nota MIDI
    ret

main_isr:
    # Troca de pilha
    csrrw sp, mscratch, sp      # troca pilha normal <-> pilha de ISR

    # Salva contexto mínimo (ra e temporários)
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)

    # Incrementa o tempo global
    la t0, _system_time
    lw t1, 0(t0)
    addi t1, t1, 100
    sw t1, 0(t0)

    # Reprograma GPT
    li t3, 100
    sw t3, temp_interromper(s1)

    # Restaura contexto
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16

    csrrw sp, mscratch, sp      # Volta pilha normal
    mret
