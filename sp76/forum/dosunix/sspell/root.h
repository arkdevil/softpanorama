/* root.h */

typedef struct wordlststruct
{
   char *word;
   char *prefix;
   char *suffix;
   struct wordlststruct *next;
   } WORDLST;

/* void root(char *in, WORDLST **outlst) */
void root();

/* void destroy(WORDLST *a) */
void destroy();

/* void initroot(char *file) */
void initroot();
