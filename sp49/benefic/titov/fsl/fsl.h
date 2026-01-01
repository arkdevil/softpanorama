#define space     ' '
#define leftpar   '('
#define rightpar  ')'
#define alfa      0x00
#define digit     0xFF
#define plus      '+'
#define minus     '-'
#define quote     0x01
#define YES       1
#define NO        0
#define maxinstrlen 255
#define maxnamel    33
#define maxvaluel   33
#define maxstringl  65
#define errsign   '^'
#define eoflex    0x02
#define eolnchr   10
#define eofchr    -1
#define tabchr    9
#define dot       '.'
#define Shor      81
#define Sver      26
#define MaxInt    32000
#define filler    ' '

#define objtype enum d3
typedef objtype {listT,stringT,intT,floatT,functT,extrnT,varT};
typedef void (*fsubr)();

#define object struct d6
object
{
 char *string;
 objtype typ;
 union
  {
    void    *first;
    char    *string;
    int     *intv;
    float   *floatv;
    fsubr functv;
    void    *voidv;
  } contents;
 object *next;
};

#define element struct d0
element
{
  object *car;
  element *cdr;
};

#define sprit struct d2
sprit
{
 int x;      /* absXY sprite coordinates in layer */
 int y;
 int index;  /* Sprite index */
 sprit *next;
};

#define layer struct d1
layer
{
 int z;     /* absZ of this layer */
 int FirstTry;
 sprit *sprites;
 layer *next;
};
