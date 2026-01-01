/* m4 -- evaluation functions                                               */
/* copyright 1984  Michael M Rubenstein                                     */

#include <stdio.h>
#include "m4.h"

long                    atonum();
char                    *evalor(), *evaland(), *evalnot(), *evalcmp(),
                        *evalsum(), *evalprod(), *evalun();
char                    *ignbl();

/* evaluate expression                                                      */
doeval(expr)
  char                  *expr;
{
  static long           n;

  if (*expr== EOS)
    putbak('0');
  else
  {
    if (*evalor(expr, &n))
      everr();
    pbnum(n);
  }
}

/* evaluate or                                                              */
char *evalor(s, n)
  char                  *s;
  long                  *n;
{
  long                  n2;

  s = evaland(s, n);
  while (*s == '|')
  {
    if (*++s == '|')
      ++s;
    if (!*s)
      everr();
    s = evaland(s, &n2);
    *n = *n || n2;
  }
  return s;
}

/* evaluate and                                                             */
char *evaland(s, n)
  char                  *s;
  long                  *n;
{
  long                  n2;

  s = evalnot(s, n);
  while (*s == '&')
  {
    if (*++s == '&')
      ++s;
    if (!*s)
      everr();
    s = evalnot(s, &n2);
    *n = *n && n2;
  }
  return s;
}

/* evaluate not                                                             */
char *evalnot(s, n)
  char                  *s;
  long                  *n;
{
  int                   not;

  not = 0;
  while (*(s = ignbl(s)) == '!')
  {
    not = !not;
    ++s;
  }
  s = evalcmp(s, n);
  if (not)
    *n = !*n;
  return s;
}

/* evaluate comparisons                                                     */
char *evalcmp(s, n)
  char                  *s;
  long                  *n;
{
  long                  n2;
  int                   op;

  s = evalsum(s, n);
  switch (op = *s)
  {
    case '!':
    case '=':           if (*(s + 1) != '=')
                          return s;
                        s += 2;
                        break;                    

    case '<':
    case '>':           if (*(s + 1) == '=')
                        {
                          op = (op == '<') ? 'l' : 'g';
                          s += 2;
                        }
                        else
                          ++s;
                        break;

    default:            return s;
  }
  s = evalcmp(s, &n2);
  switch (op)
  {
    case '=':           *n = (*n == n2);
                        break;

    case '!':           *n = (*n != n2);
                        break;
  
    case '<':           *n = (*n < n2);
                        break;
  
    case '>':           *n = (*n > n2);
                        break;
  
    case 'l':           *n = (*n <= n2);
                        break;
  
    case 'g':           *n = (*n >= n2);
                        break;
  }
  return s;
}

/* evaluate a sum or difference                                             */
char *evalsum(s, n)
  char                  *s;
  long                  *n;
{
  long                  n2;
  int                   op;

  s = evalprod(s, n);
  for (;;)
  {
    switch (op = *s)
    {
      case '+':
      case '-':         break;

      default:          return s;
    }
    s = ignbl(evalprod(s + 1, &n2));
    if (op == '+')
      *n += n2;
    else
      *n -= n2;
  }
}

/* evaluate a product, quotient, or mod                                     */
char *evalprod(s, n)
  char                  *s;
  long                  *n;
{
  long                  n2;
  int                   op;

  s = evalun(s, n);
  for (;;)
  {
    switch (op = *s)
    {
      case '*':
      case '/':
      case '%':         break;

      default:          return s;
    }
    s = evalun(s + 1, &n2);
    switch (op)
    {
      case '*':         *n *= n2;
                        break;

      case '/':         *n /= n2;
                        break;

      case '%':         *n %= n2;
                        break;
    }
  }
}

/* evaluate unary + and - and parentheses                                   */
char *evalun(s, n)
  char                  *s;
  long                  *n;
{
  int                   minus;

  minus = 0;
  while (*(s = ignbl(s)) == '+' || *s == '-')
  {
    if (*s == '-')
      minus = !minus;
    ++s;
  }
  if (*s == '(')
  {
    s = evalor(s + 1, n);
    if (*(s++) != ')')
      everr();
  }
  else
  {
    if (!isdigit(*s))
      everr();
    *n = 0;
    while (isdigit(*s))
      *n = *n * 10 + *(s++) - '0';
  }
  if (minus)
    *n = -*n;
  return ignbl(s);
}

/* ignore spaces in string                                                  */
char *ignbl(s)
  register char         *s;
{
  while (isspace(*s))
    ++s;
  return s;
}

/* evaluation error                                                         */
everr()
{
  error("illegal expression.");
}
