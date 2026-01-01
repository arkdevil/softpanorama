
/*█████████████████████████████████████████████████████████

	Copyright (c) 1993 by Gaydarenko Nickolay

		All Rights Reserved.

		 tel.(095)244-3091

  █████████████████████████████████████████████████████████*/

#include	"eg.h"

int	cx, cy, ox, oy,
	tx, ty, ff,y_m,
	wx, wy, ww, wh,
	ar,fa,txx,ctrl,
	i,j, cuu, view,
	nstr,shift, vi,
	f_rec,end=1,sy,
	m_add = 1000;
unsigned k, l, l_m, coun=1, cl, cu, ch0, ch1, stpcom;

int	form[] = {78, 2, 2};

char	str[25]="  ver 25.12.93", *stack[10],
	*fi="eg.ini", ph[30]="eg.hlp", *pcom, con[24];

char near *wcs = "┌┐┘└│─",tcorr[]="* ",tr[]=" R",//╔╗╝╚║═
	*pa = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";

char	*AltMac[26];

char	flagoptions[] = {0,1,0,0};

char	*cps,*tp,*bm,*p0,*p1,*pm,*ps,*pbox,*tpp;
int	*bs,*bsc;

main(int argc, char *argv[]) {
	edit(0,0,80,24,argv[1],0);
//	printf( "*2* %ld *2*", coreleft()); getch();
return argc;
}

int edit(int vx,int vy,int vw,int vh,char *fnm, int flag) {
unsigned a;
	for (a = i = 0; win[i]; i++);		// поиск места
	if (w) { a = w->cw+1; PushVar(); }
	if (i>8||!(win[i]=w=(sw *)calloc(sizeof(sw),sizeof(char)))) return 0;// много окон
	w->cw = i; w->nw = a;
	wx = vx; wy = vy; ww = vw; wh = vh;
	ATRM = 112<<8; ATRF = 30<<8;
	CORR = F_INS = 1; tcorr[1] = tr[0] = wcs[5];
	if (!a) {				// пришли впервые
	   bsc = (int *)MK_FP(VSG,0)+2000;
	   gettext(1,1,80,25,(bs=bsc+2000));	// упр основное окно
	   memcpy(bsc,bs,4000);
	   INIT_MOUSE; InitEdit();
	}
	PushScreen();
	if (!fnm) { fnm = pa; flag = 2; }
	if (!flag) {
	   strcpy(F_N, fnm);
	   if (!(AREA = ReadFile(F_N,m_add))) { Escap(); return 0; }
	   if (flagoptions[0]) CreatBakFile();
	}
	else {
	   l = strlen(fnm);
	   if (!(AREA = (char *)malloc(LIMM = l+m_add))) return 0;
	   strcpy(AREA, fnm);
	}
	PS = AREA; LIM = l; l_m = vi = 0;
	CURSOR_SET(wx+ww,wy+wh);		// курсор на рамку
	ResetScreen();

	while (end) {
	    Lift(vi);
	    tp = p0 = pos(PS,(sy=ty-wy-2));	// база строки
	    a = tx+BX-wx-2;			// адрес курсора в строке
	    p1 = strchr(p0,'\n')+1;
	    for (j = 0; j < a && *tp != '\n';)
		j = (*tp++ == '\t' ? FunTab(j) : j+1);
	    if (cuu && *(tp-1) == '\t' && !fa)
		{ a = j; tx = wx+2+j-BX; Lift(vi); }
	    i = a-j; ar = -1; coun++;
	    *(cps = str+1) = cuu = 0;
	    ff = CheckMark(tp);			// флаг расположения курсора в поле
	    if (pcom)
		Command();
	    else {
		pkf = arrkey;
		PutScreen(PS);
		if (view == 4)			// ascii
		   view = 0;
		else {
		    if (shift == 1)
			shift = 0;
		    else
			{ ch0 = GetChar(); HIDE_CURSOR; }
		    if (ch1 < ' ')
			while ((++pkf)->key != 255 && pkf->key != ch0);
		}
		if (view && pkf->flag) continue;// запрещена корр.
		if (f_rec) PutRecoder();
		(*(pkf->nameutil))();
	    }
	}
	end = 1;
	return 1;
}

void StartMacro(void)	{ if (question(24,(tp=cps),"File macro:")) LoadMacro();}//SF6

void Insert(void)	{ _setcursortype(cursor[F_INS ^= 1]); }		// Ins

void CtrlPageDoun(void) { cuu = vi = 9999; PS = pos(p0,vi); }		//^PgDn

void CtrlPageUp(void)	{ vi = 0; cuu = 1; PS = AREA; }			//^PgUp

void CtrlHome(void)	{ cuu = vi -= sy; ty = 0; }			//^Home

void SaveFile(void)	{ WriteDir(F_N,AREA,LIM); CORR = 1; }		// F2

void BlockPop(void)	{ if (pbox) MacroSub(pbox,1); }			// ^F5

void BlockSto(void)	{ free(pbox); pbox = CpyBox(); }		// ^F4

void PopWindow(void)	{ if (win[j=ch0-ALT]) {PushVar(); PopVar(j); ResetScreen();}}

void Empty(void)	{ }

void Home(void)		{ BX = tx = 0; }

void BlockOff(void)	{ FS = y_m = l_m = 0; }				// ^F3

void BlockBegin(void)	{ BlockOff(); bm = tp; l_m = LIM-(tp-AREA); }	// ^F8

void BlockEnd(void)	{ if ((i=tp-bm)>0) l_m=i; else {l_m-=i;bm=tp;} }// ^F9

void Set(void)		{ if ((l=(fa^((ch0-F-2)|2))) != 1) fa = l; }	// F3,F4

void CreatFrame(void)	{ edit(wx+1,wy+1,ww-1,wh-1,pa,1); }		// F5

void Ascii(void)	{ view = 3; edit(61,0,18,18,pa,1);  }		//~F10

void HelpEdit(void)	{ view = 1; edit(wx+2,wy+2,ww-2,wh-2,ph,0); }	// F2

void PushCursor(void)	{ PCUR = tp; }					// ~F3

void PopCursor(void)	{ if (PCUR) FindLine(PCUR); }			// ~F2

void BlockSave(void) {							// ^F4
char	p[40];
	strcpy(p,F_N);
	if (!l_m || !question(24,p,"Block save as:")) BELL;
	WriteDir(p,bm,l_m);
}

void BlockLoad(void) {							// F10
char	*p;
	if (question(24,cps,"File name:") && (p=ReadFile(cps,0)))
	   { FS = 1; MacroSub(p,1); free(p); }
}

void Word(void) {							// ~F5
char	p[20];
unsigned c;
	c = GetChar();
	for (pkf = arrkey; (++pkf)->key && pkf->key != c;);
	*p = '~'; strcpy(p+1, pkf->namekey); strcat(p, ";");
	MacroSub(p+!shift, 0);
}

void BlockCopyMove(void) {						// F1,F2
	if (!(p0 = CpyBox())) return;
	if (ch0 != C_F) {			// move
	   if (ff) { free(p0); BELL; }		// курсор находится в поле
	   if (PS > bm) PS -= l_m;		// поле выше окна
	   DelMar();
	}
	MacroSub(p0,1);
	free(p0);
}

void Macro(void) {							// ALT
char	*p,*pw,pc[3];
unsigned l;
	if (pcom) {
	   if (*pcom != '') return;
	   ch0 = *(pcom+1); pcom += 3;
	   p = AltChar;
	}
	else {
	   if (ctrl) return;
	   p = AltKod;
	}
	if ((pw = strchr(p,ch0)) && AltMac[l=pw-p]) {
	   if (f_rec) {
		*pc = *(pc+2) = ''; *(pc+1) = AltChar[l];
		write(f_rec, pc, 3);
	   }
	   stack[stpcom++] = pcom; pcom = AltMac[l]; Command();
	}
}

void Dos(void) {							// ~F1
	if (question(24,cps,"Command DOS ")) {
	   system("cls"); system(str+1);
	   putch('\a'); bioskey(0); ResetScreen();
	}
}

void GotoLine(void) {							// F6
int	j;
	if (!question(5,cps,"Line number:")) return;
	if ((j = Atoi(cps)) > NS) BELL;
	PS = pos(AREA,j-1);
	vi = j; ty = 0; Home();
}

void FindContext(void) {						// F7
unsigned c,lc,nc;
	if (!shift && !TextContext()) return;
	if (tp == bm) tp++;			// стоим в начале поля
	nc = vi; lc = strlen(con);
	do {
	   if (!(c = *tp++)) BELL;		// end file
	   if (c == '\n') nc++;
	} while (c != *con || strncmp(tp-1,con,lc));
	l_m = lc;				// контекст найден
	Back((bm = tp-1));			// вычисление позиции
	CheckScreen(nc);
	if ((BX = j+l_m-ww+2) < 0) BX = 0;
	tx = wx+2+j-BX;
}

void Subst(void) {							// ~F8
char	c,sub[24];
unsigned ls,lc,nc;
	*sub = 0;
	if (!TextContext() || !question(24,sub,"Subst:")) return;
	nc = vi; lc = strlen(con); ls = strlen(sub);
	while (c = *tp++) {			// end file
	   if (c == '\n') nc++;
	   if (c != *con || strncmp(tp-1,con,lc)) continue;
	   strdec(--tp,lc); strinc(ls); memcpy((bm = tp),sub,(l_m = ls));
	   tp += ls; vi = nc; ty = 0;
	}
	if (ty) BELL;
	Back(bm); PS = p0;
}

void LoadFile(void) {							// F9
	if (!view && !question(24,F_N,"File name:")) return;
	if (!(p0= ReadFile(F_N,m_add))) return;
	free(AREA);
	PS = AREA = p0; PCUR = 0;
	CORR = 1; LIM = l; vi = 0; BlockOff();
}

void Escap(void) {
int	i;
	if (fa) { fa = 0; return; }
//	if (ARR) strcpy(ARR,AREA);
	if (!CORR) {
	   if (!question(0,0,"File save ?(Y/N)")) return;
	   if ((ch1|0x20) != 'n') SaveFile();
	}
	PopScreen();
	win[w->cw] = 0;
	i = w->nw-1; j = p0-AREA; end = 0;
	free(AREA); free(w);
	if (!view) {
	   for (i = 0; i < 9 && !win[i]; i++);
	   if (i == 9) {
		close(f_rec);
		free(pbox); free(pm);
		puttext(1,1,80,25,bs);
		_setcursortype(_NORMALCURSOR);
		return;
	   }
	}
	view = 0;
	PopVar(i); ResetScreen();
}

void MoveFrame(void) {
	do {
	   if (ox==cx&&oy==cy||cx-ww<0||cy-wh<0||cx>COL||cy>LIN-1) continue;
	   PopScreen();
	   tx -= wx; ty -= wy;
	   tx += (wx = cx-ww); ty += (wy = cy-wh);// новые координаты
	   PushScreen(); ResetScreen();
	} while (READ_CURSOR == 2);
}

void ReSize(void) {
	vi += 2-ty;
	do {
	   if (ox==cx&&oy==cy||cx-wx<5||cy-wy<5||cx>COL||cy>LIN-1) continue;
	   PopScreen();
	   ww = cx-wx; wh = cy-wy;
	   tx = ty = 0;
	   PushScreen(); ResetScreen();
	} while (READ_CURSOR == 1);
}

void Zoom(void) {							// ^F7
	PopScreen();
	if (w->oh)
	   { wx=w->ox; wy=w->oy; ww=w->ow; wh=w->oh; w->oh=0; }
	else
	   { w->ox=wx; w->oy=wy; w->ow=ww; w->oh=wh; wx=wy=0; ww=80; wh=24; }
	PushScreen();
	vi += 2-ty;
	tx = ty = 0;
	ResetScreen();
}
      
void Enter(void) {
	if (view == 1) return;			// help
	if (view > 1) {				// ascii/dir
	   if (!(ch1=tx-wx-2+sy*16)) ch1= ' ';
	   Escap(); view = 4; return;
	}
	for (; *p0 <=  ' ' && p0 < tp; p0++);
	Back(p0); i = j+1; border();
	*(tp-i) = '\n'; NS++; CheckLine(1);
}

void Tab(void) {
unsigned j;
	if (i <= 0 && !shift) {
	   ch1 = '\t'; tx--;
	   InputChar();
	}
	j = tx+BX-wx-2;
	CheckCol(((j+(shift?-1:TB))&0xfff8)-j);
}

void BackSpase(void) {
	if (tp == AREA) return;			// вначале
	if (i > 0) { tx--; return; }		// внe строки
	if (*--tp == '\n')			// корр. номера строки
	   { NS--; CheckLine(-1); }
	Back(tp);
	strdec(tp,1);
}

void Delete(void) {
	if (shift) {
	   if (!l_m) BELL;
	   FindLine(tp = bm);
	   if (!*(bm+l_m)) PS = p0-BegStr(p0-1)-1;
	   DelMar(); BlockOff();
	   return;
	}
	if (i > 0 || !(*(tp+1))) return;	// конец убить нельзя
	if (*tp == '\n') NS--;
	strdec(tp,1);
}

void End(void) {
	if (shift)				// выделение до конца строки
	   { BlockBegin(); l_m = p1-tp-1; return; }
	for (i=0;--p1>p0&&isspace(*(p1-1));i++);// исключение хвостовых пробелов
	Back(p1);
	if (i) strdec(p1,i);			// длина фрагмента
}

void CtrlY(void) {
	l = p1-p0; tx = 0;
	if (*p1) NS--; else l--;
	if (bm > p0 && bm <= p1) {		// выд.внутри строки
	   if (p1 >= bm+l_m)
		l_m = 0;
	   else
		{ l_m -= p1-bm; bm = p1; }
	}
	strdec(p0,l);
}

void InputChar(void) {
	border();
	if (F_INS || !*(tp+1))
	   strinc(1);
	else
	   if (*tp == '\n') NS--;
	*tp = ch1; CORR = 0;
	CheckCol(1);
}

void CtrlRight(void) {
	for (; *tp > ' '; tp++);
	while (*tp != '\n' && *++tp <= ' ');
	Back(tp);
}

void CtrlLeft(void) {
	while (--tp >= p0 && *tp <= ' ');	// прогон пробелов
	for (; tp >= p0 && *tp > ' '; tp--);
	Back(tp+1);
}

void PageUp(void) {
	if ((vi += (cuu = (ch0 == PGDN ? wh-2 : 2-wh))) > NS) cuu += wh-2;
	if (vi-sy <= 0) vi = 0;
	PS = pos(PS,cuu);
}

void CtrlEnd(void) {
	vi += wy+wh-1-ty; ty = wy+wh-1;
	if ((cuu = vi-NS) > 0)
	   { vi = NS; ty -= cuu; }
}

void Directory(void) {							// ~F4
char	*p,*pw;
int	i;
struct	ffblk f;
	pw = p = (char *)malloc(8000);
	memset(p,' ',8000);
	for (i = findfirst("*.*",&f,0); !i; i = findnext(&f)) {
	    memcpy(pw,f.ff_name,strlen(f.ff_name));
	    *(pw+21) = *(pw+24) = '-'; *(pw+30) = ':'; *(pw+33) = '\n';
	    Itoa(f.ff_fsize, pw+13);
	    iTOa( f.ff_fdate & 0x001f, pw+19);
	    iTOa((f.ff_fdate & 0x01e0)>>5, pw+22);
	    iTOa(((f.ff_fdate& 0xfe00)>>9)+80, pw+25);
	    iTOa((f.ff_ftime & 0xf800)>>11, pw+28);
	    iTOa((f.ff_ftime & 0x07e0)>>5, pw+31);
	    pw += 14+6+9+5;
	}
	*pw = 0;
	view = 2; edit(44,0,35,15,p,1);
	if (ch0 != ESC) {
	   *(strchr(p+j,' ')) = 0; strcpy(F_N, p+j);
	   LoadFile();
	   view = 0; ResetScreen();
	}
	view = 0; free(p);
}

void SetRecoder(void) {							// ~F9
	if (f_rec) {				// выкл. рекодер
	   k = (k != 0);
	   write(f_rec, "\n};"+k, 4-k); close(f_rec);
	   f_rec = 0; return;
	}
	if ((f_rec = open("recoder", O_TRUNC|O_RDWR|O_CREAT,S_IWRITE)) == -1)
	   { question(15," press ESC key","error opening file "); f_rec = 0; }
	else
	   k = write(f_rec, "R:{\n", 4);
}

void Up(void) {
	if (ch0 == DOWN) ar = 1;
	if (fa) { SizeMove(1); return; }
	if ((cuu = vi+ar) > NS || cuu <= 0) return;
	CheckLine(ar);
	if (shift) {
	   if (coun == cl+1) {
		if (y_m+ar < 0) return;
		y_m += ar; cl = coun;
	   }
	   else {
		if (coun != cu+1) { bm = tpp = p0; BlockOff(); }
		FS = 1;
		i = abs((p1=pos(p0, ar))-p0);
		j = (p1 == tpp && ar > 0);
		bm  += i*(p1 >= tpp ? j : ar);
		l_m += i*(p1 >= tpp ? (j ? -1 : ar) : -ar);
	   }
	   cu = coun;
	}
}

void Left(void) {
int	k,l;
	ar = k = (ch0 == AR ? 1 : -1);
	if (fa) { SizeMove(0); return; }
	if (i <= 0) {				// внутри строки
	   for (l = 0; p0 < tp+ar; p0++)
		l = (*p0 == '\t' ? FunTab(l) : l+1);
	   k = l-j;
	   if (shift && j+ar >= 0) {
		if (coun != cl+1) { bm = tp; txx = j; BlockOff(); }
		cl = coun;
		i = (l == txx && ar > 0);
		bm  += (l >= txx ? i : ar);
		l_m += (l >= txx ? (i ? -1 : ar) : -ar);
	   }
	}
	CheckCol(k);
}

void SaveAs(void) {							// F8
char	*p,*pa,pn[40];
unsigned j,l,ll,f;
	if (!question(24,strcpy(pn,F_N),"Save as: ")) return;
	if (!ctrl) { WriteDir(pn,pa = AREA,ll = LIM); return; }
	p = (char *)malloc(ll);
	for (l = j = 0; l < ll;) {		// for WORD
	   for (f = l; *(pa+l) == '\n'; l++);
	   if (l-f > 1 && j) *(p+j-1) = '\n';
	   for (; (*(p+j++) = *(pa+l)) > ' '; l++);
	   *(p+j-1) = ' ';
	   for (; *(pa+l) == ' '; l++);
	}
	*(p+j-2) = '\n';
	WriteDir(pn,p,j);
	free(p);
}

void Cent(void) {							// F10
int	k,i,j,l;
	tp = p1-1; l = tp-p0;
	for (i = j = 0; i < l; i++)
	    if (*(p0+i) > ' ' || *(p0+i+1) > ' ') j++;
	if (!j || j > LST) return;
	k = (LST-j)/2;
	strinc(j+k); memset(tp,' ',j+k);
	for (i = 0; i < l; i++)
	    if (*(p0+i) > ' ')
		*(tp+k++) = *(p0+i);
	    else
		if (*(p0+i+1) > ' ') k++;
	strdec(p0,l);
}

void Form(void) {							// F9
unsigned lm,s1,s0,m,n,i,j,k,l,cls,bbs,f,pw[40];
char	*pb,pl[40];
	if (!l_m) BELL;
	tp = bm; f = ff = 2;
	for (lm = i = j = 0; j < l_m; j++,tp++) { // число строк
	    if (*tp > '@') continue; 		// чтоб было побыстрей
	    n = *(tp+1);
	    if ((m = *tp) == '\n') {		// переносы
		NS--;
		if (*(tp-1) == '-' && *(tp-2) != ' ') {
		   for (k = 1; *(tp+k) == ' '; k++);
		   strdec(tp-1,k+1);
		}
	    }
	    if (m == '(' && n == ' ') {
		for (k = 2; *(tp+k) == ' '; k++);
		strdec(tp+1,k-1);
	    }
	    if ((m == '.' || m == ',' || m == ':') && n != ' ' && m != n)
		if (!isdigit(*(tp-1)))
		   { tp++; j++; strinc(1); *tp = ' '; }
	}
//	l = l_m+l_m/10+(BST*l_m+LST)/(LST-BST-EST);
	if (!(pb = (char *)malloc(64000))) return;
	memset(pb, ' ', 64000);
	do {
	   j = 0; l = bbs = BST+3*(f > 1); cls = LST+1-EST; s0 = 1; s1 = 255;
	   for (;;) {
		for (f = 0; *(bm+i) <= ' '; i++)
		   if (*(bm+i) == '\n') f++;
		if (i >= l_m || f > 1) break;	// конец маркера,начало абзаца
		for (pw[j] = k = i; *(bm+i) > ' '; i++);
		m = i-k;			// длина слова
		if (l+m+1 > cls) {
		   s0 = 1+(cls-l)/(j-1); s1 = j-1-(cls-l)%(j-1);
		   i = k; l = cls;
		   break;			// строка не последняя
		}
		pl[j++] = m;			// длина слова
		l += m+1;
	   }
	   for (m = lm+bbs,k = 0; k < j; k++) {	// форм.строки
		memcpy(pb+m,bm+pw[k],pl[k]);
		m += pl[k]+s0+(k >= s1);
	   }
	   lm += l; *(pb+lm-1) = '\n'; NS++;
	   if (f > 1) { *(pb+lm++) = '\n'; NS++; }
	} while (i < l_m);
	strdec(tp = bm,l_m); strinc(lm); memcpy(tp,pb,l_m = lm);
	free(pb); FindLine(bm = tp);
}

//				Утилиты

int GetChar(void) {
unsigned k, j, ch = 4;
	SHOW_CURSOR;
	for (;;) {
	   do {
	      shift = ctrl = k = 0; j = ch;
	      switch (bioskey(2)&15) {
		 case 8: ch = 3; break;		// alt
		 case 4: ch = ctrl = 1; break;	// ctrl
		 case 2:case 1:ch = shift = 2; break;// shift
		 default: ch = 0; k = ((fa&1)+2)*8+3;
	      }
	      if (j != ch) {
		 PutStr(0,LIN-1,fun[ch],112);	// делаем фишку
		 if (k)
		    for (j = 0; j < 5; j++, k++)
			PUT_CHA(k,LIN-1,*(fun[ch]+k),but_col[fa>>1]);
	      }
	      if (bioskey(1)) {			// есть символ
		 ch1 = (j = bioskey(0))&255;
		 return (ctrl && ch1 && ch1 < ' ')<<8|(j>>8);
	      }
	   } while (!(k = READ_CURSOR));		// чтение состояния мыши
	   if (cx == wx+ww && cy == wy+wh) return k == 1 ? SS : MF;
	   while (READ_CURSOR);			// отжатие
	   j = 9; ch1 = 0;
	   if (!view && (cx <= wx+1 || cx > wx+ww || cy <= wy || cy > wy+wh))
	      while (j--)
		  if ((v=win[j]) && (cx > v->wx+1 &&
		     cx <= v->wx+v->ww && cy > v->wy && cy <= v->wy+v->wh))
			return j+ALT;		// переход в другое окно
	   if (k == 1) {
		if (cy == LIN) return fb[ch]+(cx-1)/8;
		if (cx == wx+ww) {		// ползунки
		   if (cy == wy+wh-1) return DOWN;
		   if (cy == wy+2)    return UP;
		   if (cy > wy+2 && cy <wy+wh-1) return cy>wy+2+MRY?PGDN:PGUP;
		}
		if (cy == wy+1) {
		   if (cx == wx+4)    return ESC;
		   if (cx == wx+ww-3) return C_F+6; // zoom
		}
		if (cx > wx+1 && cx < wx+ww && cy > wy+1 && cy < wy+wh && (j = vi+cy-ty) <= NS) {
		   vi = j; tx = cx; ty = cy;
		   shift = (shift != 0);
		   return (shift ? (l_m ? C_F+8 : C_F+7) : GOTO);
		}
	   }
	}
}

void frame(int ww,int wh,char *titl,int atr) {
int	y, j, *p, *ph;
char	pw[80];
	atr <<= 8; p = bsc+wx+wy*80; ph = p+(wh-1)*80;
	for (y = 1; y < wh-1; y++)
	    *(p+y*80) = wcs[4]|atr;		// │
	memset(pw,wcs[5],80);			// ─
	memcpy(pw+2,"[■]",3);
	*pw = wcs[0]; *(pw+ww-1) = wcs[1];	// ┌┐
	j = strlen(titl);
	if ((y = (ww-6-j)/2) > 0 && !view) {	// выдача заголовка
	   memcpy(pw+ww-5, "[]" ,3);
	   memcpy(pw+y+5, titl, j);
	   *(pw+ww-7) = w->cw+'1';
	}
	for (y = 0; y < ww; y++)		// пере. верхней рамки
	    { *(p+y) = *(pw+y)|atr; *(ph+y) = wcs[5]|atr; }
	*ph = wcs[3]|atr; *(ph+ww-1)=wcs[2]|atr;// └┘
	if (wh >= 5) {
	   *(p+80+ww-1)        = ''|atr;
	   *(p+(wh-2)*80+ww-1) = ''|atr;
	   for (y = 2; y <= wh-3; y++)
		*(p+y*80+ww-1) = '▓'|atr;
	   if (ww >= 5+18) {
		for (y = 18; y <= ww-3; y++)
		    *(ph+y) = '▓'|atr;
		*(ph+17)    = ''|atr;
		*(ph+ww-2)  = ''|atr;
	   }
	}
}

char *pos(char *p, int c) {
char *pc;
	if (c > 0) {
	   for (; c > 0; c--)
		if (!*(p=strchr((pc=p), '\n')+1)) return pc;// конец файла
	   return p;
	}
	else {
	   for (c--; c < 0; c++)
		while (p != AREA && *--p != '\n');// гоним до конца строки
	   return p+(p != AREA);
	}
}

void PutStr(int x,int y, char *str,int atr) {
	while (*str)
	   PUT_CHA(x++, y, *str++, atr);
}

int TextContext(void) {
unsigned l;
	memcpy(con, bm, (l = l_m < 23 ? l_m : 23));
	*(con+l) = 0;
	return question(24,con,"Context:");
}

int CheckMark(char *p) { return (l_m && bm <= p && bm+l_m > p); }

void PushVar(void) { TX=tx; TY=ty; BM=bm; L_M=l_m; WX=wx; WY=wy; WW=ww; WH=wh; }

void PopVar(int i) { w = win[i]; tx=TX; ty=TY; bm=BM; l_m=L_M; wx=WX; wy=WY; ww=WW; wh=WH; vi=CLIN; }

void Lift(int ln) {
int	*p,j,atr;
char	*pw,pl[9];
	if (ln <= 0 || ln > NS) {
	   ty = 0; Home();
	   for (NS = 0, p0=AREA-1; *++p0; NS++)	// подсчет  строк
		if (!(p0=strchr(p0,'\n'))) return;
	}
	if (!tx) tx = wx+2;
	if (!ty) ty = wy+2;
	if (!pcom) gotoxy(tx,ty);
	vi = CLIN = ln < 1 ? 1 : (ln > NS ? NS : ln);
	atr = ATB<<8;
	*(p=bsc+wx+wy*80+6) = tr[f_rec!=0]|atr;	// маркер рекодера
	p += ww-7;
	*(p+(2+MRY)*80) = '▓'|atr;		// обнулить старый маркер
	*(p+(2+(MRY=(vi-1)*(wh-4)/NS))*80) = '■'|AT<<8;// выдать новый маркер
	p = bsc+wx+(wy+wh-1)*80;
	*(p+3) = tcorr[CORR]|atr;
	if (fa || ww < 20) return;
	memset(pl,wcs[5],9);
	*(pw = Itoa(vi,pl)) = ':';
	Itoa(tx-wx-1+BX,pw+1);
	for (j = 0; j < 9; j++)			// делаем фишку
		*(p+7+j) = *(pl+j)|atr;
	j = BX/8;
	*(p+18+MRX) = '▓'|atr;			// обнулить старый маркер
	*(p+18+(MRX=(j > ww-23 ? ww-21 : j))) = '■'|AT<<8;
}

int read_str(char *ps,int x,int y,int l_str,int atr) {
int	cx = x, i, l, j = 1, CX;
char	*pb, *p;

    if (!(pb = (char *)malloc(l_str+1))) return 0;
    strcpy(pb, ps);
    for (;;) {
	for (i = 0; i < l_str; i++)
	    PUT_CHA(x+i, y,' ',atr);
	PutStr(x,y,pb,atr);
	CX = cx-x;
	p = pb+CX;
	gotoxy(cx+1,y+1);
	for(l = i = strlen(pb); *(--i+pb) == ' '; ); i++;
	ch0 = GetChar();
	if (ch1 < ' ')
	   switch (ch0) {
		case INS:  Insert(); break;
		case HOME: i = 0;
		case END:  cx = i+x; break;
		case DEL:  if (*p) strcpy(p, p+1); break;
		case AR:   cx++;
		     if (l <= CX )		// последний символ строки
			{ *(pb+l) = ' '; *(pb+l+1) = 0; }
		     break;
		case ENT:
		case CTRL_ENT:
		     *(pb+i) = 0; strcpy(ps, pb); j = 0;
		case ESC:  free(pb);
			return !j;
		case BS:   if (cx == x) break;
		     strcpy(p-1, p);
		case AL:   cx--; break;
		default: putch('\a');
	   }
	   else {
		if (ctrl) {
		   if (ch0 == BS) { cx = x; *pb = 0; }
		   continue;
		}
		if (CX > i) i = l;
		if (i >= l_str) continue;
		if (F_INS)
		   for (i++; i != (CX-1); i--)
			*(pb+i+1) = *(pb+i);
		else
		   if (i >= CX) *(pb+i+1) = 0;
		*p = ch1;
		cx++;
	   }
	   if (cx-x >= l_str) cx = l_str+x-1;
	   if (cx-x < 0) cx = x;
    }
}

int question(int lsi,char *si,char *so) {
unsigned l, v, y, a, wx, *p;
	if (*pcom == '') {
	   ch1 = *++pcom;
	   if (lsi) {
	      while ((*si++ = *pcom++) != '');
	      *--si = 0;
	   }
	   return ch1;
	}
	v = (l = strlen(so))+lsi+2;
	wx = (80-v)/2; a = AT<<8;
	if (!(p = (int *)malloc(v*3*2))) return 0;
	for (y = 1; y < v-1; y++)
	    *(p+y+2*v) = *(p+y) = '─'|a;
	*(p+v) = *(p+2*v-1) = '│'|a;
	*p	 = '┌'|a; *(p+v-1)   = '┐'|a;
	*(p+2*v) = '└'|a; *(p+3*v-1) = '┘'|a;

	for (y = 1; *so; y++)
	   *(p+v+y) = (*so++)|(ATB<<8);
	puttext(wx+1,13,wx+v,15,p);

	l = (lsi ? read_str(si,wx+l+1,13,lsi,15) : (GetChar() != ESC));
	if (f_rec)
	   { write(f_rec,"",1); write(f_rec,si,strlen(si)); write(f_rec,"",1); }
	return l;
}

int inter(int f,...) {
va_list ap;
struct { unsigned ax,bx,cx,dx,bp,si,di,ds,es,flags; } r;
	va_start(ap,f);
	r.ax = f;				// функция для драйвера мыши
	r.cx = va_arg(ap,int);
	r.dx = va_arg(ap,int);
	ox = cx; oy = cy;			// запомнили предыдущие коор мыши
	intr(0x33, &r);				// прерывание 33h
	cx = r.cx/8+1;				// координаты курсора мыши
	cy = r.dx/8+1;
	return f ? r.bx : r.ax;
}

void border(void) {				// курсор за границей строки
	if (i > 0) {
	   strinc(i);
	   memset(tp, ' ',i);
	   tp += i;
	}
}

void DelMar(void) {
unsigned x,l,j;
	x = BegStr(bm);
	for (l = 0; l <= y_m; l++) {
	    if (tp > bm) {
		if (strchr(bm,'\n') >= tp) tx -= l_m;
		tp -= l_m;			// корр. указателя кусора
	    }
	    for (j = 0; j < l_m; j++)
		if (*(bm+j) == '\n') {		// корр. строк
		   NS--;
		   if (y_m) { j++; break; }
		}
	    strdec(bm,j);
	    bm = strchr(bm,'\n')+x+1;
	}
}

void Command(void) {
char	*p,*p1;
	if (*pcom) {
	   shift = ch1 = 0;
	   if (*pcom == '~') { shift = 1; pcom++; }
	   for (pkf = arrkey; *(p1=pkf->namekey); pkf++) {
		for (p = pcom; *p1++ == *p++;);
		if (*(p1-1) || *(p-1) != ';') continue;
		pcom = p;
		if ((ch0 = pkf->key))
		   (*(pkf->nameutil))();
		else {				// INPUT
		   while (*++pcom && *pcom != '');// поиск разделителя конца
		   *pcom++ = 0;
		   MacroSub(p+1,0);
		}
		for (pcom--; isspace(*++pcom););
		return;
	   }
	   putch('\a');
	}
	pcom = stack[--stpcom];
	free(ps); ps = 0;
}

void MacroSub(char *p,int f) {
unsigned j,l,k,x;
	j = strlen(p)/(y_m+1);			//ошибка при realloc
	for (l = 0; l <= y_m; l++) {
	    border();				// выходим за границу строки
	    if (!l && f) { bm = tp; l_m = j; }
	    if (F_INS || i > 0) strinc(j);
	    for (k = 0; k < j; k++)		// перепись макроподстановки
		if ((*(tp+k) = *p++) == '\n') NS++;
	    x = BegStr(tp); ff = 0;
	    if (!*(tp = strchr(tp,'\n')+1)) break;
	    tp = (i = x-(strchr(tp,'\n')-tp)) > 0 ? strchr(tp,'\n') : tp+x;
	}
	if (!f) CheckCol(j);
}

char *CpyBox(void) {				// копирование памяти
char *p, *pw;
unsigned j,x;
	if (!l_m || !(p = (char *)calloc(l_m*(y_m+1)+1,sizeof(char))))
	   { putch('\a'); return 0; }
	x = BegStr(bm);
	for (j = 0,pw = bm; j <= y_m; j++) {
	    memcpy(p+j*l_m, pw, l_m);
	    pw = strchr(pw,'\n')+x+1;
	}
	return p;
}

void CreatBakFile(void) {
unsigned j;
	strcpy(str+1,F_N);
	for (j = 1; *(str+j) && *(str+j) != '.'; j++);
	strcpy(str+j,".bak");
	WriteDir(str+1,AREA,l);
}

void WriteDir(char *n,char *p,int l) {
int	j;
	if ((j = open(n, O_TRUNC|O_RDWR|O_CREAT,S_IWRITE)) == -1)
	   question(15," press ESC key","error opening file ");
	else
	   if (write(j, p, l) != l)
		question(15," press ESC key","error writing,");
	close(j);
}

void PushScreen(void) {
unsigned j;
	if (!(S_SC = (int *)malloc(ww*wh*sizeof(int)))) return;
	for (j = 0; j < wh; j++)
		memcpy(S_SC+j*ww, bsc+wx+(wy+j)*80, ww*sizeof(int));
}

void PopScreen(void) {
unsigned j;
	for (j = 0; j < wh; j++)
		memcpy(bsc+wx+(wy+j)*80, S_SC+j*ww, ww*sizeof(int));
	free(S_SC);
}

void ResetScreen(void) {
	frame(ww, wh, F_N, ATB);
	PutScreen(PS);
	_setcursortype(cursor[F_INS]);
}

int BegStr(char *p) {
int	x;
	for (x = 0; p > AREA && *--p != '\n'; x++);
	return x;
}

void CheckLine(int y) {
	vi += y;
	if (ty+y >= wy+wh || ty+y <= wy+1)
	   PS = pos(PS,y);
	else
	   ty += y;
}

void CheckScreen(int y) {
	if ((ty += y-vi) >= wy+wh || ty <= wy+1)
	   { PS = p0; ty = 0; }
	vi = y;
}

void CheckCol(int x) {
	if (tx+x >= wx+ww || tx+x < wx+2)
	   { if ((BX += x) < 0) Home(); }
	else
	   tx += x;
}

void FindLine(char *p) {
	Back(p);
	for (j = 1, p = AREA; p < p0; j++)
	    if (!*(p = strchr(p, '\n')+1)) return;
	CheckScreen(j);
}

int CheckBorder(int len) {
unsigned l0,l1,l3,l4;
	CORR = 0;
	if ((LIM += len) < LIMM) return 1;
	l0 = PS-AREA; l1 = bm-AREA; l3 = tp-AREA; l4 = PCUR-AREA;
	if (!(AREA = (char *)realloc(AREA,(LIMM = LIM+m_add)))) return 0;
	PS = AREA+l0; bm = AREA+l1; tp = AREA+l3; PCUR = AREA+l4;
	return 1;
}

void strinc(int shi)  {
char *p;
unsigned len;
	CheckBorder(shi);
	if (PCUR >= tp) PCUR += shi;		// корр
	if (bm > tp) bm += shi;			// корр базы поля
//	if (l_m && bm <= tp && bm+l_m > tp) l_m += shi;
	if (ff) l_m += shi;
	p = AREA+LIM-shi;
	len = p+1-tp;
   asm { // for (; len--; *(p+shi) = *p,p--);
	std
	push	ds
	mov	cx,len
	les	di,p
	add	di,shi
	lds	si,p
	rep	movsb
	pop	ds
   }
}

void strdec(char *p, int shi) {
	CheckBorder(-shi);
	if (!y_m && bm <= p && bm+l_m > p) l_m = (l_m < shi ? 0 : l_m-shi);
	if (PCUR >= p) PCUR -= shi;		// корр
	if (bm > p) bm -= shi;
	strcpy(p,p+shi);
}

void SizeMove(int i) {
	cx = wx+ww+!i*ar;
	cy = wy+wh+ i*ar;
	if (fa & 1) ReSize(); else MoveFrame();
}

void LoadMacro(void) {
char	c, *p;
	if (LoadName(str+1) == -1 || !(p = ReadFile(str+1,0))) return;
	free(pm); pm = p;
	memset(AltMac,0,26*sizeof(char *));
	do {
	   while (isspace((c=*p++)));
	   if (c < 'A' || c > 'Z') BELL;
	   for (p = strchr(p,'{'); isspace(*++p););
	   AltMac[c-'A'] = p;			// начало подстановки
	   while (!(*p++ == '}' && *p == ';'));
	   *(p-1) = 0;
	} while(*(p = strchr(p,'\n')+1));
}

char *ReadFile(char *n,int s) {
int long i;
int	j;
char	*p;
	if ((j=open(n, O_TRUNC|O_RDONLY|(s==0 ? 0:O_CREAT),S_IWRITE)) ==-1 || (i=filelength(j)) ==-1)
	   { question(15,n,"error opening file "); return 0; }
	if (i+s > 0xffff)
	   { question(15,n,"Large file "); return 0; }
	if (!(p = (char *)malloc(i+s))) return 0;
	l = read(j,p,i);
	if (*(p+l-1) != '\n') *(p+l++) = '\n';
	*(p+l) = 0;
	close(j);
	if (s) LIMM = i+s;
	return p;
}

void PutScreen(char *p) {			// вывод экрана
register int  x, y;
int	bs, atr, z, *vp, y_m0, x_m0;
//int	f = 0;
char	*bm0, *bm1,*pp;
	bm0 = bm; bm1 = bm+l_m; y_m0 = y_m; z = ATRF;
	if (bm && y_m0) x_m0 = BegStr(bm);
	for (y = 1; y < wh-1; y++) {
		vp = bsc+wx+(wy+y)*80+1;
		if (view == 3) {		// таблица ascii
		   for (x = 0; x < ww-2; x++)
			*(vp+x) = z++;
		   continue;
		}
		pp = p;
		atr = ((FS && p >= bm0 && p < bm1) ? ATRM : ATRF);
		for (x = 0; x < ww-2; x++)	// роспись тек. строки
		    *(vp+x) = atr;
		if (!*p) continue;
		for (z = -BX; z < 0 && *p != '\n';)//пропуск символов при скролинге
		     z += (*p++ == '\t' ? TB-(BX+z)%TB : 1);
		while (z < ww-2 && *p != '\n') {
//		    if (!f)
			atr = (p >= bm0 && p < bm1 ? ATRM : ATRF);
		    if ((x=*p++) == '\t')
			for (bs = TB-(z+BX)%TB; bs > 0 && z < ww-2; bs--)
			   *(vp+z++) = atr;
		    else {
//			if (x != '`')
			   { *(vp+z++) = atr|x;	continue; } // выдача
//			if (f)
//			   f = 0;
//			else {
//			   atr = Atoi(p)<<8;
//			   while ((f = *p++ -'0') >=0 && f < 10);
//			}
		    }
		}
		p = strchr(p,'\n')+1;		// конец файла
		if (y_m0 && bm0 >= pp && p > bm0)
		   { y_m0--; bm0 = p+x_m0; bm1 = bm0+l_m; }
	}
	if (!pcom) puttext(1,1,80,24,bsc);
}

void Back(char *p) {
int	x;
	p0 = p -= (x = BegStr(p));
	for (j = 0; x; x--)
	    j = (*p++ == '\t' ? FunTab(j) : j+1);
	if ((tx = wx+2+j-BX) >= wx+ww || tx < wx+2) {
	   if ((BX = j-ww+3) < 0) BX = 0;	// определили сдвиг экрана
	   tx = wx+2+j-BX;
	}
}

void InitEdit(void) {
unsigned i;
	if (IsFile(fi) == -1) return;
	tp = tpp = ReadFile(fi,0);
	for (; *tp <= ' '; tp++);
	for (; *tp; tp = strchr(tp,'\n')+1) {
	   for (i = 0; (p1 = options[i]); i++) {
		for (; *p1 && *p1++ == (*tp|0x20); tp++);
		if (*p1) continue;
		for (; *tp <= ' '; tp++);	// прогон пробелов
		(*fileoptions[i])(); break;
	   }
	}
	free(tpp);
}

void Condtion(void) { flagoptions[i] = (*++tp | 0x20) == 'n'; } // on/off

void ReadHelp(void) { LoadName(ph); }

int IsFile(char *p) { j = open(p, O_RDONLY); close(j); return j; }

void Start(void) { if (LoadName(str+1)) stack[++stpcom] = ps = pcom = ReadFile(str+1,0); }

int LoadName(char *p) {
unsigned j;
	for (j = 0; *tp > ' '; *(p+j++) = *tp++);
	*(p+j++) = 0;
	return IsFile(p);
}

void Format(void) {
int	j;
	for (j = 0; j < 3; j++) {
	    for (; *tp <= ' '; tp++);		// прогон пробелов
	    form[j] = Atoi(tp);
	    for (; *tp >  ' '; tp++);		// начало слова
	}
}

void PutRecoder(void) {
char	*p,pw[20];
unsigned l;
	p = pw;
	if ((l=pkf-arrkey) | k) {
	   if (!k) *p++ = '';
	   if (pkf->key == S_F+8) return;	// выход из recoder
	   if (shift) *p++ = '~';
	   *(p = stpcpy(p,pkf->namekey)) = ';';
	   if (!l)				// INPUT
	      { *++p = ''; *++p = ch1; }
	   else
	      if (nstr++ > 7 && pkf->key != 255) { nstr = 0; *++p = '\n'; }
	}
	else
	   *p = ch1;
	k = l; write(f_rec, pw, p-pw+1);
}

int Atoi(char *p) {
int	j;
	for (j = 0; isdigit(*p); j = j*10+*p++-'0');
	return j;
}

char *Itoa(unsigned i, char *p) {
unsigned j;
char str[10];
	for (j = 0; i; i /= 10)
	    str[j++] = (i%10)|'0';
	while (j)
	    *p++ = str[--j];
	return p;
}

void iTOa(int i, char *p) { *(p+1) = (i%10)|'0'; *p = ((i/10)%10)|'0'; }
