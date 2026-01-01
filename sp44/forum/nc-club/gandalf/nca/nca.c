#pragma inline

#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <sys\stat.h>

#define MK_FP( seg,ofs )( (void _seg * )( seg ) +( void near * )( ofs ))
char *getenv();
int open();
int close();
int read();
int write();

struct ffblk {
  char      ff_reserved[21];
  char      ff_attrib;
  unsigned  ff_ftime;
  unsigned  ff_fdate;
  long      ff_fsize;
  char      ff_name[13];
} FindBlock;
char copyright[128]="NCA - NC file group utility. By Gandalf Software 03-26-92 V5.0";
char Congr[]="Congratulations!\r\n";
char INFOR[]="Invalid command line format !";
char TOOLON[]="Command line too long. ",S_EMPTY[]="";
char WR[]="wt";
char Buffer[512];
char ComLine[129],Exten[5]=".";
char PathName[64]="TEMPNCA";
char FirstS[129],SecondS[129];
char Chars[]="\'})~";
char SpecChar[]=" +/,;";
char TagOps[]="SAONXU";
char *Point;

#define TSet	0
#define TAnd	1
#define TOr	2
#define TNot	3
#define TXor	4
#define TUnt	5


char bat[]="\\bnca.bat";
char nmf[]="\\ncaname.dat";
unsigned NPoint;
int NoPath=0,NewExt=0,Invert=0;
int Second,Number=0,SaveTag=0;
char Path[65]="";
extern unsigned int _psp;
extern char **environ;
char *bsearch();
char *calloc();
#define Search(What,Where,Max) bsearch((What),(Where),(Max),14,strcmp)

void SystemE(char *Str)
{
  char *s;
  _restorezero();
  asm	{
	push	ds
	mov	es,_psp
	mov	ax,es:[2Ch]
	mov	cs:EPB,ax
	lds	si,Str
	mov	di,81h
	mov	cx,128
	mov	ax,'c/'
	cld
	stosw
	mov	al,' '
	stosb
	}
  MakeS:;
  asm	{
	lodsb
	or	al,al
	je	Done
	stosb
	loop	MakeS
	}
  Done:;
  asm	{
	mov	al,0Dh
	stosb
	neg	cl
	add	cl,83h
	mov	es:[80h],cl
	pop	ds
	push	ds
	mov	ah,4Ah
	mov	bx,11h+(offset EndOf-offset Codes)/16
	int	21h
	push    _psp cs
	pop	ds es
	mov	cs:[EPB+04h],es
	mov	cs:[EPB+08h],es
	mov	cs:[EPB+0Ch],es
	mov	di,100h
	mov	si,offset Codes
	mov	cx,(offset EndOf-offset Codes)/2+1
	rep	movsw
	pop	ds
	push	es
	}
  if(s=getenv("COMSPEC"))
  {
    asm	{
	pop	es
	push	_psp
	mov	ds,s+2
	mov	dx,s
	}
  }
  else
  {
    asm	{
	pop	es
	mov	ax,es
	push	_psp
	mov	ds,ax
	mov	dx,offset Command-offset Codes+100h
	}
  }
  asm	{
	mov	bx,offset EPB-offset Codes+100h
	mov	ax,100h
	push	ax
	mov	ax,4B00h
	retf
Codes:	mov     si,cs
	mov     ss,si
	mov     sp,offset EndOf-offset Codes+100h
	int	21h
	mov	ax,cs
	mov	ds,ax
	mov	ah,4Dh
	int	21h
	mov	ah,4Ch
	int	21h
Command label	byte
	db	'c:\command.com',0
EPB	dw	0
	dw	80h,0
	dw	offset FCB1-offset Codes+100h,0
	dw	offset FCB2-offset Codes+100h,0
FCB1	db	0
	db	11 dup (' ')
	db	30 dup (0)
FCB2	db	0
	db	11 dup (' ')
	db	30 dup (0)
Stack_	dw      40 dup (0)
EndOf	label	byte
	}
}

unsigned getpoint()
{
  asm  {
	mov	ah,52h
	int	21h
	xor	ax,ax
	dec	bx
	dec	bx
	mov	bx,es:[bx]
	jmp	ELoop
  }
  BLoop:;
  asm  {
	cmp	es:[12Bh],'oS'
	jne	Check2
	cmp	es:[12Dh],'hc'
	je	Is
  }
  Check2:;
  asm  {
	cmp	es:[12Fh],'oS'
	jne	NotThat
	cmp	es:[131h],'hc'
	jne	NotThat
  }
  Is:;
  asm  	mov	ax,es
  NotThat:;
  asm  {
	add	bx,word ptr es:[3]
	inc	bx
  }
  ELoop:;
  asm  {
	mov	es,bx
	cmp	byte ptr es:[0],'M'
	je	BLoop
  }
  return;
}

void subst(char *Where,char *What,char *Save)
{
  char *s;
  strcpy(Save,Where);
  s=(char *)strrchr(Where,'\\');
  if(!s)
    s=(char *)strchr(Where,':')+1;
  if(!s)
    s=Where;
  strcpy(s,What);
}

void Shrink(char *From,int Max)
{
  char *s;
  while(Max--)
  {
    s=strchr(From,' ');
    if(s)
    {
      *s=0;
      movmem(From+14,s+1,Max*14);
      From=s+1;
    } /* if */
    else
      From+=14;
  } /* while */
}

int GetFind(char *From,char *To,int Max)
{
  int j,Count=0;
  char Arr[14];
  j=findfirst("*.*",&FindBlock,0x27);
  while(!j)
  {
    strlwr(FindBlock.ff_name);
    sprintf(Arr,"\x1%-12s",FindBlock.ff_name);
    if(!Search(Arr,From,Max))
    {
      strcpy(To,Arr);
      To+=14;
      Count++;
    }
    j=findnext(&FindBlock);
  }
  return Count;
}

void SaveTagged(char *From,char *To,char Num)
{
  int i=Num;
  char *Where=To;
  while(i--)
  {
    sprintf(To,"%-13s",From);
    strlwr(To);
    From+=strlen(From)+1;
    To+=14;
  }
  qsort(Where,Num,14,strcmp);
}

int GetFile(FILE *File,char *To)
{
  int i,Count=0;
  char *p;
  while(!feof(File))
  {
    fgets(Buffer,64,File);
    for(i=0;Buffer[i]&&Buffer[i]!='\n';i++);
    Buffer[i]=0;
    if(p=strchr(Buffer,':'))
    {
      if(toupper(*(p-1))!=*(char far *)MK_FP(NPoint,Second?0xE38:0xD80)+'A')
	continue;
      strcpy(Buffer,p+1);
    }
    p=strrchr(Buffer,'\\');
    if(p)
    {
      *p=0;
      if(strcmp(Buffer,(char far *)MK_FP(NPoint,Second?0xE3A:0xD82)))
	continue;
      strcpy(Buffer,p+1);
    }
    if(!(*Buffer))
      continue;
    sprintf(To,"\x1%-12s",Buffer);
    strlwr(To);
    To+=14;
    Count++;
  }
  return Count;
}


void TagIt(char *Name,int Oper)
{
  unsigned i,Count,Tagged;
  FILE *File;
  char *Save_Tag,*PutTag,*p;
  if(Oper!=TNot)
    if((File=fopen(Name,"rt"))==(FILE *)NULL)
      exit(printf("Unable to open file %s",Name));
  Point=(char far *)MK_FP(NPoint,0xFD6);
  Tagged=*(unsigned*)MK_FP(NPoint,Second?0xE92:0xDDA);
  Save_Tag=calloc(256,14);
  PutTag=calloc(256,14);
  SaveTagged(Point,Save_Tag,Tagged);
  switch(Oper)
  {
    case TSet: Count=GetFile(File,Point);break;
    case TNot: Count=GetFind(Save_Tag,PutTag,Tagged);
	      memcpy(Point,PutTag,Count*14);
	      break;
    case TAnd: Count=GetFile(File,PutTag);
	      for(i=0;i<Count;i++)
	      {
		if(!Search(PutTag+i*14,Save_Tag,Tagged))
		{
		  movmem(PutTag+(i+1)*14,PutTag+i*14,(Count-i-1)*14);
		  Count--;i--;
		} /* if */
	      } /* for */
	      memcpy(Point,PutTag,Count*14);
	      break;
    case TUnt: Count=GetFile(File,PutTag);
	      for(i=0;i<Count;i++)
	      {
		if(p=Search(PutTag+i*14,Save_Tag,Tagged))
		{
		  movmem(p+14,p,Save_Tag+Tagged*14-p);
		  Tagged--;
		}
	      }
	      Count=Tagged;
	      memcpy(Point,Save_Tag,Count*14);
	      break;
    case TXor: Count=GetFile(File,PutTag);
	      for(i=0;i<Count;i++)
	      {
		if(p=Search(PutTag+i*14,Save_Tag,Tagged))
		{
		  movmem(p+14,p,Save_Tag+Tagged*14-p);
		  movmem(PutTag+(i+1)*14,PutTag+i*14,(Count-i)*14);
		  Tagged--;i--;Count--;
		}
	      }
	      memcpy(PutTag+Count*14,Save_Tag,Tagged*14);
	      Count+=Tagged;
	      memcpy(Point,PutTag,Count*14);
	      break;
    case TOr: Count=GetFile(File,PutTag);
	      for(i=0;i<Count;i++)
	      {
		if(Search(PutTag+i*14,Save_Tag,Tagged))
		{
		  movmem(PutTag+(i+1)*14,PutTag+i*14,(Count-i-1)*14);
		  Count--;i--;
		} /* if */
	      } /* for */
	      memcpy(PutTag+Count*14,Save_Tag,Tagged*14);
	      Count+=Tagged;
	      memcpy(Point,PutTag,Count*14);
	      break;
  } /* switch */
  Shrink(Point,Count);
  *(unsigned*)MK_FP(NPoint,Second?0xE92:0xDDA)=Count;
  *(unsigned*)MK_FP(NPoint,Second?0xDDA:0xE92)=0;
}

int makeatm(char *Name,int Inv)
{
  char far *Names,*s;
  int i;
  FILE *AtmFile=fopen(Name,WR);
  if(AtmFile==(FILE *)NULL)
    exit(printf("%sList file creation failure!",Congr));
  Second^=Inv;
  Path[0]=*(char far *)MK_FP(NPoint,Second?0xE38:0xD80)+'A';
  *(unsigned *)(Path+1)=':';
  strcat((char far *)Path,(char far *)MK_FP(NPoint,Second?0xE3A:0xD82));
  if(!Path[3])
    Path[2]=0;
  Names=(char far *)MK_FP(NPoint,0xFD6)+1;
  if(Inv)
  {
    i=*(char far *)MK_FP(NPoint,Second?0xDDA:0xE92);
    if(i)
    {
      for(;i;i--)
        Names+=strlen(Names)+2;
    }
    i=*(char far *)MK_FP(NPoint,Second?0xE92:0xDDA);
    if(!i)
    {
      i=1;
      Names=(char far *)MK_FP(NPoint,Second?0xE84:0xDCC);
    }
  }
  else
  {
    i=*(char far *)MK_FP(NPoint,Second?0xE92:0xDDA);
    if(!i)
    {
      i=1;
      Names=(char far *)MK_FP(NPoint,Second?0xE84:0xDCC);
    }
  }
  Number=i;
  for(;i;i--)
  {
    strcpy(Buffer,Names);
    if(NewExt)
    {
      s=strrchr(Buffer,'.');
      if(!s)
	s=Buffer+strlen(Buffer);
      strcpy(s,Exten);
    }
    fprintf(AtmFile,NoPath?"%s\n":"%s\\%s\n",NoPath?Buffer:Path,Buffer);
    if(!SaveTag)
      *(Names-1)=0;
    Names+=strlen(Names)+2;
  }
  putc('\n',AtmFile);
  fclose(AtmFile);
  Second^=Inv;
  return 1;
} /* makeatm */

void main(int argc,char *argv[])
{
 char FileI[65],FileII[65],FileS[65],FileIni[65],name[65],*Pointer,*Pnt1,*e,*s;
 int HandleI,i,NeedAtm,NeedAtmI,NeedIni,SaveIni,Exec,CopyRight,Norton=0;
 int ManyTimes,Join,WasJoin,WasOpen,Len,LenS,BSlash;
 char *OutPointer,JoinC[2]=" ";
 FILE *File1,*File;
 int NotCLine=(argc>2)&&(argv[2][0]=='');
 #pragma warn -pia
 if(NPoint=getpoint())
 {
   Norton=1;
   Second=!(int)*(char far *)MK_FP(NPoint,0xD7E);
   if(argc>2 && argv[argc-1][0]=='')
     Exec=0;
   else
     Exec=1;
 }
 else
   Exec=1;
 for(e=*environ;*e;e++)
   for(;*e;e++);
 e+=3;
 strcpy(FileIni,e);
 *(char *)strrchr(FileIni,'.')=0;
 if(!(Pointer=getenv(PathName)))
 {
  strcpy(FileI,e);
 }
 else
 {
   strcpy(FileI,Pointer);
   if(FileI[(i=strlen(FileI))-1]!='\\')
     if(i>2)
       *(unsigned*)(FileI+i)='\\';
   strcat(FileI,"nca.");
 }
 strcat(FileIni,".ini");
 CopyRight=1;
 if(argc==1 || NotCLine)
 {
   CopyRight=0;
   HandleI=open(FileIni,O_RDONLY|O_BINARY);
   if(HandleI!=-1)
   {
     read(HandleI,Buffer,512);
     CopyRight=!memcmp(copyright,Buffer,128);
     close(HandleI);
   }
 }

 NeedIni=(argc==1)||(Norton&&(!CopyRight || (argc>2)&&(argv[argc-1][0]<30)&&(argv[argc-1][0])&&NotCLine));
 SaveIni=!CopyRight||( Norton&&(!Exec) );

 if(NeedIni)
 {
   puts(copyright);
   puts("Control sequences are ( case must be same, see NCA.DOC for more details ):");
   puts("  ~} - tagged files list without dirs, ~) - tagged files list with dirs,");
   puts("  ~P - path from other NC panel,\r\n  ~T - path from other NC panel with \\ on end,");
   puts("  ~C - drive from current NC panel,\r\n  ~F - NC current file,");
   puts("  ~X<ext> - set extension of all tagged files to <ext>,");
   puts("  ~D - drive from other NC panel,\r\n  ~N - new workfile name,");
   puts("  ~M - workfile name, entered by last ~N,");
   puts("  ~S - don't untag files,");
   puts("  ~I - swap panels,");
   puts("  ~{<name> - repeat for every tagged file from list <name>,");
   puts("  ~{<ch><name> - join all tagged files from list <name>,");
   puts("                 <ch> must be one of:' ' or '+' or '/' or ',' or ';',");
   puts("  NOTE: in this two cases in '~}' and '~)' you may not use the '~' character,");
   puts("  \'<ch> - reserved character <ch> used as normal.");
   puts("  ~=<op><name> - tag using operation <op> and list <name>, where <op> means:");
   puts("           'S' - set, 'A' - and, 'O' - or, 'X' - xor, ,N' - not, 'U' - untag.");
   puts("Enter command:");
   if(!CopyRight)
   {
     cputs(">");
     gets(&Buffer[128]);
   }
   else
   {
     printf("1)%s\n2)%s\n3)%s\n",&Buffer[128],&Buffer[256],&Buffer[384]);
     cputs(" [enter] - 1,[2] - 2,[3] - 3 >");
     gets(ComLine);
     if(*ComLine)
     {
      if((*ComLine>='0' && *ComLine<='3')&&!*(ComLine+1))
	memcpy(ComLine,&Buffer[128*(*ComLine-'0')],128);
      memcpy(&Buffer[384],&Buffer[256],128);
      memcpy(&Buffer[256],&Buffer[128],128);
      memcpy(&Buffer[128],ComLine,128);
     }
   }
   if(SaveIni)
   {
    HandleI=open(FileIni,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,S_IREAD|S_IWRITE);
    if(HandleI==-1)
      printf("%sConfiguration saving failure!\
      \r\nMaybe better to enable writing to disk.",Congr);
    memcpy(Buffer,copyright,128);
    write(HandleI,Buffer,512);
    close(HandleI);
   }
 } /* if <=> need to enter command */
 else
 {
   if(!NotCLine)
   {
     strcpy(&Buffer[128],(char*)((_psp+8l)<<0x10)+1);
     for(i=128;Buffer[i]&&Buffer[i]!='\r';i++);
     Buffer[i]=0;
     for(Pointer=&Buffer[128];*Pointer==' ';Pointer++);
     if(*Pointer=='/'&&tolower(Pointer[1])=='c')
       strcpy(&Buffer[128],Pointer+2);
   }
 }
 if(!Exec)
   exit(0);

 NeedAtm=ManyTimes=Join=WasOpen=NeedAtmI=0;
 *(char *)strrchr(FileI,'.')=0;
 strcpy(FileII,FileI);
 strcat(FileII,"_inv");
 strcat(FileI,".atm");
 strcat(FileII,".atm");
 Pointer=&Buffer[128];
 OutPointer=FirstS;
 while(*Pointer)
 {
   Pnt1=strpbrk(Pointer,Chars);
   if(!Pnt1)
   {
     WasOpen=0;
     strcat(OutPointer,Pointer);
     break;
   } /* if */
   strncat(OutPointer,Pointer,Pnt1-Pointer);
   BSlash=0;
   switch(*(Pointer=Pnt1))
   {
	case '\'':Pointer++;
		  strncat(OutPointer,Pointer++,1);
		  break;
	case '}': if(!WasOpen)
		  {
		    strncat(OutPointer,Pointer++,1);
		    break;
		  }
		  NoPath=1;
		  if(Invert)
                    NeedAtmI=1;
                  else
                    NeedAtm=1;
		  strcat(OutPointer,Invert?FileII:FileI);
		  Pointer++;
		  break;
	case ')': if(!WasOpen)
		  {
		    strncat(OutPointer,Pointer++,1);
		    break;
		  }
		  NoPath=0;
          if(Invert)
            NeedAtmI=1;
          else
            NeedAtm=1;
		  strcat(OutPointer,Invert?FileII:FileI);
		  Pointer++;
		  break;
	case '~': Pointer++;
	switch(*(Pointer++))
	{
	  case '{': if(ManyTimes)
		      exit(puts("Can't execute double {."));
		    WasOpen=1;
		    ManyTimes=1;
		    if(strchr(SpecChar,*Pointer))
		    {
		      Join=1;
		      JoinC[0]=*(Pointer++);
		      if(JoinC[0]==0)
			Pointer--;
		    }
		    OutPointer=SecondS;
		    continue;
	  case '}': NoPath=1;
            if(Invert)
              NeedAtmI=1;
            else
              NeedAtm=1;
		    strcat(OutPointer,Invert?FileII:FileI);
		    break;
	  case ')': NoPath=0;
            if(Invert)
              NeedAtmI=1;
            else
              NeedAtm=1;
            strcat(OutPointer,Invert?FileII:FileI);
		    break;
	  case 'I': Invert=!Invert;
		    Second=!Second;
		    break;
	  case 'T': BSlash=1;
	  case 'P': Path[0]=*(char far *)MK_FP(NPoint,Second?0xD80:0xE38)+'A';
		    *(unsigned *)(Path+1)=':';
		    strcat((char far *)Path,(char far *)MK_FP(NPoint,Second?0xD82:0xE3A));
		    if(BSlash&&(i=strlen(Path))!=3)
		      *(unsigned*)(Path+i)='\\';
		    strcat(OutPointer,Path);
		    break;
	  case 'C': *Path=*(char far *)MK_FP(NPoint,Second?0xE38:0xD80)+'A';
		    *(unsigned *)(Path+1)=':';
		    strcat(OutPointer,Path);
		    break;
	  case 'D': *Path=*(char far *)MK_FP(NPoint,Second?0xD80:0xE38)+'A';
		    *(unsigned *)(Path+1)=':';
		    strcat(OutPointer,Path);
		    break;
      case 'M': subst(FileI,nmf,FileS);
		    File=fopen(FileI,"rt");
		    strcpy(FileI,FileS);
		    if(File)
		    {
		      fgets(name,64,File);
		      fclose(File);
		      strcat(OutPointer,name);
		      break;
		    }
	  case 'N': printf("%s%s >",FirstS,(OutPointer==FirstS)?S_EMPTY:SecondS);
		    gets(name);
            subst(FileI,nmf,FileS);
		    File=fopen(FileI,WR);
		    strcpy(FileI,FileS);
		    fputs(name,File);
		    fclose(File);
		    strcat(OutPointer,name);
		    break;
	  case 'F': strcat(OutPointer,(char far *)MK_FP(NPoint,Second?0xE84:0xDCC));
		    break;
	  case 'X': NewExt=1;
		    e=strpbrk(Pointer,SpecChar);
		    strncpy(Exten+1,Pointer,i=(e?e-Pointer:strlen(Pointer)));
		    Pointer+=i;
		    break;
	  case 'S': SaveTag=1;
		    break;
	  case '=': if(e=strchr(TagOps,*Pointer))
		    {
		      s=strpbrk(Pointer,SpecChar);
		      if(s)
		      {
			i=*s;
			*s=0;
		      }
		      TagIt(Pointer+1,e-TagOps);
		      if(s)
			*s=i;
		      Pointer+=(s?s-Pointer:strlen(Pointer));
		      break;
		    }
	  default:  if(*(Pointer-1)==0)
		      Pointer--;
		    strncat(OutPointer,Pointer-2,2);
		    break;
	}/* case ~ */
		  break;
   } /* case */
 WasOpen=0;
 }/* while */
 if(WasOpen)
 {
  puts(INFOR);
  ManyTimes=0;
  strcat(FirstS,"~{");
  if(Join)
    strcat(FirstS,JoinC);
 }
 Second=!(int)*(char far *)MK_FP(NPoint,0xD7E);
 if(NeedAtm||NeedAtmI)
  if(!NPoint||(NeedAtm&&(makeatm(FileI,0)==-1))||(NeedAtmI&&(makeatm(FileII,1)==-1)))
    exit(puts("Read NCA.DOC first!\r\nUsing of some special chararcters demand NC."));
 if(!ManyTimes)
   SystemE(FirstS);
 Pointer=strpbrk(SecondS,SpecChar);
 strncpy(Path,SecondS,i=(Pointer?Pointer-SecondS:strlen(SecondS)+1));
 Path[i]=0;
 if(!Pointer)
   Pointer=S_EMPTY;
 File=fopen(Path,"rt");
 if(!Join)
 {
   subst(FileI,bat,FileS);
   File1=fopen(FileI,WR);
 }
 else
   File1=(FILE *)1;
 if(File==(FILE *)NULL || File1==(FILE *)NULL)
   exit(printf("%sExtended command processing failure!\r\n",Congr));
 if(Number==1)
 {
   if(!Join)
   {
     fclose(File1);
     unlink(FileI);
   }
   if(!fgets(Buffer,64,File))
     exit(1);
   for(i=0;Buffer[i]&&Buffer[i]!='\n';i++);
   Buffer[i]=0;
   if(i)
     sprintf(ComLine,"%s%s%s",FirstS,Buffer,Pointer);
   SystemE(ComLine);
 }
 WasJoin=Len=0;
 LenS=127-strlen(FirstS);
 if(LenS<0)
 {
  printf("%sYou have to shrink your appetite.\r\n",TOOLON);
  fclose(File1);
  fclose(File);
  exit(1);
 }
 while(!feof(File))
 {
   fgets(Buffer,64,File);
   for(i=0;Buffer[i]&&Buffer[i]!='\n';i++);
   Buffer[i]=0;
   if(Join)
   {
     if((Len+=strlen(Buffer)+Join-(WasJoin==0))<LenS)
     {
       if(*Buffer)
       {
	 if(WasJoin)
	   strcat(FirstS,JoinC);
	 strcat(FirstS,Buffer);
       }
       WasJoin=1;
     }
     else
     {
       printf("%sTry to replace ) with }.\r\n",TOOLON);
       break;
     }
   } /* if */
   else
     if(*Buffer)
       fprintf(File1,"@%s%s%s\n",FirstS,Buffer,Pointer);
 } /* while */
 fclose(File);
 if(!Join)
 {
   fclose(File1);
   SystemE(FileI);
 }
 strcat(FirstS,Pointer);
 SystemE(FirstS);
} /* main */
