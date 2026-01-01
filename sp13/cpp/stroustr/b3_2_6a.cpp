extern void strcpy(char *,char *);
extern void exit(int);
extern int strlen(char *); 

char *save_string(char* p)
{
   char* s = new char[strlen(p)+1];
   strcpy(s,p);
   return s;
}

int main (int argc, char* argv[])
{
    if (argc < 2) exit(1);
    int size = strlen(argv[1])+1;
    char* p = save_string (argv[1]);
    delete[size] p;
}

