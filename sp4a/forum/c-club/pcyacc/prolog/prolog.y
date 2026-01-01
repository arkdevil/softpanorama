/*
 * PROLOG
 *
 * Reference: PROGRAMMING IN PROLOG
 *            by CLOCKSIN & MELLISH, 2ND ED., SPRINGER, 1984.
 *
 * Copyright(c) ABRAXAS SOFTWARE INC., 1988, all rights reserved
 *
 * LOREN COBB, CORRALES SOFTWARE, CORRALES, NM.
 *
 */


%{

#define   myDebug

#include  <stdio.h>
#include  <ctype.h>
#include  <string.h>

#define   maxTokenLength   64

char      outfn[] = "prolog.out";
FILE      *fopen(), *inpf, *outf;

%}


%union {
       long   num;
       char   str[maxTokenLength];
       };

%token  <num>  NUMBER
%token  <str>  ATOM
%token  <str>  VAR
%token         ERROR

/*  Prolog operators, from C&M, 2ed, p.110:  */

%token  IF       /*  :-     (if)                 */
%token  SPY      /*  spy    (debug tool)         */
%token  NOSPY    /*  nospy  (remove debug)       */
%token  NOT      /*  not    (logical negate)     */
%token  IS       /*  is     (compute)            */
%token  UNIV     /*  =..    (univ)               */
%token  NE       /*  \=     (not equal)          */
%token  LE       /*  =<     (less or equal)      */
%token  GE       /*  >=     (greater or equal)   */
%token  SE       /*  ==     (strictly equal)     */
%token  SNE      /*  /==    (strictly not equal) */
%token  MOD      /*  mod    (modulo)             */

%nonassoc  IF
%left      ';'
%left      ','
%nonassoc  SPY  NOSPY
%right     NOT
%left      '.'       /*  really should be nonassoc!  */
%nonassoc  IS  UNIV  '='  NE  '<'  LE  GE  '>'  SE  SNE
%left      '-'  '+'
%left      '/'  '*'
%right     MOD       /*  really should be nonassoc!  */
%right     NEGATE

%start program


%%


constant  :   ATOM
          |   NUMBER
          ;

variable  :   VAR
          |   '_'
          ;

predicate :   VAR   '('  args  ')'
          |   ATOM  '('  args  ')'
          ;

args      :   args  ','  argument
          |   argument
          ;

argument  :   predicate
          |   list
          |   variable
          |   constant
          ;

spyarg    :  ATOM  '/'  NUMBER
          |  ATOM
          |  '['  spylist  ','  empty  ']'
          ;

spylist   :  spylist  ','  spyarg
          |  spyarg
          ;

empty     :   '['  ']'
          ;

list      :   '['  elts  '|'  element  ']'
              { yymess( "list [|]" ); }
          |   '['  elts  ']'
              { yymess( "list" ); }
          |   empty
              { yymess( "empty list" ); }
          ;

elts      :   elts  ','  element
          |   element
          ;

element   :   list
          |   NUMBER
          |   ATOM
          |   VAR
          |   '_'
          |   goal
          ;

goal      :   SPY  spyarg
          |   NOSPY  spyarg
          |   '!'
              { yymess( "cut" ); }
          |   predicate
              { yymess( "goal" ); }
          |   predicate  UNIV  list
          |   predicate  UNIV  VAR
          |   VAR  UNIV  list
          |   VAR  UNIV  VAR
          |   expr  IS   expr
          |   expr  '='  expr
          |   expr  SE   expr
          |   expr  NE   expr
          |   expr  SNE  expr
          |   expr  '<'  expr
          |   expr  LE   expr
          |   expr  '>'  expr
          |   expr  GE  expr
          |   '('  logic  ')'
          ;

logic     :   goal
          |   logic  ','  goal
              { yymess( "conjunction\n" ); }
          |   logic  ';'  goal
              { yymess( "disjunction\n" ); }
          ;

expr      :   expr  '+'  expr
          |   expr  '-'  expr
          |   expr  '*'  expr
          |   expr  '/'  expr
          |   expr  MOD  expr
          |   '-'  expr  %prec NEGATE
          |   primary
          ;

primary   :   '('  expr  ')'
          |   NUMBER
          |   ATOM
          |   VAR
          ;

program   :   program  clause
          |   clause
          ;

clause    :   predicate  IF  logic  '.'
              { yymess( "clause\n" ); }
          |   predicate  '.'
              { yymess( "fact\n" ); }
          |   '['  files  ']'  '.'
          ;

files     :   files  ','  file
          |   file
          ;

file      :   ATOM
          |   '-'  ATOM   %prec NEGATE
          ;

%%


int  c;

main( argc, argv )
   int    argc;
   char   *argv[];
   {

   if ( argc != 2 )
      {
      fprintf( stderr, "Usage:  prolog <source file> \n" );
      exit( 1 );
      }

   inpf = fopen( argv[1], "r" );

   if ( inpf == NULL )
      {
      fprintf( stderr, "Can't open file: \"%s\"\n", argv[1] );
      exit( 1 );
      }
/*
   outf = fopen( outfn, "w" );

   if ( outf == NULL )
      {
      fprintf( stderr, "Can't open file: \"%s\"\n", outfn );
      exit( 1 );
      }
*/
   c = getc( inpf );

   if ( yyparse() )
      fprintf( stderr, "Program not accepted.\n" );
   else
      fprintf( stderr, "Program accepted.\n" );

   fclose( inpf );
   fclose( outf );

   }

yyerror( s )
   char   *s;
   {
   fprintf( stderr, "%s\n", s );
   }


yymess( s )
   char   *s;
   {
#ifdef myDebug
   fprintf( stderr, "%s\n", s );
#endif
   }


#define  SQUOTE  ('\'')

int yylex()
   {
   int       k, max;
   char      result, capital, quoted;

   skipWhite();                    /*  skip whitespace & comments  */

   if ( c == EOF )                 /*  end of file  */
      return( EOF );

   if ( isdigit(c) )               /*  NUMBER  */
      {
      yylval.num = 0;
      while( isdigit(c) )
         {
         yylval.num += (c - '0');
         c = getc( inpf );
         }

#ifdef myDebug
fprintf( stderr, "NUMBER: %d\n", yylval.num );
#endif

      return( NUMBER );
      }

   if ( isalpha(c) || (c == SQUOTE) )   /*  ATOM or VARIABLE or keyword  */
      {
      if ( c == SQUOTE )
         {
         quoted = 1;
         capital = 0;
         c = getc( inpf );
         }
      else
         {
         quoted = 0;
         capital = isupper(c);
         }
      max = maxTokenLength - 1;
      k = 0;
      while ( isalnum(c) || (c == '_') )
         {
         if ( k < max )
            yylval.str[k] = c;
         k++;
         c = getc( inpf );
         }
      yylval.str[k] = '\0';
      if ( quoted )
         {
         if ( c == SQUOTE )
            c = getc( inpf );    /*  advance past the quote mark  */
         else
            {
            yyerror( "Closing single quote mark not found." );
            return( ERROR );
            }
         }            
      if ( capital )
         {

#ifdef myDebug
fprintf( stderr, "VARIABLE: %s\n", yylval.str );
#endif

         return( VAR );
         }

      if ( strcmp(yylval.str, "is") == 0 )     /*  keywords:  */
         {

#ifdef myDebug
fprintf( stderr, "OPER: is\n" );
#endif

         return( IS );
         }
      else if ( strcmp(yylval.str, "not") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: not\n" );
#endif

         return( NOT );
         }
      else if ( strcmp(yylval.str, "mod") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: mod\n" );
#endif

         return( MOD );
         }
      else if ( strcmp(yylval.str, "spy") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: spy\n" );
#endif

         return( SPY );
         }
      else if ( strcmp(yylval.str, "nospy") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: nospy\n" );
#endif

         return( NOSPY );
         }

#ifdef myDebug
fprintf( stderr, "ATOM: %s\n", yylval.str );
#endif

      return( ATOM );
      }

   switch( c )   /*** try to recognize this character ***/
      {
      case '/' :
         c = getc( inpf );
         if ( c == '*' )          /*  COMMENT  */
            skipComment();
         else
            result = '/';
         break;

      case ':' :
         c = getc( inpf );
         if ( c == '-' )          /*  IF  */
            {
            c = getc( inpf );

#ifdef myDebug
fprintf( stderr, "\nIF\n\n" );
#endif

            return( IF );
            }
         result = ':';
         break;

      case '=' :                  /*  UNIV or SE or LE  */
         c = getc( inpf );
         if ( c == '.' )
            {
            c = getc( inpf );
            if ( c == '.' )       /*  UNIV  */
               {
               c = getc( inpf );

#ifdef myDebug
fprintf( stderr, "UNIV\n" );
#endif

               return( UNIV );
               }
            else
               {
               ungetc( c, inpf );
               c = '.';
               result = '=';
               break;
               }
            }
         else if ( c == '=' )     /*  SE  */
            {
            c = getc( inpf );
            return( SE );
            }
         else if ( c == '<' )     /*  LE  */
            {
            c = getc( inpf );
            return( LE );
            }
         result = '=';
         break;
      
      case '>' :                  /*  GE  */
         c = getc( inpf );
         if ( c == '=' )
            {
            c = getc( inpf );
            return( GE );
            }
         result = '>';
         break;

      case '\\' :                 /*  NE or SNE  */
         c = getc( inpf );
         if ( c == '=' )
            {
            c = getc( inpf );
            if ( c == '=' )       /*  SNE  */
               {
               c = getc( inpf );
               return( SNE );
               }
            return( NE );         /*  NE  */
            }
         result = '\\';
         break;
      
      default:
         result = c;
         c = getc( inpf );
         break;
      }

#ifdef myDebug
fprintf( stderr, "CHAR: %c\n", result );
#endif

   return( result );
   }


skipComment()    /*  This function skips comments   */
   {             /*  even if they contain comments  */
   while ( 1 )
      {
      c = getc( inpf );
      if ( c == '/' )
         {
         c = getc( inpf );
         if ( c == '*' )
            skipComment();     /*  note recursion  */
         }
      else if ( c == '*' )
         {
         c = getc( inpf );
         if ( c == '/' )
            {
            c = getc( inpf );
            return;            /*  exit point  */
            }
         }
      }
   }


skipWhite()            /*  skip whitespace  */
   {
   while ( 1 )
      {
      if ( isspace(c) )
         c = getc( inpf );
      else if ( c == '/' )
         {
         c = getc( inpf );
         if ( c == '*' )
            {
            skipComment();
            continue;
            }
         else
            {
            ungetc( c, inpf );
            c = '/';
            break;
            }
         }
      else
         break;
      }
   }
