/************************************************************************/
/*	Программа КАЛАХ. 						*/
/*	См. описание.							*/
/*	Copyright 1993, InfoScope.					*/
/************************************************************************/

#include <ctype.h>
#include <bios.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <time.h>

#include "kalah.h"

NODE rootPos;                   /* Текущая позиция			*/
				/* и последний сделанный ход            */

	/* Переменные, используемые при переборе.		*/
NODE bestMove;                  /* Позиция, куда findMove советует 	*/
                                /* пойти из позиции rootPos.            */
int      cL,			/* Текущий уровень перебираемых узлов.	*/
	 maxLevel=MAXLEVEL;	/* Макс. уровень перебираемых узлов.	*/
NODE     wStack[MAXLEVEL+1];    /* Стек для прохода дерева игры         */
NODE     curPos;		/* Рабочая переменная - см. findMove.	*/

                /* Переменные для хранения ходов игры.          */
NODE gameA[100]=                /* Массив для хранения ходов игрока А.  */
                {-1,-1};        /* Трюк, используемый при выводе игры.  */
NODE gameB[100];                /* Массив для хранения ходов игрока В.  */
int gameLength=0;               /* Количество ходов в игре.             */

		/* Переменные для "интерфейсных" параметров	*/
int wEnt;			/* Нужно ли ждать нажатия ENTER после	*/
				/* сообщения "Пойду" - см. askProgram	*/
whoToMove aPlayer;		/* Игрок А - Program/Human.		*/
turnToPlay firstToPlay;		/* Первым ходит игрок А или В?		*/

int x[14],y[14];                 /* Координаты полей на экране.  	*/

		/* Расстояния между лунками.			*/
#define stepX           9
#define stepY		2
		/* Координаты левого НИЖНЕГО угла "доски".	*/
#define cornX		17
#define cornY		15

void main (void)
{
   whoToMove  movesNow;
   int endGame = 0,flag;

   askTunes();
   initialize();

   rootPos.move[0] = firstToPlay == aToPlay ? 7 : 0;
			/* "Предпервое" состояние (см. Aplays):		*/
			/* притворимся, что нулевой ход уже сделан -	*/
			/* игроком B, если первым ходить должен А,	*/
                        /* игроком А, если первым ходить должен В.	*/
   movesNow = firstToPlay == aToPlay ? aPlayer : Program;
   flag = firstToPlay == aToPlay ? 0 : 1;
   while(!endGame)
   {
      endGame = getMove(movesNow);
      movesNow = movesNow == aPlayer ? Program : aPlayer;
      if(!Aplays(rootPos))
         gameA[gameLength] = rootPos;
      else
         gameB[gameLength] = rootPos;
      if(flag) flag = !(++gameLength); else flag = 1;
   }
   drawScreen();		/* Выведем заключительную позицию.	*/
   saveGame();			/* Запишем игру в файл 'lastgame.klh'.	*/
   sayBye();
}/*main*/

void askTunes(void)
{
   char c;

   clrscr();
   printf("\n\rКто игрок A (1 - человек / 2 - программа)?:");
   while((c = getch()) != '1' && c != '2');
   aPlayer = (c == '2') ? Program : Human;
   printf(aPlayer == Human ? "Человек" : "Программа");
   if (aPlayer == Program)
   {
      printf("\n\rБудешь нажимать ENTER, чтобы программа пошла? (1-Y/2-N):");
      while((c = getch()) != '1' && c != '2');
      printf(c == '1' ? "Да" : "Нет");
   }
   else
      c = '1';
   wEnt = c == '1';
   printf("\n\rКто ходит первым: 1 - игрок А, 2 - игрок В? ");
   while((c = getch()) != '1' && c != '2');
   firstToPlay = c == '1' ? aToPlay : bToPlay;
}/*askTunes*/

void setLocs(void)
{
   int i;

   for (i=0; i < 6; i++)		/* Координаты игровых полей 	*/
   {
      y[i] = cornY + stepY * 2;
      y[i + 7] = cornY;
      x[i] = cornX + stepX * i;
      x[i + 7] = cornX + stepX * (5 - i);
   }
                                        /* Теперь - координаты калахов: */
   x[6]  = cornX + stepX * 6;           /* Калах игрока А - справа.     */
   x[13] = cornX - stepX;               /* Калах игрока B - слева.      */
   y[6]  =                              /* Зато расположены они         */
   y[13] = cornY + stepY;               /* на одной горизонтали.        */
}/*setLocs*/

void initialize(void)
{
   int i;

   randomize();
   clrscr();

   for(i=0; i < 6;i++)
      rootPos.desk[i] = rootPos.desk[i+7] = 6;
   rootPos.desk[6] = rootPos.desk[13] = 0;
   rootPos.forced = 0;

   setLocs();
   for(i=cornX - stepX; i <= cornX + 6 * stepX; i++)
   {
      gotoxy(i, cornY - 1);
      printf("─");
      gotoxy(i, cornY + stepY * 2 + 1);
      printf("─");
   }

   for(i = 0; i < 6; i++)
   {
      gotoxy (x[i],    y[i]    + 2); printf ("%2d", i);
      gotoxy (x[12-i], y[12-i] - 2); printf ("%2d", 12 - i);
   }
   drawScreen();
}/*initialize*/

void drawScreen(void)
{
   int i;

   for(i=0;i<14;i++)
   {
      gotoxy (x[i],y[i]);
      printf ("%2d",rootPos.desk[i]);
   }
}/*drawScreen*/

int ABprune(PNODE p, int alpha, int beta)
/* Alpha-beta pruning (метод граней и оценок) из статьи Д.Кнута.        */
/* Возвращает оценку заданной позиции p.				*/
{
   int 	m, t;
   PNODE 	pcurPos;

   cL++;
   pcurPos = first(p);		/* Если у позиции p нет сыновей,	*/
				/* вернем NULL.				*/
   if(pcurPos == NULL) 
   {
      cL--;
      return estimate(p);	/* ЗДЕСЬ выход из процедуры,		*/
   }   				/* когда позиция терминальна.		*/
   else 
   {
      m = alpha;
      while(m < beta && pcurPos != NULL)
      {
         t = -ABprune(pcurPos, -beta, -m);
         if(t > m)
            m = t;
         pcurPos = next(p);
      }
   }
   cL--;
   return m;				/* А ЗДЕСЬ - выход для всех 	*/
	   				/* остальных позиций.		*/
}/*ABprune*/

PNODE first(PNODE p)
{
   if(cL < maxLevel)
   {
      wStack[cL].forced = 0;
      wStack[cL].move[0] = Aplays(*p) ? -1 : 6;
      return next(p);
   }
   return NULL;
}/*first*/

void retPos(PNODE p)
{
   int i;

                      /* Сначала скопируем позицию из p         */
   memmove(wStack[cL].desk,p->desk,sizeof(p->desk));
                      /* Теперь проделаем форсированные ходы    */
                      /* до позиции, предшествующей текущей.    */
   for(i=0;i<wStack[cL].forced;i++)
   {
      scatterStones(wStack[cL].desk,wStack[cL].move[i]);
                      /* Эта позиция не может быть пустой!!	*/
   }
}/*retPos*/

PNODE next(PNODE p)
{
   int U = Aplays(*p) ? 6 : 13;
   int move,t;
		/**** Найдем очередной ход.	****/
   retPos(p); /* Построим позицию до очередного хода.     */
                         /* Найдем допустимый ход.         */
   move = wStack[cL].move[wStack[cL].forced];
   while(++move < U && wStack[cL].desk[move] == 0);
   wStack[cL].move[wStack[cL].forced] = move;

   if(move == U)
      return (wStack[cL].forced-- == 0) ? NULL : next(p);
   else
   {               /* move < U     */
      t = scatterStones(wStack[cL].desk,move);
      if(t)
      {
         if(isEmpty(&wStack[cL]))
            return &wStack[cL];
         else
         { /* 1.2. (!) */
            wStack[cL].move[++wStack[cL].forced] =
         			Aplays(*p) ? -1 : 6;
            return next(p);
         }
      }
      else
         return &wStack[cL];
   }
}/*next*/

int estimate(PNODE p)
/* Вычислить оценку позиции.			*/
{
    int value = p->desk[6] - p->desk[13];
    if(!Aplays(*p)) value = -value;
    return value;
}/*estimate*/

int findMove(PNODE p)
{
   int		res=0;
   int 	t,m;
   PNODE 	pcurPos=&curPos;

   if((pcurPos=getFirst(p)) == NULL)
   {
      return 0;			/* ЗДЕСЬ выход из процедуры,		*/
   }   				/* когда позиция терминальна.		*/
   else
   {
      m = -200;
      while(pcurPos != NULL)
      {
	 cL = -1;               /* "Предпервое" состояние уровня.       */
	 t = -ABprune(pcurPos,-200, 200);
         if(t > m || (t == m && random(2)))
         {
	    m = t;
	    bestMove = curPos;
	    res++;
	 }
	 pcurPos = getNext(p);
      }
   }
   return res;
}/*findMove*/

PNODE getFirst(PNODE p)
{
   cL=0;                        /* Чтобы воспользоваться first!         */
   first(p);         		/* Сгенерируем первого сына p.          */
   curPos = wStack[0];
   return &curPos;
}/*getFirst*/

PNODE getNext(PNODE p)
{
   PNODE pcurPos;

   wStack[0] = curPos; cL = 0;    /* Положим позицию в стек и     */
   pcurPos = next(p);             /* сгенерируем следующую.       */
   if(pcurPos)
   {
      curPos = wStack[0];
      pcurPos = &curPos;
   }
   return pcurPos;
}/*getNext*/

void sayBye(void)
{
   gotoxy(1, 1);
   printf("Игра окончена. Нажми ENTER.");
   waitEnter();
}/*sayPress*/

void saveGame(void)
{
   int i,k;
   FILE *file = fopen("lastGame.klh","wt");

   gotoxy(1,1);

   fprintf(file, "\nИгрок A : %s",
                aPlayer == Human ? "Человек" : "Программа");
   fprintf(file, "\nИгрок B : Программа");
   fprintf(file, "\nПервым ходил игрок %c\n\n",
			firstToPlay == aToPlay ? 'A' : 'B');

   for(i=0; i<gameLength; i++)
   {
      fprintf(file,"\n%2d) ",i+1);
      if(gameA[i].move[0] != -1)
      {
         fprintf(file,"A:");
         for(k=0; k<=gameA[i].forced;k++)
         {
            fprintf(file," %2d",gameA[i].move[k]);
         }
      }
      fprintf(file,"\t\tB:");
      for(k=0; k<=gameB[i].forced;k++)
      {
         fprintf(file," %2d",gameB[i].move[k]);
      }
   }
   fprintf(file,"\n\nКамней по окончании игры:\n"
   	        "\tв калахе А - %d\n"
   	        "\tв калахе B - %d\n",
                rootPos.desk[6],rootPos.desk[13]);
   fclose(file);
}/*saveGame*/

int getMove(whoToMove movesNow)
{
   switch(movesNow)
   {
      case Human:
	 askHuman();
	 break;
      case Program:
	 askProgram();
   	 rootPos = bestMove;
	 break;
   }
   return isEmpty(&rootPos);
}/*getMove*/

void askHuman(void)
{
   int rep=0, move;

   rootPos.forced = 0;
   do
   {
      if((move=askMove()) == -1)
	 exit(0);		/* нажат <ESC> - вываливаемся в ДОС	*/
      rep = makeMove(move);
      rootPos.move[rootPos.forced++] = move;
   } while(rep);

   rootPos.forced--;			/* !!! extent д.б. на 1 меньше	*/
   					/* введенного кол-ва ходов!!!	*/

}/*askHuman*/

int askMove(void)
{
   int move, ch;

   while(1)
   {                   /* Цикл ввода нажатия пользователя      */
      gotoxy(1,1); clreol();
      printf("Введи ход: ");

      ch = bioskey(0) & 0xFF;			/* ждем нажатия   	*/

      if(ch == 27)	/* Нажата клавиша <ESC> -			*/
	 return -1;	/* вернем заведомо недопустимый номер поля.	*/

      putchar(ch);
      move = ch - '0';				/* Кодируем нажатие     */
      if (!isdigit(ch) || move > 5 || rootPos.desk[move] == 0)
      {
	 putchar('\a');			/* Нажато не то: "гуднем" и -	*/
	 continue;			/* для тупых - повторим вопрос 	*/
      }
      break;				/* Здесь - выход из цикла	*/
   }
   return move;

}/*askMove*/

void sayThinking(void)
{
   gotoxy(1,1); clreol();
   lowvideo(); textattr(LIGHTGRAY+BLINK);
   cprintf("Думаю...");
   textattr(LIGHTGRAY);
}/*sayThinking*/

void sayMoving(int k)
{
   int i;

   gotoxy(1,1); clreol();
   lowvideo(); textattr(LIGHTGRAY);
   cprintf("Пойду с");
   for(i=k;i<=bestMove.forced;i++)
      cprintf(" %2d",bestMove.move[i]);
}/*sayMoving*/

void waitEnter(void)
{
   while(getch() != 13);	/* Код клавиши ENTER равен 13, правда?	*/
}/*waitEnter*/

void askProgram(void)
{
   int i;

   sayThinking();
   findMove(&rootPos);
   for(i=0;i<=bestMove.forced;i++)
   {
      sayMoving(i);
      if(wEnt)
         waitEnter();
      makeMove(bestMove.move[i]);
   }
}/*askProgram*/

int makeMove(int move)
{
   int rep;

   rep = scatterStones(rootPos.desk,move);
   drawScreen();
   if(isEmpty(&rootPos)) rep = 0;
   return rep;
}/*makeMove*/

#define INC(i)          i++;                                    \
      if (move < 6 /* Ход игрока A */ &&                        \
          i == 13  /* Собираемся класть в калах игрока B */     \
          ||                                                    \
          move > 6 /* Ход игрока B */ &&                        \
          i == 14  /* Дошли до конца массива */) i = 0;         \
      else                                                      \
      if (move > 6 /* Ход игрока B */ &&                        \
          i == 6   /* Пропустим калах игрока A */) i++;

int scatterStones(int desk[14], int move)
{
   int i, fin=0, stones;

   i = move;
   stones = desk[i];            /* Количество распределяемых камней     */
   desk[i] = 0;
   while(stones--)
   {                            /* Разложим камушки:    */
      INC(i);                            /* Увеличим i и                */
      desk[i]++;                         /* положим очередной камушек.  */
   }
                             /*** Правило 1.3: ***/
                             /* Ход закончился на СВОЕМ пустом поле.    */
   if(desk[i] == 1 && desk[12-i] > 0 &&      /* Поле напротив непусто. */
      ((move < 6 &&                          /* Ход игрока A            */
         i < 6) ||                           /* и кончили на его поле.  */
       (move > 6 &&                          /* Ход игрока B            */
        i > 6 && i < 13)))                   /* и кончили на его поле.  */
   {                 
      desk[move<6? 6:13] += desk[i] + desk[12-i];
      desk[i] = desk[12-i] = 0;
   }
		/*** Сообщим о том, что нужно применить правило 1.2. ***/
   if (move < 6 && i == 6 || move > 6 && i == 13) fin = 1;
   return fin;
}/*scatterStones*/

#undef INC

int isEmpty(PNODE p)
{
   int i,fin;
                                /*** Правило 1.4. ***/
   fin = 1;
   for(i=0;i<6;i++) if(p->desk[i]) fin = 0;
   if(fin)
   {
      for(i=7;i<13;i++)
      {
         p->desk[13] += p->desk[i]; p->desk[i] = 0;
      }
      return 1;
   }
   fin = 1;
   for(i=7;i<13;i++) if(p->desk[i]) fin = 0;
   if(fin)
      for(i=0;i<6;i++)
      {
         p->desk[6] += p->desk[i]; p->desk[i] = 0;
      }
   return fin;
}/*isEmpty*/

