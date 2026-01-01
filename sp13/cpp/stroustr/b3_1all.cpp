#include <stream.hxx>
#include <ctype.h>

enum token_value {
     NAME,  NUMBER, END,
     PLUS = '+',  MINUS = '-',  MUL='*',     DIV='/',
     PRINT=';',    ASSIGN='=',  LP='(',   RP=')'
};

token_value curr_tok;

struct name {
    char* string;
    name* next;
    double value;
};


const TBLSZ = 23;
name* table[TBLSZ];

int no_of_errors;

double error(char* s) {
    cerr << "error: " << s << "\n";
    no_of_errors++; 
    return 1;
}

extern int strlen(const char*);
extern int strcmp(const char*, const char*);
extern char* strcpy(char*, const char*);

name* look(char* p, int ins = 0)
{
    int ii= 0;
    char *pp = p;
    while (*pp) ii = ii<<1 ^ *pp++;
    if (ii < 0) ii = -ii;
    ii %= TBLSZ;

    for (name* n=table [ii]; n; n=n->next)
        if (strcmp(p,n->string) == 0) return n;

    if (ins == 0) error("name not found");

    name* nn = new name;
    nn->string = new char[strlen(p) + 1];
    strcpy(nn->string,p);
    nn->value = 1;
    nn->next = table[ii];
    table[ii] = nn;
    return nn;
}

inline name* insert(char* s) { return look (s,1); }
    
token_value get_token();
double term();

double expr()
{
    double left = term();

    for (;;)
        switch (curr_tok) {
        case PLUS:
             get_token();
             left += term();
             break;
        case MINUS:
             get_token();
             left -= term();
             break;
        default :
             return left;
        }
}

double prim();

double term()
{
    double left = prim();

    for (;;)
        switch (curr_tok) {
        case MUL:
             get_token();
             left *= prim();
             break;
        case DIV:
             get_token();
             double d = prim();
             if (d == 0) return error("divide by o");
             left /= d;
             break;
        default:
             return left;
        }
}
int number_value;
char name_string[80];

double prim()
{
    switch (curr_tok) {
    case NUMBER:
         get_token();
         return number_value;
    case NAME:
         if (get_token() == ASSIGN) {
            name* n = insert(name_string);
            get_token();
            n->value = expr();
            return n->value;
         }
         return look(name_string)->value;
    case MINUS:
         get_token();
         return -prim();
    case LP:
         get_token();
         double e = expr();
         if (curr_tok != RP) return error(") expected");
         get_token();
         return e;
    case END:
         return 1;
    default:
         return error ("primary expected");
    }
}    

token_value get_token()
{
   char ch = 0;

   do {
      if(!cin.get(ch)) return curr_tok = END;
   } while (ch!='\n' && isspace(ch));

   switch (ch) {
   case ';':
   case '\n':
        cin >> WS;
        return curr_tok=PRINT;
   case '*':
   case '/':
   case '+':
   case '-':
   case '(':
   case ')':
   case '=':
        return curr_tok=ch;
   case '0': case '1': case '2': case '3': case '4':
   case '5': case '6': case '7': case '8': case '9':
   case '.':
      cin.putback(ch);
      cin >> number_value;
      return curr_tok=NUMBER;
   default:
     if (isalpha(ch)) {
        char* p = name_string;
        *p++ = ch;
        while (cin.get(ch) && isalnum(ch)) *p++ = ch;
        cin.putback(ch);
        *p = 0;
        return curr_tok=NAME;
     }
     error ("bad token");
     return curr_tok=PRINT;
    }
}

int main(int argc, char* argv[])
{
    switch (argc) {
    case 1:
       break;
    case 2:
       cin = *new istream(strlen(argv[1]),argv[1]);
       break;
    default:
       error("too many arguments");
       return 1;
    }

    // insert predefined names:
    insert("pi")->value = 3.1415926535897932385;
    insert("e")->value = 2.7182818284590452354;

    while (1) {
       get_token();
       if( curr_tok == END) break;
       if (curr_tok == PRINT) continue;
       cout << expr() << "\n";
    }
   
    return no_of_errors;
}

