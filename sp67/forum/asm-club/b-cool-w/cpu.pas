{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X+}
{$M 16384,0,655360}
{ --------------------------------------------------------------------------- }
{ CPU.PAS  Sample program demonstrating usage of TMIOSDGL(tm) routines        }
{									      }
{ Copyright(c) 1994 by B-coolWare.  Written by Bobby Z.			      }
{ --------------------------------------------------------------------------- }
{ files needed to build project:

  CPU_HL.ASM
  CPUSPEED.ASM
  CPUTYPE.PAS								      }

uses CPUType;

begin
 WriteLn('CPU Type Identifier/Pas  Version 1.14c  Copyright(c) 1992,94 by B-coolWare.');
 WriteLn;
 WriteLn('  Processor: ',CPU_TypeStr, ', ',Trunc(CPUSpeed),'MHz');
 WriteLn('Coprocessor: ',CoPro_TypeStr);
end.
