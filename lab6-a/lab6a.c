# include <stdio.h>

int sqr_root(int num){
    int aux, k = num/2;

    for (int i = 0; i < 10; i++){
        aux = (k + (num/k))/2;
        k = aux;
    }
    return k;
}

int main(){
    int num, raiz;
    
    for (int i = 0; i < 4; i++){
        scanf("%d", &num);
        raiz = sqr_root(num);
        printf("%d", raiz);
    }

    return 0;
}