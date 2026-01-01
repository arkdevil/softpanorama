/*
**	I N T E L L I G E N T   D I S A S S E M B L E R
**
** Edit history:
**	16/02/90 OM 1.2	Fixed word offset problem, segment problem in same
**			Prepared for posting to comp.binaries.ibm.pc
**	late  87 OM 1.1	Slight fixes for public release
**	late  86 OM 1.0	Initial release for own use
*/

char progname[]="id";
char program[]=	"Intelligent Disassembler V1.2";
char copyright[]=
	"(c) 1986,87,88,89,90 by Otto J. Makela, Jyvaskyla, Finland\n"
	"This program is distributed under the GNU General Public License\n"
	"terms.  See the file COPYING for details\n\n"
	"Call JyBox +358 41 211 562, V.22bis/V.22/V.21 24h/day\n\n";

#include	<stdio.h>

	/* Some compiler-independent types */
#define	BYTE	unsigned char
#define	WORD	unsigned int
#define	SBYTE	signed char
#define	SWORD	signed int

#define	ISPRINT(c)	((c)>=' ' && (c)<='~' && (c)!='\'')
#define	MIN(a,b)	((a)<(b)?(a):(b))

	/* 8086 instruction groups (and statuses) as returned by disasm() */
#define	ERROR		0
#define	DATABYTE	1
#define	IMPLIED		2
#define	ACCIMMED	3
#define	MEMREGIMMED	4
#define	MEMREGMEMREG	5
#define	RELJUMP16	6
#define	STRING		7
#define	MEMREG		8
#define	REG16		9
#define	INOUT		10
#define	INTERRUPT	11
#define	ESCAPE		12
#define	RETURN		13
#define	RELJUMP8	14
#define	CONDRELJUMP8	15
#define	PREFIX		16
#define	REGIMMED	17
#define	SEGMEMREG	18
#define	ACCMEM		19
#define	SEGREG		20
#define	REGADR		21
#define	SHIFT		22
#define	ACCREG		23
#define	SEGPREFIX	24
#define	IMPLIEDUM	25
#define	CALLREL16	26
#define	MEM32		27
#define	REGMEM32	28
#define	CALLABS32	29
#define	JUMPABS32	30

SBYTE	adc[]="ADC",add[]="ADD",and[]="AND",call[]="CALL",cmp[]="CMP",
	dec[]="DEC",inc[]="INC",jmp[]="JMP",mov[]="MOV",or[]="OR",
	pop[]="POP",push[]="PUSH",sbb[]="SBB",sub[]="SUB",test[]="TEST",
	xchg[]="XCHG",xor[]="XOR";

struct	{
	WORD	c,cm,rm;
	SBYTE	*mn;
	BYTE	gr;
} *cc,cmd[] = {
	0x0037,0x00FF,0x0000,"AAA",IMPLIED,
	0x0AD5,0xFFFF,0x0000,"AAD",IMPLIED,
	0x0AD4,0xFFFF,0x0000,"AAM",IMPLIED,
	0x003F,0x00FF,0x0000,"AAS",IMPLIED,

	0x0014,0x00FE,0x0000,adc,ACCIMMED,
	0x1080,0x38FC,0x0000,adc,MEMREGIMMED,
	0x0010,0x00FC,0x3800,adc,MEMREGMEMREG,

	0x0004,0x00FE,0x0000,add,ACCIMMED,
	0x0080,0x38FC,0x0000,add,MEMREGIMMED,
	0x0000,0x00FC,0x3800,add,MEMREGMEMREG,

	0x0024,0x00FE,0x0000,and,ACCIMMED,
	0x2080,0x38FC,0x0000,and,MEMREGIMMED,
	0x0020,0x00FC,0x3800,and,MEMREGMEMREG,

	0x009A,0x00FF,0x0000,call,CALLABS32,
	0x00E8,0x00FF,0x0000,call,CALLREL16,
	0x18FF,0x38FF,0x0000,call,MEM32,
	0x10FF,0x38FF,0x0000,call,MEMREG,

	0x0098,0x00FF,0x0000,"CBW",IMPLIED,
	0x00F8,0x00FF,0x0000,"CLC",IMPLIED,
	0x00FC,0x00FF,0x0000,"CLD",IMPLIED,
	0x00FA,0x00FF,0x0000,"CLI",IMPLIED,
	0x00F5,0x00FF,0x0000,"CMC",IMPLIED,

	0x003C,0x00FE,0x0000,cmp,ACCIMMED,
	0x3880,0x38FC,0x0000,cmp,MEMREGIMMED,
	0x0038,0x00FC,0x3800,cmp,MEMREGMEMREG,
	0x00A6,0x00FE,0x0000,cmp,STRING,

	0x0099,0x00FF,0x0000,"CWD",IMPLIED,
	0x0027,0x00FF,0x0000,"DAA",IMPLIED,
	0x002F,0x00FF,0x0000,"DAS",IMPLIED,

	0x08FE,0x38FE,0x0000,dec,MEMREG,
	0x0048,0x00F8,0x0007,dec,REG16,

	0x30F6,0x38FE,0x0000,"DIV",MEMREG,

	0x00D8,0x00F8,0x0000,"ESC",ESCAPE,

	0x00F4,0x00FF,0x0000,"HLT",IMPLIED,

	0x38F6,0x38FE,0x0000,"IDIV",MEMREG,
	0x28F6,0x38FE,0x0000,"IMUL",MEMREG,

	0x00E4,0x00F6,0x0008,"IN",INOUT,

	0x00FE,0x38FE,0x0000,inc,MEMREG,
	0x0040,0x00F8,0x0007,inc,REG16,

	0x00CC,0x00FE,0x0000,"INT",INTERRUPT,
	0x00CE,0x00FF,0x0000,"INTO",IMPLIED,

	0x00CF,0x00FF,0x0000,"IRET",RETURN,

	0x0077,0x00FF,0x0000,"JA",CONDRELJUMP8,
	0x0073,0x00FF,0x0000,"JAE",CONDRELJUMP8,
	0x0072,0x00FF,0x0000,"JB",CONDRELJUMP8,
	0x0076,0x00FF,0x0000,"JBE",CONDRELJUMP8,
	0x00E3,0x00FF,0x0000,"JCXZ",CONDRELJUMP8,
	0x0074,0x00FF,0x0000,"JE",CONDRELJUMP8,
	0x007F,0x00FF,0x0000,"JG",CONDRELJUMP8,
	0x007D,0x00FF,0x0000,"JGE",CONDRELJUMP8,
	0x007C,0x00FF,0x0000,"JL",CONDRELJUMP8,
	0x007E,0x00FF,0x0000,"JLE",CONDRELJUMP8,

	0x00EA,0x00FF,0x0000,jmp,JUMPABS32,
	0x00EB,0x00FF,0x0000,jmp,RELJUMP8,
	0x00E9,0x00FF,0x0000,jmp,RELJUMP16,
	0x28FF,0x38FF,0x0000,jmp,MEM32,
	0x20FF,0x38FF,0x0000,jmp,MEMREG,

	0x0075,0x00FF,0x0000,"JNE",CONDRELJUMP8,
	0x0071,0x00FF,0x0000,"JNO",CONDRELJUMP8,
	0x007B,0x00FF,0x0000,"JNP",CONDRELJUMP8,
	0x0079,0x00FF,0x0000,"JNS",CONDRELJUMP8,
	0x0070,0x00FF,0x0000,"JO",CONDRELJUMP8,
	0x007A,0x00FF,0x0000,"JP",CONDRELJUMP8,
	0x0078,0x00FF,0x0000,"JS",CONDRELJUMP8,

	0x009F,0x00FF,0x0000,"LAHF",IMPLIED,

	0x00C5,0x00FF,0x3800,"LDS",REGMEM32,
	0x008D,0x00FF,0x3800,"LEA",REGADR,
	0x00C4,0x00FF,0x3800,"LES",REGMEM32,

	0x00F0,0x00FF,0x0000,"LOCK",PREFIX,

	0x00AC,0x00FE,0x0000,"LOD",STRING,

	0x00E2,0x00FF,0x0000,"LOOP",CONDRELJUMP8,
	0x00E1,0x00FF,0x0000,"LOOPZ",CONDRELJUMP8,
	0x00E0,0x00FF,0x0000,"LOOPNZ",CONDRELJUMP8,

	0x0088,0x00FC,0x3800,mov,MEMREGMEMREG,
	0x00B0,0x00F0,0x0007,mov,REGIMMED,
	0x00A0,0x00FC,0x0000,mov,ACCMEM,
	0x008C,0x20FD,0x1800,mov,SEGMEMREG,
	0x00C6,0x38FE,0x0000,mov,MEMREGIMMED,
	0x00A4,0x00FE,0x0000,mov,STRING,

	0x20F6,0x38FE,0x0000,"MUL",MEMREG,
	0x18F6,0x38FE,0x0000,"NEG",MEMREG,

	0x0090,0x00FF,0x0000,"NOP",IMPLIED,

	0x10F6,0x38FE,0x0000,"NOT",MEMREG,

	0x000C,0x00FE,0x0000,or,ACCIMMED,
	0x0880,0x38FC,0x0000,or,MEMREGIMMED,
	0x0008,0x00FC,0x3800,or,MEMREGMEMREG,

	0x00E6,0x00F6,0x0008,"OUT",INOUT,

	0x008F,0x38FF,0x0000,pop,MEMREG,
	0x0058,0x00F8,0x0007,pop,REG16,
	0x0007,0x00E7,0x0018,pop,SEGREG,
	0x009D,0x00FF,0x0000,"POPF",IMPLIED,

	0x30FF,0x38FF,0x0000,push,MEMREG,
	0x0050,0x00F8,0x0007,push,REG16,
	0x0006,0x00E7,0x0018,push,SEGREG,
	0x009C,0x00FF,0x0000,"PUSHF",IMPLIED,

	0x10D0,0x38FC,0x0000,"RCL",SHIFT,
	0x18D0,0x38FC,0x0000,"RCR",SHIFT,

	0x00F2,0x00FF,0x0000,"REPNZ",PREFIX,
	0x00F3,0x00FF,0x0000,"REPZ",PREFIX,
	
	0x00CA,0x00FE,0x0000,"RETF",RETURN,
	0x00C2,0x00FE,0x0000,"RET",RETURN,

	0x00D0,0x38FC,0x0000,"ROL",SHIFT,
	0x08D0,0x38FC,0x0000,"ROR",SHIFT,

	0x009E,0x00FF,0x0000,"SAHF",IMPLIED,

	0x38D0,0x38FC,0x0000,"SAR",SHIFT,

	0x001C,0x00FE,0x0000,sbb,ACCIMMED,
	0x1880,0x38FC,0x0000,sbb,MEMREGIMMED,
	0x0018,0x00FC,0x3800,sbb,MEMREGMEMREG,

	0x00AE,0x00FE,0x0000,"SCA",STRING,

	0x0026,0x00E7,0x0018,"",SEGPREFIX,

	0x20D0,0x38FC,0x0000,"SHL",SHIFT,
	0x28D0,0x38FC,0x0000,"SHR",SHIFT,

	0x00F9,0x00FF,0x0000,"STC",IMPLIED,
	0x00FD,0x00FF,0x0000,"STD",IMPLIED,
	0x00FB,0x00FF,0x0000,"STI",IMPLIED,

	0x00AA,0x00FE,0x0000,"STO",STRING,

	0x002C,0x00FE,0x0000,sub,ACCIMMED,
	0x2880,0x38FC,0x0000,sub,MEMREGIMMED,
	0x0028,0x00FC,0x3800,sub,MEMREGMEMREG,

	0x00A8,0x00FE,0x0000,test,ACCIMMED,
	0x00F6,0x38FE,0x0000,test,MEMREGIMMED,
	0x0084,0x00FE,0x3800,test,MEMREGMEMREG,

	0x009B,0x00FF,0x0000,"WAIT",IMPLIED,

	0x0090,0x00F8,0x0007,xchg,ACCREG,
	0x0086,0x00FE,0x3800,xchg,REGADR,

	0x00D7,0x00FF,0x0000,"XLAT",IMPLIEDUM,

	0x0034,0x00FE,0x0000,xor,ACCIMMED,
	0x3080,0x38FE,0x0000,xor,MEMREGIMMED,
	0x0030,0x00FC,0x3800,xor,MEMREGMEMREG,

	0x0000,0x0000,0x0000,"DB",DATABYTE,
	0,0,0,NULL,0 };

	/* Character constants */
#define	BYTEONE	(BYTE *)"1"
#define	BYTHREE	(BYTE *)"3"

	/* 8086 registers, and some #define's for them */
SBYTE *regset[2][8] = {	"AL","CL","DL","BL","AH","CH","DH","BH",
			"AX","CX","DX","BX","SP","BP","SI","DI" };
#define	ACC	(BYTE *)regset[word][0]
#define	AX	(BYTE *)regset[1][0]
#define	DX	(BYTE *)regset[1][2]
#define	CL	(BYTE *)regset[0][1]
SBYTE *segreg[4] = {	"ES","CS","SS","DS" };

	/* Addressing modes, BYTE/WORD PTR overrides */
SBYTE *adrmod[8] = {	"[BX+SI]","[BX+DI]","[BP+SI]","[BP+DI]",
			"[SI]","[DI]","[BP]","[BX]" };
SBYTE *bytwrd[3] = {	"BYTE","WORD","DWORD" };

	/* Command output formats */
SBYTE *oper[] = { "\t%s", "\t%s\t%s", "\t%s\t%s,%s" };
#define	NULOP	oper[0]
#define	ONEOP	oper[1]
#define	TWOOP	oper[2]

	/* Some functions */
BYTE *index(),*getmod(),*fmtcon(),*fmtadr(),disasm();

	/* Scratch area, code and reference tables (each 64kbits of length) */
#define	B64k	(64/8*1024)
	BYTE scratch[80],code[B64k],refd[B64k];
	/* General bit handling macros */
#define	SETBIT(a,b)	(a[b>>3] |= (1<<(b&7)))
#define	TSTBIT(a,b)	(a[b>>3] & (1<<(b&7)))
	/*
	** "Is code" means we try to dissassemble it.  "Is referenced"
	** means we need a label on the line and we guess at data offsets.
	*/
#define	SETCODE(i)	SETBIT(code,i)
#define	SETREFD(i)	SETBIT(refd,i)
#define	ISCODE(i)	TSTBIT(code,i)
#define	ISREFD(i)	TSTBIT(refd,i)

	/* Standard start offset for .COM-files */
#define	ADJUST	0x100
WORD adjust=ADJUST;
	/* Device driver flag */
WORD devdriver=0;


main(argc,argv)
int argc;
BYTE *argv[];	{
	register BYTE c;
	register WORD i;
	BYTE quote,filename[80];
#define	MAXENTRY	100
#define	MAXEXIT		40
	WORD j,baseadr,address,data;
	WORD entrypts[MAXENTRY],exitpts[MAXEXIT],entrys=0,exits=0;
	union	{
		WORD x;
		BYTE h[2];
	} regtrace[8];
	WORD regdefd=0;
#define	REGISTER	(word? regtrace[i].x: regtrace[i>>2].h[i&1])
#define	SETDEFINED	regdefd|=(word? 3<<(2*reg): 1<<(2*reg+4) )
	FILE *f,*g;

	*argv=(BYTE *)progname;
	fprintf(stderr,"%s - %s, compiled "__DATE__"\n%s",*argv,
		program,copyright);
	if(argc<2)	{
		fprintf(stderr,"usage: %s prog[.com] [@cmdfile] [=adjust] "
			"[[+]entry]] [-exit] [:addr] [~]...\n",*argv);
		exit(0);
	}

	strcpy(filename,argv[1]);
	if(!index(filename,'.'))
		strcat(filename,".com");
	if(!(f=fopen((char *)filename,"r")))	{
		fprintf(stderr,"%s: file \"%s\" not found\n",*argv,filename);
		exit(1);
	}

	for(i=0; i<B64k; i++) code[i]=refd[i]=0;

	g=NULL;
	do	{
		for(i=2; i<argc; i++)	{
			if(!index("0123456789ABCDEFabcdef",c=*argv[i]))
				argv[i]++;
			else
				c='+';
			if(c!='@' && c!='~' &&
				sscanf(argv[i],"%x",&address)!=1)	{
				fprintf(stderr,"%s: illegal hexadecimal offset \"%s\" - "
					"ignored\n",*argv,argv[i]);
				continue;
			}
			switch(c)	{
			case '+':
				entrypts[entrys++]=address;
				/* Flow thru */
			case ':':
				SETREFD(address);
				break;
			case '-':
				exitpts[exits++]=address;
				break;
			case '=':
				adjust=address;
				break;
			case '@':
				if(g) fclose(g);
				if(!(g=fopen((char *)argv[i],"r")))
					fprintf(stderr,"%s: cannot open file \"%s\"\n",
						*argv,argv[i]);
				break;
			case '~':
				devdriver = !devdriver;
				break;
			default:
				fprintf(stderr,"%s: unknown option '%c' - ignored\n",*argv,c);
				break;
			}
		}
	} while(g && fgets(argv[(argc=3)-1]=scratch,sizeof(scratch),g));
	if(g) fclose(g);

		/* Device driver - ignore header for now */
	if(devdriver)	{
		adjust = 0;
		fread(scratch,sizeof(BYTE),6,f);
		fread(&j,sizeof(WORD),1,f);
		entrypts[entrys++]=j; SETREFD(j);
		fread(&j,sizeof(WORD),1,f);
		entrypts[entrys++]=j; SETREFD(j);
		SETREFD(4);
		SETREFD(6);
		SETREFD(8);
		SETREFD(0xA);
	}

	SETREFD(adjust);
	if(!entrys)
		entrypts[entrys++]=adjust;

	fprintf(stderr,  "entr");
	for(i=0; i<entrys; i++)
		fprintf(stderr," %04x",entrypts[i]);
	fprintf(stderr,"\nexit");
	for(i=0; i<exits; i++)
		fprintf(stderr," %04x",exitpts[i]);
	if(!exits)
		fprintf(stderr," none\n");
	else
		fprintf(stderr,"\n");

	fprintf(stderr,"%s: pass one\n",*argv);

nextentry:
	while(entrys)	{
		baseadr=entrypts[--entrys];
nextcomm:	if(ISCODE(baseadr)) continue;
		if((c=disasm(f,baseadr,&address,0,&data))==ERROR ||
			c==DATABYTE) continue;
		for(;address--; baseadr++)
			SETCODE(baseadr);
		switch(c)	{
		case MEMREGIMMED:
		case REGADR:
		case MEMREGMEMREG:
		case MEMREG:
		case ESCAPE:
		case SEGMEMREG:
		case ACCMEM:
		case SHIFT:
		case REGMEM32:
		case MEM32:
			if(data)
				SETREFD(data);
			break;
		case CALLREL16:
		case CONDRELJUMP8:
			if(!ISCODE(baseadr))
				entrypts[entrys++]=baseadr;
			/* Flow thru */
		case RELJUMP16:
		case RELJUMP8:
			SETREFD(data);
			baseadr=data;
			break;
		case INTERRUPT:
			if(data!=0x20 && data!=0x27) break;
		case RETURN:
			goto nextentry;
		}
		for(i=0; i<exits; i++)
			if(baseadr==exitpts[i])	{
				while(++i<exits)
					exitpts[i-1]=exitpts[i];
				exits--;
				goto nextentry;
			}
		goto nextcomm;
	}

	fprintf(stderr,  "code");
	for(i=0; i<0xFFFF; i++)
		if(ISCODE(i))	{
			fprintf(stderr," %04x-",i);
			while(i<0xFFFF && ISCODE(i)) i++;
			fprintf(stderr,"%04x",i-1);
		}
	fprintf(stderr,"\nrefs");
	for(i=0; i<0xFFFF; i++)
		if(ISREFD(i))
			fprintf(stderr," %04x",i);
	fprintf(stderr,"\n");

	fprintf(stderr,"%s: pass two\n",*argv);
	printf("\tTITLE\t%s - produced by %s\n",filename,program);
	printf("CSEG\tSEGMENT\n");
	printf("\tASSUME\tCS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG\n");
	printf("\tORG\t%s\n",fmtcon(adjust,scratch,0));
	baseadr=adjust;
skip:	if(!ISCODE(baseadr))	{
		quote=0; i=75; j=0; address=1;
		while(!ISCODE(baseadr))	{
			if(address>=j)	{
				if(fseek(f,(long)(baseadr-adjust),0) ||
					!(j=fread(scratch,sizeof(BYTE),
					sizeof(scratch),f)))	{
					if(quote)
						putchar('\'');
					putchar('\n');
					goto thend;
				}
				address=0;
			}
			if(i>=75 || ISREFD(baseadr))	{
				if(quote)
					putchar('\'');
				quote=0;
				putchar('\n');
				if(ISREFD(baseadr))
					printf("LB%04X",baseadr);
				if(ISPRINT(c=scratch[address]))	{
					printf("\tDB\t'%c",c);
					quote=1;
					i=18;
				} else	{
					printf("\tDB\t%3d",c);
					i=19;
				}
				baseadr++;
				address++;
			}
			while(address<j && i<75 && !ISCODE(baseadr) &&
				!ISREFD(baseadr))	{
				if(ISPRINT(c=scratch[address]))
					if(quote)	{
						putchar(c);
						i++;
					} else	{
						printf(",'%c",c);
						quote=1;
						i+=3;
					}
				else	{
					if(quote)	{
						putchar('\'');
						quote=0;
						i++;
					}
					printf(",%3d",c);
					i+=4;
				}
				address++;
				baseadr++;
			}
		}
		if(quote)
			putchar('\'');
		putchar('\n');
	}
	if(ISREFD(baseadr))
		printf("LB%04X:",baseadr);
	if(disasm(f,baseadr,&address,1,&data)<=DATABYTE)
		goto thend;
	baseadr+=address;
	goto skip;
thend:	printf("CSEG\tENDS\n");
	printf("\tEND\tLB%04X\n",adjust);
	fclose(f);
}


/*
**	Disassemble bytes from file f at address, based at baseadr
**	If display is true, print the instructions
*/

#define	Dprintf	if(display) printf

BYTE disasm(f,baseadr,address,display,data)
FILE *f;
WORD baseadr,*address;
register WORD *data;
BYTE display;	{
	BYTE word,dir,pass;
	BYTE *p,mem[10];
	/* MEM is a WORD, Smem a SBYTE, and SMEM a SWORD - all in mem[] */
#define	MEM(i)	(*((WORD  *)(mem+i)))
#define	Smem(i)	(*((SBYTE *)(mem+i)))
#define	SMEM(i)	(*((SWORD *)(mem+i)))
	static BYTE *seg=NULL;
	WORD reg,loop;
	register WORD i;
	SWORD s;

	if(fseek(f,(long)(baseadr-adjust),0)) return ERROR;
	if(!fread(mem,sizeof(BYTE),sizeof(mem),f)) return ERROR;

	*address=0;
again:	for(loop=0; (cc=cmd+loop)->mn; loop++)
		if((MEM(*address) & cc->cm)==cc->c)	{
			word=mem[*address]&1;
			if(cc->cm & 2)
				dir=0;
			else
				dir=(mem[*address]&2)>>1;
			if(i=cc->rm)
				for(reg=MEM(*address) & i; !(i&1); i>>=1)
					reg>>=1;
			(*address)++;
			switch(cc->gr)	{
			case IMPLIED:
				Dprintf(NULOP,cc->mn);
				if(cc->cm&0xFF00) (*address)++;
				break;
			case ACCIMMED:
				if(word)
					i=MEM(1);
				else
					i=mem[1];
				Dprintf(TWOOP,cc->mn,ACC,
					fmtcon(i,scratch,6+word));
				*address+=1+word;
				break;
			case MEMREGIMMED:
				p=getmod(mem,address,word,&seg,data);
				if(dir)
					s=Smem(*address);
				else if(word)
					s=MEM(*address);
				else
					s=mem[*address];
				Dprintf(TWOOP,cc->mn,p,
					fmtcon(s,scratch,6+word));
				(*address)++;
				if(!dir && word) (*address)++;
				break;
			case REGMEM32:
				word=2;
				/* Flow thru ! */
			case REGADR:
				dir=1;
				/* Flow thru ! */
			case MEMREGMEMREG:
				p=getmod(mem,address,word,&seg,data);
				if(display) if(dir)
					printf(TWOOP,cc->mn,regset[MIN(1,word)][reg],p);
				else
					printf(TWOOP,cc->mn,p,regset[MIN(1,word)][reg]);
				break;
			case CALLREL16:
			case RELJUMP16:
				i=SMEM(*address);
				*address+=2;
				*data=*address+i+baseadr;
				Dprintf("\t%s\tLB%04X",cc->mn,*data);
				break;
			case STRING:
				if(display) if(seg)	{
					printf("%sS\t%s",cc->mn,fmtadr(adjust,
						word,scratch,&seg));
					seg=NULL;
				} else
					printf("\t%sS%c",cc->mn,word?'W':'B');
				break;
			case MEM32:
				word=2;
				/* Flow thru ! */
			case MEMREG:
				p=getmod(mem,address,word,&seg,data);
				Dprintf(ONEOP,cc->mn,p);
				break;
			case ESCAPE:
				i=((0x07&mem[0])<<3)|((0x38&mem[1])>>3);
				p=getmod(mem,address,word,&seg,data);
				Dprintf(TWOOP,cc->mn,fmtcon(i,scratch,0),p);
				break;
			case REG16:
				Dprintf(ONEOP,cc->mn,regset[1][reg]);
				break;
			case INOUT:
				if(reg)
					p=DX;
				else
					p=fmtcon((WORD)mem[(*address)++],
						scratch,0);
				if(display) if(dir)
					printf(TWOOP,cc->mn,p,ACC);
				else
					printf(TWOOP,cc->mn,ACC,p);
				break;
			case INTERRUPT:
				if(word)
					p=fmtcon(*data=mem[(*address)++],
						scratch,0);
				else	{
					p=BYTHREE;
					*data=3;
				}
				Dprintf(ONEOP,cc->mn,p);
				break;
			case RETURN:
				if(word)	{
					Dprintf(NULOP,cc->mn);
				} else	{
					Dprintf(ONEOP,cc->mn,fmtcon
						(MEM(*address),scratch,0));
					*address+=2;
				}
				break;
			case CONDRELJUMP8:
			case RELJUMP8:
				*data=baseadr+2+Smem((*address)++);
				Dprintf("\t%s\tSHORT LB%04X",cc->mn,*data);
				break;
			case PREFIX:
				Dprintf(NULOP,cc->mn);
				goto again;
			case SEGPREFIX:
				seg=(BYTE *)segreg[reg];
				goto again;
			case REGIMMED:
				word=(mem[0]&8)>>3;
				if(word)
					i=MEM(1);
				else
					i=mem[1];
				Dprintf(TWOOP,cc->mn,regset[word][reg],
					fmtcon(i,scratch,7));
				*address+=1+word;
				break;
			case SEGMEMREG:
				p=getmod(mem,address,word=1,&seg,data);
				if(display) if(dir)
					printf(TWOOP,cc->mn,segreg[reg],p);
				else
					printf(TWOOP,cc->mn,p,segreg[reg]);
				break;
			case ACCMEM:
				*data=MEM(*address);
				if(display) if(dir)
					printf(TWOOP,cc->mn,fmtadr(*data,word,
						scratch,&seg),ACC);
				else
					printf(TWOOP,cc->mn,ACC,fmtadr(*data,
						word,scratch,&seg));
				*address+=2;
				break;
			case SEGREG:
				Dprintf(ONEOP,cc->mn,segreg[reg]);
				break;
			case SHIFT:
				p=getmod(mem,address,word,&seg,data);
				Dprintf(TWOOP,cc->mn,p,dir?CL:BYTEONE);
				break;
			case ACCREG:
				Dprintf(TWOOP,cc->mn,AX,regset[1][reg]);
				break;
			case IMPLIEDUM:
				Dprintf(ONEOP,cc->mn,
					fmtadr(adjust,word=0,scratch,&seg));
				break;
			case CALLABS32:
			case JUMPABS32:
				Dprintf("\t%s\t%04X:%04X",cc->mn,
					MEM(*address+2),MEM(*address));
				*address+=4;
				break;
			case DATABYTE:
				Dprintf(ONEOP,cc->mn,fmtcon
					((WORD)mem[*address],scratch,2));
				break;
			}
			break;
		}
	Dprintf("\n");
	return cc->gr;
}


/*
**	Handle a mod/rm field
*/

BYTE *getmod(mem,addrp,word,seg,data)
WORD *addrp,*data;
BYTE mem[],word,**seg;	{
	static BYTE result[30];
	register BYTE mod,rm;
	SBYTE disp;
	BYTE *p=result;

	*data=0;
	mod=(mem[*addrp]>>6)&3;
	rm=mem[(*addrp)++]&7;
	switch(mod)	{
	case 3:
		return (BYTE *) regset[word][rm];
	case 2:
		if((*data=MEM(*addrp))>adjust && adjust)
			fmtadr(*data,word,result,seg);
		else	{
			if(*seg)	{
				while(**seg) *p++=*(*seg)++;
				*p++=':';
				*p++=' ';
				*seg=NULL;
			}
			fmtcon(*data,p,0);
			*data=0;
			strcat(p,adrmod[rm]);
		}
		*addrp+=2;
		return result;
	case 1:
		disp=Smem((*addrp)++);
		if(*seg)	{
			sprintf(result,"%s PTR %s:%d%s",bytwrd[word],*seg,
				disp,adrmod[rm]);
			*seg=NULL;
		} else
			sprintf(result,"%s PTR %d%s",bytwrd[word],disp,
				adrmod[rm]);
		return result;
	case 0:
		if(rm!=6)	{
			if(*seg)	{
				sprintf(result,"%s PTR %s:%s",bytwrd[word],
					*seg,adrmod[rm]);
				*seg=NULL;
			} else
				sprintf(result,"%s PTR %s",bytwrd[word],
					adrmod[rm]);
			return result;
		}
		fmtadr(*data=MEM(*addrp),word,result,seg);
		*addrp+=2;
		return result;
	}
}


/*
**	Format constant value to string where:
**	type&1 -	value can be a label offset
**	type&2 -	value can be a character which should be followed by
**			a comment giving it's ASCII code
**	type&4 -	value could be interpreted as negative
*/

BYTE *fmtcon(value,where,type)
WORD value,type;
BYTE *where;	{
	BYTE *p=where;
	SWORD i=(SWORD)value;

	if(type&1 && value>=adjust && adjust && ISREFD(value))
		sprintf(where,"OFFSET LB%04X",value);
	else	{
		if(type&4 && i<0 && i>=-128)	{
			*p++='-';
			value=i=-i;
		}
		if(value<10)	{
			*p++=value+'0';
			*p='\0';
		} else
			sprintf(p,"0%xh",value);
		if(type&2 && ISPRINT(value))	{
			char cc[3];
			strcat(p,"\t\t; '");
			cc[0]=value; cc[1]='\''; cc[2]='\0';
			strcat(p,cc);
		}
	}
	return where;	
}


/*
**	Format an address to string
*/

BYTE *fmtadr(value,word,where,seg)
WORD value;
BYTE word,*where,**seg;	{
	BYTE *p;

	if(*seg)	{
		sprintf(where,"%s PTR %s:LB%04X",bytwrd[word],*seg,value);
		*seg=NULL;
	} else
		sprintf(where,"%s PTR LB%04X",bytwrd[word],value);
	return where;	
}
