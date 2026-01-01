	/*					*/
	/*	Header for REDCODE.C		*/
	/*					*/
/* ----------------------------------------------------------- */


#define START_LABEL	"start"
#define END_LABEL	"end"
#define COMMAND_ERR	"Undefined command"
#define OPERAND_ERR	"Invalid operand"
#define UNDEF_LABEL_ERR	"Undefined label"
#define INV_ADR_ERR	"Illegal address mode"
#define POSSIBLE_ADR	"#@<>"
#define MAX_LEN		80
#define MAX_STR		100
#define MAX_LABEL	20
#define MAX_ADR		4
#define MAX_COMMAND	11

typedef unsigned char BYTE;

typedef struct {
		 char *text;
		 BYTE code;
		 int two_op;
		 int const1;
		 int const2;
	       } COMMAND;

typedef struct {
		 char text;
		 BYTE code;
	       } ADDRESS;

typedef struct {
		 char *str;
		 int num;
	       } LABEL;

typedef struct {
		 BYTE command;
		 BYTE adr1,adr2;
		 int  oper1,oper2;
	       } CODE;

COMMAND command[ MAX_COMMAND ] = {

		{ "mov", 1, 1 , 1, 0 },
		{ "add", 2, 1 , 1, 0 },
		{ "sub", 3, 1 , 1, 0 },
		{ "jmp", 4, 0 , 0, 0 },
		{ "jmz", 5, 1 , 0, 1 },
		{ "jmn", 6, 1 , 0, 1 },
		{ "jmg", 6, 1 , 0, 1 },
		{ "djn", 7, 1 , 0, 0 },
		{ "cmp", 8, 1 , 1, 1 },
		{ "spl", 9, 0 , 0, 0 },
		{ "dat", 0, 0 , 1, 0 }

				  };

ADDRESS adr_method[ MAX_ADR ] = {

		{ '@', 2 },
		{ '#', 0 },
		{ '>', 3 },
		{ '<', 4 }
				};

BYTE compile_command( char *str, int *two_op, int *const1, int *const2 );
char *compile_operand( char *str, BYTE *adr, int *oper, int str_num);
int right_char( char c );
void syntax_error( char *str, int n );
void STUB( void );
