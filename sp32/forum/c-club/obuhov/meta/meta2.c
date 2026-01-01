
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F9 */
/* 
   отметить границы блока и в случае надобности 
   поменять их местами
   должно вызываться два раза
   когда блок,наконец, отмечен, устанавливается цвет
   для него и обновляется экран

   если при вызове блок уже отмечен,то отметка снимается

   при выводе на экран по toscr() возле тех символов текста,
   которые попадают в диапазон блока выставляется зеленый
   атрибут atr_block

*/
void mark_block(){
  char *p;
  if(begin_block_ptr!=0 && end_block_ptr!=0){
    begin_block_ptr=0;
    end_block_ptr=0;
    atr_block=atr0;
    *(video_ptr+36*2)=' ';*(video_ptr+36*2+1)=0x30;
    *(video_ptr+37*2)=' ';*(video_ptr+37*2+1)=0x30;
    return ;
  }
  if(*curptr=='\n') curptr--;
  if(begin_block_ptr==0){
    begin_block_ptr=curptr;
    *(video_ptr+36*2)='[';*(video_ptr+36*2+1)=0xa0;
    *(video_ptr+37*2)=' ';*(video_ptr+37*2+1)=0x30;
  }
  else if(end_block_ptr==0) end_block_ptr=curptr;
  if(begin_block_ptr!=0 && end_block_ptr!=0){
    if(begin_block_ptr > end_block_ptr){
      p=begin_block_ptr;
      begin_block_ptr=end_block_ptr;
      end_block_ptr=p;
    }
    atr_block=0x2b;
    *(video_ptr+36*2)='[';*(video_ptr+36*2+1)=0xa0;
    *(video_ptr+37*2)=']';*(video_ptr+37*2+1)=0xa0;
  }
  if(*curptr=='\r')curptr++;
 }

/*
   проверка длины текущей строки после сцепления - 0/1 -
   означает нормальная/длинная, >c80-1 символов
   специально для копирования блоков 
*/
int test_leng1(char *bbp,char *ebp,char *dp){
  char *p0,*p,*p1;
  if(*dp=='\n') dp--;
  for(p0=dp;p0!=buf && *p0!='\n';p0--);
  for(p=dp;p!=endbuf && *p!='\r';p++);
  for(p1=bbp;p1!=ebp && *p1!='\r';p1++);
  if(p1==ebp && (p-p0)+(p1-bbp)>c80-2) return(1);
  if(p1!=ebp &&(dp-p0)+(p1-bbp)>c80-2) return(1);
  else return(0);
 }

/* 
  сервисная программа копирования заданного диапазона 
  по аналогии с copy_block, но с параметрами 
  bbp,ebp - концы диапазона
  dp      - целевой указатель
*/
int copy_b(char *bbp,char *ebp,char **dp){
  char *p,*q;unsigned n;
  change_flag=1;
  n=ebp-bbp;
           /* предусловия защиты */
  if(endbuf-buf+n > MAXBUF )return(1); /*есть ли место для вставки?*/
  if(bbp<=*dp && *dp<ebp)return(1);    /*указатель внутри блока?*/
  if(test_leng1(bbp,ebp,*dp))return(1);/*переполнение строки?*/

  if(n!=0 && bbp!=0 && ebp!=0){        /*непустой блок?*/
    if(**dp=='\n') (*dp)--;
           /* раздвинуть место для будущего блока  */
    for(q=endbuf-1+n,p=endbuf-1;p!=*dp-1;p--,q--) *q=*p;
    endbuf+=n;
    if(*dp<begin_block_ptr){           /* учесть сдвиг маркеров */
      if(bbp==begin_block_ptr){bbp+=n;ebp+=n;} /* увы !? */
      begin_block_ptr+=n; 
      end_block_ptr+=n; 
    }
    if(*dp<room_curpage) room_curpage+=n;

           /* затем заполнить это место блоком  */
    for(p=*dp,q=bbp;q<ebp;p++,q++) *p=*q;
    if(**dp=='\r') (*dp)++;
    return(0);
  }
  return(1);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F5 */
/* скопировать блок по текущему положению курсора*/
int copy_block(){
  int i;
  change_flag=1;
  i=copy_b(begin_block_ptr,end_block_ptr,&curptr);
  set_nline();
  return i;
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^ F8 */
/* удалить отмеченный блок */
void del_block(){
  char *p,*q;unsigned n;
  change_flag=1;

  n=end_block_ptr-begin_block_ptr;

  if(n!=0 && begin_block_ptr!=0 && end_block_ptr!=0){
    for(p=begin_block_ptr,q=end_block_ptr;q!=endbuf;p++,q++) *p=*q;
    endbuf-=n;

    /* 
      позаботиться об изменении curpage,
      если он находился за блоком или в блоке 
    */
    if(curpage>=begin_block_ptr && curpage<end_block_ptr){
      curpage=begin_block_ptr;
      if(*curpage=='\r') curpage++;
    }
    if(curpage>end_block_ptr){
      curpage-=n;
      if(*curpage=='\r') curpage++;
    }
    if(end_block_ptr<room_curpage) room_curpage-=n;

    /*
      курсор на экране после удаления, чтобы не перевычислять
      расположим в левом углу экрана,
      а курсор текста настроим на  curpage ( образ угла экрана )
    */
    curptr=curpage;
    curx=0;cury=c0;

    mark_block(); /* и снять, разумеется, отметку */
    set_nline();
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F6 */
/* скопировать блок с удалением */
void move_block(){
  if(copy_block()==0) del_block();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F7 */
/* = = = = = = = контекстный поиск по reply = = = = = = = =*/

void find(){
  int i,j,n;
  char *p;
  if(up_menu_get(reply,msg8,2,17,8,59,11,0x7070,tmp)!=-1){
    for(p=curptr+1;p<endbuf-1;p++){
     for(i=0;*(reply+i)!=0 && *(p+i)==*(reply+i);i++);
     if(*(reply+i)==0){
      curptr=p;curx=0;cury=c0;
      for( ;*p!='\n' && p>=buf-1; p--)curx++;
      curpage=p+1;curx--;
      set_nline();
      return;
     }
    }/*for*/
  up_menu(msg9,1,17,9,59,11,0x4f4f,tmp);
  }/*if*/
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^f */
/* = = = = = = =  templating = = = = = = = = = =*/
void ctrl_f(){
  int i;
  copy_b(pat_f,pat_fe,&curptr);
  for(i=0;i<4;i++) right();
  if(curptr<room_curpage) room_curpage+=(pat_fe-pat_f);
  set_nline();
 }
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^w */
void ctrl_w(){
  int i;
  copy_b(pat_w,pat_we,&curptr);
  for(i=0;i<6;i++) right();
  if(curptr<room_curpage) room_curpage+=(pat_we-pat_w);
  set_nline();
 }
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^s */
void ctrl_s(){
  int i;
  copy_b(pat_s,pat_se,&curptr);
  for(i=0;i<9;i++) right();
  if(curptr<room_curpage) room_curpage+=(pat_se-pat_s);
  set_nline();
 }

/* = = = = = = = = = justify = = = = = = = = = =*/
/*
   выравнивание абзацев по правому краю
*/
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^r */
int justify(){
  unsigned i,sum,n,maxj1;
  char bufl[MAXJ+2],*p,*q;

  home();
  if(*curptr=='\n') return(0);
  for(;*curptr==' ';){if(right())break;}
  maxj1=MAXJ-curx;
  /*
      n   - общее число слов в диапазоне 0-MAXJ
      sum - их суммарная длина
      maxj1 - длина строки для выравнивания 
  */
  sum=0;
  if(*curptr != ' ' ) n=1; else n=0;
  for(p=curptr;(p<(curptr+maxj1-1) || *p!=' ')&&(*p!='\r');p++){
    if(*p!=' ') sum++;
    if(*p==' ' && (*(p+1)!=' '&&*(p+1)!='\r')) n++;
  }
           /* проверить на допустимость */
  if(n<4) return(1);           /* мало слов?*/
  if(sum<30)return(1);         /* много промежутков?*/
  if(sum>=maxj1)return(1);        /* мало промежутков?*/
  n=n-1;
  sum=maxj1-sum;   
  if(sum<n) return(1);         /* незачем раздвигать?*/
  /*
      теперь:
      n   - общее число промежутков между словами
      sum - суммарная длина промежутков
  */
  for(i=0;i<MAXJ;i++)bufl[i]=' ';/* прогрунтовать пробелами */
  bufl[MAXJ]='\r';bufl[MAXJ+1]='\n'; /*         и концом строки */
  for(q=curptr;*q==' ';q++);   /* q=первый непробел */
  p=bufl+curx;                      /* p=буфер выравнивания */
  for(i=0;i<=n;i++){           /* пересылка с выравниванием */
    for(; *q!=' '&&p<bufl+MAXJ; p++,q++){*p=*q;}
    for(; *q==' '; q++);
    if(i<(sum%n)) p+=(sum/n)+1; else p+=(sum/n);
  }
  del_line();          /* заменить прежнюю строку на новую */
  copy_b(bufl,bufl+MAXJ+2,&curptr);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F3 */
void back(){
  curpage=room_curpage;
  curptr=curpage;
  curx=0;
  cury=c0;
  toscr();
  *(video_ptr+2*80*c0+1)=0xe0;
 }
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ F4 */
void room(){
  room_curpage=curpage;
  back();
 }
/* = = = = = = = = = = = = = = = = = = = = = = =*/

int yyparse(){
  int c;
  for(;;){
   getch();c=_AL;if(c==0){getch(); c=_AL+256;}
   yylval=c;
   switch( c ){
   case      6 : /* C_F   */   { ctrl_f();toscr();break;}
   case      8 : /* BACKSP*/   { backsp();setcur(curx,cury,0);break;}
   case     10 : /* C_CR */    { toscr();break;}
   case     13 : /* CR   */    { sym(); toscr();break;}
   case      4 : /* C_D  */    { switch_wrap();toscr();break;}
   case     18 : /* C_R  */    { justify();down1();toscr();break;}
   case     19 : /* C_S  */    { ctrl_s();toscr();break;}
   case     20 : /* C_T  */    { clear_right();toscr();break;}
   case     23 : /* C_W  */    { ctrl_w();toscr();break;}
   case     25 : /* C_Y  */    { del_line(); toscr();break;}
   case     27 : /* ESC  */    { trailer(); return(0);}
   case 256+81 : /* PGDN */    { pgdn1(); toscr();break;}
   case 256+73 : /* PGUP */    { pgup1(); toscr();break;}
   case 256+118: /* C_PGDN*/   { swap_down();toscr();break;}
   case 256+132: /* C_PGUP*/   { swap_up();  toscr();break;}
   case 256+119: /* C_HOME*/   { to_begin_file(); toscr();break;}
   case 256+77 : /* RIGHT*/    { right1();setcur(curx,cury,0);break;}
   case 256+75 : /* LEFT */    { left1(); setcur(curx,cury,0);break;}
   case 256+72 : /* UP   */    { up1();   setcur(curx,cury,0);break;}
   case 256+80 : /* DOWN */    { down1(); setcur(curx,cury,0);break;}
   case 256+79 : /* _END */    { end1(); setcur(curx,cury,0);break;}
   case 256+117: /* C_END*/    { to_end_file(); toscr();break;}
   case 256+71 : /* HOME */    { home1(); setcur(curx,cury,0);break;}
   case 256+83 : /* DEL  */    { del();   setcur(curx,cury,0);break;}
   case 256+82 : /* INS  */    { ins(); toscr(); break;}
   case 256+59 : /* F1   */    { help();break;}
   case 256+60 : /* F2   */    { save(); toscr(); break;}
   case 256+61 : /* F3   */    { back();break;}
   case 256+62 : /* F4   */    { room();break;}
   case 256+63 : /* F5   */    { copy_block();toscr();break;}
   case 256+64 : /* F6   */    { move_block();toscr();break;}
   case 256+65 : /* F7   */    { find(); toscr();break;}
   case 256+66 : /* F8   */    { del_block();toscr();break;}
   case 256+67 : /* F9   */    { mark_block();toscr();break;}
   case 256+68 : /* F10  */    { save(); trailer();return(0);}
   default:      /* SYM  */    { sym();  setcur(curx,cury,0);}
   }
  }/*for*/
 }
 
/*================ головная программа ==================*/

/* 
   far_pointer необходим для раздельного доступа к частям char far*
   чтобы достать строку аргументов, переданных программе в PSP,
   надо сформировать far-указатель вида (CS-0x10):0x81
*/
union far_pointer {
  char far *p1;
  int ind[2];
 } ; 

main() {
  char *p; 
  union far_pointer pf1;char arg_line[80];
  int i,j=0,arg1=0,arg2=0;
  video_ptr=ADR_VIDEO;
  setpage(0);
  buf=(char *)4096; /* вместо getblok */
  tmp=buf+MAXBUF;

/* 
   два параметра находятся в arg_line 
   их смещения равны соответственно arg1 и arg2 
*/
  pf1.ind[0]=0x81;
  pf1.ind[1]=_CS-0x10;
  
  for(i=0;i<80;i++){arg_line[i]=*(pf1.p1+i);}

  for(i=0;i<80 && arg_line[i]==' ';i++);
  arg1=i;
  for(i=arg1+1;i<80 && arg_line[i]!='\r';i++){
   if(arg_line[i]=='\r')break; 
   if((arg_line[i-1]==' ' || arg_line[i-1]==0 )
         && arg_line[i]!=' ' )break;
   if(arg_line[i-1]!=' ' && arg_line[i]==' '){arg_line[i]=0;}
  }
  if(arg_line[i]=='\r'){ arg2=0; arg_line[i]=0; }
  
  else arg2=i;
  if(arg2!=0){
    for(i=arg2+1;i<80 && arg_line[i]!='\r';i++){
     if((arg_line[i-1]==' ' || arg_line[i-1]==0)
         && arg_line[i]!=' ' )break;
     if(arg_line[i-1]!=' ' && arg_line[i]==' ' ) arg_line[i]=0;
    }
    arg_line[i]=0; 
  }

  if(arg_line[arg1]=='\r'){
    up_menu(msge,4,17,8,59,8+4+1,0x3030,tmp);
    exit(1);
  }

  for(i=0;i<32;i++) file_path[i]=arg_line[arg1+i];
  
  open(arg_line+arg1,0);fileh=_AX;
  if( _FLAGS & 0x01 ){
   if( fileh != 2){
     up_menu(msg1,3,17,8,59,12,0x4f4f,tmp);
     exit(0);
   }
  }

  endbuf=buf;mfl=0;
  if( fileh != 2 ){  /* файл существует */
    /* найти длину файла */
    lseek(fileh,0,0,2);mfl=_AX;
    if(mfl > MAXFILE-16 ){
      up_menu(msg6,3,17,8,59,12,0x4f4f,tmp);
      exit(0);
    }
    endbuf=buf+mfl;
    lseek(fileh,0,0,0); 
    read(fileh,buf,MAXFILE);
    if( _FLAGS & 0x01 ){
      up_menu(msg2,3,17,8,59,12,0x4f4f,tmp);
      exit(1);
    }
    close(fileh);
  }

  curpage=buf;
  if(*curpage=='\r')curpage++;
  curptr=curpage;room_curpage=curpage;
  
/* 
  захватить с экрана номера строки для позиционирования,
  позиция на экране для захвата должна быть передана
  через второй параметр в виде экранного смещения
*/

  if( arg2!=0 ){
    for(i=0,p=arg_line+arg2; '0'<=*p && *p<='9'; p++) 
       i=i*10+*p-'0';
    for(j=0; '0'<=*(video_ptr+2*i) && *(video_ptr+2*i)<='9'; i++) 
       j=j*10+*(video_ptr+2*i)-'0';
    if(1<j && j<1500){
      for(i=0;i<j-2;i++){next(&curpage);}
      if(*curpage=='\r') curpage++;
      curptr=curpage;
    }
  }

  set_bars();
  ins(); 
  toscr();            /* начальный вывод окна */
  set_nline();
  

  if(1<j && j<1500){ /* подсветить строку с ошибкой */
    for(i=0;i<80;i++) *(video_ptr+160*(c0+1)+i*2+1)=0x6f; 
  }

  yyparse();    /* анализатор вместе с самой программой */

 }
