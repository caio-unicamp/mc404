#define STDIN_FD 0
#define STDOUT_FD 1

void _start(){
    int ret_code = main();
    exit(ret_code);
}

void exit(int code){
    __asm__ __volatile__(
        "mv a0, %0\n"
        "li a7, 93\n"
        "ecall"
        : : "r"(code)
        : "a0","a7"
    );
}

int read(int __fd, const void *__buf, int __n){
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1\n"
        "mv a1, %2\n"
        "mv a2, %3\n"
        "li a7, 63\n"
        "ecall\n"
        "mv %0, a0\n"
        : "=r"(ret_val)
        : "r"(__fd), "r"(__buf), "r"(__n)
        : "a0","a1","a2","a7"
    );
    return ret_val;
}

void write(int __fd, const void *__buf, int __n){
    __asm__ __volatile__(
        "mv a0, %0\n"
        "mv a1, %1\n"
        "mv a2, %2\n"
        "li a7, 64\n"
        "ecall"
        : : "r"(__fd),"r"(__buf),"r"(__n)
        : "a0","a1","a2","a7"
    );
}

int to_binary(char *buf){

    return 0;
}

void hex_code(int val){ // Passa de decimal para hexadecimal
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

void pack(int input, int start_bit, int end_bit, int *val) {
    
}

int main(){
    char str[30];
    int size = read(STDIN_FD, str, 30);
    str[size] = 0;
    
    int neg[5] = {0,0,0,0,0}; // Alocando o indicador de negativo para cada um dos 5 números
    unsigned int final_binary = 0;
    for (int i = 0; i < 5; i++){
        if (str[i*6] == '-'){
            neg[i] = 1;
        }
    }

    return 0;
}