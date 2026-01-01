#include <stdio.h>
#include <dos.h>

main(int argc,char **argv)
{ FILE *ptr1,*ptr2;
  struct find_t findinfo;
  unsigned i,k,FONT_HEIGHT;
  unsigned char symmap[16];
  unsigned static char xlat[]=
    {	0260, 0261, 0262, 0263, 0264, 0265, 0266, 0267,
	0270, 0271, 0272, 0273, 0274, 0275, 0276, 0277,
	0300, 0301, 0302, 0303, 0304, 0305, 0306, 0307,
	0310, 0311, 0312, 0313, 0314, 0315, 0316, 0317,
	0320, 0321, 0322, 0323, 0324, 0325, 0326, 0327,
	0330, 0331, 0332, 0333, 0334, 0335, 0336, 0337,
	0360, 0361, 0362, 0363, 0364, 0365, 0366, 0367,
	0370, 0371, 0372, 0373, 0374, 0375, 0376, 0377,
	238,  160,  161,  230,  164,  165,  228,  163,
	229,  168,  169,  170,  171,  172,  173,  174,
	175,  239,  224,  225,  226,  227,  166,  162,
	236,  235,  167,  232,  237,  233,  231,  234,
	158,  128,  129,  150,  132,  133,  148,  131,
	149,  136,  137,  138,  139,  140,  141,  142,
	143,  159,  144,  145,  146,  147,  134,  130,
	156,  155,  135,  152,  157,  153,  151,  154
     };

  if(argc != 3)
    { printf("This program converts Alt.GOST matrix font files\n");
      printf("(for example, created with EVAFONT) into KOI-8\n");
      printf("Usage: UNIXFNT <ALTGOST_FNAME> <KOI8_FNAME>\n");
      return(-1);
    }

  if(_dos_findfirst(argv[1],0xFFFF,&findinfo))
    { printf("File %s doesnot exist!\n",argv[1]);
      return(-1);
    }
  switch((int)findinfo.size)
    { case 2048: FONT_HEIGHT=8; break;
      case 3584: FONT_HEIGHT=14; break;
      case 4096: FONT_HEIGHT=16; break;
      default: printf("File %s is not valid EVAFONT file!\n",argv[1]);
    }

  ptr1=fopen(argv[1],"rb");
  ptr2=fopen(argv[2],"wb");

  for(i=0;i<256;i++)
    { if(i<128)
	k=i;
      else
	k=xlat[i-128];
      fseek(ptr1,(long)(k*FONT_HEIGHT),SEEK_SET);
      fread(symmap,FONT_HEIGHT,1,ptr1);
      fwrite(symmap,FONT_HEIGHT,1,ptr2);
    }
  fclose(ptr1);
  fclose(ptr2);
}
void _nullcheck() {}
void _setenvp() {}
