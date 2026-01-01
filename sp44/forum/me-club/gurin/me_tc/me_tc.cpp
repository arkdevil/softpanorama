/* Заготовка исходного файла, обеспечивающего реализацию совместного использо-
   вания Turbo C++ и Multi-Edit в рамках единой интегрированной системы.
   Гурин С. В. Томск, ТПИ, кафедра электрических станций.
 */

# include <process.h>
# include <stdlib.h>
# include <dos.h>

# if !defined(__SMALL__)
#   error Программу можно компилировать только в модели памяти small
# endif

extern unsigned _heaplen = 2000; // размер области динамических данных
extern unsigned  _stklen = 500;  // размер области стека
extern      int     r_ax = 0;    // регистр кода ошибки
extern      int     r_bx = 0;    // обменные регистры
extern      int     r_cx = 0;
extern      int     r_dx = 0;
extern      int     r_si = 0;
extern      int     r_di = 0;

void interrupt multi_edit_handler(void); // прототип диспетчера прерываний
extern void (*function_array[])(void);   // прототип массива ссылок на функции

# pragma argsused
void main(int argc, char *argv[], char *env[])
{ static int  vector;
  static char vector_environment[16] = "ME_VECTOR=";

  // поиск свободного вектора в таблице прерываний
  for (vector = 0x80; vector <= 0xFF; ++vector)
    if (!peek(0, 4 * vector) && !peek(0, 4 * vector + 2)) break;
  if (vector == 0xFF) abort();
  // формирование строки окружения для передачи вектора в Multi-Edit
  itoa(vector, vector_environment + 10, 10);
  // добавление полученной строки в окружение
  if (putenv(vector_environment) == (-1)) abort();
  // захват вектора прерывания и установка адреса диспетчера
  setvect(vector, (void interrupt (far *)(...))multi_edit_handler);
  // запуск Multi-Edit
  if (spawnve(P_WAIT, "me.exe", argv, env) == (-1)) abort();
  // восстановление значения вектора прерывания
  setvect(vector, 0L);
}

void function_0(void) // вывод байта r_cx в порт внешнего устройства r_bx
{ outportb(r_bx, (unsigned char)r_cx); }

void function_1(void) // ввод байта r_cx из порта внешнего устройства r_bx
{ r_cx = inportb(r_bx); }

// Инициализация массива ссылок на функции
extern int max_function = 1;
extern void (*function_array[])(void) = { function_0, function_1 };
