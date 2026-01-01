/* m4 -- macro processor                                                    */
/* copyright 1984  Michael M Rubenstein                                     */

#define PGMNAME         "m4"
#include <stdio.h>
#include "m4.h"

#define BALP            "()"

char                    deftype[] = { DEFTYPE, '\0' },
                        iftype[] = { IFTYPE, '\0' },
                        incrtype[] = { INCRTYPE, '\0' },
                        decrtype[] = { DECRTYPE, '\0' },
                        subtype[] = { SUBTYPE, '\0' },
                        evtype[] = { EVTYPE, '\0' },
                        chqtype[] = { CHQTYPE, '\0' },
                        undtype[] = { UNDTYPE, '\0' },
                        ifdtype[] = { IFDTYPE, '\0' },
                        incltype[] = { INCLTYPE, '\0' },
                        sincltype[] = { SINCLTYPE, '\0' },
                        divtype[] = { DIVTYPE, '\0' },
                        undivtype[] = { UNDIVTYPE, '\0' },
                        divntype[] = { DIVNTYPE, '\0' },
                        lentype[] = { LENTYPE, '\0' },
                        indtype[] = { INDTYPE, '\0' },
                        transtype[] = { TRANSTYPE, '\0' },
                        errtype[] = { ERRTYPE, '\0' },
                        dumptype[] = { DUMPTYPE, '\0' },
                        dnltype[] = { DNLTYPE, '\0' },
                        chargtype[] = { CHARGTYPE, '\0' },
                        aquotype[] = { AQUOTYPE, '\0' },
                        nobuilttype[] = { NOBUILTTYPE, '\0' },
                        cmnttype[] = { CMNTTYPE, '\0' },
                        mactype[] = { MACTYPE, '\0' },
                        mktmptype[] = { MKTMPTYPE, '\0' },
                        syscmdtype[] = { SYSCMDTYPE, '\0' };

char                    *evals, *ep;

struct defentry {       char                *d_name;
                        char                *d_def;
                        struct defentry     *d_next;
                };
struct defentry         *deftable = NULL;

struct callstack {      char        **c_args;
                        unsigned    c_plev;
                 };
struct callstack        *cp;

char                    **argstack, **ap;
char                    *ibuf, *ip;
struct istack {         FILE        *i_file;
                        char        *i_ip;
              }         istk[ISTSIZE];
struct istack           *isp = istk;

char                    outname[] = OUTNAME;
FILE                    *outfile[10] = { NULL, NULL, NULL, NULL, NULL,
                                         NULL, NULL, NULL, NULL, NULL };
int                     curout = 0;

char                    aquotes[2 * AQUOTSZ + 1] = "";

char                    nullstr[] = "";

char                    *lookup();
char                    *malloc();
long                    atonum();

int                     lquote = LQUOTE,
                        rquote = RQUOTE,
                        argflag = ARGFLAG,
                        comment = COMMENT,
                        macchr = '\0';

int                     wargc;
char                    **wargv;

main(argc, argv)
  int                   argc;
  char                  **argv;
{
  struct callstack      callst[CALLSIZE];
  char                  *argst_[ARGSIZE];
  char                  evals_[EVALSIZE];
  char                  ibuf_[IBUFSIZ];
  static char           *defn;
  char                  token[MAXTOKEN + 1];
  static char           *tk;
  static int            t;
  static int            c;
  static int            nlb;

  cp = NULL;
  ap = argstack = argst_;
  ep = evals = evals_;
  ip = ibuf = ibuf_;
  install("define", deftype);
  install("ifelse", iftype);
  install("incr", incrtype);
  install("decr", decrtype);
  install("substr", subtype);
  install("eval", evtype);
  install("changequote", chqtype);
  install("undefine", undtype);
  install("ifdef", ifdtype);
  install("include", incltype);
  install("sinclude", sincltype);
  install("divert", divtype);
  install("undivert", undivtype);
  install("divnum", divntype);
  install("len", lentype);
  install("index", indtype);
  install("translit", transtype);
  install("errprint", errtype);
  install("dumpdef", dumptype);
  install("dnl", dnltype);
  install("changearg", chargtype);
  install("aquote", aquotype);
  install("nobuiltin", nobuilttype);
  install("comment", cmnttype);
  install("macro", mactype);
  install("maketemp", mktmptype);
  install("syscmd", syscmdtype);

  install("msdos", nullstr);

  wargc = argc;
  wargv = argv;
  if (wargc == 1)
  {
    istk[0].i_file = stdin;
    istk[0].i_ip = ibuf;
  }
  else
    nextfile();

  outfile[0] = stdout;

  while ((t = gettoken(token, MAXTOKEN)) != EOF)
  {
    switch (t)
    {
      case ALPHA:       if (macchr == '\0')
                        {
                          if ((defn = lookup(tk = token)) == NULL)
                          {
                            puttoken(token);
                            break;
                          }
                        }
                        else
                        {
                          if ((defn = lookup(tk = token + 1)) == NULL)
                          {
                            puttoken(token);
                            break;
                          }
                        }

                        cp = (cp == NULL) ? callst : ++cp;
                        if (cp >= callst + CALLSIZE)
                          error("call stack overflow.");
                        cp->c_args = ap;
                        push();
                        puttoken(defn);
                        putchr(EOS);
                        push();
                        puttoken(tk);
                        putchr(EOS);
                        push();
                        putbak(t = ngetc());
                        if (t != LPAREN)
                          pbstr(BALP);
                        cp->c_plev = 0;
                        break;

      case LQUOTE:      nlb = 1;
                        do
                        {
                          if ((t = ngetc()) == EOF)
                            error("EOF in string.");
                          if (t == rquote)
                            --nlb;
                          else
                          if (t == lquote)
                            ++nlb;
                          if (nlb)
                            putchr(t);
                        } while (nlb);
                        break;

      case COMMENT:     puttoken(token);
                        while ((t = ngetc()) != '\n' && t != EOF)
                        putchr(t);
                        if (t == '\n')
                          putchr('\n');
                        break;

      default:          if (cp == NULL)
                        {
                          puttoken(token);
                          break;
                        }
                        switch (t)
                        {
                          case LPAREN:    if ((cp->c_plev)++)
                                          {
                                            puttoken(token);
                                            break;
                                          }
                                          skipsp();
                                          break;

                          case RPAREN:    if (--(cp->c_plev))
                                          {
                                            puttoken(token);
                                            break;
                                          }
                                          putchr(EOS);
                                          eval(cp->c_args, ap - 1);
                                          ep = *(ap = cp->c_args);
                                          cp = (cp > callst) ? --cp
                                                             : NULL;
                                          break;

                          case COMMA:     if (cp->c_plev == 1)
                                          {
                                            putchr(EOS);
                                            push();
                                            skipsp();
                                            break;
                                          }
                                          puttoken(token);
                                          break;

                          default:        puttoken(token);
                          }
    }
  }

  if (cp != NULL)
    error("unexpected EOF");
  curout = 0;
  undivall();
}

/* put a token to output or evaluation stack as appropriate                 */
puttoken(s)
  register  char        *s;
{
  while (*s)
    putchr(*(s++));
}

/* put a character to output or evaluation stack as appropriate             */
putchr(c)
  int                   c;
{
  if (cp == NULL)
  {
    if (curout >= 0)
      putc(c, outfile[curout]);
  }
  else
  {
    if (ep >= evals + EVALSIZE)
      error("evaluation stack overflow.");
    *(ep)++ = c;
  }
}

/* push ep onto argstack, return updated pointer                            */
push()
{
  if (ap >= argstack + ARGSIZE)
    error("arg stack overflow.");
  *(ap++) = ep;
}

/* expand args afrom through ato; evaluate builtin or push back definition  */
eval(afrom, ato)
  char                  **afrom, **ato;
{
  static char           *def, *s;
  static char           **arg;
  static int            c;

  if ((c = **afrom) & 0x80)
  {
    afrom += 2;
    switch (c & 0xff)
    {
      case DEFTYPE:     dodef(afrom, ato);
                        break;

      case IFTYPE:      doif(afrom, ato);
                        break;

      case INCRTYPE:    doincr(afrom[0], 1);
                        break;

      case DECRTYPE:    doincr(afrom[0], -1);
                        break;

      case SUBTYPE:     dosub(afrom, ato);
                        break;

      case EVTYPE:      doeval(afrom[0]);
                        break;

      case CHQTYPE:     dochq(afrom, ato);
                        break;

      case UNDTYPE:     doundef(afrom[0]);
                        break;

      case IFDTYPE:     doifdef(afrom, ato);
                        break;

      case INCLTYPE:    doincl(afrom[0], FALSE);
                        break;

      case SINCLTYPE:   doincl(afrom[0], TRUE);
                        break;

      case DIVTYPE:     dodiv(afrom[0]);
                        break;

      case UNDIVTYPE:   doundiv(afrom, ato);
                        break;

      case DIVNTYPE:    pbnum((long) curout);
                        break;

      case LENTYPE:     pbnum((long) strlen(afrom[0]));
                        break;

      case INDTYPE:     doindex(afrom, ato);
                        break;

      case TRANSTYPE:   dotrans(afrom, ato);
                        break;

      case ERRTYPE:     fprintf(stderr, afrom[0], afrom[1], afrom[2],
                                afrom[3], afrom[4], afrom[5], afrom[6],
                                afrom[7], afrom[8]);
                        putc('\n', stderr);
                        break;

      case DUMPTYPE:    dodump(afrom, ato);
                        break;

      case DNLTYPE:     dodnl();
                        break;

      case CHARGTYPE:   argflag = (*afrom[0] == EOS) ? ARGFLAG : *afrom[0];
                        break;

      case AQUOTYPE:    doaquot(afrom, ato);
                        break;

      case NOBUILTTYPE: donobuilt();
                        break;

      case CMNTTYPE:    comment = *afrom[0];
                        break;

      case MACTYPE:     macchr = *afrom[0];
                        break;

      case MKTMPTYPE:   domktmp(afrom[0]);
                        break;

      case SYSCMDTYPE:  dosyscmd(afrom[0]);
                        break;
    }
  }
  else
  {
    def = afrom[0];
    for (s = def + strlen(def); --s > def;)
    {
      if (*(s - 1) != argflag)
        putbak(*s);
      else
      {
        if (isdigit(*s))
        {
          arg = afrom + *s - ('0' - 1);
          if (arg <= ato)
            pbstr(*arg);
        }
        --s;
      }
    }
    if (s == def)
      putbak(*s);
  }
}

/* install a definition in the table                                        */
dodef(afrom, ato)
  char                  **afrom, **ato;
{
  static int            n;

  if (ato > afrom)
  {
    if (strcmp(afrom[0], afrom[1]) == 0)
    {
      fprintf(stderr, "%s: %s defined as self\n.", PGMNAME, afrom[0]);
      exit(1);
    }
    install(afrom[0], afrom[1]);
  }
  else
    install(afrom[0], nullstr);
}

/* select argument                                                          */
doif(afrom, ato)
  register char         **afrom, **ato;
{
  for (;;)
  {
    if (ato - afrom < 2)
      return;
    if (strcmp(afrom[0], afrom[1]) == 0)
    {
      pbstr(afrom[2]);
      return;
    }
    if ((afrom += 3) > ato)
      return;
    if (afrom == ato)
    {
      pbstr(afrom[0]);
      return;
    }
  }
}

/* increment argument                                                       */
doincr(num, i)
  char                  *num;
  int                   i;
{
  if (*num == EOS)
  {
    putbak('1');
    if (i < 0)
      putbak('-');
  }
  else
    pbnum(atonum(num) + i);
}

long atonum(s)
  register char         *s;
{
  static long           n;
  static int            minus;

  n = minus = 0;
  while (*s == '+' || *s == '-')
  {
    if (*s == '-')
      minus = !minus;
    ++s;
  }
  while (isdigit(*s))
    n = n * 10 + (*(s++) - '0');
  if (*s)
    error("invalid number");
  return minus ? -n : n;
}

/* convert number to string and push back                                   */
pbnum(n)
  long                  n;
{
  static int            minus;

  minus = FALSE;
  if (n < 0)
  {
    n = -n;
    minus = TRUE;
  }

  do
  {
    putbak(n % 10 + '0');
    n /= 10;
  } while (n != 0);
  if (minus)
    putbak('-');
}

/* select substring                                                         */
dosub(afrom, ato)
  char                  **afrom, **ato;
{
  static int            i, n, l;
  static char           *s, *t;

  s = afrom[0];
  if (afrom >= ato)
    return;
  l = strlen(s);
  i = atonum(afrom[1]);
  if (i > l)
    return;
  s += i;
  if (afrom + 1 == ato)
  {
    pbstr(s);
    return;
  }
  n = atonum(afrom[2]);
  if (n <= 0)
    return;
  if (i + n > l)
  {
    pbstr(s);
    return;
  }
  for (t = s + n; --t >= s;)
    putbak(*t);
}

/* change quote character                                                   */
dochq(afrom, ato)
  char                  **afrom, **ato;
{
  if (afrom == ato && *afrom[0] == EOS)
  {
    lquote = LQUOTE;
    rquote = RQUOTE;
    return;
  }
  lquote = *afrom[0];
  if (afrom < ato)
    ++afrom;
  rquote = *afrom[0];
}

/* set alternate quote characters                                           */
doaquot(afrom, ato)
  char                  **afrom, **ato;
{
  static int            n;
  static char           *p;

  p = aquotes;
  for (n = AQUOTSZ; n-- && afrom <= ato && *afrom[0] != EOS;)
  {
    *(p++) = **afrom;
    if (afrom < ato)
      ++afrom;
    *p = (**afrom == EOS) ? *(p - 1) : **afrom;
    ++p;
    ++afrom;
  }
  *p = '\0';
}

/* delete a definition                                                      */
doundef(name)
  char                  *name;
{
  static struct defentry
                        *p, *q;

  for (q = NULL, p = deftable; p != NULL; q = p, p = p->d_next)
    if (strcmp(p->d_name, name) == 0)
    {
      if (q == NULL)
        deftable = p->d_next;
      else
        q->d_next = p->d_next;
      free(p->d_def);
      free(p);
      return;
    }
}

/* skip to end of line                                                      */
dodnl()
{
  static int            c;

  while ((c = ngetc()) != '\n' && c != EOF)
    ;
}

/* delete builtin definitions                                               */
donobuilt()
{
  static struct defentry
                        *p, *q, *r;

  for (q = NULL, p = deftable; p != NULL;)
    if (*(p->d_def) & 0x80)
    {
      r = p;
      if (q == NULL)
        p = deftable = p->d_next;
      else
        p = q->d_next = p->d_next;
      free(r->d_def);
      free(r);
    }
    else
    {
      q = p;
      p = p->d_next;
    }
  doundef("msdos");

 dodnl();
}

domktmp(s)
  char              *s;
{
  pbstr(mktemp(s));
}

dosyscmd(s)
  char              *s;
{
  system(s);
}

/* test if symbol defined                                                   */
doifdef(afrom, ato)
  char                  **afrom, **ato;
{
  if (afrom >= ato)
    return;
  if (lookup(afrom[0]))
    pbstr(afrom[1]);
  else
    if (afrom + 2 <= ato)
      pbstr(afrom[2]);
}

/* include a file                                                           */
doincl(name, quiet)
  char                  *name;
  int                   quiet;
{
  if (*name == EOS)
    return;
  if (++isp >= istk + ISTSIZE)
    error("include nesting too deep");
  if (!newin(name, quiet))
    --isp;
} 

/* divert output                                                            */
dodiv(divno)
  char                  **divno;
{
  curout = atonum(divno);
  if (curout< 0 || curout > 9)
  {
    curout = -1;
    return;
  }
  if (outfile[curout] == NULL)
  {
    outname[OUTIDX] = curout + '0';
    if ((outfile[curout] = fopen(outname, "w")) == NULL)
      error("cannot create diversion file");
  }
}

/* put diversion to output                                                  */
doundiv(afrom, ato)
  char                  **afrom, **ato;
{
  if (afrom == ato && *afrom[0] == EOS)
    undivall();
  else
    while (afrom <= ato)
      undiv((int) atonum(*(afrom++)));
}

undivall()
{
  static int            i;

  for (i = 1; i <= 9; ++i)
    undiv(i);
}

/* undivert one diversion file                                              */
undiv(i)
  register int          i;
{
  static FILE           *f;
  static int            c;

  if (i == curout || i < 1 || i > 9 || outfile[i] == NULL)
    return;
  fclose(outfile[i]);
  outname[OUTIDX] = i + '0';
  if (curout >= 0)
  {
    if ((f = fopen(outname, "r")) == NULL)
      error("cannot open diversion file");
    while ((c = getc(f)) != EOF)
      putc(c, outfile[curout]);
    fclose(f);
  }
  unlink(outname);
  outfile[i] = NULL;
}

/* index of one string in another                                           */
doindex(afrom, ato)
  char                  **afrom, **ato;
{
  if (afrom >= ato)
    return;
  pbnum((long) idx(afrom[0], ato[0]));
}

/* find index of one string in another                                      */
idx(s, t)
  register char         *s, *t;
{
  static char           *p, *q;
  static int            i, n;

  n = strlen(s) - strlen(t);
  for (i = 0; i <= n; ++i, ++s)
  {
    for (p = s, q = t; *q && *q == *p; ++p, ++q)
      ;
    if (!*q)
      return i;
  }
  return -1;
}

/* transliterate                                                            */
dotrans(afrom, ato)
  char                  **afrom, **ato;
{
  static char           *s, *s0, *from, *to;
  static int            lto;
  static int            c;
  static int            i;

  if (afrom >= ato)
    return;
  s0 = afrom[0];
  from = afrom[1];
  if (afrom + 2 > ato)
    lto = 0;
  else
    lto = strlen(to = afrom[2]);
  for (s = s0 + strlen(s0) - 1; s >= s0; --s)
  {
    c = *s;
    for (i = 0; from[i] && c != from[i]; ++i)
      ;
    if (from[i])
    {
      if (i < lto)
        putbak(to[i]);
    }
    else
      putbak(c);
  }
}

/* print out definitions                                                    */
dodump(afrom, ato)
  register char         **afrom, **ato;
{
  static struct defentry
                        *d;
  static char           *s;

  if (afrom == ato && !*afrom[0])
    for (d = deftable; d != NULL; d = d->d_next)
      prtdef(d->d_name, d->d_def);
  else
    while (afrom <= ato)
    {
      if ((s = lookup(afrom[0])) != NULL)
        prtdef(afrom[0], s);
      ++afrom;
    }
}

/* print out a definition                                                   */
prtdef(name, def)
  char                  *name, *def;
{
  fprintf(stderr, "%c%s%c\t%c%s%c\n", lquote, name, rquote, lquote,
                  (*def & 0x80) ? nullstr : def, rquote);
}

/* install a definition                                                     */
install(name, defn)
  char                  *name, *defn;
{
  static int            n1, n2;
  static struct defentry
                        *d;

  if (!isalpha(*name) && *name != '_')
    return;
  n1 = strlen(name) + 1;
  n2 = strlen(defn) +1;
  if ((d = (struct defentry *)malloc(sizeof(struct defentry))) == NULL
   || (d->d_name = malloc(n1 + n2)) == NULL)
    error("insufficient memory.");
  strcpy(d->d_name, name);
  strcpy(d->d_def = d->d_name + n1, defn);
  d->d_next = deftable;
  deftable = d;
}

/* lookup a definition                                                      */
char *lookup(name)
  char                  *name;
{
  static struct defentry
                        *d;

  for (d = deftable; d != NULL; d = d->d_next)
    if (strcmp(name, d->d_name) == 0)
      return d->d_def;
  return NULL;
}

/* skip white space                                                         */
skipsp()
{
  static int            c;

  while (isspace(c = ngetc()))
    ;
  putbak(c);
}

/* push characters back onto input                                          */
putbak(c)
  int                   c;
{
  if (c == EOF)                     /* don't push back end of file */
    return;
  if (ip >= ibuf + IBUFSIZ)
    error("too many characters pushed back.");
  *(ip++) = c;
}

/* get a (possibly pushed back) character                                   */
ngetc()
{
  static int            c;

  for (;;)
  {
    if (ip > isp->i_ip)
      return *--ip;
    if ((c = getc(isp->i_file)) != EOF)
      return c & 0x7f;
    if (isp->i_file != stdin)
      fclose(isp->i_file);
    if (isp > istk)
      --isp;
    else
      if (!nextfile())
        return EOF;
  }
}

/* switch to the next file                                                  */
nextfile()
{
  if (--wargc == 0)
    return FALSE;
  newin(*++wargv, FALSE);
  return TRUE;
}

/* open an input file                                                       */
newin(name, quiet)
  char                  *name;
{
  isp->i_ip = ip;
  if (strcmp(name, "-") == 0)
    isp->i_file = stdin;
  else
  if ((isp->i_file = fopen(name, "r")) == NULL)
  {
    if (quiet)
      return FALSE;
    fprintf(stderr, "%s: cannot open %s.\n", PGMNAME, name);
    exit(1);
  }
  return TRUE;
}

/* push a string back                                                       */
pbstr(s)
  char                  *s;
{
  static char           *t;

  for (t = s + strlen(s) - 1; t >= s; --t)
    putbak(*t);
}

/* display error message                                                    */
error(s)
  char                  *s;
{
  fprintf(stderr, "%s: %s\n", PGMNAME, s);
  exit(1);
}
