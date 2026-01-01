// Definition of a node of the TREE :

typedef struct N {
		    N* pre;
		    N* next;
		    SMALL_INT pc;

		    void* operator new( size_t num = 1 );
		    void operator delete( void* node );

		 } NODE;

const NALL = 2000;
N* nfree;

#pragma argsused
void* N::operator new( size_t num )
{
    N* p = nfree; // сначала выделить

    if (p)
	nfree = p->next;
    else { // выделить и сцепить
	N* q = (N*)new char[ NALL*sizeof(N) ];
	for (p=nfree=&q[NALL-1]; q<p; p--) p->next = p-1;
	(p+1)->next = 0;
    }

    return p; // затем инициализировать
}

void N::operator delete( void* node )
{
    ((N*)node)->next = nfree;
    nfree = (N*)node;
}

class TREE {

public :

// Pointer to current node :

	NODE *current;

// Number of nodes :

	int nodes;

// Constructor :

	TREE ( SMALL_INT pc = 0 );

// Add and remove node functions :

	int add ( SMALL_INT pc = 0 );
	int remove ( void );

// Go through the tree ( from current node ) :

	void pre ( void );
	void next ( void );
};


// Implementation of class TREE :

inline TREE::TREE ( SMALL_INT pc ) {

  current = new NODE;
  current->next = current->pre = current;
  current->pc = pc;
  nodes = 1;
}

inline int TREE::add ( SMALL_INT pc ) {

NODE *tmp;
  if ( ( tmp = new NODE ) == NULL ) return -1;
  tmp->pre = current;
  tmp->next = current->next;
  current->next->pre = tmp;
  current->next = tmp;
  tmp->pc = pc;
  current = tmp;
  nodes++;
  return 0;
}

inline int TREE::remove ( void ) {

  if( current->next == current ) return -1;
  current->next->pre = current->pre;
  current->pre->next = current->next;
  NODE *tmp = current->next;
  delete current;
  current = tmp;
  nodes--;
}

inline void TREE::pre ( void ) {

  current = current->pre;
}

inline void TREE::next ( void ) {

  current = current->next;
}
