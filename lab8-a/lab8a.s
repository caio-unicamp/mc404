.data 
    input_file: .asciz "image.pgm"  # Caminho para o arquivo de imagem
    buffer_image: .space 263000 # Tamanho em bytes com margem de erro para uma imagem no máximo 512 x 512  
.text
.globl _start

_start:
    la a3, buffer_image # Buffer pro conteúdo da imagem
    li a4, 0    # Largura da imagem
    li a5, 0    # Altura da imagem

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
    li t2, 0    # Marca qual dimensão foi lida
    li t3, 0    # Acumulador pro valor da dimensão

dimensao:
    lb t0, 0(a3)    # Carrega o byte atual lido

    addi a3, a3, 1  # Move o buffer pra conferir o próximo byte antes de quebrar essa função

    li a1, 0    # Flag pra dizer se achou ou não um whitespace
    jal ra, confere_whitespace  # Parte pra procurar whitespace
    
    li t4, 1
    beq a1, t4, proxima_linha   # Se achou um whitespace vai pra próxima dimensão
    
    addi t0, t0, -'0'   # Transforma de str pra int
    # t3 = 10*t3 + t0
    li t1, 10
    mul t3, t3, t1
    add t3, t3, t0

    j dimensao   # Continua lendo até achar o valor da dimensão da imagem

confere_whitespace:
    # Analisa se é um dos diferentes tipos de whitespace
    li t1, ' '  # Blankspace
    beq t0, t1, marca_whitespace

    li t1, '\n' # LF (Line Feed) quebra de linha
    beq t0, t1, marca_whitespace

    li t1, '\t' # Horizontal Tab
    beq t0, t1, marca_whitespace

    li t1, '\r' # CR (Carriage Return)
    beq t0, t1, marca_whitespace

    ret # Se não for um whitespace volta pra ler a dimensão

marca_whitespace:
    li a1, 1    # Marca que achou um whitespace
    ret

proxima_linha:
    addi, t2, t2, 1 # Avança no valor de qual dimensão acabou de ser lida

    li t1, 2
    beq t2, t1, salva_altura    # Se tiver lido a altura salva os pixels
    # Se não salva o registrador a4 o valor da largura
    mv a4, t3
    li t3, 0    # Reinicia o acumulador pra achar o valor da altura
    j dimensao  # Volta pra ler a altura

salva_altura:
    mv a5, t3   # Salva no registrador a5 o valor da altura

    addi a3, a3, 4  # Atualmente acabou de ler o último whitespace antes do MAXVAL, estando agora no primeiro número desse, porém sabe-se que para todas as imagens esse valor será 255 então ignora esses 3 bytes + o byte de whitespace, que dessa vez sabe-se que é único, antes de começar a leitura dos pixels reais

marca_pixels:
    # for (int i = 0; i < altura; i++){
    #   for (int j = 0; j < largura; j++{
    #       set_pixel
    #   }
    #}