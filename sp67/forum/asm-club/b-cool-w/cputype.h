/* ------------------------------------------------------------------------- */
/* CPUTYPE.H  TMIOSDGL(tm) interface module		       Version 1.14b */
/*									     */
/* Copyright(c) 1994 by B-coolWare.  Written by Bobby Z.		     */
/* ------------------------------------------------------------------------- */

#ifndef __Lib__

extern char *cpuType_Str(void);
extern char *fpuType_Str(void);
extern float CPU_Speed(void);

#endif

/* processor and coprocessor type defines follow */

#define i8088		0x0000
#define i8086		0x0001
#define V20		0x0002
#define V30		0x0003
#define i80188		0x0004
#define i80186		0x0005
#define i80286		0x0006
#define i80386sxr	0x0007
#define i80386sxv	0x0107
#define i80386dxr	0x0008
#define i80386dxv	0x0108
#define i386slr		0x0009
#define i386slv		0x0109
#define i486sxr		0x000A
#define i486sxv		0x010A
#define i486dxr		0x000B
#define i486dxv		0x010B
#define cx486slcr	0x000C
#define cx486slcv	0x010C
#define cx486dlcr	0x000D
#define cx486dlcv	0x010D
#define iP5r		0x000E
#define iP5v		0x010E
#define cxM1r		0x000F
#define cxM1v		0x010F

#define maxCPU		0x0F	/* max. CPU index returned by CPU_Type */

/* following CPUs reported only if tested as Intel 386 and clock is > 33MHz
   for Intel doesn't produce such chips */

#define am386sxr	0x0010
#define am386sxv	0x0110
#define am386dxr	0x0011
#define am386dxv	0x0111

typedef unsigned char byte;
typedef unsigned int  word;

extern word CPU_Type(void);
