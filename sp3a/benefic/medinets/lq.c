#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <stdlib.h>

#define MAXR 24                         /* matrix rows */
#define MAXC 42                         /* matrix columns */
#define H1   3                          /* 1st down-loaded code position */
#define H2   4                          /* 2nd ditto                     */
#define HSZ  5                          /* header size */
#define PSZ  129                        /* character info block max. size */

#define NUL   0x00
#define CR    0x0d
#define ESC   0x1b
#define SP    0x20
#define UP    72
#define DOWN  80
#define RIGHT 77
#define LEFT  75
#define INS   82
#define DEL   83
#define HOME  71
#define END   79
#define PGUP  73
#define PGDN  81
#define F3    61
#define F5    63
#define F6    64
#define F7    65
#define F8    66
#define F9    67
#define F10   68
#define SHF5  88
#define SHF6  89
#define SHF7  90
#define SHF8  91
#define SHF9  92
#define SHF10 93

typedef unsigned char BYTE;

void mess(void);
void backup(char *, FILE *, BYTE *, short, short, BYTE **);
void save(short *, short *, short, short, short, 
	  short, short, short [MAXR][MAXC], BYTE *);
void draw(short, short, short, short, short [MAXR][MAXC],
	  short *, short *, short *);
void unpack(BYTE *, short *, short *, short *, short [MAXR][MAXC]);
void pack(short, short, short, short [MAXR][MAXC], BYTE *);
void bars(short), pins(short), zero(short), barl(short);

static short posr[MAXR] = {
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 
   13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
};

static short posc[MAXC] = {
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46
};

static short posp[] = {
  1, 3
};

static BYTE header[HSZ] = {
  '\033', '&', '\0', '\200', '\200'   /* start downloading */
};

static short maxcc;

void main(int argc, char **argv)

{
  FILE *fd;
  register short cc, cr;
  short c, m[MAXR][MAXC], mr, mc, z, p, l, s, n1, n2, hbufl, n, flag = 0;
  short foo = 0, mrr, ro, co;
  char *y;
  BYTE buf[PSZ], *hbuf, *hb, **off;

  if (argc < 2) {
    fprintf(stderr, "LQ expected a file name at least.\n");
    exit(1);
  }
  if (argc > 2) {
    fprintf(stderr, "LQ didn't expect so many parameters.\n");
    exit(2);
  }
  if ((fd = fopen(*++argv, "r+b")) == NULL) {
    fprintf(stderr, "LQ couldn't find the file \"%s\".\n", *argv);
    fprintf(stderr, "Create new one? ");
    c = getch();
    if (toupper(c) == 'Y') {
      if ((fd = fopen(*argv, "wb")) == NULL) {
	fprintf(stderr, "LX couldn't open the file \"%s\".\n", *argv);
	exit(33);
      }
      fprintf(stderr, "Yes\n");
      do
	fprintf(stderr, "\rEnter range limits: ");
      while (scanf("%d%d", &n1, &n2) != 2);
      header[H1] = (BYTE)(n1 & 0xff);
      header[H2] = (BYTE)(n2 & 0xff);
      if (fwrite(header, 1, HSZ, fd) != HSZ) {
        fprintf(stderr, "Can't write the file header\n");
        exit(34);
      }
      buf[0] = 4;
      buf[1] = 28;
      buf[2] = 4;
      for (c = 3; c < PSZ; c++)
         buf[c] = 0;
      for (c = n1; c <= n2; c++)
        if (fwrite(buf, 1, 87, fd) != 87) {
          fprintf(stderr, "Can't write the %dth char pattern\n", c);
          exit(35);
        }
      fclose(fd);
    }
    else
      exit(3);
  }
  if ((fd = fopen(*argv, "rb")) == NULL) {
    fprintf(stderr, "LX couldn't reopen the file \"%s\" for reading.\n", *argv);
    exit(63);
  }
  if (fread(header, 1, HSZ, fd) != HSZ) {
    fprintf(stderr, "Can't read the file header\n");
    exit(44);
  }
  n1 = header[H1];
  n2 = header[H2];
  printf("%d %d\n", n1, n2);
  hbufl = (n2 - n1 + 1)*PSZ;
  if ((hbuf = (char *)malloc(hbufl)) == NULL) {
    fprintf(stderr, "No room for buffer\n");
    exit(45);
  }
  if ((off = (char **)malloc((n2 - n1 + 1)*sizeof(char *))) == NULL) {
    fprintf(stderr, "No room for ptr array\n");
    exit(55);
  }
  off[0] = hbuf;
  for (c = n1, n = 0; c <= n2; c++, n++) {
    if (n)
      off[n] = off[n - 1] + PSZ;
    l = getc(fd);
    p = getc(fd);
    s = getc(fd);
    z = p*3;
    if ((mr = fread(off[n] + 3, 1, z, fd)) != z) {
      fprintf(stderr, "Can't read the char pattern: %d %d\n", mr, z);
      exit(46);
    }
    (off[n])[0] = (BYTE)l;
    (off[n])[1] = (BYTE)p;
    (off[n])[2] = (BYTE)s;
  }
  fclose(fd);
  n = n1;
  unpack(off[n - n1], &p, &l, &s, m);
  draw(n, p, l, s, m, posr, posc, posp);
  cc = l + 1;
  cr = 0;
  mr = MAXR - 1;
  mc = MAXC - 1;
  printf("\033[%d;%dH", posr[cr], posc[cc]);
  do {
    while (!kbhit)
      ;
    c = getch();
    switch (c) {
      case NUL:                         /* function key */
        c = getch();
        switch (c) {
          case UP:
            if (cr)
              cr--;
            else
              cr = mr;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case DOWN:
            if (cr < mr)
              cr++;
            else
              cr = 0;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case LEFT:
	    if (cc > (l + 1))
              cc--;
            else
	      cc = maxcc - s;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case RIGHT:
	    if (cc < (maxcc - s))
              cc++;
            else
	      cc = l + 1;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case PGDN:
            if (n < n2) {
	      save(&flag, &foo, n, n1, p, l, s, m, off[n - n1]);
              n++;
	      unpack(off[n - n1], &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l + 1;
              cr = 0;
              printf("\033[%d;%dH", posr[cr], posc[cc]);
            }
            break;
          case PGUP:
            if (n > n1) {
	      save(&flag, &foo, n, n1, p, l, s, m, off[n - n1]);
              n--;
	      unpack(off[n - n1], &p, &l, &s, m);
              draw(n, p, l, s, m, posr, posc, posp);
	      cc = l + 1;
              cr = 0;
              printf("\033[%d;%dH", posr[cr], posc[cc]);
            }
            break;
          case HOME:
            if (n > n1) {
	      save(&flag, &foo, n, n1, p, l, s, m, off[n - n1]);
              n = n1;
	      unpack(off[n - n1], &p, &l, &s, m);
              draw(n, p, l, s, m, posr, posc, posp);
	      cc = l + 1;
              cr = 0;
              printf("\033[%d;%dH", posr[cr], posc[cc]);
            }
            break;
          case END:
            if (n < n2) {
	      save(&flag, &foo, n, n1, p, l, s, m, off[n - n1]);
              n = n2;
	      unpack(off[n - n1], &p, &l, &s, m);
              draw(n, p, l, s, m, posr, posc, posp);
	      cc = l + 1;
              cr = 0;
              printf("\033[%d;%dH", posr[cr], posc[cc]);
            }
            break;
          case F3:
            foo = 0;
	    backup(*argv, fd, header, n1, n2, off);
            break;
          case F5:
            flag = 0;
	    pack(p, l, s, m, off[n - n1]);
            mess();
            foo = 1;
            break;
	  case F6:
	    save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	    printf("\033[s\033[2;60HEnter character ");
	    putchar(c = getch());
	    printf("\033[u");
	    if ((c >= n1) && (c <= n2)) {
	      n = c;
	      unpack(off[n - n1], &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l + 1;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
	    break;
          case F7:
	    if (p <= 9)
	      mrr = 1;
	    else if (p <= 29)
	      mrr = 3;
	    else
	      mrr = 2;
	    if (l > mrr) {
              l--;
	      p++;
	      barl(l);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
              flag = 1;
            }
            break;
          case F8:
	    if (p > 1) {
              l++;
	      p--;
	      barl(l);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
              flag = 1;
            }
            break;
          case F9:
	    if (p > 1) {
	      s++;
	      p--;
              bars(s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
              flag = 1;
            }
            break;
          case F10:
	    if (p <= 9)
	      mrr = 2;
	    else if (p <= 29)
	      mrr = 4;
	    else
	      mrr = 3;
	    if (s > mrr) {
	      s--;
	      p++;
              bars(s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
              flag = 1;
            }
            break;
	  case SHF5:
	    for (co = 0; co < MAXC; co++) {
	      mrr = m[0][co];
	      for (ro = 0; ro < (MAXR - 2); ro++)
		m[ro][co] = m[ro + 1][co];
	      m[MAXR - 1][co] = mrr;
	    }
	    draw(n, p, l, s, m, posr, posc, posp);
	    printf("\033[%d;%dH", posr[cr], posc[cc]);
	    flag = 1;
	    break;
	  case SHF6:
	    for (co = 0; co < MAXC; co++) {
	      mrr = m[MAXR - 1][co];
	      for (ro = MAXR - 1; ro > 0; ro--)
		m[ro][co] = m[ro - 1][co];
	      m[0][co] = mrr;
	    }
	    draw(n, p, l, s, m, posr, posc, posp);
	    printf("\033[%d;%dH", posr[cr], posc[cc]);
	    flag = 1;
	    break;
	  case SHF7:
	    for (ro = 0; ro < MAXR; ro++) {
	      mrr = m[ro][0];
	      for (co = 0; co < (MAXC - 2); co++)
		m[ro][co] = m[ro][co + 1];
	      m[ro][MAXC - 1] = mrr;
	    }
	    draw(n, p, l, s, m, posr, posc, posp);
	    printf("\033[%d;%dH", posr[cr], posc[cc]);
	    flag = 1;
	    break;
	  case SHF8:
	    for (ro = 0; ro < MAXR; ro++) {
	      mrr = m[ro][MAXC - 1];
	      for (co = MAXC - 1; co > 0; co--)
		m[ro][co] = m[ro][co - 1];
	      m[ro][0] = mrr;
	    }
	    draw(n, p, l, s, m, posr, posc, posp);
	    printf("\033[%d;%dH", posr[cr], posc[cc]);
	    flag = 1;
	    break;
	  case SHF9:
	    if (p > 1) {
	      p--;
	      maxcc--;
	      bars(s);
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
	    }
	    break;
	  case SHF10:
	    if (maxcc < MAXC) {
	      p++;
	      maxcc++;
	      bars(s);
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
	    }
	    break;
          default:
	    ;
        }
        break;
      case '`':
      case CR:
      case SP:                          /* space bar */
        m[cr][cc] ^= 0x01;
	y = m[cr][cc] ? "▓" : "┼";
        printf("\033[%d;%dH%s\033[%d;%dH",
          posr[cr], posc[cc], y, posr[cr], posc[cc]);
        flag = 1;
      case ESC:                         /* esc */
        break;
      default:
        if ((c >= n1) && (c <= n2)) {
	  unpack(off[c - n1], &p, &l, &s, m);
          draw(n, p, l, s, m, posr, posc, posp);
          cc = l;
          cr = 0;
          printf("\033[%d;%dH", posr[cr], posc[cc]);
	  flag = 1;
        }
    }
  } while (c != ESC);
  if (foo || flag) {
    printf("\033[s\033[2;60HDidn't you forget");
    printf("\033[3;60Hto save the file? ");
    c = getch();
    putchar(c);
    if (toupper(c) == 'Y') {
      if (flag)
	pack(p, l, s, m, off[n - n1]);
      backup(*argv, fd, header, n1, n2, off);
    }
  }
  exit(0);
}

void zero(short n)                 

{
  printf("\033[2J");
  printf("\033[01;58H  `%c' %3d(dec) %02x(hex)", n, n, n);
  printf("\033[01;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼  1");
  printf("\033[02;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   2");
  printf("\033[03;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼  3");
  printf("\033[04;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   4");
  printf("\033[05;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼  5");
  printf("\033[06;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   6");
  printf("\033[07;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼  7");
  printf("\033[08;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   8");
  printf("\033[09;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼  9");
  printf("\033[10;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   10");
  printf("\033[11;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 11");
  printf("\033[12;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   12");
  printf("\033[13;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 13");
  printf("\033[14;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   14");
  printf("\033[15;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 15");
  printf("\033[16;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   16");
  printf("\033[17;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 17");
  printf("\033[18;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   18");
  printf("\033[19;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 19");
  printf("\033[20;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   20");
  printf("\033[21;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 21");
  printf("\033[22;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼   22");
  printf("\033[23;10H  ┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼ 23");
  printf("\033[24;10H  ┼┼┼┼┼┼┼┼┼┼┼╫┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼┼╫┼┼┼┼┼╫┼┼┼┼┼┼   24");
}

void barl(short val)

{
  register short c;

  printf("\033[25;9H%2d ", val);
  for (c = 0; c < val; c++)
    printf("▄");
  printf(" ");
}

void bars(short val)

{
  register short c;

  printf("\033[25;%dH%2d ------ total width: %2d ", maxcc + 12, val, maxcc);
  printf("\033[25;%dH ", maxcc + 11 - val);
  for (c = 0; c < val; c++)
    printf("▄");
  printf(" ");
}

void pack(short p, short l, short s, short m[MAXR][MAXC], BYTE buf[])

{
  register short c, r, i;
  BYTE pat, k;

  buf[0] = (BYTE)l;
  buf[1] = (BYTE)p;
  buf[2] = (BYTE)s;
  i = 2;
  for (c = l + 1; c <= (maxcc - s); c++) {
    pat = 0x80;
    k = 0;
    for (r = 0; r < 8; r++) {
      if (m[r][c])
	k |= pat;
      pat >>= 1;
    }
    buf[++i] = k;
    pat = 0x80;
    k = 0;
    for (r = 8; r < 16; r++) {
      if (m[r][c])
	k |= pat;
      pat >>= 1;
    }
    buf[++i] = k;
    pat = 0x80;
    k = 0;
    for (r = 16; r < 24; r++) {
      if (m[r][c])
	k |= pat;
      pat >>= 1;
    }
    buf[++i] = k;
  }
}

void unpack(BYTE buf[], short *p, short *l, short *s, short m[MAXR][MAXC])

{
  register short c, r, i;
  BYTE pat, k;

  *l = buf[0];
  *p = buf[1];
  *s = buf[2];
  maxcc = *l + *s + *p;
  i = 2;
  for (c = 0; c < MAXC; c++)
    for (r = 0; r < MAXR; r++)
      m[r][c] = 0;
  for (c = *l + 1; c <= (maxcc - *s); c++) {
    pat = 0x80;
    k = buf[++i];
    for (r = 0; r < 8; r++) {
      m[r][c] = (k & pat) ? 1 : 0;
      pat >>= 1;
    }
    pat = 0x80;
    k = buf[++i];
    for (r = 8; r < 16; r++) {
      m[r][c] = (k & pat) ? 1 : 0;
      pat >>= 1;
    }
    pat = 0x80;
    k = buf[++i];
    for (r = 16; r < 24; r++) {
      m[r][c] = (k & pat) ? 1 : 0;
      pat >>= 1;
    }
  }
}

void draw(short n, short p, short l, short s, short m[MAXR][MAXC], 
          short posr[], short posc[], short posp[])

{
  register short cc, cr;
  char *y;

  zero(n);
  barl(l);
  bars(s);
  for (cr = 0; cr < MAXR; cr++)
    for (cc = 0; cc < MAXC; cc++)
      if (m[cr][cc]) {
	printf("\033[%d;%dH▓\033[%d;%dH",
	       posr[cr], posc[cc], posr[cr], posc[cc]);
      }

}

void save(short *flag, short *foo, short n, short n1, short p, short l, 
          short s, short m[MAXR][MAXC], BYTE *hbuf)

{
  register short c;

  if (*flag) {
    printf("\033[s\033[1;10HIs it supposed to make the changes permanent? ");
    c = getch();
    putchar(c);
    if (toupper(c) == 'Y') {
      pack(p, l, s, m, hbuf + (n - n1)*PSZ);
      *foo = 1;
      printf("\033[u");
      mess();
    }
    else
      printf("\033[u");
    *flag = 0;
  }
}

void backup(char *fn, FILE *fd, BYTE header[], short n1, short n2, BYTE **off)

{
  short c, z;
  char *f;

  if ((fd = fopen(fn, "wb")) == NULL) {
    fprintf(stderr,
      "LX couldn't reopen for writing the file \"%s\".\n", fn);
    exit(73);
  }
  fseek(fd, 0L, SEEK_SET);
  if (fwrite(header, 1, HSZ, fd) != HSZ) {
    fprintf(stderr, "Can't rewrite the file header\n");
    exit(54);
  }
  for (c = n1; c <= n2; c++) {
    f = off[c - n1];
    z = f[1]*3 + 3;
    if (fwrite(f, 1, z, fd) != (size_t)z) {
      fprintf(stderr, "Can't rewrite the character patterns\n");
      exit(55);
    }
  }
  fclose(fd);
  printf("\033[s\033[4;60HThe file has been");
  printf("\033[5;60Hrewritten!\a\033[u");
}

void mess()

{
  printf("\033[s\033[4;60HThe pattern has");
  printf("\033[5;60Hbeen saved!\a\033[u");
}
