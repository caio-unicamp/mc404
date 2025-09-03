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

void to_binary(char *bin, int dec_num, int neg, int aux){ //Função pra transformar um decimal em binário considerando sinal e passando apenas com o número de bits referente a cada ordem que o número aparece
    char temp[33];
    int final_binary = 0;
    
    //Passando o número de decimal pra binário independente do sinal
    int i = 0;
    while (dec_num > 0){
        bin[i] = dec_num % 2 + '0'; //Salvando em ordem da esquerda pra direita e transformando o bit em string de número
        dec_num /= 2;
        i++;
    }

    if (neg){ //Números negativos 
        //Complemento de 1
        for (int i = 0; i < 33; i++) {
            bin[i] = (bin[i] == '0') ? '1' : '0';
        }

        //Complemento de 2
        int carry = 1;
        for (int i = 31; i >= 0; i--) {
            if (temp[i] == '1' && carry == '1') {
                bin[i] = '0';
                carry = 1;
            } else if (temp[i] == '0' && carry == '1') {
                bin[i] = '1';
                carry = 0;
            } else {
                bin[i] = temp[i];
                carry = 0;
            }
        }
        
        for (i = 31; i > 31 - aux; i--){
            bin[i] = temp[i]; //Passa o valor para o vetor original de acordo com o temporário
        }
    }
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

        to_binary(bin, dec, neg, i);
    }

    return 0;
}