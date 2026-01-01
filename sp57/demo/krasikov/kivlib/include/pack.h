/***************************************************************/
/*                                                             */
/*              KIVLIB include file  PACK.H                    */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/

#ifndef ____PACK____
#define ____PACK____


#ifdef __cplusplus
extern "C" {
#endif

unsigned cdecl PackLZ(unsigned char far * input,
		      unsigned length, unsigned char far * output);
/*******************************************************************
return 0xFFFF - not enough memory
       0      - can not packed
*******************************************************************/

unsigned cdecl UnpackLZ(unsigned char far * input, unsigned char far * output);
/*******************************************************************
0xFFFF - not enough memory
0      - decode stack overflow
*******************************************************************/


#ifdef __cplusplus
}
#endif

#endif
