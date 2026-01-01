#ifndef KALAH_H                         /* To prevent redefinition      */

typedef enum {Human, Program} whoToMove;
typedef enum {aToPlay, bToPlay} turnToPlay;

typedef struct treeNode {	/* Структура, представляющая позицию.	*/
   int          forced;                 /* Кол-во вынужденных ходов.    */
   int          move[30];               /* Ход в данную позицию         */
   int          desk[14];               /* Поля и калахи игроков:       */
					/*	A (0..6) и B (7..13).	*/
} NODE,*PNODE;

#define Aplays(p)    ((p).move[0] > 6)
			/* Поскольку move[0] - ход в ДАННУЮ позицию,	*/
			/* очередь хода принадлежит игроку А, если	*/
			/* в ДАННУЮ позицию привел ход игрока B, т.е.	*/
			/* 		move[0] > 6 !			*/

	/* Константа MAXLEVEL ограничивает глубину перебора	*/
	/**** Константа MAXLEVEL не может равняться нулю!!!  ****/
#define MAXLEVEL	  3	/* Максимальный уровень в дереве,	*/
				/* до которого ведется перебор.		*/


void initialize(void);          /* Инициализировать переменные.         */
                                /* и нарисовать игровое поле.           */
void setLocs(void);             /* Задать координаты полей на экране.   */

void askTunes(void);            /* Узнать у пользователя, кто игрок А   */
                                /* (программа или человек), кто первым  */
                                /* ходит - игрок А или игрок В и        */
                                /* нужно ли ждать нажатия ENTER после   */
                                /* того, как программа скажет, как      */
                                /* она собирается пойти.                */
void drawScreen(void);          /* Вывести на экран позицию rootPos.    */
void sayThinking(void);         /* На экран - надпись "Думаю..."        */
void sayMoving(int k);          /* Вывести на экран ход (серию ходов),  */
                                /* найденный программой.                */
int makeMove(int move);         /* Сделать заданный ход,                */
				/* показав результат на экране.		*/
void waitEnter(void);           /* Подождать нажатия клавиши ENTER.     */
void sayBye(void);              /* Мы ведь вежливые!                    */

int askMove(void);              /* Спросить ход у человека.             */
void askHuman(void);            /* Диалог с человеком по поводу         */
                                /* следующего хода (серии ходов).       */
                                /* Сделать эти ходы.                    */
void askProgram(void);          /* Спросить у программы следующий ход   */
                                /* и сделать его!                       */
int getMove(whoToMove movesNow);/* В зависимости от очереди             */
				/* хода либо спросить человека,		*/
				/* заставить подумать программу.	*/

int  findMove(PNODE p);         /* Найти лучший ход из позиции p.       */
				/* Учитывается очередь хода!		*/
PNODE getFirst(PNODE p);        /* Дать первого сына для позиции p.     */
PNODE getNext(PNODE p);         /* Дать очередного сына для позиции p.  */


int ABprune(PNODE p, int alpha, int beta);      /* Оценить позицию p.   */
PNODE first(PNODE p);           /* Сгенерировать первого из сыновей p.  */
void retPos(PNODE p);           /* Вспомогательная функция для next.    */
PNODE next(PNODE p);            /* Сгенерировать очередного сына для p. */
int   estimate(PNODE p);        /* Оценка терминальной позиции.         */

int scatterStones(int desk[14], int move);/* Сделать ход из позиции.    */
int isEmpty(PNODE p);           /* Применить правило 1.4.               */
				/* Вернуть 1, если в итоге поля пусты,	*/
				/* в противном случае вернуть 0.        */
void saveGame(void);            /* Спасти игру в файл "lastgame.klh".   */


#define KALAH_H				/* Prevents redefinition	*/
#endif					/* Ends "#ifndef KALAH_H"	*/

