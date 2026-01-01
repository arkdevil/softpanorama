typedef union 
{
    int     ival;
    double  dval;
    char   *sptr;
    FUNC   *uptr;
    void   *vptr;
} YYSTYPE;
extern YYSTYPE yylval;
#define T_EOF 257
#define T_EOL 258
#define T_BEGIN 259
#define T_END 260
#define T_IF 261
#define T_ELSE 262
#define T_FOR 263
#define T_DO 264
#define T_DONE 265
#define T_WHILE 266
#define T_BREAK 267
#define T_CONTINUE 268
#define T_FUNCTION 269
#define T_RETURN 270
#define T_NEXT 271
#define T_EXIT 272
#define T_PRINT 273
#define T_PRINTF 274
#define T_INDEX 275
#define T_SRAND 276
#define T_CLOSE 277
#define T_SPLIT 278
#define T_MATCH 279
#define T_DELETE 280
#define T_SUBSTR 281
#define T_SPRINTF 282
#define T_GETLINE 283
#define T_SUB 284
#define T_USER 285
#define T_NAME 286
#define T_SCON 287
#define T_DCON 288
#define T_FUNC0 289
#define T_FUNC1 290
#define T_FUNC2 291
#define T_CREATE 292
#define T_APPEND 293
#define T_STORE 294
#define T_LIOR 295
#define T_LAND 296
#define T_IN 297
#define T_NOMATCH 298
#define T_RELOP 299
#define T_CONCAT 300
#define T_SIGN 301
#define T_INCOP 302
#define T_GROUP 303
