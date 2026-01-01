/*--------------------------------------------------------------------*/
/*    Header files for ssleep.c for UUPC/extended                     */
/*--------------------------------------------------------------------*/

boolean ssleep(time_t interval);
boolean ddelay(int milliseconds);
boolean WaitEvent(int, boolean (*)(void));

#define DELAY(n) {volatile junk; for (junk = 0; junk < (n); junk++) ;}
