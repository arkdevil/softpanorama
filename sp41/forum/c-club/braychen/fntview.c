#pragma option -K -O -Z -d -ff -ms

char usage[] =
"FNTVIEW Версия 1.0\n"
"\n"
"Программа FNTVIEW служит для быстрого просмотра экранных шрифтов,\n"
"созданных с помощью редактора EVAFONT (или аналогичного).\n"
"Шрифты показываются с увеличением в 2 раза по X и по Y.\n"
"\n"
"Вызов: FNTVIEW файл1 [файл2]\n"
"Если указан 2й файл и видеоплата поддерживает 2 графические видеостраницы,\n"
"то с помощью клавиши 'Tab' можно переключаться с одного файла на другой.\n"
"Все остальные клавиши прекращают работу программы.\n"
"\n"
"Автор: В.И.Брайченко (Vadim Braychenko), Центр подготовки космонавтов.\n"
"Адрес: 141160 Московская обл., Звездный городок, а/я 139.\n"
;
/*
* Программа написана на Turbo C с использованием BGI, причем драйвер
* EGAVGA.BGI (самого распространенного адаптера) и шрифт TRIP.CHR
* компонуются вместе с программой. Другие драйверы (если это необходимо!)
* программа ищет в текущем каталоге.
* У меня весь BGI превращен в .OBJ-файлы и помещен в GRAPHICS.LIB, поэтому
* для получения .EXE-файла достаточно команды: TCC FNTVIEW GRAPHICS.LIB
* хотя в общем случае необходимо: TCC FNTVIEW EGAVGA.OBJ TRIP.OBJ GRAPHICS.LIB
*/
#include <bios.h>
#include <graphics.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_HEIGHT     16
#define X0              2
#define Y0             34
#define DELTA_X        20
#define DELTA_Y        40
#define CHARS_PER_ROW  32
#define TOTAL_CHARS   256

char bit[] = {0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01};

void DisplayScanLine(char data,int x,int y)
{
	int i;

  for (i = 0; i < sizeof bit; i++)
		if (data & bit[i]) bar(x + i * 2,y,x + i * 2 + 1,y + 1);
}

void DisplayFontFile(char *fname,int page)
{
	FILE *ffile;
	long fsize;
	int fheight,charcode,scanline,x,y;
	char header[80];

	if ((ffile = fopen(fname,"rb")) == NULL) {
		closegraph();
		perror(fname);
		exit(EXIT_FAILURE);
	}
	fsize = filelength(fileno(ffile));
	if ((fheight = (int)(fsize / TOTAL_CHARS)) > MAX_HEIGHT) {
		closegraph();
		fputs(fname,stderr);
    fputs(" : файл шрифта слишком велик",stderr);
		exit(EXIT_FAILURE);
	}
	setactivepage(page);
	settextstyle(TRIPLEX_FONT,HORIZ_DIR,0);
	settextjustify(CENTER_TEXT,TOP_TEXT);
	setusercharsize(1,1,3,4);
  sprintf(header,"%s (8 x %d)",fname,fheight);
	outtextxy(getmaxx()/2,0,header);
	for (charcode = 0; charcode < TOTAL_CHARS; charcode++) {
		x = charcode % CHARS_PER_ROW * DELTA_X + X0;
		y = charcode / CHARS_PER_ROW * DELTA_Y + Y0;
		for (scanline = 0; scanline < fheight; scanline++)
			DisplayScanLine(getc(ffile),x,y + scanline * 2 + (MAX_HEIGHT - fheight));
	}
}

int main(int argc,char ** argv)
{
	int gdriver,gmode,gpages,errorcode;

	if (argc == 1) {
		fputs(usage,stderr);
		return EXIT_FAILURE;
	}
	if ((errorcode = registerbgidriver(EGAVGA_driver)) < 0
	||  (errorcode = registerbgifont(triplex_font))    < 0) {
		fputs(grapherrormsg(errorcode),stderr);
		return EXIT_FAILURE;
	}
	detectgraph(&gdriver,&gmode);
	if ((errorcode = graphresult()) != grOk) {
		fputs(grapherrormsg(errorcode),stderr);
		return EXIT_FAILURE;
	}
	switch (gdriver) {
	case CGA:
    fputs("CGA не поддерживается - мало разрешение",stderr);
		return EXIT_FAILURE;
	case MCGA:
		gmode = MCGAHI;
		gpages = 1;
		break;
	case EGA:
		gmode = EGAHI;
		gpages = 2;
		break;
	case EGA64:
		gmode = EGA64HI;
		gpages = 1;
		break;
	case EGAMONO:
		gmode = EGAMONOHI;
		gpages = 1;
		break;
	case IBM8514:
		gmode = IBM8514LO;
		gpages = 1;
		break;
	case HERCMONO:
		gmode = HERCMONOHI;
		gpages = 2;
		break;
	case ATT400:
		gmode = ATT400HI;
		gpages = 1;
		break;
	case VGA:
		gmode = VGAMED;
		gpages = 2;
		break;
	case PC3270:
		gmode = PC3270HI;
		gpages = 1;
		break;
	default:
    fputs(grapherrormsg(grNotDetected),stderr);
		return EXIT_FAILURE;
	}
	initgraph(&gdriver,&gmode,NULL);
	if ((errorcode = graphresult()) != grOk) {
		fputs(grapherrormsg(errorcode),stderr);
		return EXIT_FAILURE;
	}
	DisplayFontFile(argv[1],0);
	if (argc == 2 || gpages == 1) bioskey(0);
	else {
		int page = 0;
		DisplayFontFile(argv[2],1);
    while (bioskey(0) == 0x0f09 /* <Tab> */) setvisualpage(page = !page);
	}
	closegraph();
	return EXIT_SUCCESS;
}
