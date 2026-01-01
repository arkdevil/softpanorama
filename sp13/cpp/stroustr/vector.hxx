/*ident	"@(#)cfront:incl/vector.h	1.4" */
/* Modified to suit primitive C pre-processors, such as Lattice */
/* New usage:-
	#define VECtype float
	#include <vector.h>
   will create a class 'vector', which is a vector of floats
   and a class 'stack', which is a stack of floats
   The only problem is that you can only have one type of vector
   per source file !						*/

#ifndef FILE
#include<stdio.hxx>
#endif

extern void abort(int);
extern genericerror( int n, char* s )
{
	fprintf( stderr, "Error %d: %s\n", n, s );
	abort(111);
	return 0;
}

typedef int (*GPT)(int,char*);

extern GPT vector_handler;
extern GPT set_vector_handler(GPT);	

class vector {							
	VECtype* v;							
	int sz;								
public:									
	vector(int s)						
	{	if (s<=0) (*vector_handler)(1,"bad vector size");
		v = new VECtype[sz=s];					
	}								
	~vector() { delete[sz] v; }				
	vector(vector&);				
	vector& operator=(vector&);			
	int size() { return sz; }					
	void set_size(int);						
	VECtype& elem(int i) { return v[i]; }				
	VECtype& operator[](int i)					
	{	if (i<0 || sz<=i)					
		    (*vector_handler)(2,"vector index out of range");
		return v[i];					
	}								
};

GPT vector_handler = genericerror;	

vector::vector(vector& a)
{
	register i = a.sz;				
	sz = i;						
	v = new VECtype[i];				
	register VECtype* vv = &v[i];			
	register VECtype* av = &a.v[i];			
	while (i--) *--vv = *--av;			
}							
							
vector& vector::operator=(vector& a)	
{							
	register i = a.sz;				
	if (i != sz)					
		(*vector_handler)(3,"different vector sizes in assignment");
	register VECtype* vv = &v[i];				
	register VECtype* av = &a.v[i];				
	while (i--) *--vv = *--av;				
	delete[i] v;						
	return *this;						
}								
								
void vector::set_size(int s)				
{								
	if (s<=0) (*vector_handler)(4,"bad new vector size");
	VECtype* nv = new VECtype[s];				
	register i = (s<=sz)?s:sz;			
	register VECtype* vv = &v[i];			
	register VECtype* av = &nv[i];			
	while (i--) *--vv = *--av;			
	delete[sz] v;					
	v = nv;						
	sz = s;						
}							
							
GPT set_vector_handler( GPT a)			
{							
	GPT oo = vector_handler;		
	vector_handler = a;			
	return oo;					
}
	
	

extern GPT stack_handler;
extern GPT set_stack_handler(GPT);
class stack : vector {	
	int t;		
public:			
	stack(int s) : (s) { t = 0; } 
	stack(stack& a) : ((vector&)a) { t = a.t; }
	void push(VECtype& a)
	{	if (t==size()-1) (*stack_handler)(1,"stack overflow");
		elem(++t) = a;
	}		
	VECtype pop()
	{	if (t==0) (*stack_handler)(2,"stack underflow");
		return elem(t--);
	}			
	VECtype& top()		
	{	if (t==0) (*stack_handler)(3,"stack empty");
		return elem(t);	
	}			
};

GPT stack_handler;
GPT set_stack_handler( GPT a)
{
	GPT oo = stack_handler;
	stack_handler = a;
	return oo;
}

