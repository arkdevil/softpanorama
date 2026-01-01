// Class SMALL_INT - declaration :


static const MAX_SMALL = 8000;  /* Maximum size of number  */

class SMALL_INT {

public:

	int data;

//  Constructor 'int' ->  'SMALL_INT' :

	SMALL_INT( int n=0 );

//  Overloaded binary operations :

	friend SMALL_INT operator+ ( SMALL_INT&, SMALL_INT& );
	friend SMALL_INT operator- ( SMALL_INT&, SMALL_INT& );

// Overloaded unary operations :

	SMALL_INT& operator++ ( void );
	SMALL_INT& operator-- ( void );
	SMALL_INT& operator+=( SMALL_INT& );
	SMALL_INT& operator-=( SMALL_INT& );

// Overloaded equality operators :

	friend int operator== ( SMALL_INT&, SMALL_INT& );
	friend int operator!= ( SMALL_INT&, SMALL_INT& );

// Overloaded relational operators :

	friend int operator< ( SMALL_INT&, SMALL_INT& );
	friend int operator> ( SMALL_INT&, SMALL_INT& );
	friend int operator<= ( SMALL_INT&, SMALL_INT& );
	friend int operator>= ( SMALL_INT&, SMALL_INT& );

// Output function :

	void print( void );

};


// Implementation of class SMALL_INT :

inline SMALL_INT::SMALL_INT( int n ) {

  data = ( ( n % MAX_SMALL ) + MAX_SMALL ) % MAX_SMALL;

}

inline SMALL_INT operator+( SMALL_INT& a, SMALL_INT& b ) {

  return a.data + b.data;

}
inline SMALL_INT operator-( SMALL_INT& a, SMALL_INT& b ) {

  return a.data - b.data;

}

inline SMALL_INT& SMALL_INT::operator++( void ) {

  *this = ++data;
  return *this;

}
inline SMALL_INT& SMALL_INT::operator--( void ) {

  *this = --data;
  return *this;
}

inline SMALL_INT& SMALL_INT::operator+=( SMALL_INT& a ) {

  *this = ( data += a.data );
  return *this;

}
inline SMALL_INT& SMALL_INT::operator-=( SMALL_INT& a ) {

  *this = ( data -= a.data );
  return *this;
}

inline int operator== ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data == b.data );
}
inline int operator!= ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data != b.data );
}

inline int operator< ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data < b.data );
}
inline int operator> ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data > b.data );
}
inline int operator<= ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data <= b.data );
}
inline int operator>= ( SMALL_INT& a, SMALL_INT& b ) {

  return ( a.data >= b.data );
}

inline void SMALL_INT::print ( void ) {

  printf( "\n%d", data );
}
