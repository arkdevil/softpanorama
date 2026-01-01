/*  Program:	SetDATE.c
 *  Version:	1.00.0
 *  Date:	1992/07/14
 *  Copyright:	Jonas I Hammarberg
 * ----------------------------------------------------------------------------
 *  Usage:	Sets enviroment variable DATE to YYMMDD
 */

#include <stdlib.h>
#include <string.h>
#include <dos.h>

#define local static

#ifndef FP_SEG
#define FP_SEG(f) (*((unsigned *)&(f) + 1))
#endif

#ifndef FP_OFF
#define FP_OFF(f) (*((unsigned *)&(f)))
#endif

#ifndef MK_FP
#define MK_FP(s,o) ((void far *)(((unsigned long)(s) << 16) | (unsigned)(o)))
#endif

extern char far   *nxtevar(char far * vptr);
extern char far   *mstenvp(void);
extern int	  envsiz(char far *envptr);

local char far	  *menv;
local char far	  *rest;
local char far	  *lstbyt;
local char	  vname[128], *txtptr;
local int	  nmlen, free_env;

local void  findvar(void){
int	    i;

    nmlen = strlen("DATE");
    txtptr = NULL;
    while(*menv){
	rest = nxtevar(menv);
	i = 0;
	while((vname[i] = menv[i]) != '\0') i++;
	if(vname[nmlen] == '='){ 
	    vname[nmlen] = '\0';
	    if(strcmp(vname, "DATE") == 0){
		txtptr = &vname[nmlen+1];
		vname[nmlen] = '=';
		return;
	    }
	}
	menv = rest;
    }
}

local void  putenvbak(void){
char	    *locptr;
int	    save_size, i;

    save_size = FP_OFF(lstbyt) - FP_OFF(rest) + 1;
    locptr = (char *)malloc(save_size);

    for(i = 0; i < save_size; i++)
	locptr[i] = rest[i];
    for(i = 0; vname[i]; i++)
	*menv++ = vname[i];
    if(vname[0])
	*menv++ = '\0';
    for(i = 0; i < save_size; i++)
	*menv++ = locptr[i];
    free(locptr);

}

void	    main(int argc, char **argv){
char	    sz[7];
struct date daAct;

    GetDate(&daAct);
    daAct.da_year %= 100;
    sz[0] = (char)(daAct.da_year / 10) + '0';
    sz[1] = (char)(daAct.da_year % 10) + '0';
    sz[2] = (char)(daAct.da_mon / 10) + '0';
    sz[3] = (char)(daAct.da_mon % 10) + '0';
    sz[4] = (char)(daAct.da_day / 10) + '0';
    sz[5] = (char)(daAct.da_day % 10) + '0';
    sz[6] = '\0';

    lstbyt = menv = mstenvp();
    free_env = envsiz(menv) << 4;
    findvar();
    while(*lstbyt) lstbyt = nxtevar(lstbyt);
    if(lstbyt[1] == 1 && lstbyt[2] == 0){
	lstbyt += 3;
	while(*lstbyt) lstbyt++;
    }
    lstbyt++;
    free_env -= FP_OFF(lstbyt);
    if(txtptr == NULL){
	free_env -= nmlen + 1;
	if(free_env < 5) return;
	strcpy(vname, "DATE=");
	txtptr = vname + nmlen + 1;
    }
    strcpy(txtptr, sz);
    putenvbak();
}
