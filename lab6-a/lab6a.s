.data
    newline: .asciiz "\n"

.section .text
.globl _start
_start:
    li t0, 0        # começa a leitura em i = 0

1: #Começo do loop
    add t1, t1, a0  # Byte offset pra str[i]
    
    
    
    li t1, 5        # Set loop limit (i <= 10)

loop_start:
    # Print the current number
    mv a0, t0       # Move current number to a0 for printing
    li a7, 1        # System call code for print_int
    ecall

    # Print a newline for readability
    la a0, newline  # Load address of newline string
    li a7, 4        # System call code for print_string
    ecall

    addi t0, t0, 1  # Increment loop counter (i = i + 1)
    ble t0, t1, loop_start # If i <= 5, repeat loop

    # Exit program
    li a7, 10       # System call code for exit
    ecall

    li a0, 0  # (stdin)
    la a1, input_address #  buffer para escrever os dados
    li a2, 5  # size (lê 5 bytes por iteração)
    li a7, 63 # syscall read (63)
    ecall

input_address: .skip 0x10  # buffer

1: #Começa o loop










    li a0, 1            # file descriptor = 1 (stdout)
    la a1, string       # buffer
    li a2, 19           # size
    li a7, 64           # syscall write (64)
    ecall
string:  .asciz "Hello! It works!!!\n"
