/* Для всех функций, осуществляющих прямые
   обращения к видеопамяти, отсчет координат
   интересующей текстовой клетки экрана ведется
   от единицы (т.е. левая верхняя символьная
   клетка имеет координаты 1,1); все
   соответствующие параметры функций должны
   удовлетворять этому соглашению. */
/* Функция выводит строку заданной длины
   по X-у.
   Заполненную одним символом.
   Параметры:
   StartX,StartY - вертикальная и горизонтальная
       координаты первого символа строки на экране;
   MaxChar - max кол-во символов;
   ChIn - символ;
   Color - цвет; */

void PrintUsingCharX(int StartX,int StartY,
		     int MaxChar,int ChIn, int Color){
char far *Video=(char far *)0xB8000000;
register unsigned int i;
   for(i=0;i < (MaxChar<<1);i+=2){
    *(Video+i+(StartY-1)*160+((StartX-1)<<1))=ChIn;
    *(Video+i+1+(StartY-1)*160+((StartX-1)<<1))=Color;
  }
}
/* Функция выводит строку заданной длины
   по Y-у.
   Заполненную одним символом.
   Параметры:
   StartX,StartY - вертикальная и горизонтальная
       координаты первого символа строки на экране;
   MaxChar - max кол-во символов;
   ChIn - символ;
   Color - цвет; */

void PrintUsingCharY(int StartX,int StartY,
		     int MaxChar,int ChIn,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned i;
   for(i=0;i < MaxChar;i++){
    *(Video+((StartY-1)+i)*160+((StartX-1)<<1))=ChIn;
    *(Video+1+((StartY-1+i))*160+((StartX-1)<<1))=Color;
  }
}
/* Функция выводит строку.
   Параметры:
   StartX,StartY - вертикальная и горизонтальная
       координаты первого символа строки на экране;
   String - строка;
   Color - цвет; */
void PrintString(int StartX,int StartY,
		 char *String,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned i;
Video+=((StartY-1)*160)+((StartX-1)<<1);
  for(i=StartY;*String;i++){
   *Video++=*String++;
   *Video++=Color;
  }
}
/* Функция изменяет атрибуты в строке
   заданной длины.
   по X-у.
   Параметры:
   StartX,StartY - вертикальная и горизонтальная
       координаты первого символа строки на экране;
   MaxChar - max кол-во символов;
   Color - цвет; */

void NegTabX(int StartX,int StartY,
	     int MaxChar,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned int i;
   for(i=0;i < (MaxChar<<1);i+=2){
    *(Video+i+1+(StartY-1)*160+((StartX-1)<<1))=Color;
   }
}
/* Функция очищает прямоугольную
   область на экране.
   Параметры:
   StartX,StartY - левый верхний угол;
   EndX,EndY - правый нижний угол; */

void ClearBox(int StartX,int StartY,
	      int EndX,int EndY){
  char far *Video=(char far *)0xB8000000;
  register unsigned i,j;
     for(j=(StartY-1);j<EndY;j++){
       for(i=((StartX-1)<<1);i<(EndX<<1);i+=2){
	  *(Video+i+j*160)=0x00;
       }
    }
}
/* Функция очищает строку заданной длины
   по X-у.
   Заполненную одним символом.
   Параметры:
   StartX,StartY - вертикальная и горизонтальная
       координаты первого символа строки на экране;
   MaxChar - max кол-во символов; */

void ClearStringX(int StartX,int StartY,int MaxChar){
char far *Video=(char far *)0xB8000000;
register unsigned int i;
   for(i=0;i < (MaxChar<<1);i+=2){
    *(Video+i+(StartY-1)*160+((StartX-1)<<1))=0x00;
  }
}
/* Функция заполняет прямоугольную
   область на экране одним символом.
   Параметры:
   StartX,StartY - левый верхний угол;
   EndX,EndY - правый нижний угол;
   ChIn - символ;
   Color - цвет; */
void PrintBox(int StartX,int StartY,
	      int EndX,int EndY,int ChIn,int Color){
  char far *Video=(char far *)0xB8000000;
  register unsigned i,j;
     for(j=(StartY-1);j<EndY;j++){
       for(i=((StartX-1)<<1);i<(EndX<<1);i+=2){
	  *(Video+i+j*160)=ChIn;
	  *(Video+i+1+j*160)=Color;
       }
    }
}
/* Функция рисует прямоугольную рамку.
   Параметры:
   StartX,StartY - левый верхний угол
   EndX,EndY - правый нижний угол
   StringLine - образы линий
   Color - цвет */
void BoxDraw(int StartX,int StartY,int EndX,int EndY,
	     char *StringLine,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned i;

    *(Video+(StartY-1)*160+((StartX-1)<<1))=StringLine[0];
    *(Video+1+(StartY-1)*160+((StartX-1)<<1))=Color;
    *(Video+(StartY-1)*160+((EndX-1)<<1))=StringLine[1];
    *(Video+1+(StartY-1)*160+((EndX-1)<<1))=Color;
    *(Video+(EndY-1)*160+((StartX-1)<<1))=StringLine[2];
    *(Video+1+(EndY-1)*160+((StartX-1)<<1))=Color;
    *(Video+(EndY-1)*160+((EndX-1)<<1))=StringLine[3];
    *(Video+1+(EndY-1)*160+((EndX-1)<<1))=Color;
    for(i=StartX;i < EndX-1;i++){
      *(Video+(StartY-1)*160+(i<<1))=StringLine[4];
      *(Video+1+(StartY-1)*160+(i<<1))=Color;
    }
    for(i=StartX;i < EndX-1;i++){
      *(Video+(EndY-1)*160+(i<<1))=StringLine[5];
      *(Video+1+(EndY-1)*160+(i<<1))=Color;
    }

    for(i=StartY;i < EndY-1;i++){
      *(Video+i*160+((StartX-1)<<1))=StringLine[6];
      *(Video+1+i*160+((StartX-1)<<1))=Color;
    }
    for(i=StartY;i < EndY-1;i++){
      *(Video+i*160+((EndX-1)<<1))=StringLine[7];
      *(Video+1+i*160+((EndX-1)<<1))=Color;
    }
}
/* Функция изменяет цвет угольной области
   экрана справа.
   Параметры:
   StartX,StartY - левый верхний угол
   EndX,EndY - правый нижний угол
   Color - цвет */
void ShadowRigth(int StartX,int StartY,
		 int EndX,int EndY,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned i;
    for(i=StartY;i < EndY+1;i++){
      *(Video+1+i*160+(EndX<<1))=Color;
      *(Video+3+i*160+(EndX<<1))=Color;
    }
    for(i=StartX+1;i < EndX+2;i++){
      *(Video+1+(EndY)*160+(i<<1))=Color;
    }
}
/* Функция изменяет цвет угольной области
   экрана слева.
   Параметры:
   StartX,StartY - левый верхний угол
   EndX,EndY - правый нижний угол
   Color - цвет */
void ShadowLeft(int StartX,int StartY,
		 int EndX,int EndY,int Color){
char far *Video=(char far *)0xB8000000;
register unsigned i;
    for(i=StartY;i < EndY+1;i++){
      *(Video+1+i*160+((StartX-3)<<1))=Color;
      *(Video+3+i*160+((StartX-3)<<1))=Color;
    }
    for(i=StartX-2;i < EndX-2;i++){
      *(Video+1+EndY*160+(i<<1))=Color;
    }
}
/* Функция  запоминает текст в прямоугольной
   области на экране
   Параметры:
   StartX,StartY - левый верхний угол
   EndX,EndY - правый нижний угол
   BufText - указатель на массив текста */
void SaveText(int StartX,int StartY,
	      int EndX,int EndY,unsigned char *BufText){
char far *Video=(char far *)0xB8000000;
char far *Text;
register unsigned i,j;
   for(i=StartY-1;i < EndY+1;i++){
      for(j=StartX-1;j < EndX+1;j++){
	Text = Video + (i*160) + (j<<1);
	*BufText++ = *Text++;
	*BufText++ = *Text;
      }
   }
}
/* Функция  восстанавливает текст в прямоугольной
   области на экране
   Параметры:
   StartX,StartY - левый верхний угол
   EndX,EndY - правый нижний угол
   BufText - указатель на массив текста */
void RestTextNorm(int StartX,int StartY,
		 int EndX,int EndY,unsigned char *BufText){
char far *Video=(char far *)0xB8000000;
char far *Text;
register unsigned i, j;
Text = Video;
   for(i=StartY-1;i < EndY+1;i++){
       for(j=StartX-1;j < EndX+1;j++){
	     Video = Text;
	     Video+=(i*160) + (j<<1);
	     *Video++=*BufText++;
	     *Video=*BufText++;
       }
   }
}
