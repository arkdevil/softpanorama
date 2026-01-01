#include <stdio.h>
#include <process.h>
#include <string.h>
char linebuf[256], *wrd, separ[]="; ," ;
int tab_size = 8;
int iswchar(int ch)
{ return  (ch|0x20)>='a'&&(ch|0x20)<='z' || ch=='_' || ch>='0'&&ch<='9' ||
			ch=='#' || ch=='$' || ch=='@';
}
void getword(char *fname, int line, int col)
{ FILE *f; int i,c;
	if(!(f=fopen(fname,"rt"))) exit(10);
	while(--line)   while(fgetc(f)!='\n');
	if(feof(f)) exit(10);
	i = 0;
        while((c=fgetc(f))!='\n'&& !feof(f) && i<255) {
		if(c=='\t')
			memset(linebuf+i,' ',c=tab_size-i%tab_size),
			i += c;
		else linebuf[i++] = c;
	}
	linebuf[255] = 0;
	fclose(f);
	if(wrd=strchr(linebuf,'\n')) *wrd=0;
	for(i=--col; i; i--)   if(iswchar(linebuf[i])) break;
	if(!iswchar(linebuf[i])) exit(9);
	for(;i;i--)  if(!iswchar(linebuf[i])) {i++; break;}
	wrd = linebuf+i;
	for(; linebuf[i]; i++)   if(!iswchar(linebuf[i])) break;
	linebuf[i] = 0;
}
int fl_append=0, eflag=0;
main(int ac, char **av)
{ int argcom, i; char *envp[] = { NULL };
	if(ac<2) goto help;
        for(i=1; i<ac; i++)
	    if(*av[i]=='/'||*av[i]=='-')
		switch(av[i][1]|0x20) {
		    case 't':
                        if((tab_size = atoi(av[i]+2)) < 1 || tab_size > 255)
				goto help;
			break;
		    case 'a': fl_append=1; break;
		    case 'e': eflag=1;	   break;
		    default: goto help;
		}
	    else break;
	argcom = i;
	if(ac < argcom+3) goto help;
        getword(av[argcom], atoi(av[argcom+1]), atoi(av[argcom+2]));
	argcom+=2; //argcom-->command-1
	if(fl_append) {
		for(i=argcom;i<ac;i++) av[i] = av[i+1];
		av[ac-1] = wrd;
	}
	else av[argcom] = av[argcom+1], av[argcom+1] = wrd;
	if(eflag) execvpe(av[argcom], av+argcom, envp);
	else	  execvp (av[argcom], av+argcom      );
	return -2;
help:	cputs(
"Word Transfer Utility for Borland C++     V 1.0    by M.Yutsis, May 1992\r\n\n"
"    Syntax:  TRWORD  [options] <filename> <line> <column> <command>\r\n"
"    Recommended command line to install in IDE via menu Options|Transfer :\r\n"
"            [options] $EDNAME $LIN $COL $SAVE CUR $NOSWAP <command>\r\n\n"
"    Options:\r\n"
"    /t<n>      Tab size (as set in Options|Environment|Editor dialog box)\r\n"
"                 default = 8\r\n"
"    /a         Append found word to the end of command line\r\n"
"                 default: word is a first command-line parameter\r\n"
"    /e         Do not pass Environment to command\r\n"
"    <command>  Command line to execute.\r\n\n"
	);
}
