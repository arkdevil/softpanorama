{$A-,B-,D+,E-,F+,G-,I-,L+,N-,O+,R-,S-,V-,X+}
{ --------------------------------------------------------------------------- }
{ CPUTYPE.PAS  CPU type detection routines ( Intel & compatible family only ) }
{                                                                             }
{ Copyright(c) 1992,93,94 by B-coolWare.  Written by Bobby Z.                 }
{ --------------------------------------------------------------------------- }
{ Modified 12/05/93 - added distinguishing between 386 and 486                }
{ Modified 15/09/93 - added some new CPUs and FPUs                            }
{ Modified 10/01/94 - added IIT math chips detection                          }
{ Modified 03/02/94 - Cyrix chips distinguishing made reliable                }
{ Modified 20/06/94 - added Cyrix M1 detection,				      }
{		      added i487sx detection				      }
{ --------------------------------------------------------------------------- }
{ files needed to build project:

  CPU_HL.ASM
  CPUSPEED.ASM								      }

unit CPUType;

interface

const  i88     =  $0000;	{ Intel 8088 }
       i86     =  $0001;	{ Intel 8086 }
       V20     =  $0002;	{ NEC V20 }
       V30     =  $0003;	{ NEC V30 }
       i188    =  $0004;	{ Intel 80188 }
       i186    =  $0005;	{ Intel 80186 }
       i286    =  $0006;	{ Intel 80286 }
       i386sxr =  $0007;	{ Intel 80386sx real mode }
       i386sxv =  $0107;	{ Intel 80386sx V86 mode }
       i386dxr =  $0008;	{ Intel 80386dx real mode }
       i386dxv =  $0108;	{ Intel 80386dx V86 mode }
       i386slr =  $0009;        { IBM 80386SL real mode }
       i386slv =  $0109;        { IBM 80386SL V86 mode }
       i486sxr =  $000A;	{ Intel i486sx real mode }
       i486sxv =  $010A;	{ Intel i486sx V86 mode }
       i486dxr =  $000B;	{ Intel i486dx real mode }
       i486dxv =  $010B;	{ Intel i486dx V86 mode }
       c486slcr=  $000C;	{ Cyrix 486slc real mode }
       c486slcv=  $010C;	{ Cyrix 486slc V86 mode }
       c486dlcr=  $000D;	{ Cyrix 486dlc real mode }
       c486dlcv=  $010D;	{ Cyrix 486dlc V86 mode }
       i586r   =  $000E;	{ Intel Pentium real mode }
       i586v   =  $010E;	{ Intel Pentium V86 mode }
       cM1r    =  $000F;	{ Cyrix M1 (586) in real mode }
       cM1v    =  $010F;	{ Cyrix M1 (586) in V86 mode }

       { these CPUs reported only if tested as Intel 386 and CPU clock > 33MHz
	 because Intel does not produce such chips }
       am386sxr=  $0010;	{ AMD Am386sx real mode }
       am386sxv=  $0110;	{ AMD Am386sx V86 mode }
       am386dxr=  $0011;	{ AMD Am386dx real mode }
       am386dxv=  $0111;	{ AMD Am386dx V86 mode }

function CPU_Type : Word;

function CPU_TypeStr : String;

function CoPro_TypeStr : String;

function CPUSpeed : Real;

implementation

const FPUType : Byte = $FF;
      CPUFix  : LongInt = $000000000;
      Shift   : Word = 2;

      CyrStr  : String[6] = 'Cyrix ';
      IntelStr: String[6] = 'Intel ';
      WeitStr : String[11]= 'Weitek 1167';
      IITStr  : String[4] = 'IIT ';
      andStr  : String[5] = ' and ';

function CPU_Type; external;
{$L cpu_tp}

function Speed(CPUId : Byte) : Word; external;
{$L speed_tp}


function Vendor( CPU : Byte ) : String;
 begin
  case CPU of
   $0C,$0D,
   $0F     : Vendor := CyrStr;
   $02,$03 : Vendor := 'NEC ';
   $09     : Vendor := 'IBM ';
   $10,$11 : Vendor := 'AMD ';
  else
   Vendor := IntelStr;
  end;
 end;

function CPU_TypeStr;
 var CPU : Word;
begin
 CPU := CPU_Type;
 case CPU of
  i88      : CPU_TypeStr := Vendor(CPU)+'8088';
  i86      : CPU_TypeStr := Vendor(CPU)+'8086';
  i188     : CPU_TypeStr := Vendor(CPU)+'80188';
  i186     : CPU_TypeStr := Vendor(CPU)+'80186';
  v20      : CPU_TypeStr := Vendor(CPU)+'V20';
  v30      : CPU_TypeStr := Vendor(CPU)+'V30';
  i286     : CPU_TypeStr := Vendor(CPU)+'80286';
  i386sxr,
  i386sxv  : if CPUSpeed > 35 then
	      CPU_TypeStr := Vendor(am386sxr)+'Am386sx'
	     else
	      CPU_TypeStr := Vendor(CPU)+'80386sx';
  i386slr,
  i386slv  : CPU_TypeStr := Vendor(CPU)+'80386sl';
  i386dxr,
  i386dxv  : if CPUSpeed > 35 then
    	      CPU_TypeStr := Vendor(am386dxr)+'Am386dx'
	     else
    	      CPU_TypeStr := Vendor(CPU)+'80386dx';
  i486sxr,
  i486sxv  : CPU_TypeStr := Vendor(CPU)+'i486sx';
  i486dxr,
  i486dxv  : CPU_TypeStr := Vendor(CPU)+'i486dx';
  c486slcr,
  c486slcv : CPU_TypeStr := Vendor(CPU)+'486sx/slc';
  c486dlcr,
  c486dlcv : CPU_TypeStr := Vendor(CPU)+'486dx/dlc';
  i586r,
  i586v    : CPU_TypeStr := Vendor(CPU)+'Pentium';
  cM1r,
  cM1v	   : CPU_TypeStr := Vendor(CPU)+'M1 (586)';
 end;
end;

function CoPro_TypeStr;
 begin
  if FPUType = $FF then
   CPU_Type;
  case FPUType of
   0,1     : CoPro_TypeStr := 'Unknown';
   2       : CoPro_TypeStr := 'None';
   3       : Copro_TypeStr := WeitStr;
   4       : Copro_TypeStr := IntelStr+'8087';
   5       : Copro_TypeStr := IntelStr+'8087'+AndStr+WeitStr;
   6       : Copro_TypeStr := IntelStr+'i487sx';
   7       : Copro_TypeStr := IntelStr+'i487sx'+AndStr+WeitStr;
   8       : Copro_TypeStr := IntelStr+'80287';
   9       : Copro_TypeStr := IntelStr+'80287'+AndStr+WeitStr;
   $A      : Copro_TypeStr := CyrStr+'2C87';
   $B      : Copro_TypeStr := CyrStr+'2C87'+AndStr+WeitStr;
   $C      : Copro_TypeStr := IntelStr+'80387';
   $D      : Copro_TypeStr := IntelStr+'80387'+AndStr+WeitStr;
   $E      : Copro_TypeStr := CyrStr+'3C87';
   $F      : Copro_TypeStr := CyrStr+'3C87'+AndStr+WeitStr;
   $10     : Copro_TypeStr := 'Internal';
   $11     : Copro_TypeStr := 'Internal'+andStr+WeitStr;
   $12     : Copro_TypeStr := CyrStr+'4C87';
   $13     : Copro_TypeStr := CyrStr+'4C87'+AndStr+WeitStr;
   $14     : Copro_TypeStr := IntelStr+'80287XL';
   $15     : Copro_TypeStr := IntelStr+'80287XL'+AndStr+WeitStr;
   22	   : Copro_TypeStr := IITStr+'2C87';
   23      : Copro_TypeStr := IITStr+'2C87'+AndStr+WeitStr;
   24	   : Copro_TypeStr := IITStr+'3C87';
   25      : Copro_TypeStr := IITStr+'3C87'+AndStr+WeitStr;
  else
   Copro_TypeStr := 'Unknown';
  end;
 end;

function CPUSpeed;
 begin
  CPUSpeed := ((LongInt(Shift)*CPUFix)/Speed(CPU_Type)+5)/10;
 end;

end.
