char usage[] =
"RCconfig - Программа конфигурации RCONSOLE.COM. Версия 1.0\n"
"\n"
"Вызов : RCconfig <путь_к_RConsole> [<файл_шрифта> ...]\n"
"<путь_к_RConsole> местонахождение файла RCONSOLE.COM (имя и тип обязательны)\n"
"<файл_шрифта>     файл, содержащий шрифт в формате EVAFONT\n"
"Чтобы отредактировать раскладку клавиатуры - не указывайте ни одного шрифта.\n"
"\n"
"Автор: В.И.Брайченко (Vadim Braychenko), Центр подготовки космонавтов.\n"
"Адрес: 141160 Московская обл., Звездный городок, а/я 139.\n"
;
/*
* К сожалению, собрать эту программу заново из этого файла невозможно,
* т.к. она использует мою собственную библиотеку экранного в/в,
* которая не представлена исключительно по причине неготовности документации.
*/
#include <bioskeys.h>
#include <errno.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <vm.h>

char screen[] = /* screen image for keyboard layout editing */
"┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐"
"│! │@ │# │$ │% │^ │& │* │( │) │_ │+ │| │"
"│1 │2 │3 │4 │5 │6 │7 │8 │9 │0 │- │= │\\ │"
"└┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┘"
" │Q │W │E │R │T │Y │U │I │O │P │{ │} │  "
" │q │w │e │r │t │y │u │i │o │p │[ │] │  "
" └┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┐ "
"  │A │S │D │F │G │H │J │K │L │: │\" │~ │ "
"  │a │s │d │f │g │h │j │k │l │; │' │` │ "
"  └┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴┬─┴──┘ "
"   │Z │X │C │V │B │N │M │< │> │? │      "
"   │z │x │c │v │b │n │m │, │. │/ │      "
"   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘      "
"\n"
"Редактор раскладки клавиатуры\n"
"▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\n"
"\x1b\x12\x1a       перемещение курсора\n"
"Alt-ввод  новое значение клавиши\n"
"Space     восстановить умолчание\n"
"Esc       выход без изменений\n"
"Enter     выход с записью изменений"
;

int SomethingChanged = 0;            /* RCONSOLE.COM modification flag     */
char * RConsole;                     /* RCONSOLE.COM image array           */
char * RC_name;                      /* RCONSOLE.COM file name string      */
size_t RC_size;                      /* size of RCONSOLE.COM               */
char *f08,*f14,*f16;                 /* font offsets in file image array   */
char *xlat;                          /* translation table offset           */
#define  f08SIZE (size_t)(256 * 8  ) /* size of CGA-style screen font      */
#define  f14SIZE (size_t)(256 * 14 ) /* size of EGA-style screen font      */
#define  f16SIZE (size_t)(256 * 16 ) /* size of VGA-style screen font      */
#define xlatSIZE (size_t)('~'-'!'+1) /* size of keyboard translation table */

#define isLat(c) ((c)>='A' && (c)<='Z' || (c)>='a' && (c)<='z')
#define isRus(c) ((c)>='А' && (c)<='п' || (c)>='р' && (c)<='я')

char XchgCase(char c)
/*
* Extended char case switching routine
*/
{
	if      (c >= 'A' && c <= 'Z') return c + 32;
	else if (c >= 'a' && c <= 'z') return c - 32;
	else if (c >= 'А' && c <= 'П') return c + 32;
	else if (c >= 'Р' && c <= 'Я') return c + 80;
	else if (c >= 'а' && c <= 'п') return c - 32;
	else if (c >= 'р' && c <= 'я') return c - 80;
	else return c;
}

int Edit(void)
/*
* Screen editor of keyboard layout
*/
{
	int i = 1, j = 2, Key;

	vmA(i,j) = vmAttr(LRed_,Grey_);
	for (;;)
		switch (Key = vmGetKey()) {
		case Esc_:
			vmA(i,j) = vmAttr(LRed_,Black_);
			return 0;
		case Enter_:
			vmA(i,j) = vmAttr(LRed_,Black_);
			return 1;
		case Left_:
			if (j > 2 && vmA(i,j-3) == vmAttr(LRed_,Black_)) {
				vmA(i,j) = vmAttr(LRed_,Black_);
				j -= 3;
				vmA(i,j) = vmAttr(LRed_,Grey_);
			}
			break;
		case Right_:
			if (j < (vmNcol_-2) && vmA(i,j+3) == vmAttr(LRed_,Black_)) {
				vmA(i,j) = vmAttr(LRed_,Black_);
				j += 3;
				vmA(i,j) = vmAttr(LRed_,Grey_);
			}
			break;
		case Up_:
			if (i < 2) break;
			vmA(i--,j) = vmAttr(LRed_,Black_);
			if (vmA(i,j) != vmAttr(LRed_,Black_)) i--,j--;
			vmA(i,j) = vmAttr(LRed_,Grey_);
			break;
		case Down_:
			if (i > 10
			|| vmA(i+1,j) != vmAttr(LRed_,Black_)
			&& vmA(i+2,j+1) != vmAttr(LRed_,Black_)) break;
			vmA(i++,j) = vmAttr(LRed_,Black_);
			if (vmA(i,j) != vmAttr(LRed_,Black_)) i++,j++;
			vmA(i,j) = vmAttr(LRed_,Grey_);
			break;
		default :
			if ((char)Key) vmC(i,j) = (char)Key;
			break;
		}
}

void main(int argc, char **argv)
{
	unsigned int offset; /* offset to install code in RCONSOLE.COM */
	int i,j,OrigMode=vmMode_;

	if (argc == 1) {
		fputs(usage,stderr);
		return;
	}
	RC_name = argv[1];
	if(freopen(RC_name,"rb",stdaux) == NULL) {
		perror(RC_name);
		return;
	}
	RC_size = (size_t)filelength(fileno(stdaux));
	if ((RConsole = malloc(RC_size)) == NULL) {
		fputs(sys_errlist[ENOMEM],stderr);
		return;
	}
	if (!fread(RConsole,RC_size,1,stdaux)) {
		perror(RC_name);
		return;
	}
	/*
	* 1st command in RCONSOLE.COM is JMP NEAR Install,
	* translation tables and fonts are placed immediately before 'Install'.
	*/
	offset = *(unsigned int *)&RConsole[1] /* JMP offset */ + 3 /* JMP NEAR command size */;
	f08  = &RConsole[offset - f08SIZE - f14SIZE - f16SIZE - 2 * xlatSIZE];
	f14  = &RConsole[offset           - f14SIZE - f16SIZE - 2 * xlatSIZE];
	f16  = &RConsole[offset                     - f16SIZE - 2 * xlatSIZE];
	xlat = &RConsole[offset                               - 2 * xlatSIZE];

	if (argc == 2) {
		vmMode(CO40_);
		vmBlink(vmNoBlink_);
		vmCursor(vmHideCursor_);
		vmPut(0,0,vmNrow_,vmNcol_-1,screen,0);
		for (i = 1; i < 13; i += 3) {
			for (j = i/3+2; j < vmNcol_ && vmC(i,j-1) >= '!' && vmC(i,j-1) <= '~'; j += 3)
				vmA(i,j) = vmA(i+1,j) = vmAttr(LRed_,Black_);
			for (j = i/3+2; j < vmNcol_ && vmA(i,j) == vmAttr(LRed_,Black_); j += 3) {
				if (xlat[vmC(i,  j-1)-33] != vmC(i,  j-1)) vmC(i,  j) = xlat[vmC(i,  j-1)-33];
				if (xlat[vmC(i+1,j-1)-33] != vmC(i+1,j-1)) vmC(i+1,j) = xlat[vmC(i+1,j-1)-33];
			}
		}
		if (Edit()) {
			for (i = 1; i < 13; i += 3)
				for (j = i/3+2; j < vmNcol_ && vmA(i,j) == vmAttr(LRed_,Black_); j += 3) {
					if (vmC(i,  j) != ' ') xlat[vmC(i,  j-1)-33] = vmC(i,  j);
					else                   xlat[vmC(i,  j-1)-33] = vmC(i,  j-1);
					if (vmC(i+1,j) != ' ') xlat[vmC(i+1,j-1)-33] = vmC(i+1,j);
					else                   xlat[vmC(i+1,j-1)-33] = vmC(i+1,j-1);
				}
			for (i = 0; i < xlatSIZE; i++)
				if (!isLat(i+33) && isRus(xlat[i]))
					xlat[i+xlatSIZE] = XchgCase(xlat[i]);
				else
					xlat[i+xlatSIZE] = xlat[i];
			SomethingChanged = 1;
		}
		vmMode(OrigMode);
	}
	else for (argc -= 2, argv += 2; argc; argc--, argv++) {
		if (freopen(*argv,"rb",stdaux) == NULL) {
			perror(*argv);
			return;
		}
		else switch ((size_t)filelength(fileno(stdaux))) {
		case f08SIZE:
			fread(f08,f08SIZE,1,stdaux);
			SomethingChanged = 1;
			break;
		case f14SIZE:
			fread(f14,f14SIZE,1,stdaux);
			SomethingChanged = 1;
			break;
		case f16SIZE:
			fread(f16,f16SIZE,1,stdaux);
			SomethingChanged = 1;
			break;
		default:
			fputs(*argv,stderr);
			fputs(" : неверный размер файла шрифта\n",stderr);
			break;
		}
	}
	if (SomethingChanged) {
		if (freopen(RC_name,"wb",stdaux) == NULL
		|| !fwrite(RConsole,RC_size,1,stdaux))
			perror(RC_name);
	}
}
