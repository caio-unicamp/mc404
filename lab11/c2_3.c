int fill_array_int(){
    int array[100];
    for (int i = 0; i < 100; i++)
        array[i] = i;
    return mystery_function_int(array);
};

int fill_array_short(){
    short array[100];
    for (short i = 0; i < 100; i++)
        array[i] = i;
    return mystery_function_short(array);
};

int fill_array_char(){
    char array[100];
    for (char i = 0; i < 100; i++)
        array[i] = i;
    return mystery_function_char(array);
};
