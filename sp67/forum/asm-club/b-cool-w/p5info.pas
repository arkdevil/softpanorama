program P5Info;

const
      FPUonChip         = $0001;
      EnhancedV86       = $0002;
      IOBreakpoints     = $0004;
      PageSizeExtensions= $0008;
      TimeStampCounter  = $0010;
      ModelSpecificRegs = $0020;
      MachineCheckExcept= $0040;
      CMPXCHG8B         = $0080;

      GenuineIntel      = $0000;

      Family            = $0F00;
      Model             = $00F0;
      Step              = $000F;

function CheckP5 : Word; far; external;

function GetP5Features : Word; far; external;

function GetP5Vendor : Word; far; external;

{$L P5INFO}

function GetVendor : String;
 begin
  if GetP5Vendor = 0 then
   GetVendor := 'GenuineIntel'
  else
   GetVendor := 'Non-Intel';
 end;

function GetFamily : Word;
 begin
  GetFamily := (CheckP5 and Family) shr 8;
 end;

function GetModel : Word;
 begin
  GetModel := (CheckP5 and Model) shr 4;
 end;

function GetStep : Word;
 begin
  GetStep := (CheckP5 and Step);
 end;

procedure PrintFeatures;
 var P5Features : Word;
 begin
  P5Features := GetP5Features;
  if (P5Features and FPUonChip) = FPUonChip then
   Write(#254)
  else
   Write(' ');
  WriteLn(' FPU on Chip');
  if (P5Features and EnhancedV86) = EnhancedV86 then
   Write(#254)
  else
   Write(' ');
  WriteLn(' Enhanced Virtual-8086 mode');
  if (P5Features and IOBreakpoints) = IOBreakpoints then
   Write(#254)
  else
   Write(' ');
  WriteLn(' I/O Breakpoints');
  if (P5Features and PageSizeExtensions) = PageSizeExtensions then
   Write(#254)
  else
   Write(' ');
  WriteLn(' Page Size Extensions');
  if (P5Features and TimeStampCounter) = TimeStampCounter then
   Write(#254)
  else
   Write(' ');
  WriteLn(' Time Stamp Counter');
  if (P5Features and ModelSpecificRegs) = ModelSpecificRegs then
   Write(#254)
  else
   Write(' ');
  WriteLn(' Pentium processor-style model specific registers');
  if (P5Features and MachineCheckExcept) = MachineCheckExcept then
   Write(#254)
  else
   Write(' ');
  WriteLn(' Machine Check Exception');
  if (P5Features and CMPXCHG8B) = CMPXCHG8B then
   Write(#254)
  else
   Write(' ');
  WriteLn(' CMPXCHG8B Instruction');
end;


begin
 WriteLn('P5Info/Pas  Version 1.00  Copyright(c) 1994 by B-coolWare.');
 WriteLn;
 if CheckP5 = 0 then
  begin
   WriteLn('This processor doesn''t handle CPUID instruction properly.');
   Halt;
  end;

 WriteLn('Make ',GetVendor);
 WriteLn('Family ',GetFamily,', Model ',GetModel,', Step ',GetStep);
 WriteLn;
 WriteLn('Processor Features:');
 PrintFeatures;
end.
