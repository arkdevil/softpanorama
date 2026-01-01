/***************************************************************/
/*                                                             */
/*              KIVLIB include file MTIMER.H                   */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___TIMER_H___
#define ___TIMER_H___


#ifdef __cplusplus
extern "C" {
#endif

void cdecl Init_Timer(void);
void cdecl Restore_Timer(void);

unsigned long cdecl ElapsedTime(unsigned long Start, unsigned long Stop);
unsigned long cdecl ReadTimer();

#ifdef __cplusplus
}
#endif


#endif




