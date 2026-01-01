//  ИCXOДНЫЙ ТЕКСТ МОДУЛЯ "ГРУППОВАЯ ЗАМЕНА В ФАЙЛЕ В ПАКЕТНОМ РЕЖИМЕ"
//  Имя модуля: RP (RePlace)
//  Автор: Вадим Низамов
//  141305 г.Сеpгиев Посад Московской обл.
//  Скобяной пос. ул. Кирпичная 27 кв.124
//  Рабочий тел. (254)4-77-98
//  Версия: 1.01
//  Дата создания: 1.06.93
//  Язык программирования: C
//  Использованный транслятор: Borland C++ 2.00

//  Производятся одновременно чтение файла, замена и запись в ОЗУ в виде
//  структуры, состоящей из 'кирпичей', каждый из которых состоит из
//  символьной строки, длины ее содержимого, указателя на следующий 'кирпич'.
//  Запуск.
//  RP <имя файла> <разделитель><набор 1><разделитель><набор 2><разделитель>
//  <Набор 1> - непустой набор любых знаков кроме пробела и <разделителя>.
//  <Набор 2> - набор любых знаков кроме пробела и <разделителя>.
//  Все вхождения <набора 1> заменяются на <набор 2>.
//  С помощью символа '^' и следующих за ним трех десятичных цифр можно
//  задать в наборе код знака. Пробел задается только его кодом.
//  Аварийные прерывания работы модуля:
//  1) не открывается редактируемый файл,
//  2) не хватило оперативной памяти для очередного 'кирпича',
//  3) не хватило места на дисководе для записи отредактированного файла,
//  4) отсутствует разделитель,
//  5) пробел внутри набора,
//  6) ошибка при вызове библиотечной функции getdfree.

#include <stdio.h>
#include <alloc.h>
#include <dos.h>

#define BRICKLINESIZE 50

FILE *rf;
struct dfree free1;
struct brick {
  unsigned char line[BRICKLINESIZE];
  int size;
  struct brick *next;
}*index,*index1,*indexfree;
size_t bricksize=sizeof(*index);
unsigned char
   search [130],
   replace[130],
   key;
int searchsize=0,
    replacesize=0,
    quanbricks=1,
    k=0;
long quanreplace=0,
     c1;

void ALLOC() {
  if((indexfree=malloc(bricksize))==NULL)
    {printf("не хватило оперативной памяти.");abort();}
  indexfree->size=0;
}
void WRITESYMBOL(symbol) unsigned char symbol; {
  if(index->size==BRICKLINESIZE)
    {ALLOC();index=index->next=indexfree;quanbricks++;}
  index->line[index->size++]=symbol;
}
void READPAR(s,c,n) char*s;unsigned char*c;int*n; {
  while(s[++k]!=s[0])
    switch(s[k]) {
    default:  c[(*n)++]=s[k];break;
    case '\0':printf("нет разделителя.");abort();
    case '^': c[(*n)++]=100*(s[k+1]-'0')+10*(s[k+2]-'0')+(s[k+3]-'0');k+=3;
    }
}
void main(n,nrf) int n;char*nrf[]; {
  register int i;
  printf("\nREPLACE,");
  if(n<=2)
    printf("Copyright(C)1993,PROZA,Nizamov\n"
    "RP <имя файла> <разделитель><набор><разделитель><набор><разделитель>");
  else if(n>3) {printf("пробел задавайте кодом.");abort();}
  else {
    READPAR(nrf[2],search, &searchsize);
    READPAR(nrf[2],replace,&replacesize);
    printf("%c%s%c%s%c,",nrf[2][0],search,nrf[2][0],replace,nrf[2][0]);
//__Чтение_файла,_замена,_запись_в_ОЗУ___________________________________
    ALLOC();
    index1=index=indexfree;
    if((rf=fopen(nrf[1],"rb"))==NULL) {printf("файл не открылся");return;}
    for(k=0;;) {
      key=fgetc(rf);
      if(feof(rf)) {for(i=0;i<k;i++) WRITESYMBOL(search[i]);break;}
      if(key==search[k]) {
	if(++k==searchsize)
	  {for(i=0;i<replacesize;i++) WRITESYMBOL(replace[i]);
	  k=0;quanreplace++;}
      }
      else if(k) {WRITESYMBOL(search[0]);fseek(rf,(long)(-k),SEEK_CUR);k=0;}
      else WRITESYMBOL(key);
    }
    fclose(rf);
    if(quanreplace) {
//____Проверка_дисковода_на_наличие_свободной_памяти_при_увеличении_файла
      if((c1=quanreplace*(replacesize-searchsize))>0) {
	k=(nrf[1][1]==':')?(nrf[1][0]-'A'):getdisk();
	getdfree(k+1,&free1);
	if(free1.df_sclus==0xFFFF) {printf("ошибка в getdfree");return;}
	else if(c1>(long)free1.df_avail*(long)free1.df_bsec*(long)free1.df_sclus)
	  {printf("на %c не хватает места",'A'+k);return;}
      }
//____Запись_файла_на_дисковод___________________________________________
      if((rf=fopen(nrf[1],"wb"))==NULL)
	{printf("файл не открылся для записи");return;}
      do
	{for(i=0;i<index1->size;i++) fputc(index1->line[i],rf);
	index1=index1->next;}
      while(--quanbricks);
      fclose(rf);
    }
    printf("сделано замен:%lu",quanreplace);
  }
}