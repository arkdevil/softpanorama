#include <ctype.h>
#include <stdio.h>
#include <string.h>

static char last='\0';
static char this='\0';

echo(c) /* Echo char appropriately on console */
{
#include "teco.h"

	if (cancel) return;			/* Skip if ^O sent */
	this=toascii(c);			/* Mask off parity */
	if (this == 27) {			/* Check for <ESC> */
		this='$';			/*  ..if so echo $ */
	} else {				/* Else process it */
		if (iscntrl(this)) {
			if (this == 10) {
				if (last == 13) {
					last=this;
					return;
				} else {
					fprintf(stderr,"\n");
					goto check;
				}
			} else {
				if (this == 13) {
					fprintf(stderr,"\n");
					goto check;
				}
				if (this == 9) {
					fprintf(stderr,"\11");
					goto check;
				} else {
					fprintf(stderr,"\^");
					this=this+64;
				}
			}
		}
	}
	fprintf(stderr,"%c",this);
	last=this;
	return;

check:	last=this;
	if (kbhit()) {
		if (15 == toascii(getch())) {
			cancel=1;
			fprintf(stderr,"\^O\n");
		}
	}
}
