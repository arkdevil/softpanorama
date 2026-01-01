/* ReSizeable RAMDisk - environment utilities
** Copyright (c) 1992 Marko Kohtala
*/

#include "srdisk.h"
#include <stdio.h>
#include <dos.h>
#include <string.h>

/*
   envptr - returns pointer to parent command.com's copy of the environment
   Provided by Doug Dougherty, original source by S. Palmer.
   Heavily modified for srdisk use.
*/

static char _seg *envptr(int *size)
{
    word parent_p;

/*  memory control block */

    struct MCB {
        byte id;
        word owner;
        word size;
    } _seg *mcb = NULL;

    parent_p = peek(_psp,0x16);     /* find pointer to parent in psp */
    if (!parent_p)          /* If DOS 1.0 or something and no parent... */
        return NULL;
    for (;;) {
        if (peek(parent_p,0x2c) == 0) {
            if (peek(parent_p,0x16) != parent_p)
                parent_p = peek(parent_p,0x16);
            else
                return NULL;
        }
        else {
           mcb = (struct MCB _seg *)(peek(parent_p,0x2c) - 1);
           break;
        }
    }
    *size = mcb->size * 16;
    return (char _seg *)(FP_SEG(mcb) + 1);
}

/*
   msetenv - place an environment variable in command.com's copy of
             the envrionment.
   Provided by Doug Dougherty, original source by S. Palmer.
*/
static int msetenv(char *var, char *value)
{
    char _seg *env;
    char near *env1, near *env2;
    char near *cp;
    int size;
    int l;

    env = envptr(&size);
    if (!env) return -2;    /* Return error if no environment found */

    env1 = env2 = 0;

    l = strlen(var);
    strupr(var);

    /*
       Delete any existing variable with the name (var).
    */
    while (*(env+env2)) {
        if ((_fstrncmp(var,(env+env2),l) == 0) && ((env+env2)[l] == '=')) {
            cp = env2 + _fstrlen((env+env2)) + 1;
            _fmemcpy((env+env2),(env+cp),size-(cp-env1));
        }
        else {
            env2 += _fstrlen((env+env2)) + 1;
        }
    }

    /*
       If the variable fits, shovel it in at the end of the envrionment.
    */
    if (_fstrlen(value) && (size-(env2-env1)) >= (l + _fstrlen(value) + 3)) {
        _fstrcpy((env+env2),var);
        _fstrcat((env+env2),"=");
        _fstrcat((env+env2),value);
        (env+env2)[_fstrlen(env+env2)+1] = 0;
        return 0;
    }

    /*
       Return error indication if variable did not fit.
    */
    return -1;
}

/*
**  Set environment variables to show SRDISK RAMDisks
**
**  Allowed not to return if error found, but if not serious error,
**  may return.
*/

void set_env()
{
    struct config_s far *conf = mainconf;
    char var[] = "SRDISK1";
    char drive[] = "A";
    int err;

    if (verbose > 1) puts("");
    do {
      drive[0] = conf->drive;

      err = msetenv(var, drive);
      if (err == -1)
        fatal("Not enough environment space");
      if (err == -2)
        fatal("No environment found to modify");

      if (verbose > 1) printf("Set %s=%s\n", var, drive);

      var[6]++;
      if (var[6] > '9' && var[6] < 'A')
        var[6] = 'A';
      conf = conf_ptr(conf->next_drive);
    } while ( conf );
}

