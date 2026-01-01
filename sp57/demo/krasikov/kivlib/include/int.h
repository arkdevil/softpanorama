/***************************************************************/
/*                                                             */
/*               KIVLIB include file INT.H                     */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___INT_H___
#define ___INT_H___


#ifdef __cplusplus
extern "C" {
#endif

void far cdecl Set09Int(int far (*Proc)(int));
// if Proc return !0 => call old ISR, zero => end of interrupt

void far cdecl Set08Int(void far (*Proc)());

#ifdef __cplusplus
}
#endif

#endif

