#define STDIN_FD  0
#define STDOUT_FD 1

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

void exit(int code){
    __asm__ __volatile__(
        "mv a0, %0\n"
        "li a7, 93\n"
        "ecall"
        : : "r"(code)
        : "a0","a7"
    );
}

void _start(){
    int ret_code = main();
    exit(ret_code);
}

void print_str(const char *s){
    int len=0;
    while(s[len]){
        len++;
        write(STDOUT_FD, s, len);
    }
}

void reverse(char *s, int n){
    for(int i = 0; i < (n/2); i++){
        char temp = s[i];
        s[i] = s[n-1-i];
        s[n-1-i] = temp;
    }
}

void to_dec_str(int val, char *buf){ // Converte um valor inteiro (signed) para uma string decimal
    if(val == 0){
        buf[0]='0'; 
        buf[1]=0; 
        return;
    }

    unsigned int x;
    int neg = 0; //Bit de sinal
    if(val < 0){
        neg=1;
        x = (unsigned int)(-val); //Transformando o valor negativo em positivo
    }else{
        x = (unsigned int)val; //Transformando o valor positivo em unsigned
    } 

    int i=0;
    while(x > 0){
        buf[i++] = (x%10) + '0'; //Transformando o dígito em caractere para os números de 0 a 9
        x /= 10; //Divisão inteira por 10
    }
    
    if(neg){ // Adicionando o sinal negativo se necessário
        buf[i++]='-';
    } 
    buf[i]=0;
    reverse(buf,i);
}

void to_unsigned_dec_str(unsigned int x, char *buf){ //Se meu valor é unsigned, não preciso me preocupar com o bit de sinal
    if(x==0){ 
        buf[0]='0';
        buf[1]=0;
        return;
    }

    int i=0;
    while(x > 0){
        buf[i++] = (x%10) + '0'; // Transformando o dígito em caractere para os números de 0 a 9
        x /= 10; // Divisão inteira por 10
    }
    buf[i]=0;
    reverse(buf,i);
}

void to_hex_str(unsigned int x, char *buf){
    char hex[]="0123456789abcdef";
    // Os dois buffers iniciais são para o prefixo "0x" para indicar que é hexadecimal
    buf[0] = '0';
    buf[1] = 'x';

    unsigned int mask = 0xF0000000; // 1111 0000 ... começa no nibble mais alto
    int shift = 28;

    int i = 0;
    int started = 0;
    while (mask != 0){
        int d = (x & mask); // Pega o grupo de 4 bits
        d /= mask; // Normaliza para o intervalo 0-15

        if (d != 0 || started || mask == 0xF){ // Se o dígito é diferente de zero ou já começou a imprimir
            buf[2 + i] = hex[d]; // Converte o dígito para o caractere hexadecimal
            i++;
            started = 1; // Marca que já começou a imprimir
        }
        mask /= 16; // Move para o próximo nibble (4 bits para a direita)
    }
    buf[2+i] = 0; // Termina a string com o caractere nulo
}

void to_bin_str(unsigned int x, char *buf){
    // Os dois buffers iniciais são para o prefixo "0b" para indicar que é binário
    buf[0]='0'; 
    buf[1]='b';
    
    unsigned int mask = 0x80000000; // 1000 0000 ... começa no bit mais alto
    int i = 0, started = 0;
    while (mask != 0){  // Enquanto houver bits para verificar
        if (x & mask) { // Verifica se o bit atual é 1
            buf[2 + i] = '1'; // Se for 1, adiciona '1' ao buffer
            started = 1; // Marca que já começou a imprimir
            i++;
        }else if (started){
            buf[2 + i] = '0'; // Se já começou a imprimir, adiciona '0'
            i++;
        }
        mask /= 2; // Move para o próximo bit (divide por 2)
    }

    if (i == 0){
        buf[2] = '0'; // Se nenhum bit foi adicionado, adiciona '0'
        i = 1; // Atualiza o índice
    }
    buf[2+i]=0;
}

unsigned int swap_endian(unsigned int x){ // Muda a ordem dos bytes de um inteiro de 32 bits
    unsigned int byte0 = x & 0x000000FF;
    unsigned int byte1 = x & 0x0000FF00;
    unsigned int byte2 = x & 0x00FF0000;
    unsigned int byte3 = x & 0xFF000000;

    unsigned int b0 = byte0 * 0x1000000;   // byte0 vai para byte3
    unsigned int b1 = byte1 * 0x100;       // byte1 vai para byte2
    unsigned int b2 = byte2 / 0x100;       // byte2 vai para byte1
    unsigned int b3 = byte3 / 0x1000000;   // byte3 vai para byte0

    return b0 | b1 | b2 | b3;
}

int main(){
    char str[20];
    int n = read(STDIN_FD,str,20);
    str[n] = 0;

    int neg = 0;
    unsigned int num = 0;

    if(str[0] == '-'){ // decimal negativo
        neg = 1;
        int i = 1;
        while(str[i] >= '0' && str[i] <= '9'){ //Transformando a string em número para os dígitos de 0 a 9
            num *= 10;
            num += (str[i]-'0');
            i++;
        }
        if(neg){
            num = (unsigned int)(-((int)num));
        }
    }else if(str[0] == '0' && str[1] == 'x'){ // hexadecimal
        int i = 2;
        while((str[i] >= '0' && str[i] <= '9') || (str[i] >= 'a' && str[i] <= 'f') || (str[i] >= 'A' && str[i] <= 'F')){
            int v;
            if(str[i]>='0'&&str[i]<='9'){ // Transformando a string em número para os dígitos de 0 a 9
                v=str[i]-'0';
            }else if(str[i]>='a'&&str[i]<='f'){ // Transformando a string em número para os dígitos de a-f
                v=str[i]-'a'+10;
            }else{ // Transformando a string em número para os dígitos de A-F
                v=str[i]-'A'+10;
            }    
            num *= 16;
            num += v;
            i++;
        }
    }else{ // decimal positivo
        int i=0;
        while(str[i] >= '0' && str[i] <= '9'){
            num *= 10;
            num += (str[i]-'0');
            i++; 
        }
    }

    /* Saídas */
    char buf[50];

    // binário
    to_bin_str(num, buf);
    print_str(buf); print_str("\n");

    // decimal signed
    to_dec_str((int)num, buf);
    print_str(buf); print_str("\n");

    // hexadecimal
    to_hex_str(num, buf);
    print_str(buf); print_str("\n");

    // decimal unsigned endian swap
    unsigned int swapped=swap_endian(num);
    to_unsigned_dec_str(swapped, buf);
    print_str(buf); print_str("\n");

    return 0;
}
