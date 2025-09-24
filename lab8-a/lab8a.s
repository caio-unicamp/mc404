.data 
    input_file: .asciz "image.pgm"  # Caminho para o arquivo de imagem
    buffer_image: .space 263000 # Tamanho em bytes com margem de erro para uma imagem no máximo 512 x 512  
.text
.globl _start

_start:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall

    mv s0, a0   # Salva o file descriptor em s0

    # Fecha o arquivo pra poder usar o file descriptor novamente
    li a0, 3             # file descriptor (fd) 3
    li a7, 57            # syscall close
    ecall

read:
    mv a0, s0   # file descriptor pra imagem 
    la a1, buffer_image # buffer de leitura
    li a2, 263000   # Tamanho máximo de 512 x 512 mais uma margem de erro
    li a7, 63   # Syscall read
    ecall

    mv s1, a0   # Salva o tamanho da imagem em bytes no registrador s1
    la s2, buffer_image # Carrega o conteúdo da imagem lida no registrador s2

    li t0, 0    # Condição de parada, bytes a mais lidos sem conteúdo são salvos como 0
salva_pixels:

