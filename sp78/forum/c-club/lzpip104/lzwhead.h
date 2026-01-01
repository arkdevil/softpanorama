/* lzwhead.h - this is part of the Tar program (see file define.h) */

int  z_getmem __ARGS__(( int ));
void z_relmem __ARGS__(( void ));
int  dbegin   __ARGS__(( int(*)() ));
int  dpiece   __ARGS__(( char *, int ));
