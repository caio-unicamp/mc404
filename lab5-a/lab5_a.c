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
    *val |= extrair << start_bit; //Salva o valor binário na lista *val, vai fazer isso até o último com o auxílio de start_bit
}

int main(){
    char str[30], bin[33];
    int size = read(STDIN_FD, str, 30);
    str[size] = 0;
    bin[33] = '\0';
    
    int neg = 0; // Alocando o indicador de negativo
    for (int i = 0; i < 5; i++){
        if (str[i*6] == '-'){ // Confere o sinal para passar a flag de negativo
            neg = 1;         
        }

        int dec = 0;
        int aux = 1;
        while(str[i*6 + aux] >= '0' && str[i*6 + aux] <= '9'){ //Transformando strings em números
            dec = dec*10 + (str[i] - '0');
            i++;
            aux++;
        }

        if (i == 0){
            //Pode ser até 3 bits = (7)10
            dec %= 10; // Só preciso do primeiro dígito
            aux = 3;
        }else if (i == 1){
            //Pode ser até 8 bits = (255)10
            dec %= 1000; //Só preciso dos primeiros 3 dígitos
            aux = 8;
        }else if (i == 2 || i == 3){
            //Pode ser até 5 bits = (31)10
            dec %= 100; //Só preciso dos primeiros 2 dígitos
            aux = 5;
        }else{ //Number order 4 Pode ser até 11 bits = (2047)10, ou seja, não preciso mudar nada e o aux possui 11 bits
            aux = 11;
        }

        to_binary(bin, dec, neg, aux);
    }

    return 0;
}