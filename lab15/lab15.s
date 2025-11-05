.bss 
  .align 4
  stack_pointer: .space 1024

.text
.align 4
.set base, 0xFFFF0100
.set gps, 0x0
.set x, 0x10
.set y, 0x14
.set z, 0x18
.set volante, 0x20
.set motor, 0x21
.set freio, 0x22

int_handler:
  ###### Syscall and Interrupts handler ######

  # <= Implement your syscall handler here
  li t0, 10
  beq a7, t0, syscall_set_engine_and_steering  # syscall_set_engine_and_steering
  li t0, 11
  beq a7, t0, syscall_set_hand_brake  # syscall_set_hand_brake
  li t0, 15
  beq a7, t0, syscall_get_position  # syscall_get_position
  
  retorno:  # Volta para onde foi chamada a syscall
    csrr t0, mepc  # Carrega o endereço de retorno (referente à instrução que chamou a syscall)
    addi t0, t0, 4 # Soma 4 no endereço de retorno para retornar após a syscall
    csrw mepc, t0  # Armazena o endereço de retorno novo no mepc
    mret           # Retorna recuperando o contexto (pc <- mepc)

  syscall_set_engine_and_steering:  # Controle da syscall que trabalha com o motor e com o volante
    li t0, base
    sb a0, motor(t0)  # Seta o estado do motor
    sb a1, volante(t0)  # Seta a posição do volante

    j retorno

  syscall_set_hand_brake: # Controla se o freio de mão deve ser ativado ou não
    li t0, base
    sb a0, freio(t0)  # Seta o estado do freio de mão

    j retorno

  syscall_get_position:
    li t0, base
    li t1, 1
    sb t1, gps(t0)  # Liga o GPS

    espera_leitura_gps:
      lbu t1, gps(t0)
      bnez t1, espera_leitura_gps # Enquanto não terminar a leitura das posições continua
    # Carrega as posições do carro nos respectivos registradores
    lw a0, x(t0)
    lw a1, y(t0)
    lw a2, z(t0)

    j retorno

.globl _start
_start:
  la sp, stack_pointer    # Inicializa o final da stack pointer
  addi sp, sp, 1024   # Vai para o topo da pilha

  la t0, int_handler  # Load the address of the routine that will handle interrupts
  csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.

# Write here the code to change to user mode and call the function
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.
  csrr t1, mstatus # Update the mstatus.MPP
  li t2, ~0x1800 # field (bits 11 and 12)
  and t1, t1, t2 # with value 00 (U-mode)
  csrw mstatus, t1
  la t0, user_main # Loads the user software
  csrw mepc, t0 # entry point into mepc
  mret # PC <= ME
  
.globl control_logic
control_logic:  # Lógica do controle do carro através de syscalls implementadas manualmente
    loop_movimento_carro:
      li a7, 15 # syscall_get_position
      ecall   # a0 = x, a1 = y, a2 = z
      mv s0, a0 # s0 = x
      mv s2, a2 # s2 = z

      li a0, 1  # Liga o motor do carro
      li a1, -15  # Gira o volante 15 graus pra esquerda
      li a7, 10 # syscall_set_engine_and_steering
      ecall 
      # Calcula a distância do carro pro destino final
      addi t0, s0, -73 # t0 = x - xf
      mul t0, t0, t0  # t0 = (x - xf)²

      addi t1, s2, +19    # t1 = z - zf
      mul t1, t1, t1  # t1 = (z - zf)²

      add t2, t0, t1  # t2 = d² = (x - xf)² + (y - yf)²

      li t0, 225
      bge t2, t0, loop_movimento_carro  # Enquanto a distância do carro pro ponto final for maior que 15, continua no loop

    li a0, 0  # Desliga o motor
    li a1, 0  # Seta o volante para o meio
    li a7, 10 # syscall_set_engine_and_steering
    ecall

    li a0, 1  # Ativa o freio de mão 
    li a7, 11 # syscall_set_hand_brake
    ecall
      