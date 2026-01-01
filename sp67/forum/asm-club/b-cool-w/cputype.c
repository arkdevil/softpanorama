/* ------------------------------------------------------------------------- */
/* CPUTYPE.C  CPU/FPU detection routines				     */
/*									     */
/* Copyright(c) 1994 by B-coolWare.  Written by Bobby Z. and VAP.	     */
/* Uses portions of TMIOSDGL(tm) v1.14					     */
/* ------------------------------------------------------------------------- */
/* files needed to build:
   
   CPUTYPE.C		- compile with memory model XXX
   CPU_HL.ASM		- set memory model to XXX,C
   CPUSPEED.ASM		- set memory model to XXX,C
*/

/* Modification history:

	21 Jun 1994  initially written

*/

#include <stdlib.h>

#define __Lib__
#include "cputype.h"

byte FPUType = 0xFF;
long CPUFix  = 0L;
word Shift   = 2;

extern int Speed( byte );

float CPU_Speed(void)
{
 word sp = Speed(CPU_Type());
 return ((Shift*CPUFix)/sp+5)/10;
}

char * cpuType_Str(void)
{
  char *Names[] = { "Intel 8088", "Intel 8086", "NEC V20", "NEC V30",
		    "Intel 80188", "Intel 80186", "Intel 80286", "Intel 80386sx",
		    "Intel 80386dx", "IBM 386sl", "Intel i486sx", "Intel i486dx",
		    "Cyrix 486sx/slc", "Cyrix 486dx/dlc", "Intel Pentium", "Cyrix M1 (586)"
		   };

  int c = CPU_Type();
  byte lo_c = c;
  if (lo_c > maxCPU)
   return ("Unknown!");
  switch(c) {
   case i80386sxr:
   case i80386sxv: if (CPU_Speed() > 35.0)
 		    return ("AMD Am386sx");
		   else
	 	    return Names[lo_c];
   case i80386dxr:
   case i80386dxv: if (CPU_Speed() > 35.0)
		    return ("AMD Am386dx");
		   else
		    return Names[lo_c];
   default:
	           return Names[lo_c];
  }
}

char *fpuType_Str(void)
{
  char *Names[] = {"Unknown!", "Unknown!", "None", "Weitek", "Intel 8087",
		   "Intel 8087 & Weitek", "Intel i487sx", "Intel i487sx & Weitek",
		   "Intel 80287", "Intel 80287 & Weitek", "Cyrix 2C87",
		   "Cyrix 2C87 & Weitek", "Intel 80387", "Intel 80387 & Weitek",
		   "Cyrix 3C87", "Cyrix 3C87 + Weitek", "Built-in",
		   "Built-in & Weitek", "Cyrix 4C87", "Cyrix 4C87 & Weitek",
		   "Intel 80287XL", "Intel 80287XL & Weitek",
		   "IIT 2C87", "IIT 2C87 & Weitek", "IIT 3C87", "IIT 3C87 & Weitek"
		  };

  if (FPUType == 0xFF)
   CPU_Type();
  if (FPUType > 25) 
   return ("Unknown!");
  else
   return Names[FPUType];
}

