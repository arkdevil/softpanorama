typedef long typ;

/*	This function implements:	big::operator[]()	*/

typ *_big__vec( f, index )
typ huge *f;
long index;
{
	return &f[index];
}


/*	Allocate the huge array		*/

typ huge bigarray[40000];
