/* Buffer to store the data read */
char input_buffer[6];
char output_buffer[2];

int main()
{
  int n = read(0, (void*) input_buffer, 10);
  
  int num1 = input_buffer[0] - '0'; 
  char op = input_buffer[2];
  int num2 = input_buffer[4] - '0';
  int result = 0;
  
  if (op == '+') {
    result = num1 + num2;
  } else if (op == '-') {
    result = num1 - num2;
  } else if (op == '*') {
    result = num1 * num2;
  }

  output_buffer[0] = (result % 10) + '0';
  output_buffer[1] = '\n'; 
  write(1, output_buffer, 2);
  return 0;
}
