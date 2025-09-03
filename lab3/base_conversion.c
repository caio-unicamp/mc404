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
    }
    write(STDOUT_FD, s, len);
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

    int i = 0;
    int started = 0;
    for(int shift = 28; shift >= 0; shift -= 4){ //O shift é de 4 em 4 bits, começando do bit mais significativo
        int d =(x >> shift) & 0xF; //Primeiro move o bit mais significativo para a direita e depois faz uma máscara para pegar os 4 bits da direita
        if(d!=0||started||shift==0){
            buf[2+i]=hex[d];
            i++;
            started=1;
        }
    }
    buf[2+i]=0;
}

void to_bin_str(unsigned int x, char *buf){
    buf[0]='0'; 
    buf[1]='b';
    int i=0,started=0;
    for(int shift=31; shift>=0; shift--){
        int b=(x>>shift)&1;
        if(b||started||shift==0){
            buf[2+i]=b?'1':'0';
            i++;
            started=1;
        }
    }
    buf[2+i]=0;
}

unsigned int swap_endian(unsigned int x){
    return ((x>>24)&0xFF) | ((x>>8)&0xFF00) | ((x<<8)&0xFF0000) | ((x<<24)&0xFF000000);
}

/* ---------------------- Função principal ---------------------- */

int main(){
    char str[20];
    int n=read(STDIN_FD,str,20);
    str[n]=0;

    int neg=0;
    unsigned int num=0;

    if(str[0]=='-'){ // decimal negativo
        neg=1;
        int i=1;
        while(str[i]>='0'&&str[i]<='9'){
            num=num*10+(str[i]-'0');
            i++;
        }
        if(neg) num = (unsigned int)(-((int)num));
    }
    else if(str[0]=='0' && str[1]=='x'){ // hexadecimal
        int i=2;
        while((str[i]>='0'&&str[i]<='9')||(str[i]>='a'&&str[i]<='f')||(str[i]>='A'&&str[i]<='F')){
            int v;
            if(str[i]>='0'&&str[i]<='9') v=str[i]-'0';
            else if(str[i]>='a'&&str[i]<='f') v=str[i]-'a'+10;
            else v=str[i]-'A'+10;
            num=num*16+v;
            i++;
        }
    }
    else{ // decimal positivo
        int i=0;
        while(str[i]>='0'&&str[i]<='9'){
            num=num*10+(str[i]-'0');
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
