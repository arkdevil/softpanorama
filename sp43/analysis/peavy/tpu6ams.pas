{$D+,O+,S+,R-,L+}
Unit TPU6AMS;

(*****************)
(**) INTERFACE (**)             USES TPU6EQU, Dos;
(*****************)

TYPE

  RngB   = 0..65534;
  RngW   = 0..32766;
  AryB   = ARRAY[rngb] OF Byte;
  AryW   = ARRAY[rngw] OF Word;
  SrcNam = _FileSpec;

  HdrAry = ARRAY[0..3] OF Char;

  LL  = Word;               { Local Scope Pointers (offsets) }

  LG  = RECORD              { Global Scope Pointers to Other Units }
             UntLL : LL;    { Local to containing unit }
             UntId : LL;    { Local to  external  unit }
        END;

  { The following Record is the Header and Locator for a Unit File } {.CP28}

  UnitPtr = ^UnitHeader;
  UnitHeader = RECORD
	UHEYE : HdrAry;		{ +00 : = 'TPU9'                     }
	UHxxx : HdrAry;		{ +04 : = $00000000                  }
	UHUDH : LL;		{ +08 : to Dictionary Head-This Unit }
	UHIHT : LL;		{ +0A : to Interface Hash Header     }
	UHPMT : LL;		{ +0C : to PROC Map                  }
	UHCMT : LL;		{ +0E : to CSeg Map                  }
	UHTMT : LL;		{ +10 : to DSeg Map-Typed CONST's    }
	UHDMT : LL;		{ +12 : to DSeg Map-GLOBAL Variables }
	UHxxy : LL;		{ +14 : purpose unknown              }
	UHLDU : LL;		{ +16 : to Donor Unit List           }
	UHLSF : LL;		{ +18 : to Source File List          }
	UHDBT : LL;             { +1A : DEBUG Trace Table            }
	UHENC : LL;  		{ +1C : to end non-code part of Unit }
	UHZCS : Word;		{ +1E : CSEG Size-Aggregate          }
	UHZDT : Word;		{ +20 : DSEG Size-Typed CONSTS Only  }
	UHZFA : Word;		{ +22 : Fix-Up Size (CSegs)          }
	UHZFT : Word;		{ +24 : Fix-Up Size (Typed CONST's)  }
	UHZFV : Word;           { +26 : DSEG Size for Global VARs    }
	UHDHT : LL;		{ +28 : to Global Hash Header        }
        UHSOV : Word;           { +2A : Overlay Controls             }
	UHPad : ARRAY[0..9]
		OF Word;	{ +2C : Reserved for Future Expansion ? }

  END; { UnitHeader }

  { The Records below provide access to the PROC Map }		{.CP12}

	PMapRecPtr  = ^PMapRec;
	PMapRec = RECORD
                ProcWd1,
                ProcWd2 : Word; { function of these words unknown       }
		CSegOfs : Word;	{ offset within CSeg Map; $FFFF if null }
		CSegJmp : Word;	{ offset to entry point;  $FFFF if null }
	END {PMapRec};

	PMapPtr = ^PMapTab;
	PMapTab =  ARRAY[0..1] OF PMapRec; { model of PROC Map }

  { The Records below provide access to the CODE Map }		{.CP12}

	CMapRecPtr = ^CMapRec;
	CMapRec = RECORD
		CSegWd0 : Word;	{ purpose is unknown              }
		CSegCnt : Word;	{ byte count of module code       }
		CSegRel : Word;	{ byte count of module Relo List  }
		CSegTrc : Word;	{ Trace table offset or $FFFF     }
	END; {CMapRec}

	CMapTabPtr = ^CMapTab;
	CMapTab = ARRAY[0..1] OF CMapRec; { model of CSeg Map }

  { The Records below provide access to the CONST DSeg Map }	{.cp12}

	DMapRecPtr = ^DMapRec;
	DMapRec = RECORD
		DSegWd0 : Word;    { purpose is unknown              }
		DSegCnt : Word;    { byte count of data block        }
		DSegRel : Word;    { byte count of data Relo List    }
		DSegOwn : LL;      { To owner scope                  }
	END; {DMapRec}

	DMapTabPtr = ^DMapTab;
	DMapTab = ARRAY[0..1] OF DMapRec;	{ model of DSeg Map }

  { The Record below is one entry in the Fix-Up List }            {.CP13}

	FixUpRecPtr = ^FixUpRec;
	FixUpRec = RECORD
		FixDnr : Byte;	{ Donor Unit Offset }
		FixFlg : Byte;	{ Entry Format Flag }
		FixWd1 : Word;	{ Offset to Map Table  }
		FixWd2 : Word;	{ Effective Address Adjuster  }
		FixOfs : Word;	{ offset to patch point in code/data block }
	END; {FixUpRec}

	FixUpPtr  = ^FixUpList;
	FixUpList = ARRAY[0..1] OF FixUpRec; { model of Fix-Up List }

  { The Record below maps the Dictionary Header in Turbo Units } {.CP08}

	DNamePtr = ^ DNameRec;
	DNameRec = RECORD
		HLink : LL;         { Hash Chain Link; Resolves Collisions }
		DForm : Char;       { Symbol Type; See StubRecord for types}
		DSymb : _LexName;   { Worst-Case Symbol Size (UPPER-CASE)  }
	END; {DNameRec}

  { The Record Below maps the Dictionary Stubs in Turbo Units  } {.CP10}

  DStubPtr = ^ DStubRcd;
  DStubRcd = RECORD
      CASE Char OF

      'P': (                     { --- For Untyped Constants --- }
           sPTD : LG;            { to type descriptor            }
           sPV1 : Word;          { value of constant - LO Word   }
           sPV2 : Word);         { (size varies)     - HI Word   }

      'Y': (                     { ----- For UNIT Entries ------ }  {.CP05}
           sYW1 : Word;          { unknown use; normally zero    }
           sYCS : Word;          { Speculate Signature Word      }
           sYNU : LL;            { to next Unit in List (SUCC)   }
           sYPU : LL);           { to prior Unit in List (PRED)  }

      'O',                       { ---- Label Declaratives ----- }  {.CP05}
      'T',                       { ---- Standard Procedures ---- }
      'U',                       { ---- Standard Functions  ---- }
      'V': (                     { ---- Standard "NEW" F/P  ---- }
           sVxx : Word);         { semantics not precisely known }

      'W': (                     { ------- Standard Ports ------ }  {.CP02}
           sWxx : Byte);         { 0=Byte Array, 1=Word Array    }

      'Q',                       { -------- Named Types -------- }  {.CP03}
      'X': (                     { ----- External Variables ---- }
           sQTD : LG);           { to type descriptor            }

      'S': (                     { ------ User Subprograms ----- }  {.CP20}
            sSTp : BYte;         { 76543210  - Bit encoded       }
                                 { .......1 = FAR Call Model     }
                                 { ......1. = INLINE Declarative }
                                 { .....1.. = INTERRUPT Routine  }
                                 { ....1... = .OBJ module code   }
                                 { ...1.... = METHOD (Any)       }
                                 { .011.... = Constructor METHOD }
                                 { .101.... = Destructor  METHOD }
                                 { 1....... = ASSEMBLER attribute}
            sSxx : Byte;         { function unknown at present   }
            sSPM : Word;         { Code byte count if INLINE,    }
                                 { else, offset to PROC Map      }
            sSPS : LL;           { to containing scope or zero   }
            sSHT : LL;           { to local scope hash table     }
            sSVM : Word);        { VMT Offset-VIRTUAL Method PTR }

            { Notes: "sSVM" is followed immediately by a Type    }
            {        Descriptor ($06).  INLINE Declarative code  }
            {        Bytes then follow (if any).                 }

      'R': (                     { -- Variable, Field, Object  -- } {.CP35}
            sRAM : Byte;         {   allocation method codes:      }
                                 { $00 = Global Variables in DS    }
                                 { $01 = Typed Constants  in DS    }
                                 { $02 = VAR-BP based-Nested Scope }
                                 { $03 = Absolute[Segment:Offset]  }
                                 { $06 = SELF Parameter-ADDR Stack }
                                 { $08 = Allocate in Record/Object }
                                 { $10 = Absolute Equivalence      }
                                 { $22 = VALUE Parameter-BP based  }
                                 { $26 = VAR   Parameter-BP based  }

            sRVF : Longint;      { See VarStub Below               }
            sRTD : LG);          { to Type Descriptor              }

      END;

  VarStubPtr = ^VarStub;
  VarStub    = RECORD
            Case  Byte Of  { sRAM Byte in Type "R" Stub }
            $02,$06,
            $22,$26:     (ROfs : Word;  { allocation offset (BP)  }
                          ROB  : Word); { To Parent Scope/Zero    }

            $00,$01:     (TOfs : Word;  { allocation offset in map}
                          TOB  : LL);   { offset in VAR/CONST Map }

            $03:         (AOfs : Word;  { Absolute Byte Offset    }
                          ASeg : Word); { Absolute Segment Adr    }

            $08:         (Bofs : Word;  { Offset-Record Relative  }
                          RChn : LL);   { To Next Field/Method    }

            $10:         (QLG  : LG);   { to Stub of Allocator    }
  End;

  { The Record below maps a Formal Parameter List Entry }        {.CP08}

  FormalParmRcd = RECORD
	   fPTD : LG;		{ to type descriptor for parameter  }
	   fPAM : Byte;		{ passing model; 2=Value, 6=Address }
     END;

  InlineLst = ARRAY[0..1] OF Word;		{ model of INLINE code }


  { The Record below maps the Type Descriptors in Turbo Units  } {.CP08}

  TypePtr   = ^TypeRecd;
  TypeRecd  = RECORD
       tpTC : Byte;		{ Identifies the Variant Part }
       tpTQ : Byte;		{ Type Qualifier              }
       tpSW : Word;		{ Storage Width in Bytes      }
       tpML : Word;             { Next Method if tpTC=$06     }

       CASE Byte OF                                                 {.CP04}
	$00,			{ For NULL or Un-Typed Variables }
	$0A,			{ For COMP,DOUBLE,EXTENDED,SINGLE }
	$0B : ();		{ -------- For REAL Type -------- }

	$01 : (			{ ------ For ARRAY Types ------- }  {.CP04}
		BaseType : LG;	{ to TypeRecd for item arrayed   }
		BounDesc : LG;	{ to TypeRecd for array bounds   }
              );

	$02 : (			{ ------ For RECORD Types ------ }  {.CP04}
		RecdHash : LL;	{ to Hash Table for Field List   }
		RecdDict : LL;	{ to Field List Dictionary Begin }
              );

	$03 : (			{ ------ For OBJECT Types ------ }  {.CP15}
		ObjtHash : LL;	{ to Fields & Methods Hash Table }
		ObjtDict : LL;	{ to Fields & Methods Dictionary }
		ObjtOwnr : LG;	{ to Parent Object Type Descript }
		ObjtVMTs : Word;{ Size of VMT if Virtual Methods }
		ObjtDMap : Word;{ Data Map Offset of VMT Template}
		ObjtVMTO : Word;{ object instance offset to VMT  }
				{ pointer; $FFFF if object has   }
				{ no Virtual Methods (no VMT)    }
		ObjtName : LL;	{ to Object Dictionary Header    }
                ObjtRes0,       { Usually $FFFF - Role Unknown   }
                ObjtRes1,       { Usually zero  - Role Unknown   }
                ObjtRes2,       { Usually zero  - Role Unknown   }
                ObjtRes3 : Word { Usually zero  - Role Unknown   }
              );

	$04,			{ ----- For FILE except TEXT ----}  {.CP04}
	$05:  (			{ ----- For TEXT file type ----- }
		FileType : LG;	{ to TypeRecd for Base File Type }
              );
	$06:  (			{ ----- For Procedure Types ---- }  {CP05}
		PFRes : LG;	{ to Function Result TD / zero   }
		PNPrm : Word;	{ Formal Parameter Count/ zero   }
                PFPar : ARRAY[1..2] OF FormalParmRcd { model only}
              );
	$07 : (			{ ------- For SET Types -------- } {.CP03}
		SetBase  : LG;	{ to base type descriptor of set }
              );
	$08 : (			{ ----- For POINTER Types ------ } {.CP03}
		PtrBase  : LG;	{ to base type descriptor        }
              );
	$09 : (			{ ------ For STRING Types ------ } {.CP04}
		StrBase  : LG;	{ to SYSTEM.CHAR type descriptor }
		StrBound : LG;	{ to array bounds for string typ }
              );
	$0C,		 { For BYTE,INTEGER,LONGINT,SMALLINT,WORD }{.CP15}
	$0D,			{ ------- For BOOLEAN Type ------ }
	$0E,			{ ------- For CHAR Type --------- }
	$0F : (			{ ---- For Enumerated Types ----- }
		LoBnd : LongInt;{ lower bound of subrange         }
		HiBnd : LongInt;{ upper bound of subrange         }
		Cmpat : LG;	{ to upward compatible Type desc  }
              );

		{ The Enumeration Type Descriptor is immediately  }
		{ followed by a SET Type Descriptor ($07) but we  }
		{ don't know what this achieves.  Its base type   }
		{ LG points to the Enumerated Type Descriptor.    }

       END;  { TypeRecd }


  { The Record below is a model Hash Table }                         {.CP07}

	HashPtr   = ^HashTable;
	HashTable = RECORD
		Bas : Word;                { Base and Max Offset in Slt }
		Slt : ARRAY[0..1] Of LL;   { Slots in Hash Table        }
	END;

  { The Record below is an entry in the Unit Code/Data Donor List } {.CP07}

	UDonorPtr = ^UDonorRec;
	UDonorRec = RECORD
		UDExxx : Word;
		UDEnam : String[8]
	END;

  { The Record below is an entry in the Source File List }            {.CP10}

	SrcFilePtr = ^SrcFileRec;
	SrcFileRec = RECORD
		SrcFlag : Byte;		{ 4=.PAS file, 3=.INC, 5=.OBJ       }
		SrcPad  : Word;		{ no apparent use - always zero ?   }
		SrcTime : Word;		{ File Time Stamp if SrcFlag=3 or 4 }
		SrcDate : Word;		{ File Date Stamp if SrcFlag=3 or 4 }
		SrcName : SrcNam;	{ Varying length FileName.Extn      }
	END;

  { The Record below is an entry in the Trace Table      }          {.CP12}

	TraceRecPtr = ^TraceRec;
	TraceRec    = RECORD
	    TrName : LL;	 { to Directory Entry of Proc/Method  }
	    TrFill : Word;	 { to proc source file                }
	    TrPfx  : Word;	 { bytes of data in front of code     }
	    TrBeg  : Word;	 { Line Number of BEGIN Stmt          }
	    TrLNos : Word;	 { Lines of Code to Execute in TRACE  }
	    TrExec : ARRAY[1..2] { Model Array of bytes that map each }
		     OF Byte;	 { line of code to be traced by DEBUG }
	END;

  BufPtr = ^Buffer;                                             {.CP06}
  Buffer = RECORD               { General Buffer Mapping }
    CASE Boolean OF
      True :( BufByt : AryB);   { Byte Array over Buffer }
      False:( BufWrd : AryW);   { Word Array over Buffer }
    END;

FUNCTION  PtrAdjust(Arg: Pointer; Adj: Word): Pointer;		{.CP22}
FUNCTION  FormLL(Base,Ceil: Pointer): LL;
FUNCTION  IsSystemUnit(U: UnitPtr): Boolean;
FUNCTION  AddrStub(arg: DNamePtr): DStubPtr;
FUNCTION  AddrHash(U: UnitPtr; Hash: LL): HashPtr;
FUNCTION  AddrDict(U: UnitPtr; Hash: LL): DNamePtr;
FUNCTION  AddrType(U: UnitPtr; TypeLG: LG): TypePtr;
FUNCTION  AddrProcType(S: DStubPtr): TypePtr;
FUNCTION  AddrNxtSrc(U: UnitPtr; Arg: SrcFilePtr): SrcFilePtr;
FUNCTION  AddrSrcTabOff(U: UnitPtr; Offset: Word): SrcFilePtr;
FUNCTION  CountPMapSlots(U: UnitPtr): Integer;
FUNCTION  AddrPMapTab(U: UnitPtr): PMapPtr;
FUNCTION  CountCMapSlots(U: UnitPtr): Integer;
FUNCTION  AddrCMapTab(U: UnitPtr): CMapTabPtr;
FUNCTION  CountDMapSlots(U: UnitPtr): Integer;
FUNCTION  AddrDMapTab(U: UnitPtr): DMapTabPtr;
FUNCTION  AddrTraceTab(U: UnitPtr): TraceRecPtr;
FUNCTION  GetTrExecSize(T: TraceRecPtr): Integer;
FUNCTION  AddrNxtTrace(U: UnitPtr; T: TraceRecPtr): TraceRecPtr;
FUNCTION  AddrFixUps(U: UnitPtr): FixUpPtr;
FUNCTION  AddrLGUnit(U: UnitPtr; TypeLG: LG): DNamePtr;
FUNCTION  Public(Arg: Char) : Char;

(**********************)                                        {.CP03}
(**) IMPLEMENTATION (**)
(**********************)

  { Function Below Converts PRIVATE Names to PUBLIC }           {.CP04}

FUNCTION Public(Arg: Char): Char;
BEGIN Public := Chr(Ord(Arg) AND $7F) END;

  { Procedure Below Traps Pointer Violations }			{.CP10}

PROCEDURE CheckPtrs(U, V: Pointer);
BEGIN
	IF (U = Nil) OR (V = Nil) OR (Seg(U^) <> Seg(V^)) THEN
	BEGIN
		WriteLn('Pointer Violation in CheckPtrs');
		Halt(1)
	END
END; {CheckPtrs}

  { Function Below Computes an LL from two Pointers }           {.CP09}

FUNCTION  FormLL(Base, Ceil: Pointer): LL;
BEGIN
	CheckPtrs(Base,Ceil);
	IF Ofs(Base^) > Ofs(Ceil^)
		THEN FormLL := LL(Ofs(Base^)-Ofs(Ceil^))
		ELSE FormLL := LL(Ofs(Ceil^)-Ofs(Base^));
END;

  { Function Below Adjusts Pointer Values by Offsets }           {.CP04}

FUNCTION  PtrAdjust(Arg: Pointer; Adj: Word): Pointer;
BEGIN     PtrAdjust := Ptr(Seg(Arg^),Ofs(Arg^) + Adj)     END;

  { Function Below Checks to See if Unit Name is "SYSTEM" }

FUNCTION  IsSystemUnit(U: UnitPtr): Boolean;
BEGIN
   IsSystemUnit := DNamePtr(Ptr(Seg(U^),Ofs(U^)+U^.UHUDH))^.DSymb = 'SYSTEM'
END;

  { Function Below Finds The Stub Belonging to a Dictionary Header } {.CP05}

FUNCTION  AddrStub(Arg: DNamePtr): DStubPtr;
CONST PrefixSize = SizeOf(LL)+SizeOf(Char) + 1;
BEGIN  AddrStub := PtrAdjust(Arg,PrefixSize + Ord(Arg^.DSymb[0]))  END;

  { Function Below Gets Pointer to Hash Table }                  {.CP04}

FUNCTION  AddrHash(U: UnitPtr; Hash: LL): HashPtr;
BEGIN   AddrHash := HashPtr(PtrAdjust(U,Hash))  END;

  { Function Below Gets Pointer to Dictionary Entry using LL }   {.CP04}

FUNCTION  AddrDict(U: UnitPtr; Hash: LL): DNamePtr;
BEGIN AddrDict := DNamePtr(PtrAdjust(U,Hash)) END;

  { Function Below Gets Pointer to Type Descriptor if Local to Unit } {.CP12}

FUNCTION  AddrType(U: UnitPtr; TypeLG: LG): TypePtr;
VAR D:DNamePtr; S: DStubPtr; R: LL;
BEGIN
	D := AddrDict(U,U^.UHUDH);      {point to our unit DE}
	S := AddrStub(D);               {point to its stub   }
	R := FormLL(U,S);               {get offset to stub  }
	IF R = TypeLG.UntId             {if offset matches   }
	THEN AddrType := TypePtr(PtrAdjust(U,TypeLG.UntLL))
	ELSE AddrType := Nil
END;

  { Function Below Gets Pointer to Unit Descriptor for Type via LG } {.CP21}

FUNCTION  AddrLGUnit(U: UnitPtr; TypeLG: LG): DNamePtr;
VAR D: DNamePtr; S: DStubPtr; R: LL;
BEGIN
	D := AddrDict(U,U^.UHUDH);      {point to our unit hdr}
	S := AddrStub(D);               {point to our stub    }
	R := FormLL(U,S);               {get offset to stub   }
	IF (R <> 0) THEN
	IF (TypeLG.UntID <> R) THEN     {if offsets don't match }
	REPEAT
	   D := AddrDict(U,S^.sYNU);            {chain to next DE}
	   IF D^.DForm <> 'Y' THEN R := 0 ELSE  {if next is unit }
	   BEGIN
	     S := AddrStub(D);                  {its stub address}
	     R := FormLL(U,S);                  {and stub offset }
	   END;
	UNTIL (R = TypeLG.UntID) OR (R = 0);    {match of end list  }
	IF R <> 0 THEN AddrLGUnit := D          {we had a match     }
	          ELSE AddrLGUnit := Nil;       {we couldn't find it}
END;

  { Function Below Gets Pointer to Procedure Stub Type Descriptor }{.CP04}

FUNCTION  AddrProcType(S: DStubPtr): TypePtr;
BEGIN AddrProcType := TypePtr(PtrAdjust(@S^.sSVM,SizeOf(S^.sSVM))) END;

  { Function Below Gets Pointer to Next Entry in Source File List } {.CP21}

FUNCTION  AddrNxtSrc(U: UnitPtr; Arg: SrcFilePtr): SrcFilePtr;
VAR J: LL;  S: SrcFilePtr;
BEGIN
	J := 0;
	IF Arg = Nil THEN AddrNxtSrc := Nil ELSE
	BEGIN
	   J := FormLL(U,Arg);
	   IF J < U^.UHLSF
	   THEN AddrNxtSrc := Nil ELSE
	   IF NOT (J < U^.UHDBT)
	   THEN AddrNxtSrc := Nil ELSE
	   BEGIN
	      S := SrcFilePtr(PtrAdjust(Arg,8 + Ord(Arg^.SrcName[0])));
	      IF FormLL(U,S) < U^.UHDBT
	      THEN AddrNxtSrc := S
	      ELSE AddrNxtSrc := Nil
	   END
	END
END;

  { Function Below Gets Pointer to Source File List Entry at Offset }{.CP09}

FUNCTION  AddrSrcTabOff(U: UnitPtr; Offset: Word): SrcFilePtr;
BEGIN
	WITH U^ DO
	IF (UHLSF+Offset) < UHDBT
	THEN AddrSrcTabOff := SrcFilePtr(PtrAdjust(U,UHLSF+Offset))
	ELSE AddrSrcTabOff := Nil
END;

  { Function Counts Number of Slots in PROC Map Table }            {.CP06}

FUNCTION  CountPMapSlots(U: UnitPtr): Integer;
BEGIN
	CountPMapSlots := (U^.UHCMT-U^.UHPMT) DIV SizeOf(PMapRec);
END;

  { Function Gets Address of PROC Map Table }                      {.CP08}

FUNCTION  AddrPMapTab(U: UnitPtr): PMapPtr;
BEGIN
	IF CountPMapSlots(U) > 0
	THEN AddrPMapTab := PMapPtr(PtrAdjust(U,U^.UHPMT))
	ELSE AddrPMapTab := Nil
END;

  { Function Counts Number of Slots in CSeg Map Table }         {.CP06}

FUNCTION  CountCMapSlots(U: UnitPtr): Integer;
BEGIN
	WITH U^ DO CountCMapSlots := (UHTMT-UHCMT) DIV SizeOf(CMapRec);
END;

  { Function Gets Address of CSeg Map Table }                   {.CP08}

FUNCTION  AddrCMapTab(U: UnitPtr): CMapTabPtr;
BEGIN
	IF CountCmapSlots(U) > 0
	THEN AddrCMapTab := CMapTabPtr(PtrAdjust(U,U^.UHCMT))
	ELSE AddrCMapTab := Nil
END;

  { Function Counts Number of DSeg Map Slots }                  {.CP06}

FUNCTION  CountDMapSlots(U: UnitPtr): Integer;
BEGIN
	WITH U^ DO CountDMapSlots := (UHDMT - UHTMT) DIV SizeOf(DMapRec)
END;

  { Function Gets Address of DSeg Map Table }                   {.CP08}

FUNCTION  AddrDMapTab(U: UnitPtr): DMapTabPtr;
BEGIN
	IF CountDMapSlots(U) > 0
	THEN AddrDMapTab := DMapTabPtr(PtrAdjust(U,U^.UHTMT))
	ELSE AddrDMapTab := Nil
END;

  { Function Below Gets Pointer to 1st Trace Table Entry or Nil }  {.CP08}

FUNCTION  AddrTraceTab(U: UnitPtr): TraceRecPtr;
BEGIN
	IF U^.UHDBT = U^.UHENC
	THEN AddrTraceTab := Nil
	ELSE AddrTraceTab := TraceRecPtr(PtrAdjust(U,U^.UHDBT))
END; {AddrTraceTab}

   { Function Below Gets Byte Count in TrExec Array }      {.CP20}

FUNCTION GetTrExecSize(T: TraceRecPtr): Integer;
VAR i,k : Integer;
BEGIN
   IF T = Nil THEN GetTrExecSize := 0 ELSE
   BEGIN
      k := T^.TrLNos;                   {number of lines in array}
      i := 1;                           {prime scan line number  }
      WHILE i <= k DO BEGIN             {still have lines to test}
         IF T^.TrExec[i] = $80 THEN     {if "escape byte" present}
	 BEGIN
	   Inc(k);                      {bump array limit        }
	   Inc(i)                       {bump to byte count slot }
	 END;
	 Inc(i)                         {check next slot         }
      END;
      GetTrExecSize := k;               {final byte count        }
   END;
END;

  { Function Below Gets Pointer to next Trace Table Entry or Nil }  {.CP14}

FUNCTION  AddrNxtTrace(U: UnitPtr; T: TraceRecPtr): TraceRecPtr;
VAR k : Integer;
BEGIN
	IF T = Nil THEN AddrNxtTrace := Nil ELSE
	BEGIN
		k := GetTrExecSize(T);
		T := TraceRecPtr(PtrAdjust(@T^.TrExec[1],LL(k)));
		IF FormLL(U,T) >= U^.UHENC
			THEN AddrNxtTrace := Nil
			ELSE AddrNxtTrace := T
	END
END; {AddrNxtTrace}

  { Function Below Gets Pointer to 1st Fixup Table Entry or Nil }  {.CP13}

FUNCTION  AddrFixUps(U: UnitPtr): FixUpPtr;
VAR j : Word;
BEGIN
	IF U^.UHZFA = 0 THEN AddrFixUps := Nil ELSE
	WITH U^ DO BEGIN
		j := (UHENC  + $F) AND $FFF0;
		j := (UHZCS  + $F) AND $FFF0 + j;
		j := (UHZDT  + $F) AND $FFF0 + j;
		AddrFixUps := Ptr(Seg(U^),Ofs(U^) + j)
	END
END; {AddrFixUps}

END.