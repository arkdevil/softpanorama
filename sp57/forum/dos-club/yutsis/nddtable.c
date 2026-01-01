
//  NDDTABLE - корректировщик NDD под нестандартные дискеты

//    (C) Михаил Юцис, февраль 1993.
//  Свободное распространение и использоание не возбраняется.
//  При изменении вы должны сохранить строку с именем автора
//      (и добавить свою информацию).
//  Компилить под MS C 6.0 (QC 2.5). 
//       (Наверное, можно и BC++, но тогда лучше заменить cputs() на puts().)
//  Для добавления новой версии NDD поменять #define NofNDDs и добавить
//      что надо в массив структур ndd[].

#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <conio.h>
#include <bios.h>
#include <stdio.h>
#define NofNDDs 3
struct {char ver[4]; long vofs;		// номер версии, смещение его в файле
	long len,tbofs,trofs,szofs;	// длина несжатого файла,
				//смещение таблицы, числа дорожек,размера
	int ntyp, tblen;	//число встроенных типов дискет, длина 1 таблицы
} ndd[NofNDDs] = {
	{"4.5",0x15462,116098,0x159c0,0x15a9a, 0L    ,7,0x1f},
	{"5.0",0x28132,187344,0x2c7c6,0x2c8a0,0x2c680,7,0x1f},
	{"6.0",0x30419,198744,0x2efc8, 0L    ,0x3002d,8,0x14}
}, *pndd;
char table[8][16] = {
	{ 0x0, 0x2, 0x1, 0x1, 0x0, 0x2, 0x40, 0x0,
	  0x40, 0x1, 0xfe, 0x1, 0x0, 0x8, 0x0, 0x1 },
	{ 0x0, 0x2, 0x1, 0x1, 0x0, 0x2, 0x40, 0x0,
	  0x68, 0x1, 0xfc, 0x2, 0x0, 0x9, 0x0, 0x1 },
	{ 0x0, 0x2, 0x2, 0x1, 0x0, 0x2, 0x70, 0x0,
	  0x80, 0x2, 0xff, 0x1, 0x0, 0x8, 0x0, 0x2 },
	{ 0x0, 0x2, 0x2, 0x1, 0x0, 0x2, 0x70, 0x0,
	  0xd0, 0x2, 0xfd, 0x2, 0x0, 0x9, 0x0, 0x2 },
	{ 0x0, 0x2, 0x2, 0x1, 0x0, 0x2, 0x70, 0x0,
	  0xa0, 0x5, 0xf9, 0x3, 0x0, 0x9, 0x0, 0x2 },
	{ 0x0, 0x2, 0x1, 0x1, 0x0, 0x2, 0xe0, 0x0,
	  0x60, 0x9, 0xf9, 0x7, 0x0, 0xf, 0x0, 0x2 },
	{ 0x0, 0x2, 0x1, 0x1, 0x0, 0x2, 0xe0, 0x0,
	  0x40, 0xb, 0xf0, 0x9, 0x0, 0x12, 0x0, 0x2 },
	{ 0x0, 0x2, 0x2, 0x1, 0x0, 0x2, 0xf0, 0x0,
	  0x80, 0x16, 0xf0, 0x9, 0x0, 0x24, 0x0, 0x2 }
};
char sizes[8][5] = {"160K","180K","320K","360K","720K","1.2M","1.4M","2.8M"};
unsigned trks[8] = {40,40,40,40,80,80,80,80};
char defaultfn[] = "NDD.EXE";
char *fn = defaultfn;
int drive, nth, uf, bf, nndd, fndd;

void eputs(char *str)
{ write(2,str,strlen(str)); }

void find_ndd(void)
{ static char ffn[256]; int f; long l; int i; char buf[3];

        _searchenv(fn,"PATH",ffn);
	if(!ffn || (f=open(ffn,O_RDONLY|O_BINARY))==-1) {
		eputs(fn); eputs(": cannot open file\r\n");
                return;
	}
	fn = ffn;
	l = filelength(f);
	for(i=0;i<NofNDDs;i++) {
		if(l < ndd[i].len) continue;
		lseek(f,ndd[i].vofs,SEEK_SET);
		read(f,buf,3);
		if(memcmp(buf,ndd[i].ver,3)) continue; // no version mark
		break;
	}
	if(i>2) { eputs(fn); eputs(": invalid NDD file\r\n"); return; }
	nndd = i; pndd = ndd+i;
	if(drive||uf) {
		close(f);
		if((f=open(fn,O_RDWR|O_BINARY))==-1) {
		eputs(fn); eputs(": cannot open file for writing\r\n");
                return;
		}
	}
	else
	    for(i=0;i<pndd->ntyp;i++) {
		lseek(f,pndd->tbofs+i*pndd->tblen,SEEK_SET);
		read(f,table[i],sizeof table[0]);
		if(pndd->szofs) {
		    lseek(f,pndd->szofs+5*i,SEEK_SET);
                    read(f,sizes[i],4);
		}
	    }
        fndd = f;
	return;
}
int writendd(char *buf, long ofs, unsigned cnt)
{  lseek(fndd, ofs, SEEK_SET);
   return write(fndd,buf,cnt)!=cnt;
}

#define I(ofs)  (*(int*)(tbl+ofs))
#define C(ofs)  (tbl[ofs])
void typetbl(char*tbl, char*szs)
{ cprintf(
  "%4d │ %3d  │  %3d   │ %3d  │ %3d  │%5d  │ %2X  │ %3d   │ %3d   │%3d  │%4s\r\n",
  I(0),   C(2),  I(3),   C(5),  I(6),  I(8), C(10), I(11),  I(13), C(15),
	pndd->szofs? szs:" -" );
}
char crn[] = "%c\r\n\n";
main(int ac, char **av)
{ int rc=0; static char sector[512]; char err=0;
  char itoabuf[10];

    cputs("\nThe NDD Diskette Table Patcher  V 1.0   by M.Yutsis, Chernovtsy, Ukraine, 1993\r\n\n");
    while(*++av)
	switch(**av) {
	    case '/': case '-':
	    	switch((*av)[1]) {
		case 'u': uf = 1; break;
		case 'b': bf = 1; break;
		default: if((*av)[1]>'0' && (*av)[1] < '9')
				nth = (*av)[1]-'0';
			else goto help;
		}
		if((*av)[2]) goto help;
		break;
	    default: if(fn!=defaultfn) goto help;
	 	if(drive ||
		    ((**av|0x20)!='a' && (**av|0x20)!='b') ||
			*(int*)(*av+1)!=':')
			fn = *av;
		else drive = (**av|0x20) -'a'+1;
	}
    if(nth==0) nth = 1;
    if(drive && uf)  goto help;

    find_ndd();

    if(!fndd) return 10;
    if(nth>pndd->ntyp) { eputs("Invalid parameter for this version of NDD!");
		return 5; 
    }
    if(drive) { _asm {
	mov     al,byte ptr drive
	dec	al
	xor	dx,dx
	mov	cx,1
	mov     bx, offset sector
	int	25h
	pop	dx
	jnc	nerr
	mov	err,al
	}
nerr:   if(err) { eputs("Diskette read error!\r\n"); return 3; }
	memcpy(&table[nth-1], sector+11, sizeof *table);
#undef I
#undef C
#define I(ofs)  (*(int*)(sector+11+ofs))
#define C(ofs)  (sector[11+ofs])
	rc = ((unsigned long)I(8) * I(0) ) >>10;  // size in K
	if(rc<1000) { itoa(rc,itoabuf,10); itoabuf[3] = 'K'; }
	else {	if(rc<1024) rc = 1024;
		if(rc > 10240) {
			*(long*)itoabuf = 0x20202020;
			eputs("Warning! Cannot patch \"disk size\" if it\'s "
				"> 10M !");
		}
                else {  itoa(rc/102,itoabuf,10);
			itoabuf[2] = itoabuf[1];
			itoabuf[1] = '.'; itoabuf[3] = 'M';
		}
	}
	memcpy(sizes[nth-1], itoabuf, 4);
	trks[nth-1] = (I(8)/I(13))>>1;
    }
    if(uf || drive) {
    if(uf) cprintf("Unpatching table entry #%d in %s...",nth,fn);
    else {
	if(!bf) {
    	cprintf("Warning! This will CHANGE the internal diskette table\r\n"
		" in your %s !  Confirm (Y/N) ? ",fn);
     aa: switch(rc=getch()) {
                case 'y': case 'Y': cprintf(crn,rc); break;
		case 'n': case 'N': cprintf(crn,rc); return 3;
		case 0: getch();
		default: goto aa;
     	}
	} //bf
    	cprintf("Changing table entry #%d from drive %c:...",nth,drive+'a'-1);
    }
    rc = 0;
    if(writendd(table[nth-1],pndd->tbofs+(nth-1)*pndd->tblen ,
    			sizeof table[0])) rc = 2;
    if(pndd->szofs)
    	if(writendd(sizes[nth-1],pndd->szofs+(nth-1)*5,4)) rc = 2;
    if(pndd->trofs)
	if(writendd((char*)(trks+nth-1),pndd->trofs+(nth-1)*2,2)) rc = 2;
    if(rc) { eputs("Write error!\r\n"); return 2; }
    cprintf(" done.\r\n");
    }
    if(uf||drive) cprintf("\r\n  New Table Entry");
    else cprintf("  Existing Table in %s",fn);
    cprintf(":\r\n\n"
"SecSz│Sec/Cl│ResrvSec│FATCnt│RootSz│TotSecs│Media│Sec/FAT│Sec/Trk│Heads│Size\r\n"
	);
    if(uf||drive) typetbl(table[nth-1],sizes[nth-1]);
    else for(rc=0;rc<pndd->ntyp;rc++) typetbl(table[rc],sizes[rc]);
return 0;

help: cprintf(
"Syntax:\r\n"
"   NDDTABLE [d:|/u] [/n] [/b] [NDD_file]\r\n"
"       d: = Patch NDD's nth table entry from diskette d:\r\n"
"       /u = Unpatch nth table entry\r\n"
"       n = 1,...,8; default = 1\r\n"
"       without d: or /u = Show existing diskette table\r\n"
"       /b = batch mode; no prompting\r\n"
"   Default NDD_file = NDD.EXE on system PATH\r\n"
"Examples: NDDTABLE ;  NDDTABLE a: ; NDDTABLE /8 /b a: ; NDDTABLE /u /1 ndd6.exe\r\n"
);
return 5;
}
