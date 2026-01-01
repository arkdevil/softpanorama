Program EXAMPL;
Uses Shelled;
var
  I,
  SLOI                                      :  integer;
  TEMPER                                    :  real;
  NAPOLNITEL                                :  string;
  OHLGD                                     :  boolean;
  STROKA,
  NOMBER                                    : byte;
  EXITSYMBOL                                : char;

BEGIN
   {ввод исходных значений}
   I:=1;
   OHLGD:=true;
   SLOI:=5;
   NAPOLNITEL:='ХЛАДОН';
   TEMPER:=7.345;

   {вывод маски на экран}
   MaskScrin(6,5,'EXAMPL0.MSK',1,3);

   repeat

     {измениение цвета вывода}
     SetColor(3,4);

     {вывод значений}
     WriteR(TEMPER,3);
     WriteI(SLOI);
     WriteS(NAPOLNITEL);
     WriteB(OHLGD,'ИМЕЕТСЯ','ОТСУТСТВУЕТ');

     {вывод управляющих клавиш листания страниц}
     if EXITSYMBOL='D' then I:=I+1;
     if (EXITSYMBOL='U') and (I>=2) then I:=I-1;
     if I=1 then WriteT('═════') else WriteT(' PgUp/ ');
     WriteT('PgDn');

     {вывод номера страницы}
     WriteI(I);
     {номера страницы становится недоступным для редактора}
     SetMayChandg(false);

     {вызов редактора}
     EditScrin(STROKA,NOMBER,EXITSYMBOL);
     {анализ кода выхода из редактора}
     {возврат для просмотра измененных значений}
   until EXITSYMBOL='0'

   {ЗДЕСЬ - если нажата F10, перейти к программе полязователя}
   {.. ПРОГРАММА ПОЛЬЗОВАТЕЛЯ}
END.
