
class   node
{
        virtual ~node(){}
public:
      	node(){}
	virtual int	val(); 		// evaluate node
	virtual void 	print();        // pretty print node
};

int node::val()
{
 	printf("error"); return 0;
}

void node::print()
{
 	printf("%d",val());		// sensible default
}


class   node_int : public node			// integer node
{
	int i;
public:
	node_int( int j ) : i(j) {}
	int	val() {   return i; }
};

class   node_bop : public node 		// binary op node
{
	node *l, *r;
public:
       ~node_bop(){ delete l; delete r; }
	node_bop( node  * ll, node  * rr) : l(ll), r(rr) {}
	int	val();
	void 	print();

	virtual int   ofn(int l, int r);// binary op function
	virtual void  osm();		// binary op symbol print
};

int node_bop::val()
{	
	return ofn( l->val(), r->val() );
}

void node_bop::print()
{
	printf("(");		l->print();
	osm();			r->print();
	printf("=%d)",		val());
}

void node_bop::osm()
{
 	printf("error");          	// shouldn't happen
}

int node_bop::ofn( int, int)
{
 	printf("error"); return 0;	// shouldn't happen
}

class   node_sub : public node_bop 		// subtraction node
{
public:
	node_sub( node * ll, node * rr) : ( ll, rr ) {}
	int	ofn(int l, int r){ return l-r; }
	void 	osm(){  printf("-"); }
};

class   node_mul : public node_bop 		// multiplication node
{
public:
	node_mul( node * ll, node * rr) : ( ll, rr ) {}
	int	ofn(int l, int r){ return l*r; }
	void 	osm(){  printf("*"); }
};

main()
{
     node * n1 = new node_int(5),
	  * n2 = new node_int(7),
	  * n3 = new node_sub(n1,n2),
	  * n4 = new node_int(10),
	  * n5 = new node_mul(n4,n3);
	n5->print();
	delete n5;
}

