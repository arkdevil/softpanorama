/*
 * Created by YACC from "awkyacc.y"
 */
/*
 * Awk syntactical analyser and pseudo code generator
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */
#include <stddef.h>
#include <alloc.h>
#include <mem.h>

#include "awk.h"
#include "awklex.h"
#include "awkyacc.h"
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval;
YYSTYPE yyval;
#define YYERRCODE 256

int     yydone;
int     yyl1, yyl2, yyl3;
LIST    *yydisplay;

static int toploop(int);
static int getloop(int);
static int poplabel(void);

static void popstack(int);
static void pushstack(int);
static void pushlabel(int, int);

static void enroll(void*, void*);

static void *newfunction(void);
static void *newelement(void*, void*);

IDENT *lookfor(ITEM *sp)
{
    IDENT *vp;

    for (vp = ident; vp != NULL; vp = vp->vnext)
        if (vp->vitem == sp)
            return vp;
    return NULL;
}

static void enroll(rule, action)
void *rule;
void *action;
{
    if (rulep == NULL) {
        rulep = rule;
        rules = rulep;
    }
    else {
        rulep->next = rule;
        rulep = rule;
    }
    rulep->next = NULL;
    rulep->action = action;
}

static void*
newelement(next, item)
void *next;
void *item;
{
    LIST    *lp;

    lp = yyalloc(sizeof(LIST));
    lp->litem = item;
    lp->lnext = next;
    return lp;
}

static void*
newfunction()
{
    int     size;
    FUNC    *fp;
    LIST    *lp;

    size = 0;
    lp = yydisplay;
    while (lp != NULL) {
        size++;
        lp = lp->lnext;
    }
    fp = yyalloc(sizeof(FUNC));
    fp->psize = size;
    fp->plist = yydisplay;
    fp->pcode = NULL;
    return fp;
}

static void
pushstack(kind)
{
    if (stackptr <= stackbot)
        yyerror("Stack overflow");
    stackptr--;
    stackptr->sclass = kind;
    stackptr->svalue.ival = 0;
    if (kind == L_MARK || kind == L_DONE) {
        stackptr->stype = yydone;
        stackptr->svalue.sptr = stacktop;
        stacktop = stackptr;
        yydone = 0;
    }
}

static void popstack(kind)
{
    int     i, j, class;

    while (stackptr < stacktop) {
        class = stackptr->sclass;
        if ( class == L_FOR || class == L_WHILE) {
            stackptr++;
            i = poplabel();
            j = poplabel();
            genjump(C_JUMP, i);
            genlabel(j);
            putlabel(i);
            putlabel(j);
        }
        else if (class == L_ELSE) {
            i = poplabel();
            genlabel(i);
            putlabel(i);
        }
        else
            yyerror("dangling label");
        if (class == kind)
            return;
    }
    if (kind == L_MARK || kind == L_DONE) {
        yydone = stackptr->stype;
        stacktop = stackptr->svalue.sptr;
        stackptr++;
    }
    else
        yyerror("syntax error");
}

static int toploop(int class)
{
    ITEM    *sp;
    int     label;

    sp = stackptr;
    while (sp < stackbot + MAXSTACK)
        if (sp->sclass == class) {
            label = sp->svalue.ival;
#ifdef LDEBUG
    printlabel("top", label);
#endif
            return label;
        }
        else
            sp++;
    return(-1);
}

static int getloop(class)
{
    while (stackptr < stacktop) {
        if (stackptr->sclass == class)
            return poplabel();
        else
            popstack(stackptr->sclass);
    }
    return(-1);
}

static void
pushlabel(class, label)
{
#ifdef LDEBUG
    printlabel("pop", label);
#endif
    if (stackptr <= stackbot)
        yyerror("Stack overflow");
    stackptr--;
    stackptr->sclass = class;
    stackptr->svalue.ival = label;
}

static int
poplabel()
{
    int     label;

    label = stackptr->svalue.ival;
#ifdef LDEBUG
    printlabel("pop", label);
#endif
    stackptr++;
    return label;
}

short yyexca[] ={
-1, 1,
    0, -1,
    -2, 0,
-1, 69,
    63, 126,
    44, 126,
    -2, 30,

};
#define YYNPROD 195
#define YYLAST 1104
short yyact[]={

 114, 240, 199, 346, 141, 198, 194, 280,  89, 110,
 248, 141,  89, 113, 251,  22,  65,  72,  89,  89,
 244, 321, 245, 252, 211,  71, 144,  59, 210,  56,
  58, 137,  46, 249, 272,  21, 142,  77, 245, 179,
  51, 232,  48, 111, 165,  48, 193, 245,  44,  11,
  48, 112,  70, 314, 107,   9, 101,  45,  56, 206,
  12,  87, 136, 258,  44,  56, 104, 293, 133, 134,
  23,  20, 102, 146, 354,  24,  10,  28, 102, 281,
 136, 342, 301,   8,   2,  80, 341,  81,  56,  56,
 372, 161,  63, 163, 164, 167, 168, 169, 170, 171,
 161, 311, 365, 307,  56, 161,  56, 327, 271, 363,
 150, 151, 152,  84, 227, 349, 180, 238,  82, 348,
 347,  25, 103,  83, 189, 336, 317, 305, 185, 145,
  56, 207, 105,  65,  17, 316,  62, 310, 135, 109,
 212, 309, 213, 297, 148, 148,  56, 149,  85,  86,
 304, 153, 154, 215, 216, 298, 282, 173, 155, 156,
 157, 201, 201, 276, 229, 218,  77,  77,  77, 283,
 217, 226,  56, 203,  56, 223, 138, 140,  56,  56,
 174, 162, 236, 204, 235, 190, 205,  14, 241,  73,
  44, 207,  65, 187,  15, 183, 108,  27,  99,  26,
  62,  19,  98,  65,  97, 257,  96, 147, 147, 158,
  95,  94,  93,  92,  91, 262,  90,  77,  66,  30,
 265, 266, 261, 167, 256, 269, 270, 264, 228, 166,
 181, 263,  47,  30, 234, 328, 214, 277, 340, 279,
  30,  49, 273, 325,  49,  30,  30, 274,  88,  49,
 242, 278, 324, 246, 286, 288, 141, 321, 259, 161,
 290, 291, 100,  30,  89, 250,  30, 268, 143, 246,
 260, 356,  13, 289,  30, 376, 366,   9, 246, 267,
 371, 364,  58, 201, 201,  58, 315,  60,  65, 295,
 295,  30,  30,  30,  30,  30, 323,  30,  46,  30,
  30,  30,  30,  30, 320,  78,  30, 330,  44, 331,
 292,  77,  79, 332,  46,  27, 302,  26, 326, 300,
 339,  30, 296, 284, 285, 201, 335, 333, 344, 345,
 343, 360,  75, 370,  76, 353, 188, 337, 318, 319,
  78, 358, 186,  44, 195, 195, 352, 132, 350, 237,
  27, 351,  26, 184, 241, 359, 334, 166, 275, 182,
 201, 201, 233, 361, 313, 357, 338, 369, 231,  30,
  30,  30, 362, 367,   7, 368,  57, 209, 208,  52,
  53,  54, 375, 176, 373, 374,   1, 178, 294, 294,
 377, 177, 201,   6, 106,  50, 192,  78, 355, 159,
  44, 200,  18,  68, 132, 197, 239,  27, 196,  26,
  67,   0,   0,   4,   5,   0,   0,   0,   0,   0,
  30,  64,   0,   3,   0,   0,   0,  30,  30,  40,
   0,   0,  38,  39,   0,  41,  42,  43,  37,  33,
  46,  32,  31,  34,  35,  36,   0,  78,   0,   0,
  44,   0,   0,   0,  79,   0,  29,  27,   0,  26,
   0,   0,   0,   0,  30,  30, 195, 195,   0,   0,
   0,   0,  30,  30,   0, 131,  16,   0,  78,   0,
   0,  44,  30,  30,   0,  79,   0, 115,  27,   0,
  26,  69,  19,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  78,   0,   0,  44,   0, 195,   0,
 132,   0, 160,  27,  30,  26,   0,  19,   0,   0,
   0, 172,   0,  16,   0, 329, 175,   0,   0,  78,
   0,  16,  44,   0,   0,   0, 132,  69,   0,  27,
 253,  26,   0,  30,  30,   0,   0,  40,   0,   0,
  38,  39,   0,  41,  42,  43,  37,  33,  46,  32,
  31,  34,  35,  36,   0,   0,  14,   0,   0,  44,
   0,  74,   0,  15,  29, 195,  27,   0,  26,   0,
  19,   0,  40,   0,   0,  38,  39,   0,  41,  42,
  43,  37,  33,  46,  32,  31,  34,  35,  36,   0,
  78,   0,   0,  44,   0,   0,   0, 287,   0,  29,
  27,   0,  26, 243,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0, 255, 116,   0, 120, 118, 119,
 117, 121, 122,   0, 123, 129, 130, 125, 126,  40,
 124, 127,  38,  39, 128,  41,  42,  43,  37,  33,
  46,  32,  31,  34,  35,  36,   0,  78,   0,   0,
  44,   0,   0,   0,  79,   0,  29,  27,   0,  26,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
 299,   0,  44,   0,  16,  16,  79,   0,   0,  40,
   0,   0,  38,  39,   0,  41,  42,  43,  37,  33,
  46,  32,  31,  34,  35,  36,   0,  78,   0, 322,
  44,   0, 254,   0, 202,   0,  29,  27,   0,  26,
  40,   0,   0,  38,  39,   0,  41,  42,  43,  37,
  33,  46,  32,  31,  34,  35,  36,   0,   0,  44,
 303,   0,   0,  61,   0,  40,   0,  29,  38,  39,
  19,  41,  42,  43,  37,  33,  46,  32,  31,  34,
  35,  36,   0,   0,   0,   0,   0,   0,   0,   0,
   0,  40,  29,   0,  38,  39,   0,  41,  42,  43,
  37,  33,  46,  32,  31,  34,  35,  36,   0,  78,
   0,   0,  44,   0,   0,   0, 191,   0,  29,  27,
   0,  26,   0,   0,   0,   0,   0,   0,  40,   0,
   0,  38,  39,   0,  41,  42,  43,  37,  33,  46,
  32,  31,  34,  35,  36,   0,   0,   0,   0,   0,
   0,   0, 139,   0,   0,  29,   0,   0,   0,   0,
   0,  55,  40,   0,   0,  38,  39,   0,  41,  42,
  43,  37,  33,  46,  32,  31,  34,  35,  36,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  29,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  40,
   0,   0,  38,  39,   0,  41,  42,  43,  37,  33,
  46,  32,  31,  34,  35,  36,   0,   0,   0,   0,
   0,  40,   0,   0,  38,  39,  29,  41,  42,  43,
  37,  33,  46,  32,  31,  34,  35,  36,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  29,  40,
   0,   0,  38,  39,   0,  41,  42,  43,  37,  33,
  46,  32,  31,  34,  35,  36,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,  29,   0,  40,   0,
   0,  38,  39,   0,  41,  42,  43,  37,  33,  46,
  32,  31,  34,  35,  36,   0,   0, 219, 220,   0,
   0, 221, 222, 224, 225,  29,   0,   0,   0,   0,
   0, 230,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 247,   0,   0,   0,
   0,  40,   0,   0,  38,  39, 247,  41,  42,  43,
  37,  33,  46,  32,  31,  34,  35,  36,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  29,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0, 306,
 308,   0,   0, 312
};
short yypact[]={

 154, -14,-1000,-245, -68, -68, -68,-1000,  44,-1000,
-265,-269,-1000,-1000, 703, 533,-1000,-1000,-272,-1000,
-109, 272,  42,  76,-1000,-1000, 646, 646, -33,  28,
-294,-1000,-1000, 176, 174, 173, 172, 171, 170, 166,
 164, 162, 158,  12, 646, -25,-1000, 154,-1000,-1000,
 -69, 156,-1000,-1000,-1000, 533,-215, 364,-215,-215,
-1000, 533,-1000, -10, 135, 136,-283,-1000, -27,-1000,
-270,-254, 445, 445, 624, 624, 624,  42, 646, 496,
 624, 624, 624, 624, 624,-1000,-1000, 646,-1000,-1000,
 496, 140, 496, 496, 470, 496, 496, 496, 496, 496,
  18,-1000, 646,-1000, 496,-1000,-1000,-1000,-247,-1000,
-1000,-1000,  -9,-1000,-1000,-1000, 155,-1000,-215,-1000,
 153,-1000,-1000, 496, 145, 756, 674, 143,-254,-1000,
 496,-1000, 496,-1000,-1000, -13, 136,-1000,-273, 496,
-1000, 496,-1000,-215,-215,-1000,-1000,-1000,-1000,-1000,
 624, 624, 624,  76,  76,-1000,-1000,-1000,-1000, 129,
  44,-1000,-1000, 124,  44,  44,-1000,-1000,  44,  44,
 134,  44, 130,-1000,-1000,  21, 364, 123,  44,-1000,
-1000,-221, 364, 496, 142,-1000,  77, 496,-1000,-1000,
 496, 496, -24,  44,-1000,-284,-1000, -30,-282,-1000,
-274, 414, 496, -15, 496, -28,-1000,-1000, 533, 533,
-1000,-1000,-1000,-1000, 496,-1000,-1000,-1000,-1000, 496,
 496,-254, 470,-1000, 496, 496,-1000,-1000, -17,-1000,
-252,-1000,-215, 364, -14, 122, 496, 364, 496,-290,
  20,-1000, 115, 128,-1000, 646, 646, 567, 567,-1000,
-215,-215,-254, 445, 445, 102,-1000, 114, 496,-269,
-1000,-254,  24, 496, 496, 109,  86,  62, 100,  96,
  60,-1000,-1000,-1000,-1000, -72,-215,  94,-1000,  85,
-254,-1000,-1000, -40,-1000,-1000,-1000, 496,-1000, 567,
-1000,-1000,-1000,-1000,-1000, 624,-1000, -40,-1000,  14,
-1000,-1000,-270,-1000,-1000,-1000, 496,-1000, 496,-1000,
-1000,-1000, 496, 364,-1000,-1000,-215,-1000,  84, 307,
-1000,-1000,  45,  23, 567, 567,-1000,-1000, 496, -38,
  79,  78,  74,-1000, 364,-1000,-215,-1000,-1000,  15,
-254,-276,-1000,-282,-1000,-1000,-1000,-1000,-1000,-1000,
-1000, 364,-1000, 496,-1000,-1000, 567,-1000, 364,  68,
  61,-1000,-1000,-215,-1000,-215, 496,-1000,-1000,  49,
 364, 364,-215,-1000,-1000,-1000, 364,-1000
};
short yypgo[]={

   0,  60,  76,  49,   0,   6, 410, 408, 405, 403,
  52,   5, 475,   2, 402, 401,  73,  71,  67,  35,
  15,  70,  75, 121,  77, 399,  59, 396, 421,  46,
 272, 134, 395, 394, 374, 393,  83, 391, 387, 386,
 230,  84, 832, 383,  51,   9, 378, 377, 376, 368,
  13, 364, 362, 359, 358, 356, 353, 351, 349, 342,
 218,  57, 341,   1, 339, 337, 336,  20, 335, 333,
 331, 281, 280, 276, 275,  56, 273, 271, 252, 243,
 238, 236, 235, 231, 227, 222,  44
};
short yyr1[]={

       0,  39,  39,  41,  41,  41,  41,  41,  41,  41,
      32,  37,  37,  38,  38,  43,  33,  35,  35,  36,
       2,  46,   2,   3,  47,   3,   1,   1,   1,   1,
       1,  30,  48,  34,  44,  44,  51,  49,  52,  49,
      50,  53,  54,  50,  55,  50,  56,  57,  50,  58,
      50,  59,  50,  62,  50,  64,  50,  50,  50,  50,
      50,  50,  50,  50,  50,  50,  50,  50,  50,  50,
      26,  26,  68,  69,  65,  70,  65,  72,  71,  73,
      74,  71,  63,  63,  27,  27,  66,  66,  67,  67,
      67,  75,  75,  31,   5,   5,   7,  76,  77,   7,
       8,  78,   8,  11,  79,  11,  80,  13,  13,  13,
      15,  15,  15,  18,  18,  29,  29,   4,   4,   6,
      81,  82,   6,   9,  83,   9,  10,  84,  10,  85,
      12,  12,  12,  14,  14,  14,  17,  17,  17,  17,
      19,  19,  20,  20,  20,  21,  21,  21,  21,  22,
      22,  22,  22,  23,  23,  24,  24,  24,  24,  24,
      24,  24,  24,  24,  24,  24,  24,  24,  24,  24,
      24,  24,  24,  24,  24,  24,  24,  24,  16,  16,
      86,  86,  28,  28,  25,  25,  60,  60,  60,  61,
      42,  40,  40,  45,  45
};
short yyr2[]={

       0,   3,   1,   3,   2,   2,   2,   1,   1,   0,
       4,   1,   0,   3,   1,   0,   4,   3,   1,   1,
       1,   0,   5,   1,   0,   5,   1,   2,   3,   4,
       1,   1,   0,   4,   3,   1,   0,   4,   0,   2,
       1,   0,   0,   5,   0,   7,   0,   0,   8,   0,
       4,   0,   5,   0,   9,   0,   6,   1,   1,   2,
       4,   5,   3,   5,   3,   4,   5,   1,   2,   0,
       1,   0,   0,   0,   7,   0,   4,   0,   4,   0,
       0,   6,   1,   0,   1,   0,   1,   0,   2,   2,
       0,   2,   0,   1,   3,   1,   1,   0,   0,   7,
       1,   0,   5,   1,   0,   5,   0,   6,   3,   1,
       1,   3,   3,   1,   1,   3,   1,   3,   1,   1,
       0,   0,   7,   1,   0,   5,   1,   0,   5,   0,
       6,   3,   1,   1,   3,   3,   1,   3,   3,   3,
       1,   2,   1,   3,   3,   1,   3,   3,   3,   1,
       2,   2,   2,   1,   3,   2,   2,   1,   3,   1,
       1,   4,   3,   4,   6,   6,   8,   8,   6,   8,
       6,   4,   6,   6,   8,   4,   3,   2,   1,   1,
       1,   1,   3,   1,   1,   0,   2,   4,   1,   1,
       2,   1,   1,   1,   0
};
short yychk[]={

    -1000, -39, -41, 269, 259, 260, -35, -34, -36, 123,
      -2,  -3,  -1, -30,  33,  40, -12, -31, -14,  47,
     -17, -19, -20, -21, -22, -23,  45,  43, -24, 302,
     -60, 288, 287, 285, 289, 290, 291, 284, 278, 279,
     275, 281, 282, 283,  36, -61, 286, -40,  59, 258,
     -32, 285, -34, -34, -34, -42,  44, -48, 295, 296,
     -30,  40, -23,  -2, -28,  -4, -60,  -6,  -9, -12,
     -10, 297, 126, 298, 299,  60,  62, -20,  33,  40,
      43,  45,  42,  47,  37, -23, -23,  94, -60, 302,
      40,  40,  40,  40,  40,  40,  40,  40,  40,  40,
     -60, -75,  60, -24,  91, -41, -33, 123,  40, -36,
     -45, 258, -44, -50,  -4, 123, 261, 266, 264, 265,
     263, 267, 268, 270, 276, 273, 274, 277, 280, 271,
     272, -12,  40, -45, -45,  -2,  -4,  41,  41, -42,
      41, 294,  63, 295, 296, -61, -16, -31, -17, -16,
     -19, -19, -19, -21, -21, -22, -22, -22, -23, -25,
     -28,  -4,  41,  -4,  -4, -86, -31,  -4,  -4,  -4,
      -4,  -4, -28, -75, -24, -28, -43, -37, -38, 286,
     125, -40, -53,  40, -56, -45, -59,  40, -66,  -4,
      40,  40, -27, -29,  -5, -60,  -7,  -8, -11, -13,
     -15, -19,  40, -29,  40, -61, -26,  -4, -46, -47,
      41, 297,  -4,  -4, -81, -45, -45,  41,  41, -42,
     -42, -42, -42,  41, -42, -42,  41,  93, -44,  41,
     -42, -49, 262, -52, -44,  -4,  40, -58,  40, -60,
     -63,  -4, -26, -28, -67,  62, 293, -42, 294,  63,
     295, 296, 297, 126, 298, -28, -67,  -4,  91,  -3,
      -1, -85,  -4, -83, -84,  -4,  -4, -61, -86,  -4,
      -4, 125, 286, -45, -50, -54,  41,  -4, -50,  -4,
     297,  59,  41,  41, -24, -24,  -5,  40,  -5, -76,
     -45, -45, -61, -18, -31, -19, -18,  41,  41, -28,
     -61,  58, -10, -12,  41,  41, -42,  41, -42,  41,
      41,  41, -42, -51, 125, -45,  41,  41, -61, -64,
     -67, 297, -28,  -5, -78, -79, -67,  93, -82, -60,
      -4,  -4,  -4, -50, -55, -45,  41, -65,  59,  -4,
     -80,  41,  58, -11, -13,  -4,  41,  41,  41,  41,
     -50, -57, -45, -68,  59, -61, -77, -50, -62, -63,
     -70,  -5, -50,  41, -71,  41, -73, -45, -45,  -4,
     -69, -72,  41, -50, -50, -45, -74, -50
};
short yydef[]={

       9,  -2,   2,   0,   0,   0,   7,   8,  18,  32,
      19,  20,  23,  26,   0,   0,  30,  31, 132,  93,
     133, 136, 140, 142, 145, 149,   0,   0, 153,   0,
     157, 159, 160,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,  92,   0, 188, 189,   9, 191, 192,
       0,   0,   4,   5,   6,   0, 194,  69, 194, 194,
      27,   0, 150,   0,   0, 183, 157, 118, 119,  -2,
     123,   0,   0,   0,   0,   0,   0, 141,   0,   0,
       0,   0,   0,   0,   0, 151, 152,   0, 155, 156,
     185,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      92, 177,   0, 186,   0,   1,   3,  15,  12,  17,
     190, 193,   0,  35,  40,  41,   0,  46, 194,  51,
       0,  57,  58,  87,   0,  85,   0,   0,   0,  67,
      71, 126,   0,  21,  24,   0,   0,  28,   0,   0,
     158,   0, 120, 194, 194, 131, 134, 178, 179, 135,
     137, 138, 139, 143, 144, 146, 147, 148, 154,   0,
     184, 183, 162,   0,   0,   0, 180, 181,   0,   0,
       0,   0,   0, 176,  91,   0,  69,   0,  11,  14,
      33,  38,  69,   0,   0,  49,   0,  83,  59,  86,
      71,   0,  90,  84, 116, 157,  95,  96, 100, 103,
     109, 110,   0,  90,   0,   0,  68,  70,   0,   0,
      29, 129, 182, 117,   0, 124, 127, 161, 163,   0,
       0,   0,   0, 171,   0,   0, 175, 187,   0,  10,
       0,  34, 194,  69,  42,   0,   0,  69,   0, 157,
       0,  82,   0,   0,  62,   0,   0,   0,   0,  97,
     194, 194,   0,   0,   0,   0,  64,   0,   0,  22,
      25,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,  16,  13,  36,  39,   0, 194,   0,  50,   0,
       0,  55,  60,  90,  88,  89, 115,   0,  94,   0,
     101, 104, 108, 111, 113, 114, 112,  90,  65,   0,
     130, 121, 125, 128, 164, 165,   0, 168,   0, 170,
     172, 173,   0,  69,  43,  44, 194,  52,   0,   0,
      61, 106,   0,   0,   0,   0,  63,  66,   0, 157,
       0,   0,   0,  37,  69,  47, 194,  56,  72,   0,
       0,   0,  98, 102, 105, 122, 166, 167, 169, 174,
      45,  69,  53,  83,  75, 107,   0,  48,  69,   0,
      79,  99,  54, 194,  76, 194,   0,  73,  77,   0,
      69,  69, 194,  74,  78,  80,  69,  81
};
/*
 * yyparse.c --  parser for yacc output
 */

#define YYFLAG -1000
#define YYABORT return(1)
#define YYACCEPT return(0)
#define YYERROR goto yyerrlab

int     yychar = -1;    /* current input token number */
int     yydebug = 0;    /* 1 for debugging */
int     yynerrs = 0;    /* number of errors */
short   yyerrflag = 0;  /* error recovery flag */
short   yys[YYMAXDEPTH];/* where the stack is stored */
YYSTYPE yyv[YYMAXDEPTH];/* where the values are stored */

#ifndef YYLOG
#define YYLOG stderr
#endif

yyparse()
{
    short   yyj;
    short   yym;
    short   *yyps;
    short   *yyxi;
    YYSTYPE *yypv;
    YYSTYPE *yypvt;
    short   yystate;
    register short  yyn;

    extern int yylex(void);
    extern void yyerror(char*);

    yystate = 0;
    yychar = -1;
    yynerrs = 0;
    yyerrflag = 0;
    yyps= &yys[-1];
    yypv= &yyv[-1];

yystack:    /* put a state and value onto the stack */
#ifdef YYDEBUG
    if (yydebug)
        fprintf(YYLOG, "state %d, char 0%o\n", yystate, yychar );
#endif
    if (++yyps> &yys[YYMAXDEPTH]) {
        yyerror("yacc stack overflow");
        goto yyabort;
    }
    *yyps = yystate;
    ++yypv;
#ifdef UNION
    yyunion(yypv, &yyval);
#else
    *yypv = yyval;
#endif
yynewstate:
    yyn = yypact[yystate];
    if (yyn <= YYFLAG)
        goto yydefault; /* simple state */
    if (yychar < 0)
        if ((yychar=yylex())<0)
            yychar=0;
    if ((yyn += yychar)<0 || yyn >= YYLAST)
        goto yydefault;
    if (yychk[yyn=yyact[yyn]] == yychar) {
        yychar = -1;
#ifdef UNION
        yyunion(&yyval, &yylval);
#else
        yyval = yylval;
#endif
        yystate = yyn;
        if (yyerrflag > 0)
            --yyerrflag;
        goto yystack;
    }
/* 
 *default state action
 */
yydefault:
    if ((yyn=yydef[yystate]) == -2) {
        if (yychar<0) if ((yychar = yylex())<0) yychar = 0;
/*
 * look through exception table
 */
        for (yyxi=yyexca; (*yyxi != (-1)) || (yyxi[1] != yystate) ; yyxi += 2)
            ;
        for (yyxi += 2; *yyxi >= 0; yyxi += 2)
            if (*yyxi == yychar)
                break;
        if ((yyn = yyxi[1]) < 0)
            return(0);   /* accept */
    }
    if (yyn == 0) {
/* error ... attempt to resume parsing */
        switch (yyerrflag) {
        case 0:
            yyerror("syntax error");
yyerrlab:
            ++yynerrs;
        case 1:
        case 2:
            yyerrflag = 3;
            while (yyps >= yys) {
                yyn = yypact[*yyps] + YYERRCODE;
                if (yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE) {
                    yystate = yyact[yyn];
                    goto yystack;
                }
                yyn = yypact[*yyps];
#ifdef YYDEBUG
                if (yydebug)
                    fprintf(YYLOG, "error recovery pops state %d, uncovers %d\n",
                                *yyps, yyps[-1]);
#endif
                --yyps;
                --yypv;
            }
yyabort:
            return(1);
        case 3:
#ifdef YYDEBUG
            if (yydebug)
                fprintf(YYLOG, "error recovery discards char %d\n", yychar );
#endif
            if (yychar == 0)
                goto yyabort; /* don't discard EOF, quit */
            yychar = -1;
            goto yynewstate;   /* try again in the same state */
        }
    }

    /* reduction by production yyn */
    yyps -= yyr2[yyn];
    yypvt = yypv;
    yypv -= yyr2[yyn];
#ifdef UNION
    yyunion(&yyval, &yypv[1]);
#else
    yyval = yypv[1];
#endif
    yym=yyn;
    yyn = yyr1[yyn];
    yyj = yypgo[yyn] + *yyps + 1;
    if (yyj>=YYLAST || yychk[yystate = yyact[yyj]] != -yyn)
        yystate = yyact[yypgo[yyn]];
    switch(yym) {
        
    case 3:{
        yydisplay = NULL;
        yypvt[-1].uptr->pcode = yypvt[-0].vptr;
    } break;
    case 4:{
        if (beginend == NULL)
            beginact = beginend = genact(yypvt[-0].vptr);
        else
            beginend = beginend->cnext = genact(yypvt[-0].vptr);
    } break;
    case 5:{
        if (endend == NULL)
            endact = endend = genact(yypvt[-0].vptr);
        else
            endend = endend->cnext = genact(yypvt[-0].vptr);
    } break;
    case 6:{
        enroll(yypvt[-1].vptr, yypvt[-0].vptr);
    } break;
    case 7:{
        genfield(0);
        lastop(C_PLUCK);
        genfcon(0);
        gencall(P_PRINT, 2);
        genbyte(C_END);
        enroll(yypvt[-0].vptr, gencode());
    } break;
    case 8:{
        enroll(genrule(NULL, NULL), yypvt[-0].vptr);
    } break;
    case 10:{
        yydisplay = yypvt[-1].vptr;
        yyval.uptr = ((IDENT*)(yypvt[-3].vptr))->vfunc = newfunction();
    } break;
    case 11:{
        yyval.vptr = yypvt[-0].vptr;
    } break;
    case 12:{
        yyval.vptr = 0;
    } break;
    case 13:{
        yyval.vptr = newelement(yypvt[-2].vptr, yypvt[-0].vptr);
    } break;
    case 14:{
        yyval.vptr = newelement(NULL, yypvt[-0].vptr);
    } break;
    case 15:{
        pushstack(L_MARK);
    } break;
    case 16:{
        popstack(L_MARK);
        if (stacktop != stackbot + MAXSTACK)
            yyerror("body jump stack");
        if (lastcode() != C_RETURN) {
            genaddr(lookfor(nul));
            genbyte(C_LOAD);
            genbyte(C_RETURN);
        }
        genbyte(C_END);
        yyval.vptr = gencode();
    } break;
    case 17:{
        yyval.vptr = genrule(yypvt[-2].vptr, yypvt[-0].vptr);
    } break;
    case 18:{
        yyval.vptr = genrule(yypvt[-0].vptr, NULL);
    } break;
    case 19:{
        genbyte(C_END);
        yyval.vptr = gencode();
    } break;
    case 21:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } break;
    case 22:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 24:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } break;
    case 25:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 27:{
        genbyte(C_NOT);
        yyval.ival = S_SHORT;
    } break;
    case 28:{
        yyval.ival = yypvt[-1].ival;
    } break;
    case 29:{
        genbyte(C_NOT);
        yyval.ival = S_SHORT;
    } break;
    case 31:{
        genfield(0);
        lastop(C_PLUCK);
        genbyte(C_SWAP);
        genbyte(C_MAT);
        yyval.ival = S_SHORT;
    } break;
    case 32:{
        pushstack(L_MARK);
    } break;
    case 33:{
        popstack(L_MARK);
        if (stacktop != stackbot + MAXSTACK)
            yyerror("action jump stack");
        genbyte(C_END);
        yyval.vptr = gencode();
    } break;
    case 36:{
        yyl1 = toploop(L_ELSE);
        if (yyl1 < 0)
            yyerror("syntax error");
        yyl1 = getloop(L_ELSE);
        pushlabel(L_ELSE, yyl1);
        yyl2 = getlabel();
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        uselabel(yyl1, yyl2);
        putlabel(yyl2);
    } break;
    case 38:{
        while (stackptr->sclass >= L_FOR)
            popstack(stackptr->sclass);
    } break;
    case 40:{
        gendrop();
    } break;
    case 41:{
        pushstack(L_MARK);
    } break;
    case 42:{
        popstack(L_MARK);
    } break;
    case 44:{
        yyl1 = getlabel();
        pushlabel(L_ELSE, yyl1);
        genjump(C_FJMP, yyl1);
    } break;
    case 46:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_WHILE);
        genlabel(yyl2);
    } break;
    case 47:{
        yyl1 = toploop(L_BREAK);
        genjump(C_FJMP, yyl1);
    } break;
    case 49:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        yyl3 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_BREAK, yyl2);
        pushlabel(L_CONTINUE, yyl3);
        pushstack(L_DONE);
        genlabel(yyl1);
        yydone = 1;
    } break;
    case 51:{
        popstack(L_DONE);
        yyl1 = toploop(L_CONTINUE);
        genlabel(yyl1);
        yydone = 0;
    } break;
    case 52:{
        yyl1 = poplabel();
        yyl2 = poplabel();
        yyl3 = poplabel();
        genjump(C_TJMP, yyl3);
        genlabel(yyl2);
        putlabel(yyl1);
        putlabel(yyl2);
        putlabel(yyl3);
    } break;
    case 53:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_FOR);
        genbyte(C_LOAD);
        genlabel(yyl2);
        genjump(C_IJMP, yyl1);
    } break;
    case 55:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_FOR);
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genlabel(yyl1);
    } break;
    case 57:{
        yyl1 = toploop(L_BREAK);
        if (yyl1 < 0) {
            yyerror("invalid break");
            YYERROR;
        }
        genjump(C_JUMP, yyl1);
    } break;
    case 58:{
        yyl1 = toploop(L_CONTINUE);
        if (yyl1 < 0) {
            yyerror("invalid continue");
            YYERROR;
        }
        genjump(C_JUMP, yyl1);
    } break;
    case 59:{
        genbyte(C_RETURN);
    } break;
    case 60:{
        gencall(P_SRAND, yypvt[-1].ival);
    } break;
    case 61:{
        gencall(P_PRINT, yypvt[-2].ival+1);
    } break;
    case 62:{
        gencall(P_PRINT, yypvt[-1].ival+1);
    } break;
    case 63:{
        gencall(P_PRINTF, yypvt[-2].ival+1);
    } break;
    case 64:{
        gencall(P_PRINTF, yypvt[-1].ival+1);
    } break;
    case 65:{
        gencall(P_CLOSE, 1);
    } break;
    case 66:{
        if (yypvt[-1].ival > 1)
            gencall(P_JOIN, yypvt[-1].ival);
        gencall(P_DELETE, 2);
    } break;
    case 67:{
        gencall(P_NEXT, 0);
    } break;
    case 68:{
        gencall(P_EXIT, yypvt[-0].ival);
    } break;
    case 70:{
        yyval.ival = 1;
    } break;
    case 71:{
        yyval.ival = 0;
    } break;
    case 72:{
        yyl1 = toploop(L_NORMAL);
        yyl2 = toploop(L_CONTINUE);
        genjump(C_JUMP, yyl1);
        genlabel(yyl2);
    } break;
    case 73:{
        yyl1 = poplabel();
        yyl2 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        putlabel(yyl2);
    } break;
    case 75:{
        yyl1 = toploop(L_BREAK);
        genjump(C_FJMP, yyl1);
    } break;
    case 77:{
        yyl1 = poplabel();
        yyl2 = poplabel();
        yyl3 = toploop(L_CONTINUE);
        uselabel(yyl3, yyl2);
        putlabel(yyl1);
        putlabel(yyl2);
    } break;
    case 79:{
        yyl1 = toploop(L_NORMAL);
        yyl2 = toploop(L_CONTINUE);
        genjump(C_JUMP, yyl1);
        genlabel(yyl2);
    } break;
    case 80:{
        yyl1 = poplabel();
        yyl2 = poplabel();
        gendrop();
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
        putlabel(yyl2);
    } break;
    case 82:{
        gendrop();
    } break;
    case 84:{
        yyval.ival = yypvt[-0].ival;
    } break;
    case 85:{
        genfield(0);
        lastop(C_PLUCK);
        yyval.ival = 1;
    } break;
    case 87:{
        genaddr(lookfor(nul));
        genbyte(C_LOAD);
    } break;
    case 88:{
        gencall(P_CREATE, 1);
    } break;
    case 89:{
        gencall(P_APPEND, 1);
    } break;
    case 90:{
        genfcon(0);
    } break;
    case 91:{
        gencall(P_OPEN, 1);
    } break;
    case 92:{
        genfcon(1);
    } break;
    case 93:{
        genrcon(regexp(1));
        yyval.ival = S_REGEXP;
    } break;
    case 94:{
        genstore(yypvt[-1].ival);
        yyval.ival = yypvt[-0].ival;
    } break;
    case 96:{
        if (yypvt[-0].ival == S_LONG)
            genbyte(C_IS);
        yyval.ival = S_SHORT;
    } break;
    case 97:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genjump(C_FJMP, yyl2);
    } break;
    case 98:{
        yyl1 = poplabel();
        yyl2 = toploop(L_NORMAL);
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
    } break;
    case 99:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_NUMBER;
    } break;
    case 101:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } break;
    case 102:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 104:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } break;
    case 105:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 106:{
        if (yypvt[-2].ival > 1)
            gencall(P_JOIN, yypvt[-2].ival);
    } break;
    case 107:{
        genbyte(C_IN);
        yyval.ival = S_SHORT;
    } break;
    case 108:{
        genbyte(C_IN);
        yyval.ival = S_SHORT;
    } break;
    case 111:{
        genbyte(C_MAT);
        yyval.ival = S_SHORT;
    } break;
    case 112:{
        genbyte(C_MAT);
        genbyte(C_NOT);
        yyval.ival = S_SHORT;
    } break;
    case 115:{
        yyval.ival = yypvt[-2].ival + 1;
    } break;
    case 116:{
        yyval.ival = 1;
    } break;
    case 117:{
        genstore(yypvt[-1].ival);
        yyval.ival = yypvt[-0].ival;
    } break;
    case 119:{
        if (yypvt[-0].ival == S_LONG)
            genbyte(C_IS);
        yyval.ival = S_SHORT;
    } break;
    case 120:{
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genjump(C_FJMP, yyl2);
    } break;
    case 121:{
        yyl1 = poplabel();
        yyl2 = toploop(L_NORMAL);
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
    } break;
    case 122:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_NUMBER;
    } break;
    case 124:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } break;
    case 125:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 127:{
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } break;
    case 128:{
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        yyval.ival = S_LONG;
    } break;
    case 129:{
        if (yypvt[-2].ival > 1)
            gencall(P_JOIN, yypvt[-2].ival);
    } break;
    case 130:{
        genbyte(C_IN);
        yyval.ival = S_SHORT;
    } break;
    case 131:{
        genbyte(C_IN);
        yyval.ival = S_SHORT;
    } break;
    case 134:{
        genbyte(C_MAT);
        yyval.ival = S_SHORT;
    } break;
    case 135:{
        genbyte(C_MAT);
        genbyte(C_NOT);
        yyval.ival = S_SHORT;
    } break;
    case 137:{
        genbyte(yypvt[-1].ival);
        yyval.ival = S_SHORT;
    } break;
    case 138:{
        genbyte(C_LT);
        yyval.ival = S_SHORT;
    } break;
    case 139:{
        genbyte(C_GT);
        yyval.ival = S_SHORT;
    } break;
    case 141:{
        genbyte(C_CAT);
        yyval.ival = S_STRING;
    } break;
    case 143:{
        genbyte(C_ADD);
        yyval.ival = S_DOUBLE;
    } break;
    case 144:{
        genbyte(C_SUB);
        yyval.ival = S_DOUBLE;
    } break;
    case 146:{
        genbyte(C_MUL);
        yyval.ival = S_DOUBLE;
    } break;
    case 147:{
        genbyte(C_DIV);
        yyval.ival = S_DOUBLE;
    } break;
    case 148:{
        genbyte(C_MOD);
        yyval.ival = S_DOUBLE;
    } break;
    case 150:{
        genbyte(C_NOT);
        yyval.ival = S_DOUBLE;
    } break;
    case 151:{
        genbyte(C_NEG);
        yyval.ival = S_DOUBLE;
    } break;
    case 152:{
        genbyte(C_NUM);
        yyval.ival = S_DOUBLE;
    } break;
    case 154:{
        genbyte(C_POW);
        yyval.ival = S_DOUBLE;
    } break;
    case 155:{
        gentwo(C__PRE, yypvt[-1].ival);
        yyval.ival = S_DOUBLE;
    } break;
    case 156:{
        gentwo(C__POST, yypvt[-0].ival);
        yyval.ival = S_DOUBLE;
    } break;
    case 157:{
        if (lastcode() == C_ADDR)
            lastop(C_FETCH);
        else if (lastcode() == C_FIELD)
            lastop(C_PLUCK);
        else
            genbyte(C_LOAD);
        yyval.ival = S_NUMBER;
    } break;
    case 158:{
        yyval.ival = S_NUMBER;
    } break;
    case 159:{
        gendcon(yypvt[-0].dval);
        yyval.ival = S_DOUBLE;
    } break;
    case 160:{
        genscon(yypvt[-0].sptr);
        yyval.ival = S_STRING;
    } break;
    case 161:{
        genuser(yypvt[-3].vptr, yypvt[-1].ival);
        yyval.ival = S_NUMBER;
    } break;
    case 162:{
        genbyte(yypvt[-2].ival);
        yyval.ival = S_NUMBER;
    } break;
    case 163:{
        genbyte(yypvt[-3].ival);
        yyval.ival = S_NUMBER;
    } break;
    case 164:{
        genbyte(yypvt[-5].ival);
        yyval.ival = S_NUMBER;
    } break;
    case 165:{
        genfield(0);
        genfield(0);
        lastop(C_PLUCK);
        gencall(yypvt[-5].ival, 4);
        yyval.ival = S_STRING;
    } break;
    case 166:{
        genbyte(C_DUP);
        genbyte(C_LOAD);
        gencall(yypvt[-7].ival, 4);
        yyval.ival = S_STRING;
    } break;
    case 167:{
        genaddr(lookfor(nul));
        genbyte(C_SWAP);
        gencall(yypvt[-7].ival, 4);
        yyval.ival = S_STRING;
    } break;
    case 168:{
        genaddr(lookfor(fs));
        genbyte(C_LOAD);
        gencall(P_SPLIT, 3);
        yyval.ival = S_DOUBLE;
    } break;
    case 169:{
        gencall(P_SPLIT, 3);
        yyval.ival = S_DOUBLE;
    } break;
    case 170:{
        gencall(P_MATCH, 2);
        yyval.ival = S_SHORT;
    } break;
    case 171:{
        genfield(0);
        lastop(C_PLUCK);
        genbyte(C_SWAP);
        gencall(P_INDEX, 2);
        yyval.ival = S_DOUBLE;
    } break;
    case 172:{
        gencall(P_INDEX, 2);
        yyval.ival = S_DOUBLE;
    } break;
    case 173:{
        gencall(P_SUBSTR, 2);
        yyval.ival = S_STRING;
    } break;
    case 174:{
        gencall(P_SUBSTR, 3);
        yyval.ival = S_STRING;
    } break;
    case 175:{
        gencall(P_SPRINTF, yypvt[-1].ival);
        yyval.ival = S_DOUBLE;
    } break;
    case 176:{
        gencall(P_GETLINE, 2);
        yyval.ival = S_DOUBLE;
    } break;
    case 177:{
        genfield(0);
        genbyte(C_SWAP);
        gencall(P_GETLINE, 2);
        yyval.ival = S_DOUBLE;
    } break;
    case 182:{
        yyval.ival = yypvt[-2].ival + 1;
    } break;
    case 183:{
        yyval.ival = 1;
    } break;
    case 184:{
        yyval.ival = yypvt[-0].ival;
    } break;
    case 185:{
        yyval.ival = 0;
    } break;
    case 186:{
        if (lastcode() == C_DCON)
            genfield(lastdcon());
        else
            genbyte(C_DOLAR);
    } break;
    case 187:{
        if (yypvt[-1].ival > 1)
            gencall(P_JOIN, yypvt[-1].ival);
        genbyte(C_SELECT);
    } break;
    case 189:{
        genaddr(yypvt[-0].vptr);
    } break;/* End of actions */
    }
    goto yystack;
}

