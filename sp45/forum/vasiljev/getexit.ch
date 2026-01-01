/***
*	getexit.ch
*/

/* Значения внутренней экспортируемой переменной get:exitState */
#define GE_NOEXIT     0  // Нет попытки выхода, подготовка для редактирования
#define GE_UP         1
#define GE_DOWN       2
#define GE_TOP        3
#define GE_BOTTOM     4
#define GE_ENTER      5
#define GE_WRITE      6
#define GE_ESCAPE     7
#define GE_WHEN       8  // Условие в WHEN не удовлетворено
#define GE_JMP_LEFT   9  // Прыжок влево
#define GE_JMP_RIGHT  10 // Прыжок вправо
#define GE_COL_TOP    11 // Прыжок на первый GET колонки
#define GE_COL_BOTTOM 12 // Прыжок на последний GET колонки