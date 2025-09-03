calc1.s: calc1.c
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calc1.c -S -o calc1.s

calc1.o: calc1.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calc1.s -c -o calc1.o


calc2.s: calc2.c
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calc2.c -S -o calc2.s

calc2.o: calc2.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calc2.s -c -o calc2.o

prog.x: calc1.o calc2.o
	ld.lld-15 calc1.o calc2.o -o prog.x

clean:
	rm -f *.s *.o prog.x
