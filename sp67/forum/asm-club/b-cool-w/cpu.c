/* ------------------------------------------------------------------------- */
/* CPU.C  Sample program demonstrating usage of TMIOSDGL(tm) routines        */
/* 									     */
/* Copyright(c) 1994 by B-coolWare.  Written by Bobby Z.		     */
/* ------------------------------------------------------------------------- */
/* files needed to build project:
   CPU.C		- compile with memory model XXX
   CPUTYPE.C		- compile with memory model XXX
   CPU_HL.ASM		- set memory model to XXX,C
   CPUSPEED.ASM		- set memory model to XXX,C
*/

#include <stdio.h>
#include "cputype.h"

void main()
{
 puts("CPU Type Identifier/C  Version 1.14c  Copyright(c) 1994 by B-coolWare.\n");

 printf("  Processor: %s, %dMHz\n",cpuType_Str(),(int)CPU_Speed());
 printf("Coprocessor: %s\n",fpuType_Str());
}
