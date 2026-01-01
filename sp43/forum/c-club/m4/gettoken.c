/* gettoken -- get a token                                                  */

#include <stdio.h>
#include "m4.h"

extern int              lquote, comment, macchr;
extern char             aquotes[];

/* get a token                                                              */
gettoken(token, toksize)
  char                  *token;
  int                   toksize;
{
  static int            c;
  static int            n;
  static char           *p;

  *(token++) = c = ngetc();
  *token = '\0';
  switch (c)
  {
    case EOF:
    case COMMA:
    case LPAREN:
    case RPAREN:        return c;

    default:            if (c == comment)
                          return COMMENT;
                        if (c == lquote)
                          return LQUOTE;
                        n = toksize;
                        for (p = aquotes; *p; p += 2)
                          if (c == *p)
                          {
                            ++p;
                            while (--n)
                              if ((*(token++) = ngetc()) == *p)
                              {
                                *token = EOS;
                                return 0;
                              }
                            error("token too long.");
                          }

                        if (macchr != '\0')
                        {
                          if (c != macchr)
                            return 0;
                          putbak(c = ngetc());
                        }

                        if (!(isalpha(c) || c == '_'))
                          return 0;

                        do
                        {
                          if (n-- <= 0)
                            error("token too long.");
                          *(token++) = c = ngetc();
                        }  while (isalpha(c) || isdigit(c) || c == '_');
                        *(token - 1) = EOS;
                        putbak(c);
                        return ALPHA;
  }
}
