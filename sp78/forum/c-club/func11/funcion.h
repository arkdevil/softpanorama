void *function_create(char *cadena);
void function_syntax_check(void *funcion, void (*n_error)(char *s, int cursor));
double function_calculate(double nx, void *funcion);
void function_destroy(void *funcion);