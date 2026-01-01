#include <stdio.h>
#include "lib.h"

boolean port_active = FALSE;
boolean remote_debug = FALSE;
boolean Makelog = FALSE;
char LINELOG[] = "nul";
FILE *log_stream = NULL;
int logmode = 0;

int w_flush(void) {return 0;}

