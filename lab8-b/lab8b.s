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
    lbu t0, 0(a3)    # Carrega o ubyte atual lido

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
    addi t2, t2, 1 # Avança no valor de qual dimensão acabou de ser lida

    li t1, 2
    beq t2, t1, salva_altura    # Se tiver lido a altura salva os pixels
    # Se não salva o registrador a4 o valor da largura
    mv a4, t3
    li t3, 0    # Reinicia o acumulador pra achar o valor da altura
    j dimensao  # Volta pra ler a altura

salva_altura:
    mv a5, t3   # Salva no registrador a5 o valor da altura

    addi a3, a3, 4  # Atualmente acabou de ler o último whitespace antes do MAXVAL, estando agora no primeiro número desse, porém sabe-se que para todas as imagens esse valor será 255 então ignora esses 3 bytes + o byte de whitespace, que dessa vez sabe-se que é único, antes de começar a leitura dos pixels reais

    mv s5, a3   # Marca onde está o começo da imagem em s5
    mv s6, a4   # Salva a largura original em s6
    mv s7, a5   # Salva a altura original em s7
tamanho_tela:

    mv a0, a4   # Largura da tela
    mv a1, a5   # Altura da tela
    li a7, 2201 # syscall setCanvasSize
    ecall

    li t1, 0    # Marca em qual altura está 
    li t2, 0    # Marca em qual largura está
    

marca_pixel:    # Marca os pixels da matriz de output aplicando a convolução com o kernel
    # 
    #       -1  -1  -1
    #   w = -1   8  -1
    #       -1  -1  -1
    #
    
    # Se estiver em uma das bordas 
    beq t1, x0, preto
    beq t2, x0, preto

    addi t3, a4, -1
    beq t2, t3, preto
    
    addi t3, a5, -1
    beq t1, t3, preto

    beq t2, a4, pulo_output # Se estiver na última coluna, pula de linha

    # offset = (t1 - 1) * largura + (t2 - 1)
    addi t4, t1, -1     # t4 = y_out - 1
    mul t4, t4, s6      # t4 = (y_out - 1) * largura_original (s6)
    addi t5, t2, -1     # t5 = x_out - 1
    add t4, t4, t5      # t4 = offset final
    add a3, s5, t4      # a3 = endereço_inicial_dos_pixels (s5) + offset

    add s1, a3, s6  # Salva o ponteiro pra linha logo abaixo 
    add s2, s1, s6  # Salva o ponteiro pra linha duas abaixo
    # Os passos abaixo realizam a soma de 8 pixels menos o central pra só depois múltiplicar por -1
    lbu s3, 0(a3)   # Carrega o pixel atual 
    lbu t0, 1(a3)   # Carrega o pixel logo à frente 
    add s3, s3, t0

    lbu t0, 2(a3)   # Carrega o último pixel que será lido na mesma linha
    add s3, s3, t0 

    lbu t0, 0(s1)   # Carrega o primeiro pixel da segunda linha
    add s3, s3, t0

    lbu t0, 2(s1)   # Carrega o último pixel da segunda linha
    add s3, s3, t0

    lbu t0, 0(s2)   # Carrega o primeiro pixel da terceiro linha
    add s3, s3, t0  

    lbu t0, 1(s2)   # Carrega o segundo pixel da terceira linha
    add s3, s3, t0

    lbu t0, 2(s2)   # Carrega o último pixel da terceira linha
    add s3, s3, t0

    sub s3, x0, s3  # Múltiplica a soma de todos os 8 da borda por -1

    lbu t0, 1(s1)   # Carrega o pixel do meio
    li s4, 8
    mul s4, s4, t0  # 8*pixel do meio

    add s3, s3, s4  # Finaliza a soma e salva o pixel de output em s3
    jal ra, confere_limite  

    slli t0, s3, 24 # Referente ao R
    slli s1, s3, 16 # Referente ao G
    slli s2, s3, 8  # Referente ao B
    li t4, 0xFF     # Alpha = 255 em todos

    or t0, t0, s1   # R or G combina os dois
    or t0, t0, s2   # R or G or B combina os três
    or t0, t0, t4   # R or G or B or A combina os quatro
    # t0 = 0xRRGGBBAA filtrado

    mv a0, t2   # Coordenada x do pixel
    mv a1, t1   # Coordenada y do pixel
    mv a2, t0   # pixel filtrado
    li a7, 2200 # Syscall setPixel
    ecall

    addi t2, t2, 1  # Parte para a próxima coluna

    j marca_pixel

confere_limite: # Verifica se o número ultrapassou os limites de um byte
    blt s3, x0, set_zero
    li t0, 255
    bge s3, t0, set_max
    ret
set_zero:   # Caso seja menor que 0 seta pra 0
    li s3, 0 
    ret
set_max:    # Caso seja maior que o máximo seta pro máximo
    li s3, 255
    ret

confere_altura_output:
    beq t1, a5, confere_coluna_output   # Confere se está na última linha
    ret
confere_coluna_output:
    beq t2, a4, marca_fim_output    # Confere se está na última coluna da última linha
    ret
marca_fim_output:
    li t3, 0    # Caso esteja, marca que encerrou
    ret

pulo_output:
    # Pra pular uma linha aumenta em 1 o valor da altura, aumenta o buffer pra próxima linha reseta o valor da coluna e volta a ler o loop
    addi t1, t1, 1
    li t2, 0
    j marca_pixel
    
preto:
    mv a0, t2   # Coordenada x do pixel
    mv a1, t1   # Coordenada y do pixel
    li a2, 0   # Preto
    li a7, 2200 # Syscall setPixel
    ecall

    jal confere_altura_output

    li t3, 0   # Flag pra indicar se já acabou os loops, se manter assim encerra
    jal ra, confere_altura_output
    li t4, 1
    beq t3, t4, escala_tela # Caso já tenha chegado ao final do loop parte pra próxima parte 

    beq t2, a4, pulo_output # Se estiver na última coluna, pula de linha

    addi t2, t2, 1  # Parte para a próxima coluna

    j marca_pixel
    
escala_tela:
    # mv a0, a4   # Largura
    # mv a1, a5   # Altura
    # li a7, 2202 # Syscall setScaling

exit:
    # Fecha o arquivo
    li a0, 3             # file descriptor (fd) 3
    li a7, 57            # syscall close
    ecall
    
    li a0, 0
    li a7, 93   # Exit syscall 
    ecall