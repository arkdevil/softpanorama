/* 06-02-90 from Herbert Shildt  C: The complete reference */

/* The Quicksort algorithm */

void	quick(char *item,int count);
void	qs(char *item,int left,int right);

main(int argc,char *argv[])
{
	printf	(" %s",argv[1]);
	quick	(argv[1],strlen(argv[1]));
	printf	("\n %s",argv[1]);
}

void	quick(char *item,int count)
{
 	qs(item,0,count-1);
}

/* The Quicksort */

void	qs(char *item,int left,int right)
{
       	register	int		i,j;
        char		x,y;

	i = left; j = right;

	x = item[(left + right)/2];

do	{
	while( item[i]<x && i<right ) i++;
	while( x<item[j] && j>left  ) j--;

	if (i<=j)	{
		y = item[i];
		item[i] = item[j];
		item[j] = y;
		i++; j--;
			}
	}while(i<=j);

	if( left<j ) qs(item, left, j );
	if( i<right) qs(item, i, right);
}
