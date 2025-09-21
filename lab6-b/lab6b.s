.data
    buf_output_in1: .space 12   # Esse buffer será usado tanto para leitura da primeira linha quanto para saída
    buf_input2: .space 20   # Buffer para a leitura da segunda linha

.text
.globl _start

_start:
    li t1, 0    # Fará mudança de str pra int
    li a5, 12    # Flag pra dizer em que linha está a partir do tamanho da leitura
    li a4, 0    # Flag pra dizer em que número está
    la a3, buf_output_in1   # Ponteiro pra primeira leitura

read:
    # Leitura da primeira linha
    li a0, 0  # file descriptor = 0 (stdin)
    mv a1, a3 #  buffer to write the data
    mv a2, a5  # size (12 bytes - 1º; 20 bytes - 2º)
    li a7, 63 # syscall read (63)
    ecall

    li t0, 20
    beq a5, t0, str_to_int  # Se estiver lendo a segunda linha ignora números negativos
    
    lb t3, 0(a3)    # Salva o sinal do número
    addi a3, a3, 1  # Começa leitura dos dígitos
    li t0, '-'
    beq t3, t0, negativo   # Se o número for negativo muda o sinal dele

    li t3, 1    # Se chegou até aqui o primeiro número lido é positivo

str_to_int:
    lb t0, 0(a3)    # Pega o caractere atual da string 
    li t2, ' '
    beq t0, t2, prox_num    
    li t2, '\n'
    beq t0, t2, prox_linha  # se for '\n' vai pra prox linha

    addi t0, t0, -'0'   # Muda de str pra int
    mul t0, t0, t3  # Sinal
    # t1 = 10*t1 + t0
    li t2, 10
    mul t1, t1, t2  
    add t1, t1, t0

    addi a3, a3, 1  # Segue no buffer da string
    j str_to_int    # Continua a passagem 

prox_num:
    addi a4, a4, 1  # Adiciona 1 pra dizeer em que número está
    addi a3, a3, 1  # Segue para o próximo caractere

    # Analisa em que número está para salvar no registrador correto
    li t0, 1
    beq a4, t0, salva_yb
    li t0, 3
    beq a4, t0, salva_ta
    li t0, 4
    beq a4, t0, salva_tb
    li t0, 5
    beq a4, t0, salva_tc

prox_linha:
    li t0, 20
    beq a5, t0, salva_tr # Se foi pra próxima linha e o buffer é de tamanho 20 salva a última variável

    addi a4, a4, 1  # a4 = 2 (2º número)
    j salva_xc  # Salva o valor de xc 

salva_yb:   # O valor de Yb está em s1
    mv s1, t1   # Salva o valor temporário em um registrador
    
    li t1, 0    # Reseta o valor que será salvo

    lb t3, 0(a3)    # Salva o sinal do segundo número
    addi a3, a3, 1  # Começa leitura do Xc
    li t0, '-'
    beq t3, t0, negativo   # Se o número for negativo muda o sinal dele

    li t3, 1    # Se não for negativo apenas passa como positivo
    j str_to_int    # Volta para passar de str pra int
salva_xc:   # O valor de Xc está em s2
    mv s2, t1

    li a5, 20   # Muda o tamanho para a próxima leitura de linha
    la a3, buf_input2   # Carrega o buffer pro segundo input

    li t1, 0    # Reseta o valor que será salvo
    j read    # Volta para ler a nova linha
salva_ta:   # O valor de Ta está em s4
    mv s4, t1
    
    li t1, 0    # Reseta o valor que será salvo para a próxima variável
    j str_to_int    # Volta para passar de str pra int
salva_tb:   # O valor de Tb está em s5
    mv s5, t1
    
    li t1, 0    # Reseta o valor que será salvo
    j str_to_int    # Volta para passar de str pra int
salva_tc:   # O valor de Tc está em s6
    mv s6, t1
    
    li t1, 0    # Reseta o valor que será salvo
    j str_to_int    # Volta para passar de str pra int
salva_tr:   # O valor de Tr está em s7
    mv s7, t1

    sub s4, s7, s4  # Ta medido = Tr - Ta
    sub s5, s7, s5  # Tb medido = Tr - Tb
    sub s6, s7, s6  # Tc medido = Tr - Tc

    # Salva agora as distâncias em vez dos tempos usando c = 3*10^8 m/s e sabendo que os tempos estão em ns
    li t1, 3
    mul s4, s4, t1

    li t0, 10
    li t6, 5
    blt s4, x0, arredonda_dist_neg_s4
    add s4, s4, t6
    j arredonda_dist_s4
arredonda_dist_neg_s4:
    sub s4, s4, t6
arredonda_dist_s4:
    div s4, s4, t0

    mul s5, s5, t1

    blt s5, x0, arredonda_dist_neg_s5
    add s5, s5, t6
    j arredonda_dist_s5
arredonda_dist_neg_s5:
    sub s5, s5, t6
arredonda_dist_s5:
    div s5, s5, t0

    mul s6, s6, t1

    blt s6, x0, arredonda_dist_neg_s6
    add s6, s6, t6
    j arredonda_dist_s6
arredonda_dist_neg_s6:
    sub s6, s6, t6
arredonda_dist_s6:
    div s6, s6, t0
    
    # Como em nenhum momento é usado as distâncias simples, salva o quadrado delas
    mul s4, s4, s4  # dA² está em s4
    mul s5, s5, s5  # dB² está em s5
    mul s6, s6, s6  # dC² está em s6

calculos:   # Aplica os cálculos da coordenada
    # Os passos abaixo calculam y = (dA² + Yb² - dB²)/2Yb que ficará salvo em s8
    li t1, 2
    mul s8, s1, s1  # Yb²
    add s8, s8, s4  # dA² + Yb² 
    sub s8, s8, s5  # dA² + Yb² - dB²

    div s8, s8, t1
    div s8, s8, s1
    # Os passos abaixo calculam x² = dA² - y² que ficará salvo em s9
    mul s9, s8, s8
    li t1, -1
    mul s9, s8, t1
    add s9, s9, s4
    mv t3, s9   # Auxiliar para as iterações da raiz

    li a1, 21   # Números de iterações pro cálculo da raiz

    li t1, 2
    div t2, t3, t1  # Inicializa o auxiliar como o número dividido por 2, t2 = k = num/2

raiz:   # Calcula a raiz quadrada utilizando o método babilônico
    div t0, t3, t2  # Divide num por k, t0 = num/k
    add t0, t0, t2  # Soma k com num/k, t0 = k + (num/k)
    div t2, t0, t1  # Divide tudo por 2, t2 = (k + (num/k))/2 = aux

    addi a1, a1, -1 # Subtrai o contador de iterações 21 >= a1 >= 1

    li t4, 1
    beq a1, t4, escolha

    j raiz  # Continua no loop enquanto não fizer 21 iterações

negativo:
    li t3, -1   # t3 diz o sinal
    j str_to_int    # Começa a passar de str pra int de acordo com o sinal

escolha:    # Escolhe qual a melhor raíz para o x, a positiva ou a negativa
    mv s9, t2   # Salva o valor da raíz aproximada em s9

    # Os passos abaixo calculam o erro quadrático em relação a dC para a raíz positiva (x-Xc)² + y² que será salvo em t2 
    sub t2, s9, s2  # x - xc
    mul t2, t2, t2  # (x - xc)²
    mul t3, s8, s8  # y²
    add t2, t2, t3  # (x - xc)² + y²
    sub t2, t2, s6  # (x - xc)² + y² - dC²
    mul t2, t2, t2  # ((x - xc)² + y² - dC²)²

    # Os passos abaixo calculam o erro quadrático em relação a dC para a raíz negativa -((x-Xc)² + y²) que será salvo em t4
    li t5, -1
    mul s10, s9, t5 # Salva o valor da raíz negativa
    sub t4, s10, s2 # x - xc
    mul t4, t4, t4    # (x - xc)²
    # t3 já é y²
    add t4, t4, t3  # (x - xc)² + y²
    sub t4, t4, s6  # (x - xc)² + y² - dC²
    mul t4, t4, t4  # ((x - xc)² + y² - dC²)²

    la a3, buf_output_in1   # Carrega o buffer para o print
    mv s3, a3   # Movimenta o print byte a bytey

    li t0, '+'
    sb t0, 0(s3)    # Se continuar assim já salvou o primeiro byte como positivo pra raíz negativa

    blt t2, t4, print_x # if t2 < t4 não precisa alterar o sinal pois a raíz mais próxima é a positiva

    li t0, '-'
    sb t0, 0(s3)    # Caso contrário, salva o primeiro byte como - pra dizer que o número é negativo

print_x:
    li t0, 1000
    div t1, s9, t0  # Salva o primeiro dígito de x em t1
    rem t2, s9, t0  # Salva o resto da divisão por 1000 em t2
    mv s9, t2   # Salva o valor do resto de novo em s9

    addi t1, t1, '0'    # Transforma o primeiro dígito em string
    sb t1, 1(s3)    # Coloca no segundo byte do buffer

    li t0, 100
    div t1, s9, t0  # Salva o segundo dígito de x em t1
    rem t2, s9, t0  # Salva o resto da divisão por 100 em t2
    mv s9, t2   # Salva o valor do resto de novo em s9

    addi t1, t1, '0'    # Transforma o segundo dígito em string
    sb t1, 2(s3)    # Coloca no terceiro byte do buffer

    li t0, 10
    div t1, s9, t0  # Salva o terceiro dígito de x em t1
    rem t2, s9, t0  # Salva o resto da divisão por 10 em t2
    mv s9, t2   # Salva o valor do resto de novo em s9

    addi t1, t1, '0'    # Transforma o terceiro dígito em string
    sb t1, 3(s3)    # Coloca no quarto byte do buffer

    addi s9, s9, '0'    # Transforma o último dígito de x em string
    sb s9, 4(s3)    # Coloca no quinto byte do buffer

    li t0, ' '
    sb t0, 5(s3)    # Formatação correta com espaço entre x e y

    li t0, '+'
    sb t0, 6(s3)    # Se continuar assim, já salvou o segundo número como positivo

    bge s8, x0, print_y # if y >= 0 não altera o buffer de sinal e começa a printar o segundo número

    li t0, '-'
    sb t0, 6(s3)    # Caso contrário, salva o primeiro byte como - pra dizer que o número é negativo 
    li t0, -1
    mul s8, s8, t0  # Muda o número para positivo pois já tratou o sinal

print_y:
    li t0, 1000
    div t1, s8, t0  # Salva o primeiro dígito de y em t1
    rem t2, s8, t0  # Salva o resto da divisão por 1000 em t2
    mv s8, t2   # Salva o valor do resto de novo em s8

    addi t1, t1, '0'    # Transforma o primeiro dígito em string
    sb t1, 7(s3)    # Coloca no oitavo byte do buffer

    li t0, 100
    div t1, s8, t0  # Salva o segundo dígito de y em t1
    rem t2, s8, t0  # Salva o resto da divisão por 100 em t2
    mv s8, t2   # Salva o valor do resto de novo em s8

    addi t1, t1, '0'    # Transforma o segundo dígito em string
    sb t1, 8(s3)    # Coloca no nono byte do buffer

    li t0, 10
    div t1, s8, t0  # Salva o terceiro dígito de y em t1
    rem t2, s8, t0  # Salva o resto da divisão por 10 em t2
    mv s8, t2   # Salva o valor do resto de novo em s8

    addi t1, t1, '0'    # Transforma o terceiro dígito em string
    sb t1, 9(s3)    # Coloca no décimo byte do buffer

    addi s8, s8, '0'    # Transforma o último dígito de y em string
    sb s8, 10(s3)    # Coloca no décimo-primeiro byte do buffer

    li t0, '\n'
    sb t0, 11(s3)    # Finaliza com o \n

    li a0, 1  # file descriptor = 1 (stdout)
    mv a1, a3 #  buffer to write the data
    li a2, 12  # size (12 bytes)
    li a7, 64 # syscall write (64)
    ecall
    
fim:    # Encerra o programa
    li a0, 0
    li a7, 93
    ecall