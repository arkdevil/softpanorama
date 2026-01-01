
typedef union  {
  int   i;
  float r;
  char *s;
} YYSTYPE;
extern YYSTYPE yylval;
#define COMMENT 257
#define INTEGER 258
#define FLOAT 259
#define STRING 260
#define IDENTIFIER 261
#define OPERATOR 262
