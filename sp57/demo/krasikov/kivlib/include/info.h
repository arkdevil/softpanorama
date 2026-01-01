/***************************************************************/
/*                                                             */
/*              KIVLIB include file INFO.H                     */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#include <dos.h>
#include <stdio.h>

#ifndef ___INFO___
#define ___INFO___

#include <structs.h>

extern unsigned int PROCESSOR;
/*
   Lo byte - Num:
   0 - Intel 8088
   1 - Intel 8086
   2 - NEC V20
   3 - NEC V30
   4 - Intel 80188
   5 - Intel 80186
   6 - Intel 80286
   7 - Intel 80386/80486 - High byte - 0 - 80386,
                                       1 - Virtual 86 IOPL = 3
                                       2 - Virtual 86 IOPL < 3
*/

typedef enum {D_None,D_MDPAmono,D_CGA,D_EGAcolor,D_EGAmono,D_PGC,
              D_VGAmono,D_VGAcolor,D_MCGAmono,D_MCGAcolor,
              D_Unknown} Display_type;

typedef enum {ct_XT,ct_AT,ct_PC,ct_PCjr,ct_ConvPC,ct_XT640,
              ct_PS30,ct_PS80,ct_UnknType} Computer_type;
/* XT также может быть PC, Portable PC;
   AT - также XT 286, PS 50/60; PS30 - PS/2 -30, PS80 - PS/2-80   */

typedef enum { ft_NotDrv, ft_F360K, ft_F12M,
	       ft_F720K, ft_F144M,ft_FUnkn } floppies_type;


#ifdef __cplusplus
extern "C" {
#endif

int             cdecl UnderWindows();
Display_type    cdecl display_type(void);
Computer_type   cdecl computer_type(void);
int             cdecl freq();  //frequency (MHz) - approximately!!!
void            cdecl compbios_date(struct date * D);
char            cdecl bootdrive(void);
floppies_type   cdecl floppy_type(int num);


CVTType far *  cdecl get_CVT(void);
MCBType far *  cdecl firstMCB(void);
MCBType far *  cdecl nextMCB(MCBType far * M);
int     cdecl        existDriver(char * DName);
DPBType far *  cdecl getDPB(unsigned char Drive); //0-def, 1-A etc.
DPBType far *  cdecl getFirstDPB(CVTType far * CVT);
DPBType far *  cdecl getNextDPB(DPBType far * DPB);


int cdecl ZenithBIOS();
int cdecl CompaqBIOS();

int cdecl EnhKbd(); //Установлена ли Enhanced Keyboard


#ifdef __cplusplus
}
#endif

#endif
