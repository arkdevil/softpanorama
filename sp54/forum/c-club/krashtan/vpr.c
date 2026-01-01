/* Печать текста поперек страницы   *
 * Разработал Евгений Краштан       *
 * E-mail: eug@el.cs.kiev.ua        *
 * Дата создания 20-03-93           */

#include <stdio.h>
#include <bios.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAXLEN  300     /* максим. длина строки символов */
#define MAXLINES 90     /* макс. число строк на странице */

int param_w = 128;  /* символов в строке */
int param_l = 52;   /* строк на листе */
char fname[50];     /* имя печатаемого файла */
FILE *fp, *fp1;     /* активные файлы */
char *buf, *strbuf, *fontbuf;  /* буффер страницы и шрифта */
char pil[MAXLINES]; /* место формирования столбца символов */
char outname[30] = "LPT1"; /* имя выходного устройства */
char fontname[30] = "vpr.fnt";   /* файл шрифтов */
char initstr[] = {27,79,24,27,'3',19,0}; /* инициализация принтера */
char firstpr[] = {10,13,27,'L',0};    /* программирование принтера */
int sym_l = 16;     /* количество строк в символе */
int len_p;          /* количество выводимых точек */
int blank = 1;      /* просвет между символами */

void readpage(void)
/* Считывание страницы из файла */
{
int i;

    for ( i = 0; i < param_l ; i ++ )
        if (fgets( &buf[ i * param_w ], param_w, fp) == NULL)
            break;
}

void toprn(int len)
/* принтер выводит одну графическую строку длиной len */
{
int i;

    fprintf(fp1,"%s",firstpr);
    fputc(len % 256, fp1);
    fputc((int)len / 256, fp1);
    for (i = 0; i < len; i ++)
        fputc((int) strbuf[i], fp1);

}

int convsym(void)
/* Формирует графическую строку (или столбец) и
 * возвращает номер последнего ненулевого байта в графической строке */
{
int i, j;
int r = 1;

    for ( i = 0; i < param_l; i ++) {
        for (j = 0; j < sym_l; j ++)
            if ((strbuf[i*(sym_l+blank)+j] = fontbuf[pil[i]*sym_l+j]) != 0)
                r = i*(sym_l+blank) + j;
        for (j = 0; j < blank; j ++)
            strbuf[i*(sym_l+blank)+sym_l+j] = 0;
    }

    return r + 1;
}

void prpage(void)
{
int i, j;
char c;

    printf("\nInsert next page and press any key...\n");
    bioskey(0);
    for ( i = param_w - 1; i >= 0; i -- ) {
        for ( j = 0; j < param_l; j ++)
            pil[j] = ((c = buf[param_w*j+i]) == '\0' || c == 10) ? ' ' : c ;
        toprn(convsym());
        printf("%3d\b\b\b",i);
    }

}

void clearpage(void)
{
    memset(buf,' ',param_w*param_l);
}

void initprn(void)
{
char c;
int i = 0;

    while ((c = initstr[ i ++ ]) != 0)
        putc(c, fp1);
}

main(argc, argv)
char **argv;
int  argc;
{
int i, j;

    if(argc > 1 ) {
        strcpy(fname, argv[1]);
        for (i = 2; i <= argc; i ++ )
            switch (j=toupper(argv[i][0]),argv[i]++,j) {
                case 'W':
                    param_w = (( j = atoi(argv[i]) + 1) <= MAXLEN) ?
                        ((j > 10) ? j : 10) : MAXLEN;
                    break;
                case 'L':
                    param_l = ((j = atoi(argv[i])) <= MAXLINES) ?
                        (( j > 3) ? j : 3) : MAXLINES;
                    break;
                case 'B':
                    blank = ((j = atoi(argv[i])) <= 99) ?
                        (( j > 0) ? j : 0) : 99;
                    break;
                case 'S':
                    sym_l = ((j = atoi(argv[i])) <= 64) ?
                        (( j > 1) ? j : 1) : 64;
                    break;
                case 'F':
                    strcpy(fontname,argv[i]);
                    break;
                case 'O':
                    strcpy(outname,argv[i]);
            }
    } else {
        printf("\n\tUsage:\n%s name [Wnn][Lnn][Bnn][Sn][Oout][Ffont]",argv[0]);
        printf("\n\n   Wnn - page width nn symb. (default 128)");
        printf("\n   Lnn - nn lines on page    (default 52)");
        printf("\n   Bnn - line spacing nn (default 1)");
        printf("\n   Sn  - Symbol size 8xn (default 8x16)");
        printf("\n   out - LPTn, COMn, or output file name (default LPT1)");
        printf("\n   font - font file name (default 'vpr.fnt')\n");
        exit(1);
    }

    printf("\n File name: %s   L%d  W%d  O %s  B%d \n",fname,
               param_l, param_w - 1, outname, blank);

    if ((fp = fopen(fontname,"rb")) == NULL) {
        printf("\n\007File not found: %s\n",fontname);
        exit(1);
    }

    fontbuf = malloc( 256 * 16 );
    fread( fontbuf, 256 * 16, 1, fp);
    fclose(fp);

    len_p = (sym_l + blank) * param_l;

    if ((fp = fopen(fname,"r")) == NULL) {
        printf("\n\007File not found: %s\n",fname);
        exit(1);
    }

    if ((fp1 = fopen(outname,"w+b")) == NULL) {
        printf("\n\007Error in device: %s\n",outname);
        exit(1);
    }

    initprn();

    if ((buf = malloc(param_w*param_l)) == NULL ||
            (strbuf = malloc(len_p)) == NULL) {
        printf("\n\007Memory allocation error!\n");
        exit(1);
    }
    i = 0;
    while (!feof(fp)) {
        clearpage();
        readpage();
        printf("\n Page %d", i ++ );
        prpage();
    }

    fclose(fp);
    fclose(fp1);
}
