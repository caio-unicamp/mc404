.text
.set base_gpt, 0xFFFF0100
.set read_sys_time, 0x0
.set tempo, 0x4
.set temp_interromper, 0x8

.set base_synthesizer, 0xFFFF0300
.set start_play, 0x0
.set intrument_ID, 0x02
.set nota, 0x04
.set vel_nota, 0x05
.set dur_nota, 0x06

.globl _start, main, _system_time, play_note

_start: # Inicializa sp, seta interrupções e chama a função main
    
    addi sp, sp, -4
    sw ra, 0(sp)    # Salva o ra antes de chamar a main
    jal main


play_note:
