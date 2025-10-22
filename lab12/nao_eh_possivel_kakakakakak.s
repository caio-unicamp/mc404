.text
.set base, 0xFFFF0100
.set gps, 0x0
.set x, 0x10
.set z, 0x18
.set volante, 0x20
.set engine, 0x21

.globl _start

_start:
    li s0, base # Endereço base está salvo em s0
    li s1, 1000
    li t0, -15
    sb t0, volante(s0)  # Vira o volante 15 para a esquerda

    li t0, 1
    sb t0, engine(s0)   # Liga o motor
    bnez s1, _start
# vrum_vrum:
#     lw a0, x(s0)
#     lw a1, z(s0)

# exit:   # Encerra o programa
#     li a0, 0
#     li a7, 93
#     ecall

# calcula_dist:
