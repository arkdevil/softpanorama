#include <stdio.h>
#include <conio.h>

typedef unsigned int word;

#define Family 0x0F00
#define Model  0x00F0
#define Step   0x000F

#define FPUonChip 	0x0001
#define EnhancedV86 	0x0002
#define IOBreakpoints 	0x0004
#define PageSizeExt 	0x0008
#define TimeStampCnt	0x0010
#define ModelSpecific	0x0020
#define MachineCheckExc	0x0040
#define CMPXCHG8B	0x0080

extern word CheckP5(void);

extern word GetP5Vendor(void);

extern word GetP5Features(void);

char * getVendor(void)
{
 if (!GetP5Vendor())
  return "GenuineIntel";
 else
  return "Non-Intel";
}

word getFamily(void)
{
 return ((CheckP5() & Family) >> 8);
}

word getModel(void)
{
 return ((CheckP5() & Model) >> 4);
}

word getStep(void)
{
 return (CheckP5() & Step);
}

void printFeatures(void)
{
 word Features = GetP5Features();

 if (Features & FPUonChip)
  putch(0xFE);
 else
  putch(' ');
 puts(" FPU on chip");

 if (Features & EnhancedV86)
  putch(0xFE);
 else
  putch(' ');
 puts(" Enhanced Virtual-8086 mode");

 if (Features & IOBreakpoints)
  putch(0xFE);
 else
  putch(' ');
 puts(" I/O Breakpoints");

 if (Features & PageSizeExt)
  putch(0xFE);
 else
  putch(' ');
 puts(" Page Size Extensions");

 if (Features & TimeStampCnt)
  putch(0xFE);
 else
  putch(' ');
 puts(" Time Stamp Counter");

 if (Features & ModelSpecific)
  putch(0xFE);
 else
  putch(' ');
 puts(" Pentium processor-style model specific registers");

 if (Features & MachineCheckExc)
  putch(0xFE);
 else
  putch(' ');
 puts(" Machine Check Exception");

 if (Features & CMPXCHG8B)
  putch(0xFE);
 else
  putch(' ');
 puts(" CMPXCHG8B Instruction");
}

void main(void)
{
 puts("P5Info/C  Version 1.00  Copyright(c) 1994 by B-coolWare.\n");

 if(!CheckP5())
  {
   puts("This processor doesn't handle CPUID instruction properly.");
   return;
  }
 printf("Make %s\nFamily %d Model %d Step %d\n\nProcessor Features:\n",
        getVendor(),getFamily(),getModel(),getStep());
 printFeatures();
}
