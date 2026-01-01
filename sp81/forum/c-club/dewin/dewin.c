#include <stdio.h>
#include <dos.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <process.h>

// compile it in Compact model !
typedef  unsigned int uint;
typedef  unsigned int ushort;
typedef  unsigned long ulong;
typedef  unsigned char uchar;


static char *jmem, *jcode, *jread, *INtable, *tempp;

static char *explain[8] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
//    array of pointers to the Func Explain File's

char pathName[140];

int options;

   FILE *in, *out, *bout;      // streams
        ulong    newExeOffset;

   struct EXEo {
	char sign[2];		// MZ
    int  pPage, totalPages;    // всего стpаниц в обpазе
	int  rCount;		// элементов в таблице ссылок
	int  hSize;		// pазмеp заголовка в 16-байтн. $
    int  minMemory, maxMemory;
    int  SSoffset, SPoffset;
    uint  chkSum, IP, CS, RitemOffset, ovlNumber;
    } o;

   struct NEWheader {
	char sign[2];		// NE
    unsigned char linkVer, linkRev;  // веpсия LINK, revision of LINK
    uint  EToffset, ETlen;      // EntryTable offset & len from NewEXE
        ulong IchkSum;  // image chksum
	int  MFW;		// module flag word
	int  autoDATAsegNum;	// number of autoDATA seg's
	int  isLocHEAP;		// init size of local heap, added to autoDATA
	int  isStack;		// init size of stack, added to autoDATA
    int  winIP, winCS, winSP, winSS;
	int  SEGtableEnt;	// number of entries in segment table
	int  MODrefEnt;		// number of entries in module reference tbl
	int  NRtableLen;	// non-resident names table length
       uint  SEGtableOff;       // segment table offset from new exe
       uint  RStableOff;        // resource table offset
       uint  RnamesTableOff;    // offset of resident names table
       uint  MODrefOff;         // module ref table offset
       uint  IMPnamesTableOff;  // imported names table offset
        ulong  NRtableOff;      // non-resident names table offset
					// from file begin
	int  MEPcount;		// movable entry point counter
	int  AlignSC;		// alignment shift count (0 same as 9)
    char reserv[2], os, reserv_[7], win_rev, win_ver;
	} newH;

    struct segRECORD {
    uint Offset, Length;
    uint FlagWord, AllocSize;
    } segR;

    struct resRECORD {
    uint resType, resCount;
    ulong resResvd;
    } res;

    struct resDESCRIPTOR {
    uint resOffset, resLen, resFLAG, resName;
    ulong resResvd;
    } resD;

    uint Lshift;

    static char *resNAME[] = { "CURSOR", "BITMAP", "ICON", "MENU",
    "DIALOG", "STRING", "FONTDIR", "FONT",
    "ACCELERATOR", "RCDATA","?-(11)","GROUP CURSOR",
    "?-(13)","GROUP ICON","","VERSION INFO"};

    static char *osName[] = { "Unknown", "OS/2", "Windows",
    "MS-DOS 4.x", "Windows 386", "BOSS", "invalid" };

#define MaxNRnames 1800 // максимальный размер массива имен
#define MaxEntry 1800   // размер таблицы точек входа

    static char mName[16][33];     // module names up to 32 char
    //static char nrName[MaxNRnames][33];    // non-resident names table
    char *nrName;
    static char oname[40];

ulong flen( FILE *f )
{
    ulong len; fseek( f, 0, 2); len=ftell(f); fseek( f, 0, 0); return len;
}

void ofprintf( char *t ) { fprintf( out, t ); }

void iseek( ulong i ) { fseek( in, i, 0 ); }

void iseekNE( ulong i ) { fseek( in, i+newExeOffset, 0 ); }

void getAt( ulong offset, uint size, void *where )
{
    fseek( in, offset, 0); fread( where, size, 1, in);
}

void go_back(signed int c)
{
 fseek(in, (signed long)-c, 1);
}

char *mount( char *where )
{
    FILE *j;
    ulong s;

    if ((j = fopen(pathName, "rb"))  == NULL) return NULL;
    s = flen(j);
    where = malloc( s + 1);
    if ( where == NULL ) {
    printf ( "WARNING: Not enough memory for Explain allocation\n");
    fclose(j);
    return NULL; }
    fread( where, s, 1, j);
    fclose(j);
    where[s] = 0; // for string op's zero delimiter
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
	if ( memcmp( explain[i], module, strlen(module)) == 0 )
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

typedef struct ENTRY { char seg; uint offset; uint name; } ENTRY ;
    ENTRY entry[MaxEntry];
    int entryTOTAL;


void entryINIT(void) // clear an array of entry table ref's
{
	asm push ax cx di es ds
	asm pop es
	asm xor al,al
	asm mov di,offset entry
        _CX = MaxEntry*sizeof( entry[0] );
	asm rep stosb
	asm pop es di cx ax
    entryTOTAL = 0;
}

void entryPUT( char seg, int offset)
{
    if (entryTOTAL == MaxEntry) return;
    asm push bx
    asm mov bx,entryTOTAL
    asm mov ax,bx
    asm shl bx,2
    asm add bx,ax
    asm mov al,seg
    asm mov byte ptr entry.seg[bx],al
    asm mov ax,offset
    asm mov word ptr entry.offset[bx],ax
    asm pop bx
    entryTOTAL++;
}

int entryGET( char seg, int where, struct ENTRY *to)
{
    int i=entryTOTAL;
xe:
    if (i==0) return -1;
    i--;
    _BX = i;
    asm mov ax,bx
    asm shl bx,2
    asm add bx,ax
    asm mov ax, word ptr entry.offset[bx]
    asm cmp ax,where
    asm jne xe
    asm mov al, byte ptr entry.seg[bx]
    asm cmp al,seg
    asm jne xe

    asm push es
    asm les bx,dword ptr to
    asm mov byte ptr es:[offset entry.seg-offset entry][bx],al
    asm mov ax,where
    asm mov word ptr es:[offset entry.offset-offset entry][bx],ax
    _BX = i;
    asm mov ax,bx
    asm shl bx,2
    asm add bx,ax
    asm mov ax, word ptr entry.name[bx]
    asm mov bx, word ptr to
    asm mov word ptr es:[offset entry.name-offset entry][bx],ax
    asm pop es
	return ++i ;
}





typedef struct RELOC { int offset, module, func; char mode; } RELOC ;
    RELOC reloc[MaxEntry];
    int relocTOTAL;

void relocINIT(void) // clear an array of module ref's for current .seg
{
        asm push ax cx di ds
	asm pop es
	asm xor al,al
	asm mov di,offset reloc
        _CX = MaxEntry*sizeof( reloc[0] );
	asm rep stosb
        asm pop di cx ax
    relocTOTAL = 0;
}

void relocPUT( int offset, int module, int func, char mode)
{
    if (relocTOTAL == MaxEntry) return;
    asm push bx dx
    asm mov ax,relocTOTAL
    _DX = sizeof( reloc[0] );
    asm mul dx
    asm mov bx,ax
    asm mov al,mode
    asm mov byte ptr reloc.mode[bx],al
    asm mov ax,offset
    asm mov word ptr reloc.offset[bx],ax
    asm mov ax,module
    asm mov word ptr reloc.module[bx],ax
    asm mov ax,func
    asm mov word ptr reloc.func[bx],ax
    asm pop dx bx
    relocTOTAL++;
}

// fill out an structure offset:module.function contain the same offset
int relocGET( int where, struct RELOC *to)
{
    int i=relocTOTAL;
xe:
    if (i==0) return -1;
    i--;
    _AX = i;
    _DX = sizeof( reloc[0] );
    asm mul dx
    asm mov bx,ax
    asm mov ax, word ptr reloc.offset[bx]
    asm cmp ax,where
    asm jne xe

    // be careful !     DO NOT word align
    asm push si di
    asm mov si,offset reloc
    asm add si,bx
    asm les di,dword ptr to
    _CX = sizeof( reloc[0] );
    asm rep movsb
    asm pop di si
	return 0;
}


unsigned int *tree; // store cross ref's chain in a tree
int tree_lev;       // size of tree

void tree_put( int adr, int ref )
{
        asm mov ax,tree_lev
        asm cmp ax,4096
        asm jnc ex
        asm shl ax,1
        asm les bx,dword ptr tree
        asm add bx,ax
        asm mov ax,adr
        asm mov word ptr es:[bx],ax
        asm mov ax,ref
        asm mov word ptr es:[bx+2],ax
        asm add tree_lev,2
        ex:
        ;
}

// be careful ! RECURSIVE

int tree_get( int adr )
{
	int j, count = 0;
	if ( adr == 0 ) return 0;

        f:
	if ( count >= tree_lev ) return adr; // not found nothing

        j = tree[ count++ ]; // adres of caller

	if ( tree[ count++ ] == adr+1 ) return tree_get( j );
        else goto f;
}



char *INstring(int offset)
{
    char i;
    char *t;
    char k=0;
    if ( INtable != NULL )
    {   t=INtable;
        t += offset;
	i = *t++;
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
        asm push bx cx ds ds
	asm lds bx,[buf]
	asm mov cx,ds
	asm pop ds
	asm lds ax,[code]
	asm call DESS
	asm pop ds cx bx
	return _AX;
}

// creates deassembled code segment
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
    int e;
    int cmd_class;
    char far *pref; // pointer to segment prefix string, like a 'ES:'
    char pref_buf[10]; // temporary buffer
    char need_ins=0; // =1 if prefix string need to insert into command

    tree_lev = 0; // chain tree empty

   if ((ain = fopen(name, "rb"))  == NULL) return -1;
   clen = flen(ain);
   if ( clen > ((ulong) 0xFF00) ) {
   fprintf( out, "Code %s is too long, skipped\n", name);
   fclose(ain); return -1;}

   cname = strstr( name, ".seg" );
   cname = strcpy( cname, ".sea" );

   if   ((aout = fopen( name, "wt")) == NULL) { fclose(ain); return -1; };

    jmem = malloc( clen + 256);
    jread = malloc( clen + 256);
    if (( jmem == NULL ) || ( jread == NULL )) {
    fprintf ( aout, "Code seg not malloc()ed\n");
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


// pass one: cross ref analyze
   tempp = jcode;
   printf("Pass #1 \r");
   while (((unsigned long) off) < clen)
   {
    t=off;

    off = decode( strb, jcode );
    cmd_class = _DX; // class of deassembled command

    if ( cmd_class == 3 ) // far call's
    {
        jcode++;
        tree_put( t, *((unsigned short *)jcode));
        jcode--;
    }
    else if (cmd_class == 1)
    {
        asm push ds dx bx
        asm mov bx,off
        asm lds dx,jcode
	asm cmp byte ptr ds:[bx],0
        asm pop bx dx ds
        asm jne norm_
	asm inc off
	norm_:
	;
    }
   asm push ax
   asm mov ax,off
   asm mov word ptr jcode,ax
   asm pop ax
   };
   off = 0;
   jcode = tempp;
// pass one end

   printf("Pass #2 \n");
   while (((unsigned long) off) < clen)
   {
    t=off;
    if (( t & 0x003F) == 0x003F) {
    int procent;
    asm push ax cx dx
    asm mov ax,[t]
    asm mov cx,100
    asm mul cx
    asm mov cx, word ptr [clen]
    asm div cx
    asm mov [procent],ax
    asm pop dx cx ax
    printf("%3d%%\r", procent);
    } // progress indicator

    if ( t == newH.winIP ) fprintf( aout, "\n; Program Entry point\n");
    off = decode( strb, jcode );
    cmd_class = _DX; // class of deassembled command

    if ((( cmd_class == 0 ) && (need_ins == 0)) ||
       (( cmd_class == 3 ) && (need_ins == 0)))
    {
    fprintf( aout, "%s", strb);
    }
    else if (cmd_class == 2)
    {
	pref=strb; pref += 5; *pref++ =0;
	strcpy(pref_buf,pref);
	fprintf( aout, "%s\t", strb);
        need_ins=1;
    }
    else if (cmd_class == 1)
    {
        asm push ds dx bx
        asm mov bx,off
        asm lds dx,jcode
	asm cmp byte ptr ds:[bx],0
        asm pop bx dx ds
        asm jne norm
	fprintf( aout, "%s\t; db 0 skipped", strb);
        off++;
        goto ex;
        norm:
        fprintf( aout, "%s", strb);
        ex:
        need_ins=0;
    }
    else if (need_ins == 1)
    {
	char far *ttc;
	ttc=strchr(strb,0x5B);
	if (ttc) *ttc= 0;
	pref=strb; pref += 6;
	fprintf( aout, "%s", pref); // command body
	fprintf( aout, "%s", pref_buf); // saved prefix
	if (ttc) {*ttc=0x5B; fprintf( aout, "%s", ttc);}
	need_ins=0;
    }

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
		fprintf( aout, "\t\t; %s.%s",
		mName[rel.module], INstring(rel.func) );
		break;
   }
   else if ((e = entryGET( segn,t, &ent)) > 0)
    {fprintf( aout, "\t\t; E=%d, %04X:%04Xh", e, ent.seg, ent.offset);
     if (ent.name != 0) fprintf( aout, "\t %s", nrName+ent.name*33);}

   else if ((cmd_class == 3) && ( (t=tree_get(t)) > 0 ))
         {       // если в reloc table имеется запись, описывающая эту машинную команду
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
			     fprintf( aout, "\t\t; %s.%s",
                             mName[rel.module], INstring(rel.func) );
                             break;
                }
                else if ((e = entryGET( segn,t, &ent)) > 0)
                 {fprintf( aout, "\t\t; E=%d, %04X:%04Xh", e, ent.seg, ent.offset);
                  if (ent.name != 0) fprintf( aout, "\t %s", nrName+ent.name*33 );}
         }

   if (need_ins == 0) fprintf( aout, "\n");
   if (cmd_class == 1) fprintf( aout, "\n");

   asm push ax
   asm mov ax,off
   asm mov word ptr jcode,ax
   asm pop ax
   };
   fclose(aout); fclose(ain);
   free(jread); free(jmem);
   return 0;
}

void pString(ulong offset)
{
    char i;
    ulong curpos = ftell(in);
    getAt( offset, sizeof(i), &i );
    while (i-- > 0) fputc( fgetc(in), out);
    iseek( curpos );
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
    iseekNE( (ulong)newH.EToffset );
    fprintf( out,"[Entry table]\n\tat\t%lXh, movable entries"\
             " %d.\n\t#\tFix/Mov\tseg:offset\t#parm\tflags\n",
             newExeOffset+(ulong)newH.EToffset, newH.MEPcount );

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
            fprintf( out,"\t%d.\tF\t%04X:%04Xh\t%s\n",
            entry++, ETheader.seg, fixed.offset, pFlag(fixed.flag) );
            // entryPUT( 0xFF, fixed.offset );
            entryPUT( ETheader.seg, fixed.offset );
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

char copyBuffer[1024];
void fileCopy( FILE *in, FILE *out, long len )
{
    int n;
    while ( len != 0) {
		n = (unsigned int)(( len > 1024 ) ? 1024 : len );
		fread ((char *)copyBuffer, 1, n, in);
                fwrite((char *)copyBuffer, 1, n, out);
		len -= n;
    }
}

// copies code segment from .dll to standalone file
void seg2file( ulong offset, uint len, char *name)
{
    long curpos;
    int n;
    if ((bout = fopen(name, "wb"))  == NULL) return;
    curpos = ftell(in);
    iseek( offset );
    fileCopy( in, bout, (ulong)len );
    iseek( curpos );
    fclose(bout);
}

void fineSegSRC( char *name )
{
   long clen, cclen;
   FILE *ain, *aout;      // streams
    int j, adr;
    char c, d, e;

    char *nmbr = malloc( 0x7FFF );
    if ( nmbr == NULL ) { printf("label check failed, no heap\n");
	return; }

    for ( j=0; j<0x7FFF; j++ ) nmbr[j] = 0;

   if ((ain = fopen(name, "rb"))  == NULL) {
        free( nmbr );
	return; // name of .sea
   }
   cclen = clen = flen(ain);

   adr = 0;
   while ( clen-- >0 )
   {
        c = fgetc(ain);
	if ( isxdigit(c) )
	{
		adr *= 16;
		if ( c < 65 ) adr += (c-48);
		else adr += (c-65+10);
	}
	else  // ":" ends the addres label
        {
		if ( c != 58 ) nmbr[adr & 0x7FFF] = 1;
                adr = 0;
        }
   }
   fseek( ain,0,0 );

   printf(" search done, ");
   strcpy( strstr( name, ".sea" ), ".asm" );

   if ((aout = fopen(name, "wb"))  == NULL) {
        fclose( ain );
        free( nmbr );
	return; // name of .asm
   }

   clen = cclen;

   while ( clen-- >0 )
   {
        c = fgetc(ain);
        if ( c != 0x0A ) fputc( c, aout );
        else
        {
               fputc( c, aout );
               adr = 0;
               j = 0;                   // count of fgetc()

               rr:
                c = fgetc(ain); j++;

                if ( isxdigit(c) )
                {
                        adr *= 16;
                        if ( c < 65 ) adr += (c-48);
                        else adr += (c-65+10);
                        if ( j < 7 ) goto rr;
		}

		    fgetc(ain);   // skip Tab
		d = fgetc(ain);   // get 'C' if Call
		e = fgetc(ain);   // get 'a' if Call
		fseek( ain, (signed long)(-3), 1 );


		if (( nmbr[adr & 0x7FFF] != 0 ) ||
		    ( j != 5 ) ||
                    (( d == 0x43) && ( e == 0x61) && ( nmbr[(adr+1) & 0x7FFF] != 0 ))
                    )
                {
			fseek( ain, (signed long)(-j), 1 );     // go back
                }
		else clen -= j;


        }
   }

   fclose(ain);
   fclose(aout);
   free(nmbr);
}

void pSegment(void)
{
    int count = newH.SEGtableEnt, cname = 1;
    char name[40];

    iseekNE( (ulong)newH.SEGtableOff );

    fprintf( out,"[Segment table] at %lXh\n"\
    "\tnote:\tFS means \'fixed segment\'\n\t\tMSE means \'movable Seg Entry\'\n"\
    "\tOffset\tLength\tFLAGS\tAllocSize\tType\n",
             newExeOffset+(ulong)newH.SEGtableOff );

    while (count-- >0)
    {   fread( &segR, sizeof( segR ), 1, in);
        fprintf( out,"\t%lXh\t%Xh\t%Xh\t%Xh",
        (ulong)segR.Offset*Lshift,
        segR.Length, segR.FlagWord, segR.AllocSize);
        if (( segR.FlagWord & 0x1) != 0) ofprintf("\t\tDATA\n");
        else ofprintf("\t\tCODE\n");
	sprintf( name, "%04d.seg", cname++);
        seg2file( (ulong)segR.Offset*Lshift, segR.Length, name);
	relocINIT();
        if (( segR.FlagWord & 0x0100) != 0) if (( options & 0x8) == 0)
        {
	    int rcount;
	    struct { char adr_type, rel_type; int offset; } h;
            struct { int module, func; } imp;
            ulong curpos = ftell(in);

            ofprintf("   ■■ Relocations for this segment:\n");
        getAt( ((ulong) segR.Offset)*Lshift + segR.Length,
               sizeof( rcount ), &rcount);
            while ( rcount-- > 0 )
            {   fread( &h, sizeof( h ), 1, in);
                switch ( h.adr_type) {
                    case 1: ofprintf("\tOff"); break;
                    case 2: ofprintf("\tSeg"); break;
                    case 3: ofprintf("\tO+S"); break;
                    case 5: ofprintf("\tOFFS"); break;
                }
                fprintf( out, "\t%04Xh", h.offset);
                fread( &imp, sizeof( imp ), 1, in);
                switch ( h.rel_type & 0x03) {
                    case 0: if (( imp.module & 0xFF) != 0xFF ) fprintf( out,
			    "\tto FS %04X:%04Xh\n",
			    imp.module, imp.func );
			    else fprintf( out,
			    "\tto MSE #%04d.\n", imp.func );
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
			    ofprintf("\t??\n");
		    } // end case
	    }; // end while (rcount
	    iseek( curpos );
	}; // end if(
	if ((( segR.FlagWord & 0x1) == 0) &&
	     (( options & 0x1) == 0)   )
	{
		processSEG( name, cname-1 );   // create .sea
		printf("%s created, ",name);
                fineSegSRC( name );
		printf("%s\n",name);
                strcpy( strstr( name, "." ), ".sea" );
                unlink( name );                // delete .sea

		}
    else printf("%s\t\r", name);
   if ((( segR.FlagWord & 0x1) == 0) && ((options & 0x0004) == 0)) {
   strcpy( strstr( name, "." ), ".seg" );
   unlink( name );                             // delete .seg for CODE
   }

	};
}

void putPascalStr(int o)
{
    ofprintf("\x27");
    pString( newExeOffset+(ulong)newH.RStableOff+(ulong)o );
    ofprintf("\x27\n");
}


// structures for BITMAP resource save
struct BMPheader {

// BitMapFileHeader
    int       bfType;             // BM
    long int  bfSize;                // file size
    int       bfReserved1;
    int       bfReserved2;
    long int  bfOffBits;             // offset BITMAP from begin of file
} BMPfileH;

struct BMPinfo {
// BitMapInfoHeader
    long int    biSize;         // header partial size, 40./12. bytes
    long int    biWidth;
    long int    biHeight;
    int         biPlanes;
    int         biBitCount;
} BMPheader;

struct {                        // only if biSize is 40. bytes
    long int    biCompression;
    long int    biSizeImage;
    long int    biXPelsPerMeter;
    long int    biYPelsPerMeter;
    long int    biClrUsed;
    long int    biClrImportant;
} h40;


char BMPname[14];
FILE *createDIB( char *name, int *count) // create an .ICO .BMP .CUR file
{
    sprintf( BMPname, name, (*count)++);
    return fopen(BMPname, "wb");
}

int BMPcount=1;
void putBITMAP( long off )
{
    FILE *b;
    long count;
    long curpos = ftell(in);
    if (( options & 0x0002 ) == 0) return;

    if ((b = createDIB( "bmp%04d.bmp", &BMPcount )) == NULL) return;

	getAt( off, sizeof(BMPheader), &BMPheader );

    BMPfileH.bfType = 0x4D42;   		// 'BM'
    count = 4L << (BMPheader.biBitCount);       // RGBquad[] size
    BMPfileH.bfOffBits=             		// offs BITMAP from begin of file
    BMPheader.biSize+((long)sizeof( BMPfileH )) + count;
    BMPfileH.bfSize =                   	// .BMP file size
    BMPfileH.bfOffBits +
    BMPheader.biWidth*BMPheader.biHeight*(long)(BMPheader.biBitCount)/8 ;

    BMPfileH.bfReserved1=BMPfileH.bfReserved2=0;

    fwrite( &BMPfileH, sizeof(BMPfileH), 1, b);
    iseek(off);
    count = BMPfileH.bfSize-sizeof(BMPfileH);
    fileCopy( in, b, count );
    fclose(b);
    iseek(curpos);
}

struct ICOheader {              // ICOfileHeader
    int       reserved;
    int       type;           // icon/cursor file signature 8-)
    int       count;          // 1 icon per file
//--------------------------- IcoDirEntry ------------
    char        biWidth;
    char        biHeight;
    char        biColorCount;
    char        reserved_;
    int         res1, res2;
    long        dwBytesInRes;
    long        dwImageOffset;
} ICOfile;

int ICOcount=1;
void putICON( long off )
{
    FILE *b;
    long count;
    long curpos = ftell(in);
    if (( options & 0x0002 ) == 0) return;

    if ((b = createDIB( "ico%04d.ico", &ICOcount )) == NULL) return;

	getAt( off, sizeof(BMPheader), &BMPheader );

    ICOfile.reserved=0;
    ICOfile.type=1;           // icon/cursor file signature 8-)
    ICOfile.count=1;          // 1 icon per file
    ICOfile.biWidth=(unsigned char)BMPheader.biWidth;
    ICOfile.biHeight=(unsigned char)(BMPheader.biHeight>>1);
    ICOfile.biColorCount=(unsigned char)(1<<BMPheader.biBitCount);
    ICOfile.reserved_=0;
    ICOfile.res1=ICOfile.res2=0;
    count = ((ulong)ICOfile.biWidth)*((ulong)ICOfile.biHeight);
    ICOfile.dwBytesInRes=BMPheader.biSize+4L*ICOfile.biColorCount+
    count*(ulong)(BMPheader.biBitCount)/8+count/8;
    ICOfile.dwImageOffset=sizeof(ICOfile);

    fwrite( &ICOfile, sizeof(ICOfile), 1, b);
    iseek(off);
    count = ICOfile.dwBytesInRes;
    fileCopy( in, b, count );
    fclose(b);
    iseek(curpos);
}


int CURcount=1;
void putCUR( long off )
{
    FILE *b;
    long count, temp;
    long curpos = ftell(in);
    if (( options & 0x0002 ) == 0) return;

    if ((b = createDIB( "cur%04d.cur", &CURcount )) == NULL) return;

    getAt( off, 2, &(ICOfile.res1));  // hot spot X
    getAt( off+2, 2, &(ICOfile.res2));  // hot spot Y
	getAt( off+4, sizeof(BMPheader), &BMPheader );
    fread( &temp, 4, 1, in);

    ICOfile.reserved=0;
    ICOfile.type=2;           // icon/cursor file signature 8-)
    ICOfile.count=1;          // 1 icon per file
    ICOfile.biWidth=(unsigned char)BMPheader.biWidth;
    ICOfile.biHeight=(unsigned char)(BMPheader.biHeight>>1);
    ICOfile.biColorCount=(unsigned char)(1<<BMPheader.biBitCount);
    ICOfile.reserved_=0;
    count = ((long)ICOfile.biWidth)*((long)ICOfile.biHeight);
    ICOfile.dwBytesInRes=BMPheader.biSize+4L*ICOfile.biColorCount+
    count*(long)(BMPheader.biBitCount)/8+count/8;
    ICOfile.dwImageOffset=sizeof(ICOfile);

    fwrite( &ICOfile, sizeof(ICOfile), 1, b);
    iseek(off+4);
    count = ICOfile.dwBytesInRes;
    fileCopy( in, b, count );
    fclose(b);
    iseek(curpos);
}

void spaces( int count )
{
    int space;
    ofprintf("\t");
    for ( space=0; space < count*3; space++ ) fputc( 0x20, out);
}

void putASCIIZ( void )
{
    char c;
    fputc( 0x22, out); while (( c = fgetc(in)) != 0) fputc(c, out);
    fputc( 0x22, out);
}

void putMENU( long off )
{
    long count;
    unsigned int flag, menuID;
    char c;
    int indent = 1;
    char endflag[32]; char level = 0;
    long curpos = ftell(in);

    if ( options & 0x0010 ) return;

    getAt( off, 4, &count );  // empty header
    ofprintf( "\n\tBegin\n" );

    read:
    fread( &flag, sizeof(flag), 1, in);
    spaces(indent);

    if (( flag & 0x0010) == 0 ) // normal menu item
    {
    fread( &menuID, sizeof(menuID), 1, in);
    ofprintf( "MenuItem " ); putASCIIZ(); fprintf( out, ", %u\n", menuID);
    if (( flag & 0x0080) != 0 )  // End
    {
        indent--;
        spaces(indent); ofprintf( "End\n" );
        while (( endflag[level] ) && (level))
        {
        indent--; level--;
        spaces(indent); ofprintf( "End\n" );
        }
        if ( indent <= 0 ) { iseek(curpos); return; }
    }
    }
    else                        // pop-up menu item
    {
    ofprintf( "POPUP " ); putASCIIZ(); ofprintf("\n");
    spaces(indent); ofprintf("Begin\n");
    indent++; level++;
    if (( flag & 0x0080) != 0 )  // End
      endflag[level] = 1;
    else endflag[level] = 0;
    }

    goto read;
}

char *class[6] = { "button","edit","static","listbox","scrollbar","combobox" };
void putDLG( long off )
{
    long style;
    unsigned int flag, menuID, j;
    unsigned int i[4];
    unsigned char count, c, len, name[64];
    long curpos = ftell(in);

    if ( options & 0x0010 ) return;

    getAt( off, 4, &style );                    // dialog style
    fread( &count, sizeof(count), 1, in);       // controls

    fread( &(i[0]), sizeof(i), 1, in);
    fprintf( out, "\nDIALOG %u, %u, %u, %u\n",
			 i[0],i[1],i[2],i[3] ); // coordinates

    if ((c=fgetc(in)) != 0) {
        ofprintf("menu ");
        if ( c == 0xFF )                // dialog has a menu, numeric label
        {
            fread( &j, sizeof(j), 1, in);
            fprintf( out, "%u", j );
        }
        else { go_back(1); putASCIIZ(); } // string labeled menu
        ofprintf("\n");
    }

    if ((c=fgetc(in)) != 0) {
    ofprintf("class "); go_back(1); putASCIIZ(); }

    fprintf( out, " STYLE 0x%08lXL\n", style );

    ofprintf( "CAPTION " ); putASCIIZ(); ofprintf( "\n" ); // caption
    if ( style & 0x0040L )
    {
            fread( &j, sizeof(j), 1, in);
            fprintf( out, "FONT %u, ", j );
            putASCIIZ(); ofprintf( "\n" ); // font name
    }
    ofprintf( "\n\tBegin\n" );
    while (count-- > 0)
    {
    fread( &(i[0]), sizeof(i), 1, in);    // rectangle
    fread( &j, sizeof(j), 1, in);         // itemID
    fread( &style, sizeof(style), 1, in); // style
	    c = fgetc(in);
            if(c < 0x80 || c > 0x85)   /* non standard class, Andreas Gruen*/
            {
            name[0]=0;
            if ( c )
            {
                len=0;
                go_back(1);
                while (( len<60 ) && (( name[len] = fgetc(in)) != 0)) len++;
                name[len] = 0;

            }
            }
            else strcpy( name, class[c & 0x7] );
	    ofprintf( "\tControl "); putASCIIZ(); fgetc(in);
	    fprintf( out, ",\n\t%u,\t\x22%s\x22,\t0x%08lXL, %u, %u, %u, %u\n",
	    j, name, style, i[0],i[1],i[2],i[3] );

    }
    ofprintf( "\tEnd\n\n" );
    iseek(curpos);
}

void pResFlag( int i )
{
        if ( i & 0x0010 != 0 ) ofprintf("MOVEABLE");
        else                   ofprintf("FIXED");
        if ( i & 0x0020 != 0 ) ofprintf(", PURE");
        if ( i & 0x1000 != 0 ) ofprintf(", DISCARDABLE");
        if ( i & 0x0040 != 0 ) ofprintf(", PRELOAD");
        else                   ofprintf(", LOADONCALL");
        ofprintf("\n");
}


void pResource(void)
{
    int RScount, count, rType;
    long boff;

    fprintf( out,"[Resource table]\n\toffset\t\t%d.\n", newH.RStableOff );
    getAt( newExeOffset+(ulong)newH.RStableOff, 2, &RScount);

    // смещения измеpены в 1^RScount байт
    fread( &res, sizeof( res ), 1, in); // read resource header

    while ( res.resType != 0 ) // 0 if last resource
    {
    rType= res.resType & 0x7FFF;
    ofprintf("\n\tClass:\t");
    if ((res.resType & 0x8000) != 0) // номеp < 0 это индекс в таблице имен
    fprintf( out,"%d.\t%s\n", rType, resNAME[rType-1] );
    // иначе это стpока в стиле Паскаль
    else putPascalStr(res.resType);

    count = res.resCount;
    // для всех pесуpсов этого типа
    ofprintf("\tOffset\tLength\tFLAGS\n");
    while (count-- > 0)
    {
    fread( &resD, sizeof( resD ), 1, in);
    boff = ((ulong) resD.resOffset) << ((long)RScount);
    fprintf( out,"\t%lX\t%d.\t%Xh\t",
    boff, resD.resLen, resD.resFLAG);
    pResFlag(resD.resFLAG);
    ofprintf("\tres.name\t");
    if (rType == 1) putCUR( boff );
    if (rType == 2) putBITMAP( boff );
    if (rType == 3) putICON( boff );

    // if below than 0 it's name index, else PASCAL-style string
    if ((resD.resName & 0x8000) != 0) fprintf( out,"%d.\n", (resD.resName & 0x7FFF));
    else putPascalStr(res.resType);

    if (rType == 4) putMENU( boff );
    if (rType == 5) putDLG( boff );

    if (rType == 6) {           // stringtable
        int block;
        unsigned char c;
        long curpos = ftell(in);
        fseek( in, boff, 0);
	ofprintf("\tBegin\n");
        for ( block=0; block<16; block++ )
        {
	    if ((c=fgetc(in)) != 0) {               // Pascal-style strlen
                fprintf( out, "\t%5u, \x22", block+
                ((resD.resName & 0x7FFF)-1)*16 );
                while (c-- > 0) fputc( fgetc(in), out);
                ofprintf("\x22\n");
            }
        }
	ofprintf("\tEnd\n");
        iseek( curpos );
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
    iseek( where );
    lo:
    fread( &i, sizeof(i), 1, in);
    if (i==0) return;
    ofprintf("\t");
    fileCopy( in, out, (ulong)i );
    fread( &ref, sizeof(ref), 1, in);
    fprintf( out, "\t%4d.\n", ref);
    goto lo;
}

long len;

void ChkName(char *a)
{
   if (( strstr(strupr(a),".EXE") == NULL ) &&
       ( strstr(strupr(a),".DLL") == NULL ) &&
       ( strstr(strupr(a),".DRV") == NULL ))
   {
      fprintf(stderr, "Input file extension is not .exe nor .dll nor .drv\n"); exit(1);
   }

   if ((in = fopen(a, "rb"))  == NULL)
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
fprintf( out,"\tFile load checksum\t\t%Xh\n\tOverlay #\t\t\t%Xh\n",
             o.chkSum, o.ovlNumber );
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
    iseekNE( (ulong)newH.MODrefOff );
    while (c-->0) {
    fread( &o, sizeof( o ), 1, in);
    ofprintf("\t");
    {
    char i,k=0;
    long curpos_;
    curpos_ = ftell(in);
    getAt( (ulong) newExeOffset + newH.IMPnamesTableOff + o, sizeof(i), &i);
    k = (char) fread( mName[m], 1, i, in);
    fwrite( mName[m], 1, i, out);
    mName[m][k] = 0;
    if ( m < 15 ) m++;
    iseek( curpos_ );
    }
    ofprintf("\n");
    }
    if ( INtable != NULL )
    {   iseekNE( (ulong) newH.IMPnamesTableOff );
        fread( INtable, newH.EToffset - newH.IMPnamesTableOff, 1, in );}
    iseek( curpos );
}

void pNRnames(void)
{
    uchar i,j;
    uint k, ref;
    ulong where= newH.NRtableOff;
    ulong old=ftell(in);
    fprintf( out,"[Resident names table]\n\toffset\t%Xh\n",
    newH.RnamesTableOff );
    pNames( newExeOffset+(ulong)newH.RnamesTableOff);

    fprintf( out,"[Non-resident names table]\n\toffset\t%lXh\tlength %Xh\n"\
	 "\tName\t\tIndex into Entry table\n",
	 newH.NRtableOff, newH.NRtableLen );
    k=0;
    iseek( where );
    lo:
    fread( &i, sizeof(i), 1, in);
    if (i==0) { iseek( old ); return;}
    ofprintf("\t");
    if (i>32)
    {
        ofprintf("(>32) "); fileCopy( in, out, (ulong)i );
        fread( &ref, sizeof(ref), 1, in); goto pri;
    };

    j = (char) fread( nrName+k*33, 1, i, in);
    fwrite( nrName+k*33, 1, i, out);
    nrName[j+k*33] = 0;

    fread( &ref, sizeof(ref), 1, in);
    if ((ref!=0)&&(k!=0)) entry[ref-1].name=k;
    pri:
    fprintf( out, "\t% 4d.\n", ref);
    if (k<MaxNRnames-2) k++; else
    {
       fprintf( out,"\t...skipped because more than %u names\n",
       MaxNRnames );
       iseek( old ); return;
    };
    goto lo;
}

void PrintNewHeader(void)
{
fprintf( out,
"\tLink version\t%d.%d\n", newH.linkVer, newH.linkRev );
fprintf( out,
"\tLength of ET\t%d.\n\tImage chkSum\t%lXh\n",
newH.ETlen, newH.IchkSum );
fprintf( out,"[Module flag word]\n\t%Xh\n", newH.MFW );
if ((newH.MFW & 0x8000) != 0) // библиотека
{ fprintf( out,"\tLibrary module\n");
  if ((newH.MFW & 0x0001) != 0) fprintf( out,"\tSINGLEDATA\n");
  else fprintf( out,"\tNOAUTODATA\n");
}
else
{ ofprintf("\tProgram module\n");
  if ((newH.MFW & 0x0002) != 0)
  ofprintf("\tMULTIPLEDATA\n");
}
  if ((newH.MFW & 0x4000) != 0) // нет ноpмального стека
  fprintf( out,"\tValid stack is not maintained\n");

  if ((newH.MFW & 0x0004) != 0) ofprintf("\tRuns in real mode\n");
  if ((newH.MFW & 0x0008) != 0) ofprintf("\tRuns in protected mode\n");

fprintf( out,"\t # of autoDATA seg's %d.\n", newH.autoDATAsegNum );
fprintf( out,"\tInit size of local heap/stack, + to autoDATA %d. / %d.\n",
        newH.isLocHEAP, newH.isStack );

fprintf( out,"Win program entry  %04X:%04X\nInit stack pointer %04X:%04X\n",
              newH.winCS, newH.winIP, newH.winSS, newH.winSP );
fprintf( out,"\t # of entries in segment table     %d.\n", newH.SEGtableEnt );

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

	char far *pname;
	char far *pnam;
        int pnameLen, s, tiH, tiL;


	int eseg = peek( _psp, 0x002C ); pname = MK_FP( eseg, 0 );

	tiL = peek( 0, 0x046C );
	tiH = peek( 0, 0x046E );

	scan:
	while (*pname++ != 0) ;
	if (*pname != 0) goto scan;

	pname += 3;
	sprintf( pathName, "%s", pname );
	pnam = pname = pathName;

	pnameLen = strlen( pname );
	pnam += pnameLen;

	while (( pname != pnam ) && ( *pnam != 0x5C )) pnam-- ;
	pnam++; *pnam = 0;

    if (argc < 2) { printf(
"\nDeWin: dump for MS Windows executable files\n\
    v1.05  (c) 1995 Milukow A.V. АО \'Царицыно\'\n\
    usage: DeWin [-options] Infile.exe [Outfile]\n\n\
	options: -d disable .asm code creating\n\
		 -b extract bitmaps, icons, cursor\n\
		 -c don`t delete .seg file(s) contain CODE segment\n\
		 -m don`t put menu & dialog source into [Outfile]\n\
		 -r don`t process relocations table(s), debug purpose\n\n\
    Example: DeWin -bd calendar.exe calendar.def\n\
	     Creates an header-info file calendar.def\n\
	     and extract all DIB images from .exe\n\
    \n"); return 1;
    }

    s = 0;
    options = 0;
    if ( argv[1][0] == 0x2D ) // -x means option 'x'
    {
        s = 1;
	if ( strchr( argv[1], 'd')) options |=  1; // -d disable code dizasm
	if ( strchr( argv[1], 'b')) options |=  2; // -b extract bitmaps
	if ( strchr( argv[1], 'c')) options |=  4; // -c don't delete code seg
	if ( strchr( argv[1], 'm')) options |= 16; // -m don't put menu
	if ( strchr( argv[1], 'r')) options |=  8; // -r don't relocations
    }

   if (( nrName = calloc( MaxNRnames, 33)) == NULL)
   {
      printf( "calloc() for Names Table failure\n");
      exit(1);
   };

   if   ((out = fopen(argv[2+s], "wt")) == NULL)    out = stdout;

    ChkName(argv[1+s]);

    len = flen( in );

   fread( &o, sizeof(o), 1, in);    // считать заголовок

   if ((o.sign[0] != 'M') || (o.sign[1] != 'Z'))
        { ofprintf("Not found 'MZ'\n");
        fclose(in); fclose(out);
	exit(1); }

   PrintOldHeader();

   getAt( (ulong) 0x3c , sizeof( newExeOffset ), &newExeOffset );

   if ( newExeOffset != 0L )
   {
   fprintf( out, "[NewExe header]\n\tfound at:\t%08lXh\n", newExeOffset );
   getAt( newExeOffset , sizeof( newH ), &newH );

   sprintf( pnam, "%s", "krnl386.ex" );
   explain[0] = mount( explain[0] );
   sprintf( pnam, "%s", "gdi.ex" );
   explain[1] = mount( explain[1] );
   sprintf( pnam, "%s", "user.ex" );
   explain[2] = mount( explain[2] );
   sprintf( pnam, "%s", "keyboard.ex" );
   explain[3] = mount( explain[3] );
   sprintf( pnam, "%s", "commdlg.ex" );
   explain[4] = mount( explain[4] );

   if (( tree = malloc( 2050*4 )) == NULL) { printf("Tree not malloc()ed\n");
                                                exit(1); }

   Lshift = 1<<newH.AlignSC;
   PrintNewHeader();
   free(tree);
   free( explain[0] );
   free( explain[1] );
   free( explain[2] );
   };

   fclose(in); fclose(out);
   free( nrName );
        asm mov ax,[tiL]
        asm mov dx,[tiH]
        asm push ax dx
        tiL = peek( 0, 0x046C );
        tiH = peek( 0, 0x046E );
        asm pop dx ax
        asm sub [tiL],ax
        asm sbb [tiH],dx

        len = (ulong)tiL+((ulong)tiH << 16L);
	newExeOffset = len/1092;
	s = (len-newExeOffset*1092L)/18;
	printf("Elapsed time %d:%02d\n", (int)newExeOffset, s );

   return 0;
}
