Unit TPU6EQU;

{ -------------------------------------------------------------	}
{ This UNIT defines CONSTs, TYPEs, PROCEDUREs and FUNCTIONs of  }
{ general utility to the program.  It also enables a Heap Error }
{ Function which causes the Heap Manager to return NIL if any   }
{ Heap Allocation Request (NEW or GETMEM) finds insufficient    }
{ Heap Space to satisfy the request.  Two variables are defined }
{ which allow tracking of Heap utilization to be performed by a }
{ using program.  There is very little in this unit that is     }
{ specific to ".TPU" files per-se.				}
{ ------------------------------------------------------------- }

(*****************)
(**) INTERFACE (**)	Uses Dos;
(*****************)

Const	_UnitEye = 'TPU9';		{ Identifies TP6 Units 		 }
	_Library = 'TURBO.TPL';		{ Turbo Pascal Unit Library Name }

	_FilNamLen = SizeOf(Dos.NameStr)+SizeOf(Dos.ExtStr)-2;
        _FilDirLen = SizeOf(Dos.DirStr)-1+_FilNamLen;

Type	_UnitName = String[8];		{ Max Size of a Unit Name     }
	_FileSpec = String[_FilNamLen];	{ Max Size of Name.Extension  }
        _FileXpnd = String[_FilDirLen];	{ Max Size of above plus Path }
        _LexName  = String[63];		{ Max Size of Pascal Names    }
  	_StrByte  = String[2];		{ String for Hex Byte Display }
	_StrWord  = String[4];          { String for Hex Word Display }

        _Paragraph= Array[0..15] of Byte;	{ 8086 Paragraph Size }

Var     _HeapHighWaterMark,		{ Max Heap Utilization Pointer }
	_HeapOriginalMark : Pointer;	{ Min Heap Utilization Pointer }

Function  PtrNormal(P : Pointer): Pointer;	{ Normalizes a Pointer }
Function  PtrDelta(P,Q: Pointer): LongInt;	{ Pointer Differential }
Function  HexB(Arg:Byte): _StrByte;		{ Byte to Hex String   }
Function  HexW(Arg:Word): _StrWord;		{ Word to Hex String   }

(**********************)
(**) IMPLEMENTATION (**)
(**********************)

  { Function Below Converts POINTER to Normalized Form }	{.CP22}
  { Version 6.0 of TURBO Pascal is Mandatory for This  }

FUNCTION  PtrNormal(P : Pointer) : Pointer;
Var I, J : Word;
Begin
   I := Seg(P^); J := Ofs(P^);
   ASM
      XOR   DX,DX	{ make a zero			}
      MOV   CX,4        { set shift magnitude		}
      MOV   AX,J        { fetch OFFSET part		}
      ADD   AX,7        { round up to QWORD boundary	}
      RCR   DH,CL       { save CF in DX bit 12		}
      MOV   BX,00008h   { set AND mask for offset 	}
      AND   BX,AX       { form normalized OFFSET	}
      MOV   J,BX        { save normalized OFFSET 	}
      SHR   AX,CL       { align OFFSET for SEGMENT 	}
      ADD   AX,DX	{ add saved CF for SEGMENT Wrap }
      ADD   I,AX        { normalize SEGMENT part	}
   End;
   PtrNormal := Ptr(I,J)  { return "normalized" pointer }
End; {PtrNormal}

  { Function Below Computes the SIGNED Difference between the }	{.CP11}
  { EFFECTIVE Values of two pointers, P and Q.  The result is }
  { negative if P^ < Q^, non-negative otherwise.	      }

Function PtrDelta(P, Q: Pointer): LongInt;	{ Pointer Differential }
Var Lp, Lq : LongInt;
Begin
   Lp := LongInt(Seg(P^)) SHL 4 + Ofs(P^);	{ Convert P to LongInt }
   Lq := LongInt(Seg(Q^)) SHL 4 + Ofs(Q^);	{ Convert Q to LongInt }
   PtrDelta := Lp - Lq;				{ Return Difference    }
End; {PtrDelta}

  { Function Below Converts a byte to Printable Hex }		{.CP05}

FUNCTION HexB(Arg:byte): _StrByte;
CONST HexTab : ARRAY[0..15] OF Char = '0123456789ABCDEF';
BEGIN HexB := HexTab[Arg SHR 4] + HexTab[Arg AND $F] END;

  { Function Below Converts a Word to Printable Hex }		{.CP04}

FUNCTION HexW(Arg:Word): _StrWord;
BEGIN HexW := HexB(HI(Arg)) + HexB(LO(Arg)) END;

  { Heap Error Function Returns NIL if Allocation Fails }	{.CP11}

Function HeapErrorProc(Arg : Word): Integer; FAR;
Begin
	If Arg = 0 Then		{ Heap Pointer Being Raised   }

        If PtrDelta(System.HeapPtr,_HeapHighWaterMark) > 0
	Then _HeapHighWaterMark := System.HeapPtr;

        HeapErrorProc := 1;     { Allow NIL Return by HeapMgr }
End;   {HeapErrorProc}

Begin   {Unit Initialization}
	System.HeapError   := @HeapErrorProc;
        _HeapHighWaterMark := System.HeapPtr;
        _HeapOriginalMark  := System.HeapOrg;
End.
