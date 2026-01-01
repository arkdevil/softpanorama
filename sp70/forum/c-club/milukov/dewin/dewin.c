#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <process.h>

// compile it in Compact model !

static char *jmem, *jcode, *jread, *INtable;

static char *explain[8] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
//    array of pointers to the Func Explain File's

   FILE *in, *out, *bout;      // streams
	long	newExeOffset;

   struct EXEo {
	char sign[2];		// MZ
    int  pPage, totalPages;    // всего стpаниц в обpазе
	int  rCount;		// элементов в таблице ссылок
	int  hSize;		// pазмеp заголовка в 16-байтн. $
    int  minMemory, maxMemory;
    int  SSoffset, SPoffset;
    int  chkSum, IP, CS, RitemOffset, ovlNumber;
    } o;

   struct NEWheader {
	char sign[2];		// NE
    unsigned char linkVer, linkRev;  // веpсия LINK, revision of LINK
    int  EToffset, ETlen;      // EntryTable offset & len from NewEXE
	unsigned long IchkSum;	// image chksum
	int  MFW;		// module flag word
	int  autoDATAsegNum;	// number of autoDATA seg's
	int  isLocHEAP;		// init size of local heap, added to autoDATA
	int  isStack;		// init size of stack, added to autoDATA
    int  winIP, winCS, winSP, winSS;
	int  SEGtableEnt;	// number of entries in segment table
	int  MODrefEnt;		// number of entries in module reference tbl
	int  NRtableLen;	// non-resident names table length
	int  SEGtableOff;	// segment table offset from new exe
	int  RStableOff;	// resource table offset
	int  RnamesTableOff;	// offset of resident names table
	int  MODrefOff;		// module ref table offset
	int  IMPnamesTableOff;	// imported names table offset
	unsigned long  NRtableOff;	// non-resident names table offset
					// from file begin
	int  MEPcount;		// movable entry point counter
	int  AlignSC;		// alignment shift count (0 same as 9)
    char reserv[2], os, reserv_[7], win_rev, win_ver;
	} newH;

    struct segRECORD {
    unsigned int Offset, Length;
    unsigned int FlagWord, AllocSize;
    } segR;

    struct resRECORD {
    unsigned int resType, resCount;
    unsigned long resResvd;
    } res;

    struct resDESCRIPTOR {
    unsigned int resOffset, resLen, resFLAG, resName;
    unsigned long resResvd;
    } resD;

    unsigned int Lshift;

    static char *resNAME[] = { "Cursor", "Bitmap", "Icon", "Menu template",
    "Dialog-box template", "String table", "Font directory", "Font",
    "Keyboard accelerator table", "","","Group Cursor",
    "","Group Icon","","Version Info"};

    static char *osName[] = { "Unknown", "OS/2", "Windows",
    "MS-DOS 4.x", "Windows 386", "BOSS", "invalid" };

    static char mName[16][33];     // module names up to 32 char
    static char nrName[128][33];    // non-resident names table
    static char oname[40];

long flen( FILE *f )
{
    long len;
    fseek( f, 0, 2); len=ftell(f); fseek( f, 0, 0);
    return len;
}

void getAt( FILE *f, long offset, unsigned int size, void *where )
{
    fseek( f, offset, 0);
    fread( where, size, 1, f);
}

char *mount( char *where, char *name )
{
    FILE *j;
    long s;
    char *temp;
    if ((j = fopen(name, "rb"))  == NULL) return NULL;
    s = flen(j);
    where = malloc( s + 1);
    if ( where == NULL ) {
    printf ( "WARNING: Not enough memory for Explain allocation\n");
    fclose(j);
    return NULL; }
    fread( where, s, 1, j);
    fclose(j);
    temp = where;
    temp += s;
    *temp = 0; // for string op's zero delimiter
    return where;
}

// expands expression MODULE.FUNC to string
char *NameIt( char *module, int func )
{
    char i, k=0;
    char s[10] = { 0,0,0,0,0, 0,0,0,0,0 };
    char *name;

    for (i=0; i < 8; i++ )
    {
    if (( explain[i] != NULL )&&( module != NULL )) {
        if ( strstr( explain[i], module ) == explain[i] )
            { sprintf( s, "~%d~", func );
              if (( name = strstr( explain[i], s )) == NULL) break;
              else {
                name += strlen( s );
                while (( *name != 0x0D ) && (k<39)) oname[k++] = *name++;
                oname[k] = 0;
                return oname;
                } //else
            }
	}
    }
    sprintf( oname, "%d", func );
    return oname;
}

typedef struct ENTRY { char seg; int offset; char name; } ENTRY ;
    ENTRY entry[512];
    int entryTOTAL;

void entryINIT(void) // clear an array of entry table ref's
{
    int i;
    for (i=0; i<512; i++) {
        entry[i].seg    = 0;
        entry[i].offset = 0;
        entry[i].name   = 0;
    }
    entryTOTAL = 0;
}

void entryPUT( char seg, int offset)
{
    int i=entryTOTAL;

    if (entryTOTAL == 512) return;
        entry[i].seg    = seg   ;
        entry[i].offset = offset;
    entryTOTAL++;
}

int entryGET( char seg, int where, struct ENTRY *to)
{
    int i=entryTOTAL;
xe:
    if (i==0) return -1;
    if (( where == entry[i-1].offset) && ( seg == entry[i-1].seg ))
    {
    to->offset = entry[i-1].offset;
    to->seg    = entry[i-1].seg   ;
    to->name   = entry[i-1].name  ;
        return 0;
    }
    i--;
    goto xe;
}





typedef struct RELOC { int offset, module, func; char mode; } RELOC ;
    RELOC reloc[512];
    int relocTOTAL;

void relocINIT(void) // clear an array of module ref's for current .seg
{
    int i;
    for (i=0; i<512; i++) {
        reloc[i].offset = 0;
        reloc[i].module = 0;
        reloc[i].func   = 0;
        reloc[i].mode   = 0;
    }
    relocTOTAL = 0;
}

void relocPUT( int offset, int module, int func, char mode)
{
    int i=relocTOTAL;

    if (relocTOTAL == 512) return;
        reloc[i].offset = offset;
        reloc[i].module = module;
        reloc[i].func   = func  ;
        reloc[i].mode   = mode  ;
    relocTOTAL++;
}

// fill out an structure offset:module.function contain the same offset
int relocGET( int where, struct RELOC *to)
{
    int i=relocTOTAL;
xe:
    if (i==0) return -1;
    if ( where == reloc[i-1].offset) {
	to->offset = reloc[i-1].offset;
	to->module = reloc[i-1].module;
	to->func   = reloc[i-1].func  ;
    to->mode   = reloc[i-1].mode  ;
        return 0;
    }
    i--;
    goto xe;
}

char *INstring(int offset)
{
    char i;
    char *t;
    char k=0;
    if ( INtable != NULL )
    {   t=INtable;
        t += offset;
        i=*t++;
        if (i>40) i=35;
        while (i-- > 0) oname[k++] = *t++;
        oname[k] = 0;
        return oname;
    }
    sprintf( oname, "FuncName offs %04Xh", offset);
    return oname;
}


unsigned int far decode( char *buf, char *code )
{
	asm extrn DESS:far
	asm push bx cx ds
	asm push ds
	asm lds bx,[buf]
	asm mov	cx,ds
	asm pop ds
	asm lds ax,[code]
	asm call DESS
	asm pop ds cx bx
	return _AX;
}

int processSEG( char *name, char segn )
{
   long clen;
   FILE *ain, *aout;      // streams
    char *cname;
    struct ENTRY ent;
    struct RELOC rel;
    unsigned int off=0;
    unsigned int t;
    char strb[128];

   if ((ain = fopen(name, "rb"))  == NULL) return -1;
   clen = flen(ain);
   if ( clen > ((unsigned long) 0xFF00) ) {
   fprintf( out, "Code file %s is too long, not processed\n", name);
   fclose(ain); return -1;}

   cname = strstr( name, ".seg" );
   cname = strcpy( cname, ".sea" );

   if   ((aout = fopen( name, "wt")) == NULL) { fclose(ain); return -1; };

    jmem = malloc( clen + 256);
    jread = malloc( clen + 256);
    if (( jmem == NULL ) || ( jread == NULL )) {
    fprintf ( aout, "Not enough memory for code allocation\n");
    fclose(ain); fclose(aout); return -1;
    };

    // пpеобpазуем char far *mem в code так, что смещение = 0
    asm push ax
    asm mov ax,word ptr jmem
    asm shr ax,4
    asm add ax,word ptr jmem+2
    asm inc ax
    asm inc ax
    asm mov word ptr jcode+2,ax
    asm mov word ptr jcode,0
    asm pop ax

   fread( jread, 1, clen, ain);

   asm push ax cx si di es ds
   asm les di,dword ptr jcode
   asm mov cx,word ptr [clen]
   asm lds si,dword ptr jread
   asm rep movsb
   asm pop ds es di si cx ax

   while (((unsigned long) off) < clen)
   {
    t=off;
    if ( t == newH.winIP ) fprintf( aout, "\n; Program Entry point\n");
    off = decode( strb, jcode );
    fprintf( aout, "%s", strb);

   // если в reloc table имеется запись, описывающая эту машинную команду
   if (relocGET( t+1, &rel) == 0)
   switch (rel.mode) {
    case 0: fprintf( aout, "\t\t; %s.%s",
    mName[rel.module], NameIt(mName[rel.module], rel.func) ); break;
    case 1:
                if ( ((rel.module)&0xFF) != 0xFF ) fprintf( aout,
		"\t; to fixed seg %04X:%04Xh", rel.module, rel.func );
		else fprintf( aout,
		"\t; to movable seg Entry #%04d.", rel.func );
		break;
    case 2:
		fprintf( aout, "\t; %s. %s",
                mName[rel.module], INstring(rel.func) );
		break;
   }
   else if (entryGET( segn,t, &ent) == 0)
    {fprintf( aout, "\t\t; %04X:%04Xh", ent.seg, ent.offset);
     if (ent.name != 0) fprintf( aout, "\t %s", nrName[ent.name]);}

   fprintf( aout, "\n");
   asm push ax
   asm mov ax,off
   asm mov word ptr jcode,ax
   asm pop ax
   };
   fclose(aout);
   fclose(ain);
   free(jread);
   free(jmem);
   return 0;
}

void pString(long offset)
{
    char i;
    long curpos;
    curpos = ftell(in);
    getAt( in, offset, sizeof(i), &i );
    while (i-- > 0) fputc( fgetc(in), out);
    fseek( in, curpos, 0);
}

static char fb[40];

char *pFlag( char flag )
{
    fb[0] = 0;
	sprintf( fb, "%d.", flag>>2 );
        if (( flag & 0x1) != 0) strcat( fb, "\tExports");
        if (( flag & 0x2) != 0) strcat( fb, "\tUseSingleDATA");
    return fb;
}

void pETable(void)
{
    struct { char number, seg; } ETheader;
    struct { char flag; int offset; } fixed;
    struct { char flag, cd, _3f, number; int offset; } movable;
    int entry=1;
    entryINIT();

// напечатаем таблицу адpесов входов в модуль
    fseek( in, newExeOffset+(long)newH.EToffset , 0 );
    fprintf( out,"[Entry table]\n\tat\t%lXh, movable entries"\
             " %d.\n\t#\tFix/Mov\tseg:offset\t#parm\tflags\n",
             newExeOffset+(long)newH.EToffset, newH.MEPcount );

    for (;;)
    {
        fread( &ETheader, sizeof( ETheader ), 1, in);
        if (ETheader.number == 0) break; // конец таблицы
        if (ETheader.seg == 0) // пустышка, пpопустим
        { fprintf( out,"\t%d.\tNull entry\n", entry++);
          entryPUT( 0,0 );
        fread( &ETheader, sizeof( ETheader ), 1, in);
        if (ETheader.number == 0) break;
        };
        while (ETheader.number-- >0)
        { if (ETheader.seg != 0xFF)    // fixed seg entries
            { fread( &fixed, sizeof( fixed ), 1, in);
            fprintf( out,"\t%d.\tF\t     %04Xh\t%s\n",
            entry++, fixed.offset, pFlag(fixed.flag) );
            entryPUT( 0xFF, fixed.offset );
            }
        else
            { fread( &movable, sizeof( movable ), 1, in);
            fprintf( out,"\t%d.\tM\t%04X:%04Xh\t%s\n",
            entry++, (int) movable.number, movable.offset,
            pFlag(movable.flag) );
            entryPUT( movable.number, movable.offset );
            };
	};
    }
}

void s2file(long offset, unsigned int len, char *name)
{
    long curpos;
    if ((bout = fopen(name, "wb"))  == NULL) return;
    curpos = ftell(in);
    fseek( in, offset, 0);
    while (len-- > 0) fputc( fgetc(in), bout);
    fseek( in, curpos, 0);
    fclose(bout);
}

void pSegment(void)
{
    int count = newH.SEGtableEnt, cname = 1;
    char name[40];

    fseek( in, newExeOffset+(long)newH.SEGtableOff , 0 );
    fprintf( out,"[Segment table] at %lXh\n\tOffset\tLength\tFLAGS\tAllocSize\tType\n",
             newExeOffset+(long)newH.SEGtableOff );

    while (count-- >0)
    {   fread( &segR, sizeof( segR ), 1, in);
        fprintf( out,"\t%lXh\t%Xh\t%Xh\t%Xh",
        (long)segR.Offset*Lshift,
        segR.Length, segR.FlagWord, segR.AllocSize);
        if (( segR.FlagWord & 0x1) != 0) fprintf( out, "\t\tDATA\n");
        else fprintf( out, "\t\tCODE\n");
        sprintf( name, "%d.seg", cname++);
        s2file( (long)segR.Offset*Lshift, segR.Length, name);
	relocINIT();
        if (( segR.FlagWord & 0x0100) != 0)
        {
	    int rcount;
	    struct { char adr_type, rel_type; int offset; } h;
            struct { int module, func; } imp;
            long curpos = ftell(in);

	    fprintf( out, "   ■■ Relocations for this segment:\n");
        getAt( in,((long) segR.Offset)*Lshift + segR.Length,
               sizeof( rcount ), &rcount);
            while ( rcount-- > 0 )
            {   fread( &h, sizeof( h ), 1, in);
                switch ( h.adr_type) {
                    case 1: fprintf( out, "\tOff"); break;
                    case 2: fprintf( out, "\tSeg"); break;
                    case 3: fprintf( out, "\tO+S"); break;
                    case 5: fprintf( out, "\tOFFS"); break;
                }
                fprintf( out, "\t%04Xh", h.offset);
                fread( &imp, sizeof( imp ), 1, in);
                switch ( h.rel_type & 0x03) {
                    case 0: if (( imp.module & 0xFF) != 0xFF ) fprintf( out,
                            "\tto fixed seg %04X:%04Xh\n",
                            imp.module, imp.func );
                            else fprintf( out,
                            "\tto movable seg Entry #%04d.\n", imp.func );
                            relocPUT( h.offset, imp.module, imp.func, 1);
                            break;
                    case 1:
                            if ( imp.module < 15 ) {
                            fprintf( out, "\t%s.%s\n",
                            mName[imp.module],
                            NameIt(mName[imp.module], imp.func) );
                            relocPUT( h.offset, imp.module, imp.func,0);
                            }
                            else
                            fprintf( out, "\tModule #%d.\tFunc %d.\n",
                            imp.module, imp.func ); break;
                    case 2:
                            if ( imp.module < 15 ) {
                            fprintf( out, "\tin %s. %s\n",
                            mName[imp.module], INstring(imp.func) );
                            relocPUT( h.offset, imp.module, imp.func,2);}
                            else
                            fprintf( out, "\tModule #%d.\t%s\n",
                            imp.module, INstring(imp.func) ); break;
                    default:
                            fprintf( out, "\t??\n");
                    } // end case
            }; // end while (rcount
            fseek( in, curpos, 0);
        }; // end if(
	if (( segR.FlagWord & 0x1) == 0) processSEG( name, cname-1 );
    printf("%s\t\r", name);
	};
}


void pResource(void)
{
    int RScount;
    int count;
    fprintf( out,"[Resource table]\n\toffset\t\t%d.\n", newH.RStableOff );
    getAt( in, newExeOffset+(long)newH.RStableOff, 2, &RScount);
    // смещения измеpены в 1^RScount байт
    fread( &res, sizeof( res ), 1, in);
    // пpочитаем заголовок pесуpса
    while ( res.resType != 0 )
    // тип 0 пpизнак последнего заголовка
    {
    fprintf( out,"\n\tResource ID\t");
    if ((res.resType & 0x8000) != 0) // номеp < 0 это индекс в таблице имен
    fprintf( out,"%d.\t%s\n",
    (res.resType & 0x7FFF),
    resNAME[(res.resType & 0x7FFF)-1]);
    // иначе это стpока в стиле Паскаль
    else {
    fprintf( out,"\x27");
    pString( newExeOffset+(long)newH.RStableOff+(long)res.resType);
    fprintf( out,"\x27\n");
    }
    count = res.resCount;
    // для всех pесуpсов этого типа
    fprintf( out,"\tOffset\tLength\tFLAGS\n");
    while (count-- > 0)
    {
    fread( &resD, sizeof( resD ), 1, in);
    fprintf( out,"\t%d.\t%d.\t%Xh\n",
    resD.resOffset, resD.resLen, resD.resFLAG);
    fprintf( out,"\tres.name\t");
    if ((resD.resName & 0x8000) != 0)
    // если номеp < 0 то это индекс в таблице имен
    fprintf( out,"%d.\n", (resD.resName & 0x7FFF));
    // иначе это стpока в стиле Паскаль
    else {
    fprintf( out,"\x27");
    pString( newExeOffset+(long)newH.RStableOff+(long)resD.resName);
    fprintf( out,"\x27\n");
    }
    };
    // пpочитаем следующий тип pесуpса
      fread( &res, sizeof( res ), 1, in);
    }
}

void pNames(long where)
{
    char i;
    int ref;
    fseek( in, where , 0 );
    lo:
    fread( &i, sizeof(i), 1, in);
    if (i==0) return;
    fprintf( out, "\t");
    while (i-- > 0) fputc( fgetc(in), out);
    fread( &ref, sizeof(ref), 1, in);
    fprintf( out, "\t% 4d.\n", ref);
    goto lo;
}

long len;

void ChkName(char *argv[])
{
   if (( strstr(strupr(argv[1]),".EXE") == NULL ) &&
      ( strstr(strupr(argv[1]),".DLL") == NULL ))
   {
      fprintf(stderr, "Input file not .exe nor .dll\n"); exit(1);
   }

   if ((in = fopen(argv[1], "rb"))  == NULL)
   {
      fprintf(stderr, "Can`t open input file.\n"); exit(1);
   }
}

void PrintOldHeader(void)
{
fprintf( out,"[DOS]\n\tFile Size\t%ld.\tLoad Image Size\t%Xh\n",
       len, o.totalPages*512 );
fprintf( out,"\tRelocation Table: entries %d. address %Xh\n",
       o.rCount, o.RitemOffset );
fprintf( out,"\tSize of header (in paragraphs) %Xh\n", o.hSize );
fprintf( out,"\tMemory Requirement (in paragraphs): min %Xh max %Xh\n",
            o.minMemory, o.maxMemory );
fprintf( out,"\tFile load checksum\t\t%Xh\n", o.chkSum );
fprintf( out,"\tOverlay Number\t\t\t%Xh\n", o.ovlNumber );
fprintf( out,"\tStack Segment (SS:SP)\t\t%04X:%04X\n",
            o.SSoffset, o.SPoffset );
fprintf( out,"\tProgram Entry Point (CS:IP)\t%04X:%04X\n",
            o.CS, o.IP );
}


void pModuleName(void)
{
    int c=newH.MODrefEnt;
    int o=0;
    char m; // module #
    long curpos = ftell(in);
    for (m=0; m<16; m++) mName[m][0] = 0;
    m=1;
    fprintf( out,"[Module reference table]\n\toffset\t%Xh,",
	     newExeOffset + newH.MODrefOff );
    fprintf( out," entries: %d.\n", newH.MODrefEnt);
    fprintf( out,"[Imported names table]\n\toffset\t%04Xh\n",
             newExeOffset + newH.IMPnamesTableOff );
    fseek( in, newExeOffset + newH.MODrefOff, 0);
    while (c-->0) {
    fread( &o, sizeof( o ), 1, in);
    fprintf( out,"\t");
    {
    char i,k=0;
    long curpos_;
    curpos_ = ftell(in);
    getAt( in, (long) newExeOffset + newH.IMPnamesTableOff + o, sizeof(i), &i);
    while (i-- > 0) {
        mName[m][k] = fgetc(in);
        fputc( mName[m][k++], out);
    }
    mName[m][k] = 0;
    if ( m < 15 ) m++;
    fseek( in, curpos_, 0);
    }
    fprintf( out,"\n");
    }
    if ( INtable != NULL )
    {   fseek( in, (long) newExeOffset + newH.IMPnamesTableOff, 0);
        fread( INtable, newH.EToffset - newH.IMPnamesTableOff, 1, in );}
    fseek( in, curpos, 0);
}

void pNRnames(void)
{
    char i,j,k;
    int ref;
    long where= newH.NRtableOff;
    long old=ftell(in);
fprintf( out,"[Resident names table]\n\toffset\t%Xh\n", newH.RnamesTableOff );
pNames( newExeOffset+(long)newH.RnamesTableOff);

fprintf( out,"[Non-resident names table]\n\toffset\t%lXh\tlength %Xh\n"\
	 "\tName\t\tIndex into Entry table\n",
	 newH.NRtableOff, newH.NRtableLen );
    k=0;
    fseek( in, where , 0 );
    lo:
    fread( &i, sizeof(i), 1, in);
    if (i==0) { fseek( in, old, 0); return;}
    fprintf( out, "\t");
    j=0;
    while (i-- > 0)
    { nrName[k][j]= fgetc(in); fputc( nrName[k][j++], out); }
    nrName[k][j]=0;
    fread( &ref, sizeof(ref), 1, in);
    if ((ref!=0)&&(k!=0)) entry[ref-1].name=k;
    fprintf( out, "\t% 4d.\n", ref);
    if (k<120) k++;
    goto lo;
}

void PrintNewHeader(void)
{
fprintf( out,
"\tLink version\t%d.%d\n", newH.linkVer, newH.linkRev );
fprintf( out,
"\tLength of ET\t%d.\n\tImage chkSum\t%lXh\n",
newH.ETlen, newH.IchkSum );
fprintf( out,"[Module flag word]\t%Xh\n", newH.MFW );
if ((newH.MFW & 0x8000) != 0) // библиотека
{ fprintf( out,"\tLibrary module\n");
  if ((newH.MFW & 0x4000) != 0) // нет ноpмального стека
  fprintf( out,"\tValid stack is not maintained\n");
  if ((newH.MFW & 0x0001) != 0) fprintf( out,"\tSINGLEDATA\n");
  else fprintf( out,"\tNOAUTODATA\n");
}
else
{ fprintf( out,"\tProgram module\n");
  if ((newH.MFW & 0x4000) != 0) // нет ноpмального стека
  fprintf( out,"\tValid stack is not maintained\n");
  if ((newH.MFW & 0x0002) != 0)
  fprintf( out,"\tMULTIPLEDATA\n");
}
  if ((newH.MFW & 0x0004) != 0) fprintf( out,"\tRuns in real mode\n");
  if ((newH.MFW & 0x0008) != 0) fprintf( out,"\tRuns in protected mode\n");

fprintf( out,"Number of autoDATA seg's %d.\n", newH.autoDATAsegNum );
fprintf( out,"Init size of local heap, added to autoDATA %d.\n", newH.isLocHEAP );
fprintf( out,"Init size of stack, added to autoDATA      %d.\n", newH.isStack );
fprintf( out,"Program entry      %04X:%04X\nInit stack pointer %04X:%04X\n",
              newH.winCS, newH.winIP, newH.winSS, newH.winSP );
fprintf( out,"Number of entries in segment table     %d.\n", newH.SEGtableEnt );

pETable();

INtable = NULL; // "imported names table" buffer
INtable = malloc( newH.EToffset - newH.IMPnamesTableOff + 1 );

pModuleName();
pNRnames();
pSegment();

if (INtable != NULL ) free( INtable );

if ( newH.RStableOff != newH.RnamesTableOff ) pResource();


fprintf( out,"Alignment shift count (0 same as 9) %d.\n", newH.AlignSC );
if (newH.os < 6 )
fprintf( out,"[Operating System]\n\t%s\n", osName[newH.os] );
fprintf( out,"[Expected Windows Version]\n\t%d.%d\n",
             newH.win_ver, newH.win_rev );
}

int main(int argc, char *argv[])    // входные паpаметpы
{
    if (argc < 2) { printf(
"\nDeWin: dump for MS Windows .exe & .dll files\n\
    v1.0  (c) 1994 Milukow A.V. 8-(254) 4-41-27\n\
    usage: DeWin Infile.exe [Outfile]\n\n\
    Creates an header-info file and 1 or more `*.seg` and `*.sea` file(s)\n\
    containing much more information about WINDOWS application\n"); return 1;
    }

   if   ((out = fopen(argv[2], "wt")) == NULL)    out = stdout;

    ChkName(argv);

    len = flen( in );

   fread( &o, sizeof(o), 1, in);    // считать заголовок

   if ((o.sign[0] != 'M') || (o.sign[1] != 'Z'))
        { fprintf( out, "Not found 'MZ'\n");
        fclose(in); fclose(out);
        return 0; }

   PrintOldHeader();

   getAt( in, (long) 0x3c , sizeof( newExeOffset ), &newExeOffset );

   if ( newExeOffset != 0L )
   {
   fprintf( out, "[NewExe header]\n\tfound at:\t%08lXh\n", newExeOffset );
   getAt( in, newExeOffset , sizeof( newH ), &newH );
   explain[0] = mount( explain[0], "krnl386.ex" );
   explain[1] = mount( explain[1], "gdi.ex" );
   explain[2] = mount( explain[2], "user.ex" );
   Lshift = 1<<newH.AlignSC;
   PrintNewHeader();
   free( explain[0] );
   free( explain[1] );
   free( explain[2] );
   };

   fclose(in); fclose(out);
   return 0;
}
