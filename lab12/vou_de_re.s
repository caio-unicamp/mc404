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
    li t1, 14750
    virando:
        li t0, -127
        sb t0, volante(s0)  # Vira o volante 15 para a esquerda

        li t0, 1
        sb t0, motor(s0)   # Liga o motor
        
        addi t1, t1, -1
        bnez t1, virando   # Continua no loop até um dado momento

    de_re:
        li t0, 1
        sb t0, gps(s0)

        lw a0, x(s0)
        lw a1, z(s0)

        jal ra, calcula_dist

        li t0, 16
        sb t0, volante(s0)  # Vira o volante 15 para a esquerda

        li t0, -1
        sb t0, motor(s0)   # Dá ré
        
        li t0, 225
        bge a0, t0, de_re   # Continua no loop até um dado momento

    li t1, 1800
    drift_insano:
        li t0, -127
        sb t0, volante(s0)

        li t0, 1
        sb t0, motor(s0) 

        li t0, 1
        sb t0, freio(s0)    # Puxa o freio de mão pra encerrar com um drift

        addi t1, t1, -1
        bnez t1, drift_insano

    li t0, 0
    sb t0, motor(s0)    # Desliga o motor pra parar

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