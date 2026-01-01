	//                                              //
	//              Header for MARS.CPP             //
	//                                              //
//-----------------------------------------------------------------//



#include "smallint.h"
#include "tree.h"

#define OOPS            0
#define MOV             1
#define ADD             2
#define SUB             3
#define JMP             4
#define JMZ             5
#define JMN             6
#define DJN             7
#define CMP             8
#define SPL             9
#define MAX_COMMAND     9

////////
int PROG_COLOR;
///////

typedef unsigned char BYTE;

// Prototypes :

// Open file to execute and check for valid code :

	int openfile( char* name );

// Right header for MARS executable :

	extern "C" void STUB(void);

// Tell who won :

        void win( char [] );

// Put a message on the screen :

        void message( char *str );

// Initialize graphic function :

        void init_graph( void );

// Draw point :

        void bar4( SMALL_INT address, int color );

// Print free memory size :

	void print_mem( void );

// Append extention 'ext' if it's not given :

	void append_extention( char *name, char *ext );


// Class COMMAND - declaration & implementation :

class COMMAND {

public :

	BYTE instr;
	BYTE adr1;
	BYTE adr2;
	SMALL_INT oper1;
	SMALL_INT oper2;

// Dummy constructor :

	COMMAND(){ COMMAND(0); }

// Constructor 'int' -> 'COMMAND' :

	COMMAND( int = 0 );

// Constructor 'SMALL_INT' -> 'COMMAND' :

	COMMAND( SMALL_INT& );

// Overloaded unary operations :

	COMMAND& operator++ ( void );
	COMMAND& operator-- ( void );

// Overloaded assigment operators :

	COMMAND& operator=  ( COMMAND& );
	COMMAND& operator+= ( COMMAND& );
	COMMAND& operator-= ( COMMAND& );

// Overloaded equality operators :

	friend int operator== ( COMMAND&, COMMAND& );
	friend int operator!= ( COMMAND&, COMMAND& );

// Overloaded array subscript operator :                       ?
//                                                             ?
//      COMMAND& operator[] ( SMALL_INT& );                    ?

//  Processing command :

	int execute ( SMALL_INT& pc );

// The field of battle :

	static COMMAND array [ MAX_SMALL ];

// Pointer to current executing command :

	static SMALL_INT* current_execute;

// Output function :

	void print ( void );

// Return 'pointer' to operand  ( _CONST == 0 )
// or operand if one's constant ( _CONST == 1 ) :

friend SMALL_INT GetOperand( BYTE, SMALL_INT& );

private :

// The current program counter ( modified by 'execute' ):

	static SMALL_INT _PCnt;

// The switch for GetOperand :

	static int _CONST;

// RedCode instruction emulation functions prototypes :

	int oops( void );
	int mov( void );
	int add( void );
	int sub( void );
	int jmp( void );
	int jmz( void );
	int jmn( void );
	int djn( void );
	int cmp( void );
	int spl( void );
};


// Implementation of class COMMAND :

inline COMMAND::COMMAND ( int num ) {

  instr = adr1 = adr2 = 0;
  oper1 = 0;
  oper2 = num;
}

inline COMMAND::COMMAND ( SMALL_INT& num ) {

  instr = adr1 = adr2 = 0;
  oper1 = 0;
  oper2 = num;
}

COMMAND COMMAND::array [ MAX_SMALL ];
SMALL_INT* COMMAND::current_execute;
int COMMAND::_CONST;
SMALL_INT COMMAND::_PCnt;

inline COMMAND& COMMAND::operator+= ( COMMAND& com ) {

  oper2 += com.oper2;
  return *this;
}

inline COMMAND& COMMAND::operator-= ( COMMAND& com ) {

  oper2 -= com.oper2;
  return *this;
}

inline COMMAND& COMMAND::operator++ ( void ) {

  oper2 ++;
  return *this;
}

inline COMMAND& COMMAND::operator-- ( void ) {

  oper2 --;
  return *this;
}

inline COMMAND& COMMAND::operator= ( COMMAND& com ) {

  instr = com.instr;
  adr1  = com.adr1;
  adr2  = com.adr2;
  oper1 = com.oper1;
  oper2 = com.oper2;
  return *this;
}

inline int operator== ( COMMAND& com1, COMMAND& com2 ) {

  return ( com1.oper2 == com2.oper2 );
}

inline int operator!= ( COMMAND& com1, COMMAND& com2 ) {

  return ( com1.oper2 != com2.oper2 );
}

//inline COMMAND& COMMAND::operator[] ( SMALL_INT& ind ) {     ?
//                                                             ?
//  return this[ ind.data ];                                   ?
//}                                                            ?


void COMMAND::print ( void ) {

int two_op = 1;

  switch( instr ) {
    case MOV:
      printf( " MOV ");
    break;
    case ADD:
      printf( " ADD ");
    break;
    case SUB:
      printf( " SUB ");
    break;
    case JMP:
      printf( " JMP ");
      two_op = 0;
    break;
    case JMZ:
      printf( " JMZ ");
    break;
    case JMN:
      printf( " JMN ");
    break;
    case DJN:
      printf( " DJN ");
    break;
    case CMP:
      printf( " CMP ");
    break;
    case SPL:
      printf( " SPL ");
      two_op = 0;
    break;
    default:
      printf( " \007OOPS\n" );
      return;
  }

  switch ( adr1 ) {
    case 0:
      printf( "#" );
    break;
    case 1:
    break;
    case 2:
      printf( "@" );
    break;
    case 3:
      printf( ">" );
    break;
    case 4:
      printf( "<" );
    break;
  }
  printf( "%d ", oper1.data );

  if( two_op ) {
    switch ( adr2 ) {
      case 0:
	printf( "#" );
      break;
      case 1:
      break;
      case 2:
	printf( "@" );
      break;
      case 3:
	printf( ">" );
      break;
      case 4:
	printf( "<" );
      break;
    }
    printf( "%d ", oper2.data );
  }
  printf( "\n" );
}

inline int COMMAND::oops( void ) { return instr; }

inline int COMMAND::mov( void ) {

SMALL_INT op1, op2;

  op2 = GetOperand( adr2, oper2 );
  op1 = GetOperand( adr1, oper1 );
  array[op2.data] =
    ( _CONST ) ? COMMAND( op1 ) : array[op1.data];
#ifdef GRAPHICS_NEED
  if( array[op2.data].instr == OOPS ) {
    bar4( op2, W );
  }
  else {
    bar4( op2, PROG_COLOR );
  }
#endif
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::add( void ) {

SMALL_INT op1, op2;

  op2 = GetOperand( adr2, oper2 );
  op1 = GetOperand( adr1, oper1 );
  array[op2.data] +=
    ( _CONST ) ? COMMAND( op1 ) : array[op1.data];
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::sub( void ) {

SMALL_INT op1, op2;

  op2 = GetOperand( adr2, oper2 );
  op1 = GetOperand( adr1, oper1 );
  array[op2.data] -=
	      ( _CONST ) ? COMMAND( op1 ) : array[op1.data];
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::jmp( void ) {

SMALL_INT op1;

  op1 = GetOperand( adr1, oper1 );
  *current_execute = op1;
  return instr;
}

inline int COMMAND::jmz( void ) {

SMALL_INT op1, op2;

  op1 = GetOperand( adr1, oper1 );
  op2 = GetOperand( adr2, oper2 );
  if( (( _CONST ) ? COMMAND( op2 ) : array[op2.data]) == 0 )
    *current_execute = op1;
  else
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::jmn( void ) {

SMALL_INT op1, op2;

  op1 = GetOperand( adr1, oper1 );
  op2 = GetOperand( adr2, oper2 );
  if( (( _CONST ) ? COMMAND( op2 ) : array[op2.data]) != 0 )
    *current_execute = op1;
  else
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::djn( void ) {

SMALL_INT op1, op2;

  op1 = GetOperand( adr1, oper1 );
  op2 = GetOperand( adr2, oper2 );
  if( --array[ op2.data ] != 0 )
    *current_execute = op1;
  else
  ( *current_execute )++;
  return instr;
}

inline int COMMAND::cmp( void ) {

SMALL_INT op1, op2;
int const1;

  op1 = GetOperand( adr1, oper1 );
  const1 = _CONST;
  op2 = GetOperand( adr2, oper2 );
  if( ( ( const1 ) ? COMMAND( op1 ) : array[op1.data] )
      != ( ( _CONST ) ? COMMAND( op2 ) : array[op2.data]) )
    ( *current_execute )+= 2;
  else
  ( *current_execute )++;
  return instr;
}

// 'Pointer' to the new branch of programm ( after SPL ) :

	SMALL_INT _SPL_PC;

inline int COMMAND::spl( void ) {

  _SPL_PC = GetOperand( adr1, oper1 );
  ( *current_execute )++;
  return instr;
}

int COMMAND::execute ( SMALL_INT& pc ) {

  _PCnt = pc;

  switch( instr ) {
    case MOV: return mov();
    case ADD: return add();
    case SUB: return sub();
    case JMP: return jmp();
    case JMZ: return jmz();
    case JMN: return jmn();
    case DJN: return djn();
    case CMP: return cmp();
    case SPL: return spl();
    default:  return oops();
  }
}


SMALL_INT GetOperand( BYTE adr, SMALL_INT& oper ) {

  COMMAND::_CONST = 0;
  SMALL_INT PC = COMMAND::_PCnt;

  switch( adr ) {

    case 0:
      COMMAND::_CONST = 1;
      return oper;
    case 1:
      return PC + oper;
    case 2:
      return PC + oper
	     + COMMAND::array[ ( PC + oper ).data ].oper2;
    case 3:
      SMALL_INT tmp = PC + oper
      + COMMAND::array[ ( PC + oper ).data ].oper2;
      ++ ( COMMAND::array[ ( PC + oper).data ] );
      return tmp;
    case 4:
      -- ( COMMAND::array[ ( PC + oper).data ] );
      return PC + oper
	     + COMMAND::array[ ( PC + oper).data ].oper2;
  }
}

