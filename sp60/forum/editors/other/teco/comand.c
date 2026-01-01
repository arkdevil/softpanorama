#include <ctype.h>
#include <stdio.h>
#include <string.h>

comand()
{
#include "teco.h"

	char last,this;
	int  tmp;

reset:	memset(getbuf,'\33',getsiz);
	getptr=0;
	last=0;

	while (kbhit()) getch();
	fprintf(stderr,"*");

loop:	tmp=getch();
	this=toascii(tmp);

	if (this != 27 | last != 27) {
		if (this == 8 | this == 127) {
			if (!getptr) {
				fprintf(stderr,"\n");
				goto reset;
			}
			if (getbuf[getptr] == 13 | getbuf[getptr] == 9) {
				if (getbuf[getptr] == 9) fprintf(stderr,"\n");
				tmp=getptr;
				while (getbuf[--tmp] != 13 & tmp != 0);
				while (++tmp != getptr) echo(getbuf[tmp]);
			} else {
				if (getbuf[getptr]<32 & getbuf[getptr]!=27) {
					fprintf(stderr,"\10 \10\10 \10");
				} else {
					fprintf(stderr,"\10 \10");
				}
			}
			getbuf[getptr]='\0';
			getptr=getptr-1;
			goto loop;
		} else {
			echo(this);
			if (this == 21) {
				if (!getptr) {
					fprintf(stderr,"\n");
					goto reset;
				}
				tmp=getptr;
				while (getbuf[tmp] !=13 & --tmp !=0);
				if (!tmp) {
					fprintf(stderr,"\n");
					goto reset;
				}
				getptr=tmp;
				echo('\15');
			} else {
				if (getptr > getsiz) {
				   fprintf(stderr,"?MEM, Memory overflow\n\7");
				   goto reset;
				}
				getbuf[++getptr]=this;
				if (this == 13) {
					this=10;
					getbuf[++getptr]=this;
				}
			}
			last=this;
			goto loop;
		}
	}
	fprintf(stderr,"$\n");
}
