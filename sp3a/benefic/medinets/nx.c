#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <stdlib.h>

#define MAXR 8                          /* matrix rows */
#define MAXC 11                         /* matrix columns */
#define H1   3                          /* 1st down-loaded code position */
#define H2   4                          /* 2nd ditto                     */
#define HSZ  5                          /* header size */
#define PSZ  12                         /* character info block size */

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

typedef unsigned char BYTE;

void mess(void);
void backup(FILE *, BYTE *, BYTE *, short);
void save(short *, short *, short, short, short, 
	  short, short, short [MAXR][MAXC], BYTE *);
void draw(short, short, short, short, short [MAXR][MAXC],
	  short *, short *, short *);
void unpack(BYTE *, short *, short *, short *, short [MAXR][MAXC]);
void pack(short, short, short, short [MAXR][MAXC], BYTE *);
void bars(short), pins(short), zero(short), barl(short, short);

static short posr[MAXR] = {
  7, 9, 11, 13, 15, 17, 19, 21
};
static short posc[MAXC] = {
  14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34
};

static short posp[] = {
  1, 3
};

static BYTE header[HSZ] = {
  '\033', '&', '\0', '\200', '\200'   /* start downloading */
};

void main(int argc, char **argv)

{
  FILE *fd;
  register short cc, cr;
  short c, m[MAXR][MAXC], mr, mc, z, p, l, s, n1, n2, hbufl, n, flag = 0;
  short foo = 0;
  char *y;
  BYTE buf[PSZ], *hbuf, *hb;

  if (argc < 2) {
    fprintf(stderr, "NX expected a file name at least.\n");
    exit(1);
  }
  if (argc > 2) {
    fprintf(stderr, "NX didn't expect so many parameters.\n");
    exit(2);
  }
  if ((fd = fopen(*++argv, "r+b")) == NULL) {
    fprintf(stderr, "NX couldn't find the file \"%s\".\n", *argv);
    fprintf(stderr, "Create new one? ");
    c = getch();
    if (toupper(c) == 'Y') {
      if ((fd = fopen(*argv, "w+b")) == NULL) {
	fprintf(stderr, "NX couldn't open the file \"%s\".\n", *argv);
	exit(33);
      }
      do
	fprintf(stderr, "Enter range limits: ");
      while (scanf("%d%d", &n1, &n2) != 2);
      header[H1] = (BYTE)(n1 & 0xff);
      header[H2] = (BYTE)(n2 & 0xff);
      if (fwrite(header, 1, HSZ, fd) != HSZ) {
	fprintf(stderr, "Couldn't write the file header\n");
	exit(34);
      }
      for (cr = 0; cr < MAXR; cr++)
	for (cc = 0; cc < MAXC; cc++)
	  m[cr][cc] = 0;
      p = 1;
      l = 1;
      s = 10;
      pack(p, l, s, m, buf);
      for (c = n1; c <= n2; c++)
	if (fwrite(buf, 1, PSZ, fd) != PSZ) {
	  fprintf(stderr, "Couldn't write the %dth char pattern\n", c);
	  exit(35);
	}
      fseek(fd, 0L, SEEK_SET);
    }
    else
      exit(3);
  }
  if (fread(header, 1, HSZ, fd) != HSZ) {
    fprintf(stderr, "Couldn't read the file header\n");
    exit(44);
  }
  n1 = header[H1];
  n2 = header[H2];
  hbufl = (n2 - n1 + 1)*PSZ;
  if ((hbuf = (char *)malloc(hbufl)) == NULL) {
    fprintf(stderr, "No room for buffer\n");
    exit(45);
  }
  if (fread(hbuf, 1, hbufl, fd) != (size_t)hbufl) {
    fprintf(stderr, "Couldn't read char patterns\n");
    exit(46);
  }
  n = n1;
  unpack(hbuf, &p, &l, &s, m);
  draw(n, p, l, s, m, posr, posc, posp);
  cc = l;
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
	    if (cc > l)
              cc--;
            else
	      cc = s - 1;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case RIGHT:
	    if (cc < (s - 1))
              cc++;
            else
	      cc = l;
            printf("\033[%d;%dH", posr[cr], posc[cc]);
            break;
          case INS:
            if (p) {
              p--;
              pins(posp[p]);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
          case DEL:
            if (!p) {
              p++;
              pins(posp[p]);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
          case PGDN:
	    if (n < n2) {
	      save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	      n++;
	      unpack(hbuf + (n - n1)*PSZ, &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
            break;
          case PGUP:
	    if (n > n1) {
	      save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	      n--;
	      unpack(hbuf + (n - n1)*PSZ, &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
	    break;
	  case HOME:
	    if (n > n1) {
	      save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	      n = n1;
	      unpack(hbuf + (n - n1)*PSZ, &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
	    break;
	  case END:
	    if (n < n2) {
	      save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	      n = n2;
	      unpack(hbuf + (n - n1)*PSZ, &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
	    break;
	  case F3:
	    foo = 0;
	    backup(fd, header, hbuf, hbufl);
	    break;
          case F5:
	    flag = 0;
	    pack(p, l, s, m, hbuf + (n - n1)*PSZ);
	    mess();
	    foo = 1;
            break;
	  case F6:
	    save(&flag, &foo, n, n1, p, l, s, m, hbuf);
	    printf("\033[s\033[1;10HEnter character ");
	    putchar(c = getch());
	    printf("\033[u");
	    if ((c >= n1) && (c <= n2)) {
	      n = c;
	      unpack(hbuf + (n - n1)*PSZ, &p, &l, &s, m);
	      draw(n, p, l, s, m, posr, posc, posp);
	      cc = l;
	      cr = 0;
	      printf("\033[%d;%dH", posr[cr], posc[cc]);
	    }
	    break;
          case F7:
            if (l) {
              l--;
              barl(l, s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
          case F8:
            if ((s - l) > 5) {
              l++;
              barl(l, s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
          case F9:
            if ((s - l) > 5) {
              s--;
              barl(l, s);
              bars(s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
          case F10:
            if (s < 11) {
              s++;
              barl(l, s);
              bars(s);
              printf("\033[%d;%dH", posr[cr], posc[cc]);
	      flag = 1;
            }
            break;
        }
        break;
      case '`':
      case CR:
      case SP:                          /* space bar */
        if (cc)
          z = m[cr][cc - 1];
        else
          z = 0;
        if (cc < mc)
          z += m[cr][cc + 1];
        if (!z) {
          m[cr][cc] ^= 0x01;
          if (m[cr][cc])
            y = "▒▒▒";
          else if (cc & 1)
            y = " │ ";
          else
            y = "   ";
          printf("\033[%d;%dH%s\033[%d;%dH",
                 posr[cr], posc[cc] - 1, y, posr[cr], posc[cc]);
	  flag = 1;
        }
        else
          putchar('\a');
      case ESC:                         /* esc */
        break;
      default:
	if ((c >= n1) && (c <= n2)) {
	  unpack(hbuf + (c - n1)*PSZ, &p, &l, &s, m);
	  draw(n, p, l, s, m, posr, posc, posp);
	  cc = l;
	  cr = 0;
	  printf("\033[%d;%dH", posr[cr], posc[cc]);
	  flag = 1;
	}
    }
  } while (c != ESC);
  if (foo || flag) {
    printf("\033[s\033[1;10HDidn't you forget to save the file? ");
    c = getch();
    putchar(c);
    if (toupper(c) == 'Y') {
      if (flag)
	pack(p, l, s, m, hbuf + (n - n1)*PSZ);
      backup(fd, header, hbuf, hbufl);
    }
  }
  exit(0);
}

void pins(short pos)

{
  printf("\033[%d;43H       ", pos);
  printf("\033[1B\033[7D       ");
  printf("\033[1B\033[7D       ");
  printf("\033[1B\033[7D┌───┐  ");
  printf("\033[1B\033[7D│ ■ │ 9");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 8");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 7");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 6");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 5");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 4");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 3");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 2");
  printf("\033[1B\033[7D├───┤  ");
  printf("\033[1B\033[7D│ ■ │ 1");
  printf("\033[1B\033[7D└───┘  ");
  printf("\033[1B\033[7D       ");
  printf("\033[1B\033[7D       ");
  printf("\033[1B\033[7D       ");
}

void zero(short n)

{
  printf("\033[2J");
  printf("\033[03;10H  `%c' %3d(dec) %02x(hex)", n, n, n);
  printf("\033[05;10H    1 2 3 4 5 6 7 8 9 A B    ");
  printf("\033[06;10H  ┌───┬───┬───┬───┬───┬───┐  ");
  printf("\033[07;10H  │   │   │   │   │   │   │ 7");
  printf("\033[08;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[09;10H  │   │   │   │   │   │   │ 6");
  printf("\033[10;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[11;10H  │   │   │   │   │   │   │ 5");
  printf("\033[12;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[13;10H  │   │   │   │   │   │   │ 4");
  printf("\033[14;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[15;10H  │   │   │   │   │   │   │ 3");
  printf("\033[16;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[17;10H  │   │   │   │   │   │   │ 2");
  printf("\033[18;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[19;10H  │   │   │   │   │   │   │ 1");
  printf("\033[20;10H  ├───┼───┼───┼───┼───┼───┤  ");
  printf("\033[21;10H  │   │   │   │   │   │   │ 0");
  printf("\033[22;10H  └───┴───┴───┴───┴───┴───┘  ");
}

void barl(short val, short foo)

{
  register short c, v;

  printf("\033[23;9H%2d   ", val);
  v = val << 1;
  for (c = 0; c < v; c++)
    printf(" ");
  v = ((foo - val) << 1) - 1;
  for (c = 0; c < v; c++)
    printf("▀");
  printf("  ");
}

void bars(short val)

{
  register short c, v;

  printf("\033[24;9H%2d   ", val);
  v = (val << 1) - 1;
  for (c = 0; c < v; c++)
    printf("▀");
  printf("  ");
}

void pack(short p, short l, short s, short m[MAXR][MAXC], BYTE buf[])

{
  register short c, r;
  BYTE pat, k;

  buf[0] = (BYTE)(((p & 0x01) << 7) | ((l & 0x07) << 4) | (s & 0x0f));
  for (c = 0; c < MAXC; c++) {
    pat = 0x80;
    k = 0;
    for (r = 0; r < MAXR; r++) {
      if (m[r][c])
        k |= pat;
      pat >>= 1;
    }
    buf[c + 1] = k;
  }
}

void unpack(BYTE buf[], short *p, short *l, short *s, short m[MAXR][MAXC])

{
  register short c, r;
  BYTE pat, k;

  *p = (buf[0] >> 7) & 0x01;
  *l = (buf[0] >> 4) & 0x07;
  *s = buf[0] & 0x0f;
  for (c = 0; c < MAXC; c++) {
    pat = 0x80;
    k = buf[c + 1];
    for (r = 0; r < MAXR; r++) {
      if (k & pat)
	m[r][c] = 1;
      else
	m[r][c] = 0;
      pat >>= 1;
    }
  }
}

void draw(short n, short p, short l, short s, short m[MAXR][MAXC], 
          short posr[], short posc[], short posp[])

{
  register short cc, cr;
  void pins(), zero(), barl(), bars();

  zero(n);
  pins(posp[p]);
  barl(l, s);
  bars(s);
  for (cr = 0; cr < MAXR; cr++)
    for (cc = 0; cc < MAXC; cc++)
      if (m[cr][cc])
	printf("\033[%d;%dH▒▒▒\033[%d;%dH",
	       posr[cr], posc[cc] - 1, posr[cr], posc[cc]);

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

void backup(FILE *fd, BYTE header[], BYTE hbuf[], short hbufl)

{
  fseek(fd, 0L, SEEK_SET);
  if (fwrite(header, 1, HSZ, fd) != HSZ) {
    fprintf(stderr, "Couldn't rewrite the file header\n");
    exit(54);
  }
  if (fwrite(hbuf, 1, hbufl, fd) != (size_t)hbufl) {
    fprintf(stderr, "Couldn't rewrite the character patterns\n");
    exit(55);
  }
  printf("\033[s\033[2;10HThe file has been rewritten!\a\033[u");
}

void mess()

{
  printf("\033[s\033[2;10HThe pattern has been saved!\a\033[u");
}
