.data 
    input_file: .asciz "image.pgm"  # Caminho para o arquivo de imagem
    buffer_image: .space 263000 # Tamanho em bytes com margem de erro para uma imagem no máximo 512 x 512  
.text
.globl _start

_start:
    la a3, buffer_image # Buffer pro conteúdo da imagem

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

    addi a3, a3, 3  # Tendo certeza que é um arquivo pgm, os dois primeiros bytes lidos são os números mágicos "p" e "5" e o próximo byte é um whitespace, a partir daq encontra-se primeiro a largura e depois a altura

largura:
    lb t0, 0(a3)    # Carrega o byte atual lido
    # Analisa se é um dos diferentes tipos de whitespace
    li t1, ' '  # Blankspace
    beq t0, t1, altura

    li t1, '\n' # LF (Line Feed) quebra de linha
    beq t0, t1, altura

    li t1, '\t' # Horizontal Tab
    beq t0, t1, altura

    li t1, '\r' # CR (Carriage Return)
    beq t0, t1, altura

altura:
