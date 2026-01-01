#include "vgallev.h"
main(argc,argv)
int argc;
char **argv;
{ int i,zero;
  if(argc<2)
    { printf("Usage: pcxview <file1> [file2] ...\n");
      return(-1);
    }
  zero=0;
  for(i=1;i<argc;i++)
    { loapcx_(&zero,&zero,argv[i]);
      printf("Cannot display file %s\nPress any key\n",argv[i]);
      if(getch()=='P'-'A'+1) hardco();
      initgr(0);
    }
  return(0);
}
