
# line 4 "pascal.y"
typedef union  {
  int   i;
  float r;
  char *s;
} YYSTYPE;
#define YYSUNION /* %union occurred */
#define _AND 257
#define _ARRAY 258
#define _BEGIN 259
#define _CASE 260
#define _CONST 261
#define _DIV 262
#define _DO 263
#define _DOWNTO 264
#define _ELSE 265
#define _END 266
#define _FILE 267
#define _FOR 268
#define _FORWARD 269
#define _FUNCTION 270
#define _GOTO 271
#define _IF 272
#define _IN 273
#define _LABEL 274
#define _MOD 275
#define _NIL 276
#define _NOT 277
#define _OF 278
#define _OR 279
#define _PACKED 280
#define _PROCEDURE 281
#define _PROGRAM 282
#define _RECORD 283
#define _REPEAT 284
#define _SET 285
#define _THEN 286
#define _TO 287
#define _TYPE 288
#define _UNTIL 289
#define _VAR 290
#define _WHILE 291
#define _WITH 292
#define _IDENT 293
#define _INT 294
#define _REAL 295
#define _STRING 296
#define _ASSIGN 297
#define _NE 298
#define _GE 299
#define _LE 300
#define _DOTDOT 301
#define _UNARY 302
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
#define YYERRCODE 256

#include <stdio.h>
FILE *yytfilep;
char *yytfilen = "pascal.ast";
int yytflag = 1;

char *svdnams[] = {
  "$accept", "program", "$end", "$EOP", "program", "_PROGRAM", "_IDENT", " (", "opt_identifier_list", " )", 
  " ;", "block", " .", "$EOP", "opt_identifier_list", "identifier_list", "$EOP", "opt_identifier_list", "$EOP", "identifier_list", 
  "_IDENT", "$EOP", "identifier_list", "_IDENT", " ,", "identifier_list", "$EOP", "block", "opt_labels", "opt_constants", 
  "opt_types", "opt_variables", "opt_procedure_or_function_heading_dcls", "_BEGIN", "statements", "_END", "$EOP", "opt_labels", "_LABEL", "integer_list", 
  " ;", "$EOP", "opt_labels", "$EOP", "integer_list", "_INT", "$EOP", "integer_list", "_INT", " ,", 
  "integer_list", "$EOP", "opt_constants", "_CONST", "constant_dcls", "$EOP", "opt_constants", "$EOP", "opt_types", "_TYPE", 
  "type_dcls", "$EOP", "opt_types", "$EOP", "opt_variables", "_VAR", "variable_dcls", "$EOP", "opt_variables", "$EOP", 
  "opt_procedure_or_function_heading_dcls", "opt_procedure_or_function_heading_dcls", "procedure_or_function_heading", " ;", "block_directive", " ;", "$EOP", "opt_procedure_or_function_heading_dcls", "$EOP", "block_directive", 
  "block", "$EOP", "block_directive", "directive", "$EOP", "directive", "_FORWARD", "$EOP", "statements", "statement", 
  "$EOP", "statements", "statements", " ;", "statement", "$EOP", "constant_dcls", "_IDENT", " =", "constant", 
  " ;", "$EOP", "constant_dcls", "constant_dcls", "_IDENT", " =", "constant", " ;", "$EOP", "variable_dcls", 
  "identifier_list", " :", "type", " ;", "$EOP", "variable_dcls", "variable_dcls", "identifier_list", " :", "type", 
  " ;", "$EOP", "statement", "opt_label", "unlabeled_statement", "$EOP", "opt_label", "_INT", " :", "$EOP", 
  "opt_label", "$EOP", "unlabeled_statement", "variable", "_ASSIGN", "expression", "$EOP", "unlabeled_statement", "_IDENT", "opt_proc_parameter_list", 
  "$EOP", "unlabeled_statement", "_BEGIN", "statements", "_END", "$EOP", "unlabeled_statement", "_IF", "expression", "_THEN", 
  "statement", "$EOP", "unlabeled_statement", "_IF", "expression", "_THEN", "statement", "_ELSE", "statement", "$EOP", 
  "unlabeled_statement", "_WHILE", "expression", "_DO", "statement", "$EOP", "unlabeled_statement", "_CASE", "expression", "_OF", 
  "case_body", "_END", "$EOP", "unlabeled_statement", "_REPEAT", "statements", "_UNTIL", "expression", "$EOP", "unlabeled_statement", 
  "_FOR", "_IDENT", "_ASSIGN", "expression", "direction", "expression", "_DO", "statement", "$EOP", "unlabeled_statement", 
  "_WITH", "variable_list", "_DO", "statement", "$EOP", "unlabeled_statement", "_GOTO", "_INT", "$EOP", "unlabeled_statement", 
  "$EOP", "variable_list", "variable", "$EOP", "variable_list", "variable_list", " ,", "variable", "$EOP", "constant_list", 
  "constant", "$EOP", "constant_list", "constant_list", " ,", "constant", "$EOP", "case_body", "constant_list", " :", 
  "statement", "case_trailer", "$EOP", "case_trailer", " ;", "$EOP", "case_trailer", " ;", "case_body", "$EOP", 
  "case_trailer", "$EOP", "direction", "_DOWNTO", "$EOP", "direction", "_TO", "$EOP", "opt_proc_parameter_list", " (", 
  "expression_opt_formats_list", " )", "$EOP", "opt_proc_parameter_list", "$EOP", "expression_opt_formats_list", "expression_opt_formats", "$EOP", "expression_opt_formats_list", "expression_opt_formats_list", 
  " ,", "expression_opt_formats", "$EOP", "expression_opt_formats", "expression", "opt_formats", "$EOP", "opt_formats", " :", "expression", 
  "$EOP", "opt_formats", " :", "expression", " :", "expression", "$EOP", "opt_formats", "$EOP", "expression_list", 
  "expression", "$EOP", "expression_list", "expression_list", " ,", "expression", "$EOP", "expression", "expression", " +", 
  "expression", "$EOP", "expression", "expression", " -", "expression", "$EOP", "expression", "expression", " *", 
  "expression", "$EOP", "expression", "expression", "_DIV", "expression", "$EOP", "expression", "expression", "_MOD", 
  "expression", "$EOP", "expression", "expression", "_AND", "expression", "$EOP", "expression", "expression", "_OR", 
  "expression", "$EOP", "expression", "expression", " <", "expression", "$EOP", "expression", "expression", " >", 
  "expression", "$EOP", "expression", "expression", " =", "expression", "$EOP", "expression", "expression", "_NE", 
  "expression", "$EOP", "expression", "expression", "_GE", "expression", "$EOP", "expression", "expression", "_LE", 
  "expression", "$EOP", "expression", "expression", " .", "expression", "$EOP", "expression", "expression", "_IN", 
  "expression", "$EOP", "expression", "expression", " /", "expression", "$EOP", "expression", " -", "expression", 
  "$EOP", "expression", " +", "expression", "$EOP", "expression", "_NOT", "expression", "$EOP", "expression", 
  "primary", "$EOP", "primary", "_IDENT", "variable_trailer_func_parm_list", "$EOP", "primary", " (", "expression", " )", 
  "$EOP", "primary", "unsigned_literal", "$EOP", "primary", " [", "opt_elipsis_list", " ]", "$EOP", "variable_trailer_func_parm_list", 
  "variable_trailers", "$EOP", "variable_trailer_func_parm_list", " (", "expression_list", " )", "$EOP", "opt_elipsis_list", "elipsis_list", "$EOP", 
  "opt_elipsis_list", "$EOP", "elipsis_list", "elipsis", "$EOP", "elipsis_list", "elipsis_list", " ,", "elipsis", "$EOP", 
  "elipsis", "expression", "$EOP", "elipsis", "expression", "_DOTDOT", "expression", "$EOP", "variable", "_IDENT", 
  "variable_trailers", "$EOP", "variable_trailers", " [", "expression_list", " ]", "variable_trailers", "$EOP", "variable_trailers", " .", 
  "_IDENT", "variable_trailers", "$EOP", "variable_trailers", " ^", "variable_trailers", "$EOP", "variable_trailers", "$EOP", "constant", 
  " +", "unsigned_constant", "$EOP", "constant", " -", "unsigned_constant", "$EOP", "constant", "unsigned_constant", "$EOP", 
  "unsigned_literal", "_REAL", "$EOP", "unsigned_literal", "_INT", "$EOP", "unsigned_literal", "_STRING", "$EOP", "unsigned_literal", 
  "_NIL", "$EOP", "unsigned_constant", "_IDENT", "$EOP", "unsigned_constant", "unsigned_literal", "$EOP", "type", " ^", 
  "_IDENT", "$EOP", "type", "ordinal_type", "$EOP", "type", "opt_packed", "packable_type", "$EOP", "packable_type", 
  "_ARRAY", " [", "ordinal_type_list", " ]", "_OF", "type", "$EOP", "packable_type", "_RECORD", "field_list", 
  "_END", "$EOP", "packable_type", "_FILE", "_OF", "type", "$EOP", "packable_type", "_SET", "_OF", 
  "ordinal_type", "$EOP", "ordinal_type_list", "ordinal_type", "$EOP", "ordinal_type_list", "ordinal_type_list", " ,", "ordinal_type", "$EOP", 
  "ordinal_type", "_IDENT", "$EOP", "ordinal_type", " (", "identifier_list", " )", "$EOP", "ordinal_type", "constant", 
  "_DOTDOT", "constant", "$EOP", "field_list", "identifier_list", " :", "type", "$EOP", "field_list", "identifier_list", 
  " :", "type", " ;", "field_list", "$EOP", "field_list", "_CASE", "tag", "_OF", "cases", 
  "$EOP", "field_list", "$EOP", "tag", "_IDENT", "$EOP", "tag", "_IDENT", " :", "type", 
  "$EOP", "cases", "constant_list", " :", " (", "field_list", " )", "cases_trailer", "$EOP", "cases_trailer", 
  " ;", "cases", "$EOP", "cases_trailer", " ;", "$EOP", "cases_trailer", "$EOP", "procedure_or_function_heading", "_PROCEDURE", 
  "_IDENT", "opt_formal_parm_list", "$EOP", "procedure_or_function_heading", "_FUNCTION", "_IDENT", "opt_formal_parm_list", "opt_return", "$EOP", "opt_formal_parm_list", 
  " (", "formal_parms", " )", "$EOP", "opt_formal_parm_list", "$EOP", "formal_parms", "opt_var", "identifier_list", " :", 
  "formal_parm_trailer", "$EOP", "formal_parms", "procedure_or_function_heading", "proc_parm_trailer", "$EOP", "opt_var", "_VAR", "$EOP", "opt_var", 
  "$EOP", "formal_parm_trailer", "_IDENT", "proc_parm_trailer", "$EOP", "formal_parm_trailer", "conformant_array_schema", "proc_parm_trailer", "$EOP", "proc_parm_trailer", 
  " ;", "formal_parms", "$EOP", "proc_parm_trailer", "$EOP", "conformant_array_schema", "opt_packed", " [", "index_type_spec_list", " ]", 
  "_OF", "_IDENT", "$EOP", "conformant_array_schema", "opt_packed", " [", "index_type_spec_list", " ]", "_OF", "_IDENT", 
  "conformant_array_schema", "$EOP", "opt_packed", "_PACKED", "$EOP", "opt_packed", "$EOP", "index_type_spec_list", "_IDENT", "_DOTDOT", 
  "_IDENT", " :", "_IDENT", "$EOP", "opt_return", " :", "_IDENT", "$EOP", "opt_return", "$EOP", 
  "type_dcls", "_IDENT", " =", "type", " ;", "$EOP", "type_dcls", "type_dcls", "_IDENT", " =", 
  "type", " ;", "$EOP", 
};

int svdprd[] = {
  0, 4, 14, 17, 19, 22, 27, 37, 42, 44, 
  47, 52, 56, 58, 62, 64, 68, 70, 77, 79, 
  82, 85, 88, 91, 96, 102, 109, 115, 122, 126, 
  130, 132, 137, 141, 146, 152, 160, 166, 173, 179, 
  189, 195, 199, 201, 204, 209, 212, 217, 223, 226, 
  230, 232, 235, 238, 243, 245, 248, 253, 257, 261, 
  267, 269, 272, 277, 282, 287, 292, 297, 302, 307, 
  312, 317, 322, 327, 332, 337, 342, 347, 352, 357, 
  361, 365, 369, 372, 376, 381, 384, 389, 392, 397, 
  400, 402, 405, 410, 413, 418, 422, 428, 433, 437, 
  439, 443, 447, 450, 453, 456, 459, 462, 465, 468, 
  472, 475, 479, 487, 492, 497, 502, 505, 510, 513, 
  518, 523, 528, 535, 541, 543, 546, 551, 559, 563, 
  566, 568, 573, 579, 584, 586, 592, 596, 599, 601, 
  605, 609, 613, 615, 623, 632, 635, 637, 644, 648, 
  650, 656, 
};

int yyexca[] = {
  -1, 1,
  0, -1,
  -2, 0,
  -1, 60,
  301, 107,
  -2, 118,
  -1, 92,
  297, 99,
  -2, 54,
  -1, 306,
  91, 146,
  -2, 143,
  0,
};

#define YYNPROD 152
#define YYLAST 964

int yyact[] = {
     136,     174,     172,     300,     173,     185,     187,      59,
      86,     202,     174,     172,     246,     173,     185,     187,
      48,     121,      71,     179,     181,     180,     276,     145,
     257,     115,      19,      63,     179,     181,     180,     310,
      44,      43,      46,      45,      47,     306,      44,      44,
     275,      44,      44,     303,     295,     136,     144,     209,
       7,     168,     159,     141,      79,      74,      73,      44,
      44,      36,       7,     174,     172,      30,     173,     185,
     187,      29,     174,     172,      23,     173,     185,     187,
       3,      27,     245,      21,      44,     179,     181,     180,
      52,       2,     281,      63,     179,     181,     180,      44,
      89,      89,      49,      51,     302,     254,      81,     213,
     117,     116,      14,     264,     150,      52,     105,      83,
     240,     174,     172,      14,     173,     185,     187,     268,
      51,      44,      89,     156,     204,      44,      44,      82,
      17,      84,     126,     179,     181,     180,     207,      40,
     197,      41,     147,     113,     164,     174,     172,     174,
     173,     185,     187,     185,     187,     299,     219,     241,
     288,     112,      68,     211,      55,     218,      38,     179,
     181,     180,     106,      37,      31,     269,      44,     305,
      12,     174,     172,     292,     173,     185,     187,     125,
     193,     208,     127,     280,     307,     269,     126,     256,
     153,     124,     252,     179,     181,     180,     146,     126,
     111,     110,      87,     270,     214,     174,     172,     220,
     173,     185,     187,      61,     210,      78,      40,     135,
      41,      44,     131,      72,     130,      65,     157,     179,
     181,     180,      91,      24,      44,      10,      44,      44,
     177,     185,     166,     125,     152,     175,     127,     272,
     101,     177,     258,      75,     125,     108,     175,     127,
     186,     103,     176,      54,      15,     242,     178,     265,
     128,     186,     219,     176,     140,     215,     273,     178,
     216,      25,     137,      61,       9,     301,      40,      44,
      41,     182,     183,     184,     277,     205,     118,     106,
      12,       8,     182,     183,     184,     243,      44,     246,
     289,     107,     177,      97,       4,     294,     274,     175,
     293,     177,     148,     151,     304,      59,     175,      68,
     158,     154,     186,      80,     176,      44,     196,     170,
     178,     186,     195,     176,     149,     191,     133,     178,
     217,      57,      44,     163,     174,     172,     143,     173,
     185,     187,     277,     182,     183,     184,     258,     201,
     177,      88,     182,     183,     184,     175,     179,     181,
     180,     309,     308,     291,     276,     257,      50,     203,
     186,     142,     176,     253,     271,     122,     178,      90,
      70,     104,     102,      34,     177,     260,     177,     149,
      28,     175,     204,     175,      22,      33,      26,      20,
      48,     182,     183,     184,     186,      16,     176,     297,
     176,      13,     178,     266,     245,       5,      93,      96,
     177,      43,      46,      45,      47,     175,       1,      98,
     147,       0,     100,      94,     279,     182,     183,     184,
     186,     164,     176,     197,       0,     200,     178,      97,
       0,       0,     286,     287,     177,       0,      95,      99,
      92,     175,     199,     289,     239,     276,     207,     251,
       0,     182,     183,     184,     186,     296,     176,       0,
       0,       0,     178,       0,     113,      58,      18,      48,
       0,       0,      62,      48,     132,     165,       0,       0,
       0,       0,       0,       0,      42,     182,     183,     184,
      60,      46,      45,      47,     134,      46,      45,      47,
      32,       0,     166,       0,       0,       0,      91,      18,
     174,     172,      39,     173,     185,     187,       0,       0,
       0,      64,      38,       0,       0,       0,       0,       0,
       0,       0,     179,     181,     180,      66,      67,      48,
      69,       0,       0,      63,     174,     172,       0,     173,
     185,     187,       0,      86,       0,       0,       0,       0,
      60,      46,      45,      47,       0,       0,       0,      41,
      42,       0,       0,       0,       0,       0,       0,       0,
       0,     119,       0,     177,       0,       0,       0,       0,
     175,       0,       0,       0,     129,     138,     139,       0,
       0,       0,       0,     186,       0,     176,     155,       0,
       0,     178,       0,     161,       0,       0,       0,       0,
     171,       0,     200,       0,       0,       0,       0,     162,
       0,       0,       0,     167,     182,     183,     184,      95,
     188,     189,     190,       0,       0,     194,       0,     198,
      96,     121,     120,       0,       0,       0,     123,       0,
       0,     117,       0,       0,       0,       0,       0,     211,
       0,       0,       0,       0,       0,       0,       0,       0,
     125,       0,       0,       0,       0,     201,       0,       0,
       0,     171,     223,     224,     225,     226,     227,     228,
     229,     230,     231,     232,     233,     234,     235,     236,
     237,     238,     131,     132,     135,       0,       0,     167,
     137,       0,       0,     247,     243,       0,      56,     248,
     249,     255,       0,       0,       0,       0,       0,       0,
     247,       0,       0,       0,       0,       0,       0,       0,
     261,     262,       0,       0,     222,     173,     174,     175,
     176,     177,     178,     179,     180,     181,     182,     183,
     184,     185,     186,     187,     193,       0,       0,     177,
     198,     267,      62,       0,     175,      58,     202,     218,
     244,       0,       0,       0,     250,      76,      77,     186,
       0,     176,       0,     219,     242,     178,       0,       0,
     283,     271,       0,     177,       0,     285,     169,     199,
     175,       0,     109,      55,      75,     192,     292,     290,
     182,     183,     184,     281,       0,     176,       0,     247,
     165,     178,       0,       0,       0,     203,       0,       0,
       0,       0,       0,     264,     247,       0,       0,       0,
       0,       0,       0,       0,     116,       0,       0,     221,
     134,     282,       0,     160,     114,       0,       0,     284,
       0,       6,       0,       9,       0,       0,      11,       0,
      27,       0,       0,     270,       0,     293,       0,     168,
       0,       0,       0,       0,       0,       0,     298,       0,
      35,       0,       0,      69,       0,       0,       0,      53,
      34,       0,       0,       0,     212,       0,       0,     157,
       0,       0,       0,     263,     220,       0,       0,       0,
       0,       0,      61,       0,       0,       0,       0,       0,
       0,       0,      85,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,     148,       0,       0,       0,     123,       0,
       0,       0,       0,     214,       0,     259,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,     278,       0,       0,
       0,       0,     254,       0,       0,       0,       0,       0,
       0,     206,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,      56,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,     114,
};

int yypact[] = {
    -201,   -1000,    -221,     236,    -245,     224,   -1000,     208,
     154,    -245,    -176,   -1000,     190,    -141,    -268,   -1000,
    -213,    -225,     152,     205,    -217,    -228,    -232,      95,
   -1000,    -268,   -1000,    -245,    -236,      94,      89,      84,
   -1000,    -169,    -245,     177,      87,     211,      84,     146,
    -260,    -260,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,
   -1000,    -276,     144,    -239,    -240,     169,     211,     211,
     138,    -241,   -1000,    -164,   -1000,    -245,    -293,   -1000,
     127,   -1000,   -1000,   -1000,      55,   -1000,     115,     166,
    -167,     233,     233,     211,     126,     125,   -1000,   -1000,
   -1000,      54,    -235,    -181,    -182,     221,      84,   -1000,
   -1000,    -276,   -1000,    -280,     137,    -276,     159,     159,
     159,    -276,    -242,    -247,    -271,   -1000,     123,   -1000,
   -1000,   -1000,   -1000,    -190,     162,     117,   -1000,   -1000,
     155,    -151,     148,    -243,     211,     155,   -1000,   -1000,
   -1000,     159,   -1000,   -1000,     159,     159,    -244,      76,
      29,     266,     159,     159,     159,   -1000,     128,     159,
   -1000,     159,     147,     119,      30,    -288,      72,   -1000,
      76,   -1000,   -1000,     220,    -245,     110,   -1000,   -1000,
    -246,   -1000,     103,   -1000,   -1000,     211,    -183,     130,
   -1000,   -1000,     422,     204,   -1000,      91,      98,     422,
      76,   -1000,   -1000,    -276,     159,     159,     159,     159,
     159,     159,     159,     159,     159,     159,     159,     159,
     159,     159,     159,     159,   -1000,   -1000,     171,   -1000,
   -1000,     159,      63,      50,     193,   -1000,     -32,    -276,
      84,     159,     159,    -276,    -247,   -1000,     120,   -1000,
    -190,   -1000,    -185,     155,     116,      84,     211,   -1000,
     159,   -1000,     159,     159,      76,   -1000,    -166,      93,
      93,     171,     171,     171,     171,      93,     450,     450,
     450,     450,     450,     450,   -1000,     450,     171,     198,
   -1000,   -1000,     159,     159,   -1000,    -155,     129,   -1000,
     422,     -41,   -1000,   -1000,    -253,   -1000,     211,   -1000,
    -235,   -1000,     113,   -1000,   -1000,      24,     422,   -1000,
    -276,   -1000,   -1000,     422,   -1000,      84,    -276,     159,
   -1000,   -1000,   -1000,     110,     110,      53,   -1000,   -1000,
     232,     159,   -1000,   -1000,     104,      17,   -1000,   -1000,
    -249,    -235,     422,   -1000,      84,    -276,      48,    -298,
     212,   -1000,   -1000,    -186,    -250,     100,    -256,     114,
   -1000,      84,    -197,    -262,   -1000,   -1000,   -1000,
};

int yypgo[] = {
       0,     382,     373,     160,     756,     369,     365,     359,
     358,     357,     146,     430,     356,     352,     347,     300,
     346,     345,     488,     434,     638,     344,     343,     210,
     437,     341,      74,     340,     337,      12,     331,     307,
     132,     304,     218,     302,     301,       0,     298,     582,
     294,     128,     444,     429,       7,     291,     289,     131,
     288,      24,     284,     154,     283,     130,     282,     278,
     126,      22,     277,
};

int yyr1[] = {
       0,       1,       2,       2,       4,       4,       3,       5,
       5,      11,      11,       6,       6,       7,       7,       8,
       8,       9,       9,      16,      16,      17,      10,      10,
      12,      12,      14,      14,      18,      21,      21,      22,
      22,      22,      22,      22,      22,      22,      22,      22,
      22,      22,      22,      28,      28,      29,      29,      26,
      30,      30,      30,      27,      27,      25,      25,      31,
      31,      32,      33,      33,      33,      34,      34,      24,
      24,      24,      24,      24,      24,      24,      24,      24,
      24,      24,      24,      24,      24,      24,      24,      24,
      24,      24,      24,      35,      35,      35,      35,      36,
      36,      38,      38,      40,      40,      41,      41,      23,
      39,      39,      39,      39,      19,      19,      19,      37,
      37,      37,      37,      42,      42,      20,      20,      20,
      45,      45,      45,      45,      46,      46,      43,      43,
      43,      47,      47,      47,      47,      48,      48,      49,
      50,      50,      50,      15,      15,      51,      51,      53,
      53,      54,      54,      55,      55,      56,      56,      57,
      57,      44,      44,      58,      52,      52,      13,      13,
};

int yyr2[] = {
       2,       8,       1,       0,       1,       3,       8,       3,
       0,       1,       3,       2,       0,       2,       0,       2,
       0,       5,       0,       1,       1,       1,       1,       3,
       4,       5,       4,       5,       2,       2,       0,       3,
       2,       3,       4,       6,       4,       5,       4,       8,
       4,       2,       0,       1,       3,       1,       3,       4,
       1,       2,       0,       1,       1,       3,       0,       1,
       3,       2,       2,       4,       0,       1,       3,       3,
       3,       3,       3,       3,       3,       3,       3,       3,
       3,       3,       3,       3,       3,       3,       3,       2,
       2,       2,       1,       2,       3,       1,       3,       1,
       3,       1,       0,       1,       3,       1,       3,       2,
       4,       3,       2,       0,       2,       2,       1,       1,
       1,       1,       1,       1,       1,       2,       1,       2,
       6,       3,       3,       3,       1,       3,       1,       3,
       3,       3,       5,       4,       0,       1,       3,       6,
       2,       1,       0,       3,       4,       3,       0,       4,
       2,       1,       0,       2,       2,       2,       0,       6,
       7,       1,       0,       5,       2,       0,       4,       5,
};

int yychk[] = {
   -1000,      -1,     282,     293,      40,      -2,      -4,     293,
      41,      44,      59,      -4,      -3,      -5,     274,      46,
      -6,     261,     -11,     294,      -7,     288,     -12,     293,
      59,      44,      -8,     290,     -13,     293,     293,      61,
     -11,      -9,     -14,      -4,     293,      61,      61,     -19,
      43,      45,     -42,     293,     -37,     295,     294,     296,
     276,     259,     -15,     281,     270,      -4,      58,      61,
     -20,      94,     -43,     -44,     293,      40,     -19,     280,
     -19,      59,     -42,     -42,     -10,     -18,     -21,     294,
      59,     293,     293,      58,     -20,     -20,      59,     293,
     -45,     258,     283,     267,     285,      -4,     301,      59,
     266,      59,     -22,     -23,     293,     259,     272,     291,
     260,     284,     268,     292,     271,      58,     -16,      -3,
     -17,     269,     -51,      40,     -51,     -20,      59,      59,
      91,     -47,      -4,     260,     278,     278,      41,     -19,
     -18,     297,     -25,     -39,      40,      91,      46,      94,
     -10,     -24,      45,      43,     277,     -35,     293,      40,
     -37,      91,     -24,     -24,     -10,     293,     -28,     -23,
     293,     294,      59,     -53,     -54,     -15,     290,     -52,
      58,      59,     -46,     -43,     266,      58,     -48,     293,
     -20,     -43,     -24,     -31,     -32,     -24,     -34,     -24,
     293,     -39,     266,     286,      43,      45,      42,     262,
     275,     257,     279,      60,      62,      61,     298,     299,
     300,      46,     273,      47,     -24,     -24,     -24,     -36,
     -39,      40,     -24,     -38,     -40,     -41,     -24,     263,
     278,     289,     297,     263,      44,      41,      -4,     -56,
      59,     293,      93,      44,     -20,     278,      58,      41,
      44,     -33,      58,      44,      93,     -39,     -18,     -24,
     -24,     -24,     -24,     -24,     -24,     -24,     -24,     -24,
     -24,     -24,     -24,     -24,     -24,     -24,     -24,     -34,
      41,      93,      44,     301,     -18,     -26,     -29,     -19,
     -24,     -24,     -18,     -23,      58,     -53,     278,     -43,
      59,     -49,     -29,     -20,     -32,     -24,     -24,     -39,
     265,      41,     -41,     -24,     266,      44,      58,     -27,
     264,     287,     -55,     293,     -57,     -44,     -20,     -47,
      58,      58,     -18,     -19,     -18,     -24,     -56,     -56,
      91,      40,     -24,     -30,      59,     263,     -58,     293,
     -47,     -26,     -18,      93,     301,      41,     278,     293,
     -50,      59,     293,      58,     -49,     -57,     293,
};

int yydef[] = {
       0,      -2,       0,       0,       3,       0,       2,       4,
       0,       0,       8,       5,       0,      12,       0,       1,
      14,       0,       0,       9,      16,       0,      11,       0,
       7,       0,      18,       0,      13,       0,       0,       0,
      10,       0,      15,       0,       0,     146,       0,       0,
       0,       0,     102,     107,     108,     103,     104,     105,
     106,      30,       0,       0,       0,       0,     146,     146,
       0,       0,     110,       0,      -2,       0,       0,     145,
       0,      24,     100,     101,       0,      22,      42,       0,
       8,     134,     134,     146,       0,       0,     150,     109,
     111,       0,     124,       0,       0,       0,       0,      25,
       6,      30,      28,       0,      -2,      30,       0,       0,
       0,      30,       0,       0,       0,      29,       0,      19,
      20,      21,     131,     138,     149,       0,      26,     151,
       0,       0,       0,       0,     146,       0,     119,     120,
      23,       0,      32,      95,       0,       0,       0,      99,
       0,       0,       0,       0,       0,      82,      99,       0,
      85,      90,       0,       0,       0,       0,       0,      43,
      99,      41,      17,       0,       0,     142,     137,     132,
       0,      27,       0,     116,     113,     146,       0,     125,
     114,     115,      31,       0,      55,      60,       0,      61,
      99,      98,      33,      30,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,      79,      80,      81,      83,
      87,       0,       0,       0,      89,      91,      93,      30,
       0,       0,       0,      30,       0,     133,       0,     136,
     138,     148,       0,       0,     121,       0,     146,      53,
       0,      57,       0,       0,      99,      97,      34,      63,
      64,      65,      66,      67,      68,      69,      70,      71,
      72,      73,      74,      75,      76,      77,      78,       0,
      84,      86,       0,       0,      36,       0,       0,      45,
      38,       0,      40,      44,     146,     141,     146,     117,
     124,     123,       0,     126,      56,      58,      62,      96,
      30,      88,      92,      94,      37,       0,      30,       0,
      51,      52,     135,     142,     142,       0,     112,     122,
       0,       0,      35,      46,      50,       0,     139,     140,
       0,     124,      59,      47,      48,      30,       0,       0,
       0,      49,      39,       0,       0,     130,       0,       0,
     127,     129,      -2,       0,     128,     144,     147,
};

/*****************************************************************/
/* PCYACC LALR parser driver routine -- a table driven procedure */
/* for recognizing sentences of a language defined by the        */
/* grammar that PCYACC analyzes. An LALR parsing table is then   */
/* constructed for the grammar and the skeletal parser uses the  */
/* table when performing syntactical analysis on input source    */
/* programs. The actions associated with grammar rules are       */
/* inserted into a switch statement for execution.               */
/*****************************************************************/


#ifndef YYMAXDEPTH
#define YYMAXDEPTH 200
#endif
#ifndef YYREDMAX
#define YYREDMAX 1000
#endif
#define PCYYFLAG -1000
#define WAS0ERR 0
#define WAS1ERR 1
#define WAS2ERR 2
#define WAS3ERR 3
#define yyclearin pcyytoken = -1
#define yyerrok   pcyyerrfl = 0
YYSTYPE yyv[YYMAXDEPTH];     /* value stack */
int pcyyerrct = 0;           /* error count */
int pcyyerrfl = 0;           /* error flag */
int redseq[YYREDMAX];
int redcnt = 0;
int pcyytoken = -1;          /* input token */


yyparse()
{
  int statestack[YYMAXDEPTH]; /* state stack */
  int      j, m;              /* working index */
  YYSTYPE *yypvt;
  int      tmpstate, *yyps, n;
  YYSTYPE *yypv;
  int     *yyxi;


  tmpstate = 0;
  pcyytoken = -1;
  pcyyerrct = 0;
  pcyyerrfl = 0;
  yyps = &statestack[-1];
  yypv = &yyv[-1];


  enstack:    /* push stack */
    if (++yyps > &statestack[YYMAXDEPTH]) {
      yyerror("pcyacc internal stack overflow");
      return(1);
    }
    *yyps = tmpstate;
    ++yypv;
    *yypv = yyval;


  newstate:
    n = yypact[tmpstate];
    if (n <= PCYYFLAG) goto defaultact; /*  a simple state */


    if (pcyytoken < 0) if ((pcyytoken=yylex()) < 0) pcyytoken = 0;
    if ((n += pcyytoken) < 0 || n >= YYLAST) goto defaultact;


    if (yychk[n=yyact[n]] == pcyytoken) { /* a shift */
      pcyytoken = -1;
      yyval = yylval;
      tmpstate = n;
      if (pcyyerrfl > 0) --pcyyerrfl;
      goto enstack;
    }


  defaultact:


    if ((n=yydef[tmpstate]) == -2) {
      if (pcyytoken < 0) if ((pcyytoken=yylex())<0) pcyytoken = 0;
      for (yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=tmpstate); yyxi += 2);
      while (*(yyxi+=2) >= 0) if (*yyxi == pcyytoken) break;
      if ((n=yyxi[1]) < 0) { /* an accept action */
        if (yytflag) {
          int ti; int tj;
          yytfilep = fopen(yytfilen, "w");
          if (yytfilep == NULL) {
            fprintf(stderr, "Can't open t file: %s\n", yytfilen);
            return(0);          }
          for (ti=redcnt-1; ti>=0; ti--) {
            tj = svdprd[redseq[ti]];
            while (strcmp(svdnams[tj], "$EOP"))
              fprintf(yytfilep, "%s ", svdnams[tj++]);
            fprintf(yytfilep, "\n");
          }
          fclose(yytfilep);
        }
        return (0);
      }
    }


    if (n == 0) {        /* error situation */
      switch (pcyyerrfl) {
        case WAS0ERR:          /* an error just occurred */
          yyerror("syntax error");
          yyerrlab:
            ++pcyyerrct;
        case WAS1ERR:
        case WAS2ERR:           /* try again */
          pcyyerrfl = 3;
	   /* find a state for a legal shift action */
          while (yyps >= statestack) {
	     n = yypact[*yyps] + YYERRCODE;
	     if (n >= 0 && n < YYLAST && yychk[yyact[n]] == YYERRCODE) {
	       tmpstate = yyact[n];  /* simulate a shift of "error" */
	       goto enstack;
            }
	     n = yypact[*yyps];


	     /* the current yyps has no shift on "error", pop stack */


	     --yyps;
	     --yypv;
	   }


	   yyabort:
	     return(1);


	 case WAS3ERR:  /* clobber input char */
          if (pcyytoken == 0) goto yyabort; /* quit */
	   pcyytoken = -1;
	   goto newstate;      } /* switch */
    } /* if */


    /* reduction, given a production n */
    if (yytflag && redcnt<YYREDMAX) redseq[redcnt++] = n;
    yyps -= yyr2[n];
    yypvt = yypv;
    yypv -= yyr2[n];
    yyval = yypv[1];
    m = n;
    /* find next state from goto table */
    n = yyr1[n];
    j = yypgo[n] + *yyps + 1;
    if (j>=YYLAST || yychk[ tmpstate = yyact[j] ] != -n) tmpstate = yyact[yypgo[n]];
    switch (m) { /* actions associated with grammar rules */
          }
    goto enstack;
}
