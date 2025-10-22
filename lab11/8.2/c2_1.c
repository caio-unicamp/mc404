int swap_int(int *a, int *b){
    int aux = *a;
    *a = *b;
    *b = aux;
    return 0;
};

int swap_short(short *a, short *b){
    short aux = *a;
    *a = *b;
    *b = aux;
    return 0;
};

int swap_char(char *a, char *b){
    char aux = *a;
    *a = *b;
    *b = aux;
    return 0;
};
