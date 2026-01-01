
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/

#include <stdio.h>

int	slevel[10];
int	clevel	= 0;
int	spflg[20][10];
int	sind[20][10];
int	siflev[10];
int	sifflg[10];
int	iflev	= 0;
int	ifflg	= -1;
int	level	= 0;
int	ind[10]	= {
	0,0,0,0,0,0,0,0,0,0 };
int	eflg	= 0;
int	paren	= 0;
int	pflg[10] = {
	0,0,0,0,0,0,0,0,0,0 };
char	lchar;
char	pchar;
int	aflg	= 0;
int	ct;
int	stabs[20][10];
int	qflg	= 0;
char	*wif[] = {
	"if",0};
char	*welse[] = {
	"else",0};
char	*wfor[] = {
	"for",0};
char	*wds[] = {
	"case","default",0};
int	j	= 0;
char	string[200];
char	cc;
int	sflg	= 1;
int	peek	= -1;
int	tabs	= 0;
int	lastchar;
int	c;
int	getstr();

format(in, out)
FILE *in, *out;
{
	while((c = getch(in)) != EOF){
		switch(c){
		case ' ':
		case '\t':
			if(lookup(welse) == 1){
				gotelse();
				if(sflg == 0 || j > 0)string[j++] = c;
				yyputs(out);
				sflg = 0;
				continue;
			}
			if(sflg == 0 || j > 0)string[j++] = c;
			continue;
		case '\n':
			if((eflg = lookup(welse)) == 1)gotelse();
			yyputs(out);
			fprintf(out, "\n");
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
			yyputs(out);
			getnl(in, out);
			yyputs(out);
			fprintf(out, "\n");
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
			yyputs(out);
			tabs--;
			ptabs(out);
			if((peek = getch(in)) == ';'){
				fprintf(out, "%c;",c);
				peek = -1;
			}
			else fprintf(out, "%c",c);
			getnl(in, out);
			yyputs(out);
			fprintf(out, "\n");
			sflg = 1;
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
			while((cc = getch(in)) != c){
				string[j++] = cc;
				if(cc == '\\'){
					string[j++] = getch(in);
				}
				if(cc == '\n'){
					yyputs(out);
					sflg = 1;
				}
			}
			string[j++] = cc;
			if(getnl(in, out) == 1){
				lchar = cc;
				peek = '\n';
			}
			continue;
		case ';':
			string[j++] = c;
			yyputs(out);
			if(pflg[level] > 0 && ind[level] == 0){
				tabs -= pflg[level];
				pflg[level] = 0;
			}
			getnl(in, out);
			yyputs(out);
			fprintf(out, "\n");
			sflg = 1;
			if(iflev > 0)
				if(ifflg == 1){iflev--;
					ifflg = 0;
				}
				else iflev = 0;
			continue;
		case '\\':
			string[j++] = c;
			string[j++] = getch(in);
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
				yyputs(out);
			}
			else{
				tabs--;
				yyputs(out);
				tabs++;
			}
			if((peek = getch(in)) == ';'){
				fprintf(out, ";");
				peek = -1;
			}
			getnl(in, out);
			yyputs(out);
			fprintf(out, "\n");
			sflg = 1;
			continue;
		case '/':
			string[j++] = c;
			if((peek = getch(in)) != '*')continue;
			string[j++] = peek;
			peek = -1;
			comment(in, out);
			continue;
		case ')':
			paren--;
			string[j++] = c;
			yyputs(out);
			if(getnl(in, out) == 1){
				peek = '\n';
				if(paren != 0)aflg = 1;
				else if(tabs > 0){
					pflg[level]++;
					tabs++;
					ind[level] = 0;
				}
			}
			continue;
		case '#':
			string[j++] = c;
			while((cc = getch(in)) != '\n')string[j++] = cc;
			string[j++] = cc;
			sflg = 0;
			yyputs(out);
			sflg = 1;
			continue;
		case '(':
			string[j++] = c;
			paren++;
			if(lookup(wfor) == 1){
				while((c = getstr(in, out)) != ';');
				ct=0;
cont:
				while((c = getstr(in, out)) != ')'){
					if(c == '(') ct++;
				}
				if(ct != 0){
					ct--;
					goto cont;
				}
				paren--;
				yyputs(out);
				if(getnl(in, out) == 1){
					peek = '\n';
					pflg[level]++;
					tabs++;
					ind[level] = 0;
				}
				continue;
			}
			if(lookup(wif) == 1){
				yyputs(out);
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
ptabs(out)
FILE *out;
{
	int i;
	for(i=0; i < tabs; i++)fprintf(out, "\t");
}
getch(in)
FILE *in;
{
	if(peek < 0 && lastchar != ' ' && lastchar != '\t')pchar = lastchar;
	lastchar = (peek<0) ? getc(in):peek;
	peek = -1;
	return(lastchar);
}
yyputs(out)
FILE *out;
{
	if(j > 0){
		if(sflg != 0){
			ptabs(out);
			sflg = 0;
			if(aflg == 1){
				aflg = 0;
				if(tabs > 0)fprintf(out, "    ");
			}
		}
		string[j] = '\0';
		fprintf(out, "%s",string);
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
getstr(in, out)
FILE *in, *out;
{
	char ch;
beg:
	if((ch = string[j++] = getch(in)) == '\\'){
		string[j++] = getch(in);
		goto beg;
	}
	if(ch == '\'' || ch == '"'){
		while((cc = string[j++] = getch(in)) != ch)if(cc == '\\')string[j++] = getch(in);
		goto beg;
	}
	if(ch == '\n'){
		yyputs(out);
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
getnl(in, out)
FILE *in, *out;
{
	while((peek = getch(in)) == '\t' || peek == ' '){
		string[j++] = peek;
		peek = -1;
	}
	if((peek = getch(in)) == '/'){
		peek = -1;
		if((peek = getch(in)) == '*'){
			string[j++] = '/';
			string[j++] = '*';
			peek = -1;
			comment(in, out);
		}
		else string[j++] = '/';
	}
	if((peek = getch(in)) == '\n'){
		peek = -1;
		return(1);
	}
	return(0);
}
comment(in, out)
FILE *in, *out;
{
	int i = j;

	while ((c = getch(in)) != EOF) {
		string[j++] = c;
		switch(c) {
		case '/':
			if (j > i + 1 && string[j-2] == '*')
				return;
			break;
		case '\n':
			yyputs(out);
			sflg = 1;
			break;
		}
	}
}
