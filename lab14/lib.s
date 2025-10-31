.data
    _system_time: 0 
.bss 
    .align 16
    stack_pointer: .space 1024 


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

.globl _start, main

_start: # Inicializa sp, seta interrupções e chama a função main
    la sp, stack_pointer    # Inicializa o final da stack pointer
    la s0, base_gpt # Memória base do GPT está em s0
    la s1, base_synthesizer # Memória base do synthesizer está em s1
    
    # Setar interrupções
        
    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de chamar a main
    jal main

exit:
    li a0, 0    # fd = 0 
    li a7, 93   # Exit syscall
    ecall


play_note:  # void play_note(int ch, int inst, int note, int vel, int dur)
    sh a1, intrument_ID(s1) # Armazena o short referente ao ID do instrumento
    sb a2, note(s1) # Armazena o byte referente à nota a ser tocada
    sb a3, vel_nota(s1) # Armazena o byte referente à velocidade da nota
    sh a4, dur_nota(s1) # Armazena o short referente à duração da nota

    sb a0, chanel(s1)   # Armazena o byte referente ao canal em que será tocada a nota MIDI
    ret

