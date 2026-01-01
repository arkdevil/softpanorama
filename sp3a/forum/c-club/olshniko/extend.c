#define BYTE unsigned  char
#define WORD unsigned  int
#define DWORD unsigned long
#include <stdio.h>
#include <dos.h>
#include <conio.h>
typedef struct
	{
	WORD 	limit;
	WORD	low;
	BYTE 	high;
	BYTE 	acc;
	WORD	reserv;
	}  DT;
struct	{
	DT	dummy;
	DT	GDT_LOC;
	DT	src;
	DT 	tag;
	DT	cs;
	DT	ss;
	}  GDT =
	       {
	       { 0,0,0,0,0 },
	       { 0,0,0,0,0 },
	       { 0xFFFF,0,0,0x93,0 },
	       { 0xFFFF,0,0,0x93,0 },
	       { 0,0,0,0,0 },
	       { 0,0,0,0,0 }
	       };

main()
{
WORD pattern=0x55AA;
WORD save;
WORD tmp;
DWORD pattern_ptr;
DWORD save_ptr;
DWORD tmp_ptr;
WORD i,j;
BYTE  h;
pattern_ptr=( (DWORD)FP_SEG(&pattern) << 4 ) + FP_OFF(&pattern);
save_ptr   =( (DWORD)FP_SEG(&save)    << 4 ) + FP_OFF(&save);
tmp_ptr    =( (DWORD)FP_SEG(&tmp)     << 4 ) + FP_OFF(&tmp);
do
{
printf("\n    EXTENDED MEMORY SIZER   ESC-exit OTHER KEY - repeat ");
for (i=0;i<16;i++)
	{
	printf("\n%02X:",i*16);
	for(j=0;j<16;j++)
		{
                h=i*16+j;
                if (h<0x0a) {putch(' ');continue;} /* don't test main memory */
                /* ----------- save -------------- */
                GDT.src.high=h;
                GDT.src.low =0;  /* 64 kB  bounds */
                GDT.tag.low=(WORD) ( save_ptr & 0xFFFF );
                GDT.tag.high=(BYTE) ( (save_ptr & 0xFF0000l) >> 16  );
                _CX=1;_ES=_DS;_SI=FP_OFF(&GDT);_AH=0x87;
                __int__(0x15);
                /* ----------- write pattern ------------- */
                pattern=h*256+h;
                GDT.tag.high=h;
                GDT.tag.low =0;  /* 64 kB  bounds */
                GDT.src.low=(WORD) ( pattern_ptr & 0xFFFF );
                GDT.src.high=(BYTE) ( (pattern_ptr & 0xFF0000l) >> 16  );
                _CX=1;_ES=_DS;_SI=FP_OFF(&GDT);_AH=0x87;
                __int__(0x15);
                /* ----------- verify ------------- */
                tmp=0x1234;
                GDT.src.high=h;
                GDT.src.low =0;  /* 64 kB  bounds */
                GDT.tag.low=(WORD) ( tmp_ptr & 0xFFFF );
                GDT.tag.high=(BYTE) ( (tmp_ptr & 0xFF0000l) >> 16  );
                _CX=1;_ES=_DS;_SI=FP_OFF(&GDT);_AH=0x87;
                __int__(0x15);

                if (tmp==pattern) putch('+');
			else
			if (tmp!=0xFFFF)  putch('-');else putch('.');
                /* ----------- restore -------------- */
                GDT.tag.high=h;
                GDT.tag.low =0;  /* 64 kB  bounds */
                GDT.src.low=(WORD) ( save_ptr & 0xFFFF );
                GDT.src.high=(BYTE) ( (save_ptr & 0xFF0000l) >> 16  );
                _CX=1;_ES=_DS;_SI=FP_OFF(&GDT);_AH=0x87;
                __int__(0x15);
		}

	}
}
while (getch()!=0x1b);
}
