/***************************************************************/
/*                                                             */
/*                KIVLIB  include file  RUS.H                  */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___RUSSIAN___
#define ___RUSSIAN___

#ifdef __cplusplus
extern "C" {
#endif

void cdecl LoadRusFont14();
void cdecl LoadRusFont16();
void cdecl LoadRusFont8();

extern unsigned char RusSwitch;


//WARNING! TAKE CARE USING THIS FUNCTIONS!
void cdecl RusKbEnable();
void cdecl RusKbDisable();
//Warning ! Maybe non-predicatable errors!

#ifdef __cplusplus
};
#endif

#endif
