/***************************************************************/
/*                                                             */
/*                KIVLIB include file  DEFINES.H               */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#if !defined(__DEFINES_H__)
#define __DEFINES_H__


#if !defined( ___DEFS_H )
#include <_defs.h>
#endif



typedef unsigned int  word;
typedef unsigned char byte;
typedef void _FAR *   pointer;
typedef enum {False, True} Bool;

#define  TYPE(VAR, type)    (*((type _FAR *)&VAR))

#define  LOWORD(s)          (word)(s)
#define  HIWORD(s)          (word)((s)>>16)
#define  LOBYTE(s)          (byte)(s)
#define  HIBYTE(s)          (byte)((s)>>8)


#endif

