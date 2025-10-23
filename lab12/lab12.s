.text
.set base, 0xFFFF0100
.set gps, 0x0
.set x, 0x10
.set z, 0x18
.set volante, 0x20
.set motor, 0x21
.set freio, 0x22

.globl _start

_start:
    li s0, base # Endereço base está salvo em s0

vrum_vrum:
    li t0, 1
    sb t0, gps(s0)

    lw a0, x(s0)
    lw a1, z(s0)

    jal ra, calcula_dist

    li t0, -15
    sb t0, volante(s0)  # Vira o volante 15 para a esquerda

    li t0, 1
    sb t0, motor(s0)   # Liga o motor
    
    li t0, 225
    bge a0, t0, vrum_vrum   # Enquanto a distância do carro pro ponto final for maior que 15, continua no loop

    li t0, 0
    sb t0, motor(s0)    # Desliga o motor pra parar

    li t0, 1
    sb t0, freio(s0)    # Freia completamente

exit:   # Encerra o programa quando chegou o final
    li a0, 0
    li a7, 93
    ecall

calcula_dist:   # Função pra calcular a distância ao quadrado entre o carro e o final
    addi a0, a0, -73 # x - xf
    mul a0, a0, a0  # (x - xf)²

    addi a1, a1, +19    # z - zf
    mul a1, a1, a1  # (z - zf)²

    add a0, a0, a1  # a0 = d² = (x - xf)² + (y - yf)²

    ret