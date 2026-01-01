void printf( char*, ... );
inline void put2( int x ) { printf( " %d %d ", x, x ); }
main() {
int i = 5;
put2( i++ );
}

