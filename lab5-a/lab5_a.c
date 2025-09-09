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

void pack(int input, int start_bit, int end_bit, int *val){
    /* Empacota os bits necessários de `input` nas posições [start_bit..end_bit] dentro de *val.
    A extração é a partir da representação em complemento de 2, então `input` deve ser convertido para unsigned antes do masking.
    *val é tratado como um inteiro de 32 bits contendo o resultado parcial. */
    unsigned int u = (unsigned int) input;
    int tam_num = end_bit - start_bit + 1;
    unsigned int mask = (1u << tam_num) - 1u; //Cria uma máscara com tam_num bits iguais a 1
    unsigned int extrair = u & mask; //Isso serve para extrair apenas a quantidade de bits pedida pela ordem dos inputs 
    *val |= (extrair << start_bit); //Salva o valor em *val, vai fazer isso até o último com o auxílio de start_bit
}

int main(){
    char str[31];
    int size = read(STDIN_FD, str, 30);
    str[size] = 0;
    
    int nums[5];
    for (int i = 0; i < 5; i++){
        int offset = i*6;
        int neg = (str[offset] == '-'); // Alocando o indicador de negativo
        int dec = 0;
        for (int j = 0; j <= 4; j++){
            dec = dec*10 + (str[offset + j] - '0'); //Transformando strings em números
        }
        
        if (neg){
            dec = -dec;
        }
        nums[i] = dec; //Salva numa lista a cada iteração na ordem dos números lidos
    }
    int out = 0;
    pack(nums[0],  0,  2, &out);  // 3 LSB
    pack(nums[1],  3, 10, &out);  // 8 LSB
    pack(nums[2], 11, 15, &out);  // 5 LSB
    pack(nums[3], 16, 20, &out);  // 5 LSB
    pack(nums[4], 21, 31, &out);  // 11 LSB

    hex_code(out);
    return 0;
}