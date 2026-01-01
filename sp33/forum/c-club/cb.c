#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

int     commpp  = 0;
int     slevel[10];
int     clevel  = 0;
int     spflg[20][10];
int     sind[20][10];
int     siflev[10];
int     sifflg[10];
int     iflev   = 0;
int     ifflg   = -1;
int     level   = 0;
int     ind[10] = {
	0,0,0,0,0,0,0,0,0,0 };
int     eflg    = 0;
int     paren   = 0;
int     pflg[10] = {
	0,0,0,0,0,0,0,0,0,0 };
char    lchar;
char    pchar;
int     aflg    = 0;
int     ct;
int     stabs[20][10];
int     qflg    = 0;
char    *wif[] = {
	"if",0};
char    *welse[] = {
	"else",0};
char    *wfor[] = {
	"for",0};
char    *wds[] = {
	"case","default",0};
int     j       = 0;
char    string[200];
int	cc;
int     sflg    = 1;
int     peek    = -1;
int     tabs    = 0;
int     lastchar;
char	tabst[] = "\t\0bbbbbbb";
char	tabsa[] = "    \0bbbb";
char	flagnstr = 0;

main(ac, av)
char **av;
{
	int  flagf;
	int  fdinp, fdout, fd0, fd1;
	int  n, c;
	char *p, *pp;
	char	namefile[80], name[80], nametmp[80], namebak[80];

	flagf = 0;
	while(--ac > 0) {
		p = *++av;
		if(*p == '-') {
			switch(*++p) {
			case 'v':
			case 'V':
				printf("@VO: CB -tT[A] -n [Files ...]\n");
				exit(0);
			case 't':
			case 'T':
				for(pp=tabst, n=0; n<2; n++,pp=tabsa) {
					if(*++p == 0)
						break;
					c = *p - '0';
					if(c < 0 || c > 9) {
						printf("Bad tab. value\n");
						exit(1);
					}
					while(c--)
						*pp++ = ' ';
					*pp = 0;
				}
				break;
			case 'n':
			case 'N':
				flagnstr++;
				break;
			default:
				printf("Bad key %s ignored.",*av);
				break;
			}
			continue;
		}
		flagf++;
		strcpy(namefile,p);
		printf("File: %-12s ",namefile);
		if((fdinp = open(namefile,O_RDONLY)) < 0) {
			for(p = name; *p; p++)
				if(*p == '.') {
					break;
				}
			if(*p == 0) {
				strcat(namefile,".c");
				printf("\rFile: %-12s ",namefile);
				fdinp = open(namefile,O_RDONLY);
			}
			if(fdinp < 0) {
				printf("*** Bad File\n");
				continue;
			}
		}
		strcpy(name,namefile);
		for(p = name; *p; p++)
			if(*p == '.') {
				*p = 0;
				break;
			}
		strcpy(nametmp,name);
		strcat(nametmp,".tmp");
		strcpy(namebak,name);
		strcat(namebak,".bak");
		if((fdout = open(nametmp,O_WRONLY|O_CREAT,S_IREAD|S_IWRITE)) < 0) {
			printf("*** Can't open file %s\n",nametmp);
			close(fdinp);
			continue;
		}
		fd0 = stdin->fd;
		fd1 = stdout->fd;
		stdin->fd = fdinp;
		stdout->fd = fdout;
		work();
		stdin->fd = fd0;
		stdout->fd = fd1;
		close(fdout);
		close(fdinp);
		if(unlink(namebak), rename(namefile,namebak) ||
		    rename(nametmp,namefile))
			printf("*** Bad rename *** ");
		printf("\n");
	}
	if(flagf == 0)
		work();		/* Стандартный в/в */
}

work()
{
	register int c;

	while((c = getch()) != EOF){
		switch(c){
		case ' ':
		case '\t':
			if(lookup(welse) == 1){
				gotelse();
				if(sflg == 0 || j > 0)string[j++] = c;
				putstr();
				sflg = 0;
				if(getnl() == 1){
					putstr();
					printf("\n");
					sflg = 1;
					pflg[level]++;
					tabs++;
				}
				continue;
			}
			if(sflg == 0 || j > 0)string[j++] = c;
			continue;
		case '\n':
			if((eflg = lookup(welse)) == 1)gotelse();
			putstr();
			printf("\n");
			sflg = 1;
			if(eflg == 1){
				pflg[level]++;
				tabs++;
			}
			else
				if(pchar == lchar)
					aflg = 1;
			continue;
		case '{':
			if(lookup(welse) == 1)gotelse();
			siflev[clevel] = iflev;
			sifflg[clevel] = ifflg;
			iflev = ifflg = 0;
			clevel++;
			if(sflg == 1 && pflg[level] != 0){
				pflg[level]--;
				tabs--;
			}
			string[j++] = c;
			putstr();
			getnl();
			if(commpp==0)
			{
				putstr();
				printf("\n");
			}
			commpp=0;
			tabs++;
			sflg = 1;
			if(pflg[level] > 0){
				ind[level] = 1;
				level++;
				slevel[level] = clevel;
			}
			continue;
		case '}':
			clevel--;
			if((iflev = siflev[clevel]-1) < 0)iflev = 0;
			ifflg = sifflg[clevel];
			if(pflg[level] >0 && ind[level] == 0){
				tabs -= pflg[level];
				pflg[level] = 0;
			}
			putstr();
			tabs--;
			ptabs();
			if((peek = getch()) == ';'){
				printf("%c;",c);
				peek = -1;
			}
			else printf("%c",c);
			/* Перевод строки при "}else","}while" и др. */
			if(flagnstr) {
				getnl();
				if(commpp==0)
				{
					putstr();
					printf("\n");
				}
				commpp=0;
				sflg = 1;
			}
			if(clevel < slevel[level])if(level > 0)level--;
			if(ind[level] != 0){
				tabs -= pflg[level];
				pflg[level] = 0;
				ind[level] = 0;
			}
			continue;
		case '"':
		case '\'':
			string[j++] = c;
			while((cc = getch()) != c && cc != EOF){
				string[j++] = cc;
				if(cc == '\\'){
					string[j++] = getch();
				}
				if(cc == '\n'){
					putstr();
					sflg = 1;
				}
			}
			string[j++] = cc;
			if(getnl() == 1){
				lchar = cc;
				peek = '\n';
			}
			continue;
		case ';':
			string[j++] = c;
			putstr();
			if(pflg[level] > 0 && ind[level] == 0){
				tabs -= pflg[level];
				pflg[level] = 0;
			}
			getnl();
			if(commpp==0)
			{
				putstr();
				printf("\n");
			}
			commpp=0;
			sflg = 1;
			if(iflev > 0)
				if(ifflg == 1){
					iflev--;
					ifflg = 0;
				}
				else iflev = 0;
			continue;
		case '\\':
			string[j++] = c;
			string[j++] = getch();
			continue;
		case '?':
			qflg = 1;
			string[j++] = c;
			continue;
		case ':':
			string[j++] = c;
			if(qflg == 1){
				qflg = 0;
				continue;
			}
			if(lookup(wds) == 0){
				sflg = 0;
				putstr();
			}
			else{
				tabs--;
				putstr();
				tabs++;
			}
			if((peek = getch()) == ';'){
				printf(";");
				peek = -1;
			}
			getnl();
			if(commpp==0)
			{
				putstr();
				printf("\n");
			}
			commpp=0;
			sflg = 1;
			continue;
		case '/':
			string[j++] = c;
			if((peek = getch()) == '*')
			{
				string[j++] = peek;
				peek = -1;
				comment();
			}
			if(peek == '/')
			{
				string[j++]=peek;
				peek = -1;
				ppcomment();
			}
			continue;
		case ')':
			paren--;
			string[j++] = c;
			putstr();
			if(getnl() == 1){
				peek = '\n';
				if(paren != 0)aflg = 1;
				else if(tabs > 0){
					pflg[level]++;
					tabs++;
					ind[level] = 0;
				}
			}
			commpp=0;
			continue;
		case '#':
			string[j++] = c;
			while((cc = getch()) != '\n' && cc != EOF)
				string[j++] = cc;
			string[j++] = cc;
			sflg = 0;
			putstr();
			sflg = 1;
			continue;
		case '(':
			string[j++] = c;
			paren++;
			if(lookup(wfor) == 1){
				while((c = getstr()) != ';');
				ct=0;
cont:
				while((c = getstr()) != ')'){
					if(c == '(') ct++;
				}
				if(ct != 0){
					ct--;
					goto cont;
				}
				paren--;
				putstr();
				if(getnl() == 1){
					peek = '\n';
					pflg[level]++;
					tabs++;
					ind[level] = 0;
				}
				continue;
			}
			if(lookup(wif) == 1){
				putstr();
				stabs[clevel][iflev] = tabs;
				spflg[clevel][iflev] = pflg[level];
				sind[clevel][iflev] = ind[level];
				iflev++;
				ifflg = 1;
			}
			continue;
		default:
			string[j++] = c;
			if(c != ',')lchar = c;
		}
	}
}
ptabs(){
	register int i;
	for(i=0; i < tabs; i++)
		printf(tabst);
}
getch(){
	if(peek < 0 && lastchar != ' ' && lastchar != '\t')pchar = lastchar;
	lastchar = (peek<0) ? getc(stdin):peek;
	peek = -1;
	return(lastchar);
}
putstr(){
	if(j > 0){
		if(sflg != 0){
			ptabs();
			sflg = 0;
			if(aflg == 1){
				aflg = 0;
				if(tabs > 0)printf(tabsa);
			}
		}
		string[j] = '\0';
		printf("%s",string);
		j = 0;
	}
	else{
		if(sflg != 0){
			sflg = 0;
			aflg = 0;
		}
	}
}
lookup(tab)
char *tab[];
{
	char r;
	int l,kk,k,i;
	if(j < 1)return(0);
	kk=0;
	while(string[kk] == ' ')kk++;
	for(i=0; tab[i] != 0; i++){
		l=0;
		for(k=kk;(r = tab[i][l++]) == string[k] && r != '\0';k++);
		if(r == '\0' && (string[k] < 'a' || string[k] > 'z' || k >= j))return(1);
	}
	return(0);
}
getstr(){
	char ch;
beg:
	if((ch = string[j++] = getch()) == '\\'){
		string[j++] = getch();
		goto beg;
	}
	if(ch == '\'' || ch == '"'){
		while((cc = string[j++] = getch()) != ch && cc != EOF)
			if(cc == '\\')
				string[j++] = getch();
		goto beg;
	}
	if(ch == '\n'){
		putstr();
		aflg = 1;
		goto beg;
	}
	else return(ch);
}
gotelse(){
	tabs = stabs[clevel][iflev];
	pflg[level] = spflg[clevel][iflev];
	ind[level] = sind[clevel][iflev];
	ifflg = 1;
}
getnl(){
	while((peek = getch()) == '\t' || peek == ' '){
		string[j++] = peek;
		peek = -1;
	}
	if((peek = getch()) == '/'){
		peek = -1;
		if((peek = getch()) == '*'){
			string[j++] = '/';
			string[j++] = '*';
			peek = -1;
			comment();
		}
		else
			if (peek=='/')    /*  Вставка для коментариев С++  */
			{
				string[j++]='/';
				string[j++]='/';
				peek = -1;
				ppcomment();
			}
			else
				string[j++] = '/';
	}
	if((peek = getch()) == '\n'){
		peek = -1;
		return(1);
	}
	return(0);
}
comment(){
	register int c;
rep:
	while((c = string[j++] = getch()) != '*')
		if(c == EOF) break;
	if(c == '\n'){
		putstr();
		sflg = 1;
	}
gotstar:
	if((c = string[j++] = getch()) != '/'){
		if(c == '*')goto gotstar;
		/* Исправлена ошибочка */
		if(c == '\n'){
			putstr();
			sflg = 1;
		}
		goto rep;
	}
}
ppcomment()
{
	register int c;

	while((c = string[j++] = getch()) != 0x0A)
		if(c == EOF) break;
	string[j++]='\0';
	putstr();
	commpp=1;
	sflg = 1;
}

