.text
.align 4

int_handler:
  ###### Syscall and Interrupts handler ######

  # <= Implement your syscall handler here

  csrr t0, mepc  # load return address (address of
                 # the instruction that invoked the syscall)
  addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
  csrw mepc, t0  # stores the return address back on mepc
  mret           # Recover remaining context (pc <- mepc)


.globl _start
_start:

  la t0, int_handler  # Load the address of the routine that will handle interrupts
  csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                      # the interrupt array.

# Write here the code to change to user mode and call the function
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.

.globl control_logic
control_logic:
  # implement your control logic here, using only the defined syscalls
