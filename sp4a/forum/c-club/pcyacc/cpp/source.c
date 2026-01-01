extern void exit (int );
struct inset {
	int cursize ;
	int maxsize ;
	int *x ;
	int test ;
};
void inset_insert (int t );
int inset_member (int t );
inset__inset();
inset_inset (int m , int n );
int inset_next (int *index ){
	return x[index++];
}
int inset_ok (int *i ){
	int k ;
	k = i < cursize;
	return k;
}
int inset_iterate (int *i ){
	i = 0;
}
inset_inset (int m , int n ){
	if (m < 1 || n < m) exit(1);
	cursize = 0;
	maxsize = m;
	x = ( int *) malloc(sizeof(int ) * maxsize);
}
inset__inset(){
	free(x);
}
void inset_insert (int t ){
	if (++cursize > maxsize) exit(1);
	int i = cursize - 1;
	x[i] = t;
	while (i > 0 && x[i - 1] > x[i]) {
		int s = x[i];
		x[i] = x[i - 1];
		x[i - 1] = s;
		i--;
	}
}
int inset_member (int t ){
	int l = 0;
	int u = cursize - 1;
	int m ;
	while (l <= u) {
		m = (l + u) / 2;
		if (t < x[m]) {
			u = m - 1;
		}

		else if (t > x[m]) {
			u = l + 1;
		}

		else {
			return 1;
		}
	}
	return 0;
}
