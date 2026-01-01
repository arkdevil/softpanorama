{$R-,E-,N-,S+}
Unit TPU6UTL;

{ This Unit provides the tools needed for high-level analysis }
{ of desired units by the main program (TPU6).  It is object  }
{ oriented in its implementation but not in its interface.    }
{ The intended user of this unit has relatively simple needs  }
{ and no additional capabilities are provided.  In particular }
{ the details of implementation including data structures are }
{ hidden from any potential user.  The object methodology is  }
{ not very spiritual.  Neither inheritance nor virtual method }
{ techniques are employed, but static objects are utilized to }
{ assist with data management on the heap providing a highly  }
{ structured environment for implementation.		      }

(*****************)
(**) INTERFACE (**)	Uses TPU6EQU, TPU6AMS, TPU6RPT, Dos;
(*****************)

{ -------------------------------------------------------- }	{.CP04}
{ PurgeAllUnits	- Removes all Units and Analyses from Heap }

  Procedure PurgeAllUnits;

{ --------------------------------------------------------------- }{.CP05}
{ AnalyzeUnit	- Loads and analyzes a Unit; references to Units  }
{		  it USES are resolved to clarify LG references   }

  Function  AnalyzeUnit(Name: _UnitName; Path: String): UnitPtr;

{ --------------------------------------------------------------- }{.CP13}
{ ResolveLG	- Checks all Directly referenced Units to locate  }
{		  the Unit and the Dictionary Entry for the owner }
{		  of the Descriptor referenced by an LG provided  }
{		  AnalyzeUnit has been called before-hand	  }

Type
     RespLG = Record		{ Returned by ResolveLG    }
        UPtr : UnitPtr;		{ Pointer to Named Unit    }
        Ownr : LL;		{ LL to Owner of LG'd Item }
     End;

  Procedure ResolveLG(N: _UnitName; L : LG; VAR R: RespLG);

{ ---------------------------------------------------------- }	{.CP23}
{ FetchSurveyRec  - is called to fetch the next SurveyRec    }
{		    to support formatted Dictionary printing }
{		    of the primary Unit			     }

Type CoverId = (cvName,		{ Dictionary Entry Headers }
                cvHash,		{ Hash Tables              }
                cvType,		{ Type Descriptors         }
                cvINLN,		{ INLINE Code Bytes        }
                cvNULL);	{ terminating status       }

     SurveyRecPtr = ^ SurveyRec;	{ Output of Survey }

     SurveyRec = RECORD
        LocLL  : LL;       { LL to location of data structure      }
	LocOwn : LL;       { LL to Dictionary Header of Owner or 0 }
	LocTyp : CoverId;  { Class of Structure (see above)        }
        LocNxt : LL;       { LL to location of following structure }
        LocLvl : Word;     { Nesting Level of entry                }
     End;

  Procedure FetchSurveyRec (VAR S : SurveyRec);	{ Gets Dictionary Survey }
                          			{ Results Sequentially   }

{ ---------------------------------------------------------------- } {.CP53}
{ SortProcRefs	- is called to sort the reference information for  }
{		  PROC Maps into either CSEG or PROC map order to  }
{		  print.  BOTH sequences are used by TPU6.  Only a }
{		  Unit has such references constructed for it.	   }
{								   }
{ FetchMapRef	- is called to fetch a MapRefRec (see below) using }
{		  the map offset.  Only the primary Unit has such  }
{		  references constructed for it.		   }

Type
     MapFlags = (mfNULL,	{ Undefined / Unused Entry       }
                 mfINTF,	{ INTERFACE CONST/VAR Map Entry  }
                 mfIMPL,	{ IMPLEMENTATION CONST/VAR Map   }
                 mfNEST,	{ NESTED Scope Typed CONST DSeg  }
                 mfXTRN,	{ EXTERNAL CONST/VAR DSeg        }
                 mfTVMT,	{ VMT Template in CONST Map      }
                 mfPROC,	{ PROC Map Entry                 }
                 mfPRUI,        { PROC Map Entry - Unit Init     }
                 mfCSEG);	{ CSEG Map Entry                 }

     MapClass = (rPROC,		{ PROC Map 			 }
     		 rCSEG,		{ CSeg Map 			 }
		 rVARS,		{ VARS Map - Global VAR DSeg Map }
		 rCONS);	{ CONS Map - Typed Constants Map }

     MapRefRecPtr = ^ MapRefRec;  { Output of VAR/CONST Map Survey }
     MapRefRec = RECORD                                             
	MapTyp : MapFlags; { Defining Scope Category (see above)   }
        MapOfs : Word;     { Offset within Map Table               }
	MapOwn : LL;       { DNAME of Parent Scope / PROC          }
        MapSrc : LL;       { Offset in Source File Table           }
        MapLod : LL;       { Load Point for CODE/CONST Segment     }
        MapSiz : Word;     { Size of Segment / PROC (Bytes)        }

     CASE MapFlags OF
        mfCSEG: (                    {--CSEG/CONST Map Table Only--}
                  MapFxI : LL;       { Segment Fix-Up (Initial)    }
                  MapFxJ : LL;       { Segment Fix-Up (Final)      }
                );
        mfPROC: (                    {-----PROC Map Table Only-----}
                  MapEPT : LL;       { Entry Point for PROC        }
                  MapCSM : LL;       { Offset in CSEG Map for PROC }
                );
     END;

     SortMode = (CSegOrder,      { Sort Proc Map into CSeg Order }
                 PMapOrder);     { Sort Proc Map into Proc Order }

  Procedure SortProcRefs (Mode  : SortMode);  { PROC Map Ref Sorts   }

  Procedure FetchMapRef  (VAR S : MapRefRec;  { Gets map references  }
                            C   : MapClass;   { for the primary unit }
                          Offset: Word);

(**********************)					{.PA}
(**) IMPLEMENTATION (**)
(**********************)

Type
        UnitMode  = (Entire,Partial);
	TUnitPtr  = ^ TUnit;
	RMapPtr   = ^ RMap;
	MapTabPtr = ^ MapTab;
	CvrTabPtr = ^ CvrTab;
	CvrRecPtr = ^ CvrRec;

     CvrRec = RECORD
        LocLL  : LL;       { LL to location of data structure      }
	LocOwn : LL;       { LL to Dictionary Header of Owner or 0 }
	LocTyp : CoverId;  { Type of Structure                     }
        LocLvl : Word;     { Entry Nesting Level in Dictionary     }
     END;

     CvrTab = ARRAY[1..2] OF CvrRec;  	{ Model of Stack/Queue }
     MapTab = ARRAY[0..4] OF MapRefRec; { Model of Cross-Refs  }

     RMapVec   = Array[MapClass] of RMapPtr;

{ ----------------------------------------------------- }	{.CP38}
{ The TUnit Object is used to organize all information  }
{ known about a Unit.  It functions as an index node to }
{ allow reasonably fast access to a Unit by either name }
{ or by address.  It provides links RMap objects which  }
{ anchor "map" analyses.  It contains the controls that }
{ manage the dictionary "cover" built for each Unit.    }
{ ----------------------------------------------------- }

     TUnit = Object
       Link : 	   TUnitPtr;	{ To Next TUnit in List	}
       UImg : 	   UnitPtr;	{ To Unit Image on Heap	}
       USiz : 	   Word;	{ Allocated Image Size	}
       Name : 	   _UnitName;	{ Name for Fast Search	}
       CvrRMaps  : RMapVec;     { To Map Analyses	}
       CvrStkPtr : CvrTabPtr;   { To Cover Stack	}
       CvrQuePtr : CvrTabPtr;   { To Completed Survey	}
       CvrSize:    LongInt;	{ Allocation Size Bytes }
       CvrLimit,                { Stack/Queue Maxima    }
       CvrStkTop,               { Cover Stack Top	}
       CvrQueTail,              { Cover Queue Tail	}
       CvrStkBot,               { Cover Stack Bottom	}
       CvrStkMax,               { Cover Stack Ceiling	}
       CvrQueHead,              { Cover Queue Head	}
       CvrQueMax : Word;        { Cover Queue Ceiling	}
       Destructor  Done;
       Constructor Init(Id: _UnitName; Locn: UnitPtr; Size: Word);
       Procedure   DisposeStack;
       Procedure   DisposeQueue;
       Procedure   PackQueue;
       Procedure   CalcCovers;
       Procedure   IndexMaps;
       FUNCTION    QueuePos(Locn : LL) : Word;
       PROCEDURE   EnQueue(Arg : CvrRec);
       FUNCTION    Queued(Key : LL) : Boolean;
       PROCEDURE   Push(ArgLoc,ArgOwn : LL; ArgTyp : CoverId; ArgLvl:Word);
       PROCEDURE   Pop(VAR Arg : CvrRec);
     End;  { TUnit }

{ ----------------------------------------------------- }	{.CP17}
{ The RMap Object is used to organize the information   }
{ pertaining to Unit Map references.  One such object   }
{ is spawned for each Map type (CSeg,PROC,DSeg,CONST)   }
{ and this object stores allocator information about    }
{ the vector in which the references are stored.        }
{ ----------------------------------------------------- }

     RMap = Object
       RMapTabPtr : MapTabPtr;   { To Map References }
       RMapTabSiz : Word;        { Reference Counter }
       Destructor  Done;
       Constructor Init(Width : Word);
       Procedure   SortPmap(Mode : SortMode);
       Procedure   FetchRef(VAR S : MapRefRec; Offset : Word);
       Procedure   StoreRef(    S : MapRefRec; Offset : Word);
     End;

Const RecLen = SizeOf(MapRefRec); MapLen = SizeOf(DMapRec);
      LstRoot : TUnitPtr = Nil; LstLocus : TUnitPtr = Nil;
      NullMap : MapRefRec = (MapTyp: mfNULL; MapOfs: 0;
                             MapOwn: $FFFF;  MapSrc: 0;
                             MapLod: 0;      MapSiz: 0;
                             MapEPT: 0;      MapCSM: 0);

VAR   CvrWork : CvrRec;

     {   Begin Methods for   R M a p   }			{.CP18}

     Constructor RMap.Init(Width : Word);
     Var I : Word; S : MapRefRec;
     Begin
        RMapTabPtr := Nil; RMapTabSiz := Width DIV SizeOf(DMapRec);
        IF RMapTabSiz > 0 Then
        Begin
           GetMem(RMapTabPtr,RMapTabSiz * SizeOf(MapRefRec));
           S := NullMap;
           If RMapTabPtr = Nil Then RMapTabSiz := 0
	   Else
              For I := 0 To RMapTabSiz-1 Do Begin
                 RMapTabPtr^[i] := S;
                 Inc(S.MapOfs,SizeOf(DMapRec));
              End;
        End;
     End;

     Destructor RMap.Done;					{.CP05}
     Begin
        IF RMapTabSiz > 0 Then FreeMem(RMapTabPtr,RMapTabSiz * RecLen);
        RMapTabPtr := Nil; RMapTabSiz := 0;
     End;

     Procedure RMap.SortPmap(Mode: SortMode);			{.CP28}
     Var Rmt: MapTabPtr; I, J, K : Word; W: MapRefRec;
     Begin
        Rmt := RMapTabPtr; I := 0;
        If Rmt <> Nil Then
        Repeat                             { Slow but simple sort }
           J := I + 1; K := I;
           While J < RMapTabSiz Do Begin
              Case Mode Of
                CSegOrder:
                   If Rmt^[J].MapCSM < Rmt^[K].MapCSM
                   Then K := J Else
                   If Rmt^[J].MapCSM = Rmt^[K].MapCSM
                   Then If Rmt^[J].MapEPT < Rmt^[K].MapEPT
                        Then K := J;

                PMapOrder:
                  If Rmt^[J].MapOfs < Rmt^[K].MapOfs Then K := J;
              End; {Case}
              Inc(J);
           End;    {While}
           If K <> I Then    { We need to do a swap }
           Begin
              W := Rmt^[I]; Rmt^[I] := Rmt^[K]; Rmt^[K] := W
           End;
           Inc(I);
        Until I >= RMapTabSiz;
     End; {SortPMap}

     Procedure RMap.FetchRef(VAR S : MapRefRec; Offset : Word);	{.CP10}
     Var I : Word;
     Begin
        If (Offset MOD MapLen) = 0
        Then I := Offset Div MapLen
        Else I := RMapTabSiz;
        If NOT (I < RMapTabSiz)
        Then S := NullMap
        Else S := RMapTabPtr^[I];
     End;

     Procedure   RMap.StoreRef(S : MapRefRec; Offset : Word);	{.CP09}
     Var I : Word;
     Begin
        If (Offset MOD MapLen) = 0
        Then I := Offset Div MapLen
        Else I := RMapTabSiz;
        If (I < RMapTabSiz)
        Then RMapTabPtr^[I] := S
     End;

     {   Begin  Methods For   T U n i t   }			{.CP18}

Constructor TUnit.Init( Id: _UnitName;
			Locn: UnitPtr;
			Size: Word);
Begin
   Link := Nil;			UImg := Locn;
   USiz := Size;		Name := Id;
   CvrRMaps[rPROC] := Nil;	CvrRMaps[rCSEG] := Nil;
   CvrRMaps[rVARS] := Nil;	CvrRMaps[rCONS] := Nil;
   CvrStkTop  := 0;     CvrStkBot  := 0;        CvrStkMax := 0;
   CvrQueTail := 0;     CvrQueHead := 0;        CvrQueMax := 0;
   CvrStkPtr  := Nil;   CvrQuePtr  := Nil;
   CvrSize := (Locn^.UHPMT-Locn^.UHIHT) + SizeOf(CvrRec) - 1;
   CvrSize := CvrSize-(CvrSize MOD SizeOf(CvrRec));
   CvrLimit:= CvrSize DIV SizeOf(CvrRec);
   GetMem(CvrQuePtr,CvrSize);
   If CvrQuePtr = Nil Then Fail;
   GetMem(CvrStkPtr,CvrSize);
   If CvrStkPtr = Nil Then Fail;
End;  {TUnit.Init}

Procedure TUnit.DisposeStack;					{.CP05}
Begin
   If CvrStkPtr <> Nil Then FreeMem(CvrStkPtr,CvrSize);
   CvrStkPtr := Nil
End;

Procedure TUnit.DisposeQueue;					{.CP05}
Begin
   If CvrQuePtr <> Nil Then FreeMem(CvrQuePtr,CvrSize);
   CvrQuePtr := Nil
End;

Procedure TUnit.PackQueue; { Releases un-used part of queue }	{.CP15}
Var T, K : Word; P : Pointer;
Begin
   If CvrQuePtr <> Nil Then
   Begin
      T := CvrQueTail * SizeOf(CvrRec);
      If T < CvrSize Then
      Begin
         K := (CvrSize - T) AND $FFF8;
         P := PtrNormal(@CvrQuePtr^[CvrQueTail+1]);
         FreeMem(P,K);               { VER60 Requires P be Normalized }
         CvrSize := CvrSize - K;
      End;
   End;
End;   {TUnit.PackQueue}

Destructor  TUnit.Done;						{.CP09}
Begin
   DisposeStack; DisposeQueue;
   If CvrRMaps[rPROC] <> Nil Then CvrRMaps[rPROC]^.Done;
   If CvrRMaps[rCSEG] <> Nil Then CvrRMaps[rCSEG]^.Done;
   If CvrRMaps[rVARS] <> Nil Then CvrRMaps[rVARS]^.Done;
   If CvrRMaps[rCONS] <> Nil Then CvrRMaps[rCONS]^.Done;
   If UImg <> Nil Then FreeMem(UImg,USiz); UImg := Nil; USiz := 0;
End;

FUNCTION TUnit.QueuePos(Locn : LL):Word;			{.CP16}
VAR Lo, Mid, Hi : Word;
BEGIN
   IF CvrQueTail < 1 THEN QueuePos := 1 ELSE
   BEGIN
      Lo := 1; Hi := CvrQueTail;
      REPEAT
         ASM
         	XOR BX,BX	{ make a Zero        }
                MOV AX,Lo       { fetch Lo           }
                ADD AX,Hi       { Add Hi             }
                RCR BH,1        { save carry         }
                SHR AX,1        { divide sum by 2    }
                OR  AH,BH       { restore carry      }
                MOV Mid,AX      { save (Lo+Hi) DIV 2 }
         End;
	 IF Locn > CvrQuePtr^[Mid].LocLL
	 THEN Lo := Mid + 1
	 ELSE Hi := Mid - 1
      UNTIL (CvrQuePtr^[Mid].LocLL=Locn) OR (Lo > Hi);
      IF Locn > CvrQuePtr^[Mid].LocLL THEN Inc(Mid);
      QueuePos := Mid;
   END;     {WITH}
END; {QueuePos}

PROCEDURE TUnit.EnQueue(Arg : CvrRec);				{.CP40}
VAR I,J,K,L, Key : LL;
BEGIN
If CvrQuePtr <> Nil Then
If CvrQueTail < CvrLimit Then
Begin
   Key := QueuePos(Arg.LocLL);
   IF Arg.LocLL < UImg^.UHPMT THEN
   IF Key > CvrQueTail THEN
   BEGIN
      Inc(CvrQueTail);
      CvrQuePtr^[CvrQueTail] := Arg
   END ELSE
   IF Arg.LocLL <> CvrQuePtr^[Key].LocLL THEN { Raise higher entries to }
   BEGIN                                      { make room for insertion }
      Inc(CvrQueTail);                    
      I := Seg(CvrQuePtr^[CvrQueTail]);   { Segment of Tail Entry   }
      J := Ofs(CvrQuePtr^[CvrQueTail]);   { Offset  of Tail Entry   }
      K := Ofs(CvrQuePtr^[Key]);          { Offset to insert point  }
      L := SizeOf(CvrRec);              { Size of Cover Record    }
      ASM            { ASM used for speed only - can be done with FOR Loop }
         PUSH DS                                       { Save DS for Turbo }
         MOV  BX,J                           { Ofs(CvrQuePtr^[CvrQueTail]) }
         MOV  CX,BX                                           { Copy To CX }
         DEC  BX                                        { Back Down 1 Byte }
         MOV  SI,BX                        { Ofs(CvrQuePtr^[CvrQueTail])-1 }
         MOV  AX,L                                        { SizeOf(CvrRec) }
         MOV  DI,BX                        { Ofs(CvrQuePtr^[CvrQueTail])-1 }
         ADD  DI,AX                                      { +SizeOf(CvrRec) }
         SUB  CX,K      { Ofs(CvrQuePtr^[CvrQueTail])-Ofs(CvrQuePtr^[Key]) }
         MOV  AX,I                           { Seg(CvrQuePtr^[CvrQueTail]) }
         MOV  ES,AX                                   { Set Target Segment }
         MOV  DS,AX                                   { Set Source Segment }
         STD                                 { Set Direction Right-To-Left }
         REPNZ MOVSB                                     { Raise the queue }
         POP  DS                                    { Restore DS for Turbo }
      END;                                              { Replacement Ends }
      CvrQuePtr^[Key] := Arg
   END;
   WITH CvrQuePtr^[Key] DO
   IF LocOwn = 0 THEN LocOwn := Arg.LocOwn;
   IF CvrQueTail > CvrQueMax THEN CvrQueMax := CvrQueTail;
End;
END; {EnQueue}

PROCEDURE TUnit.Push( ArgLoc, ArgOwn : LL;			{.CP13}
                      ArgTyp : CoverId; ArgLvl : Word);
VAR Arg : CvrRec;
BEGIN
   Arg.LocLL  := ArgLoc; Arg.LocOwn := ArgOwn;
   Arg.LocTyp := ArgTyp; Arg.LocLvl := ArgLvl;
   If CvrStkPtr <> Nil Then
   If CvrStkTop < CvrLimit Then
   BEGIN
      Inc(CvrStkTop);
      IF CvrStkTop > CvrStkMax
      THEN CvrStkMax := CvrStkTop;
      CvrStkPtr^[CvrStkTop] := Arg
   END
END; {Push}

PROCEDURE TUnit.Pop(VAR Arg : CvrRec);				{.CP05}
BEGIN
   If CvrStkPtr <> Nil Then
   If CvrStkTop > 0 Then
   Begin
      Arg := CvrStkPtr^[CvrStkTop];
      Dec(CvrStkTop);
   End;
END; {Pop}

FUNCTION TUnit.Queued(Key : LL):Boolean;			{.CP12}
VAR Loc : Word;
BEGIN
   Queued := False;
   If CvrQuePtr <> Nil Then
   If CvrQueTail > 0   Then
   Begin
      Loc := QueuePos(Key);
      IF Loc <= CvrQueTail
      THEN Queued := Key = CvrQuePtr^[Loc].LocLL
   End;
END; {Queued}

Procedure TUnit.CalcCovers;					{.CP03}

   PROCEDURE CoverWrapUp;

      PROCEDURE CoverWrapPost(x,s:LL);                         {.CP09}
      VAR J : LL;
      BEGIN
         j := QueuePos(s);
         If CvrQuePtr <> Nil Then
	 WITH CvrQuePtr^[j] DO
	 IF LocLL = s THEN
	 IF (LocOwn > x) OR (LocOwn = 0)
	 THEN LocOwn := x;
      END; {CoverWrapPost}

      PROCEDURE CoverWrapType(x : LL);				{.CP27}
      VAR D : DNamePtr; S : DStubPtr; T : TypePtr; i,j,k : LL;
         RP : VarStubPtr; DF : Char;
      BEGIN
         D := AddrDict(UImg,x);			{ Q entry  }
	 S := AddrStub(D);			{ its stub }
         RP := @S^.sRVF;
	 T := AddrType(UImg,S^.sQTD);
	 IF T <> Nil THEN			{ TD in this unit }
	 BEGIN
            DF := Public(D^.DForm);
	    CoverWrapPost(x,S^.sQTD.UntLL);
	    IF (T^.tpTC = 2) OR (T^.tpTC = 3) THEN
	    BEGIN
	       i := T^.RecdDict;
	       IF i <> x THEN
	       WHILE i <> 0 DO BEGIN
	          CoverWrapPost(x,i);
		  D := AddrDict(UImg,i);
		  S := AddrStub(D);
		  IF DF = 'R' THEN i := RP^.ROB ELSE
		  IF DF = 'S' THEN i := S^.sSHT
		  ELSE i := 0;
	       END  {While I}
	    END
	 END  {IF T <> Nil}
      END;	{CoverWrapType}

   VAR i : Integer;						{.CP08}
   BEGIN {CoverWrapUp}
      If CvrQuePtr <> Nil Then
      For i := 1 TO CvrQueTail DO
      WITH CvrQuePtr^[i] DO
      IF LocTyp = cvName THEN
      IF Public(AddrDict(UImg,LocLL)^.DForm) = 'Q'
      THEN CoverWrapType(LocLL)
   END;	{CoverWrapUp}

   PROCEDURE CoverType(Arg : CvrRec);				{.CP51}
   VAR T, TT : TypePtr; H:HashPtr; TTL : LL; I : Integer; L : Word;
   BEGIN {CoverType}
      T := TypePtr(PtrAdjust(UImg,Arg.LocLL));
      TTL := Arg.LocLL;
      IF T <> Nil THEN
      WITH T^ DO
      CASE tpTC OF
         $01: BEGIN
	         IF AddrType(UImg,BaseType) <> Nil
                    THEN Push(BaseType.UntLL,0,cvType,L);
		 IF AddrType(UImg,BounDesc) <> Nil
                    THEN Push(BounDesc.UntLL,0,cvType,L);
	      END; {CASE $01}
	 $02: IF RecdHash <> 0
                 THEN Push(RecdHash,Arg.LocOwn,cvHash,L+1);
	 $03: IF ObjtHash <> 0
                 THEN Push(ObjtHash,ObjtName,cvHash,L+1);
	 $04,
         $05: IF AddrType(UImg,FileType) <> Nil
                 THEN Push(FileType.UntLL,0,cvType,L);
	 $06: BEGIN
	         IF AddrType(UImg,T^.PFRes) <> Nil
                    THEN Push(T^.PFRes.UntLL,Arg.LocOwn,cvType,L);
		 { Handle Parameter List Entries Here }
		 FOR I := 1 TO T^.PNPrm DO WITH T^.PFPar[I] DO
		 IF AddrType(UImg,fPTD) <> Nil
                    THEN Push(fPTD.UntLL,Arg.LocOwn,cvType,L);
	      END; {CASE $06}
	 $07: IF AddrType(UImg,SetBase) <> Nil
                 THEN Push(SetBase.UntLL,0,cvType,L);
	 $08: IF AddrType(UImg,PtrBase) <> Nil
                 THEN Push(PtrBase.UntLL,0,cvType,L);
	 $09: BEGIN
	         IF AddrType(UImg,StrBase) <> Nil
                    THEN Push(StrBase.UntLL,0,cvType,L);
		 IF AddrType(UImg,StrBound) <> Nil
                    THEN Push(StrBound.UntLL,0,cvType,L);
	      END; {CASE $09}
	 $0C, $0D,
	 $0E: IF AddrType(UImg,Cmpat) <> Nil
                 THEN Push(Cmpat.UntLL,0,cvType,L);
	 $0F: BEGIN
	         IF AddrType(UImg,Cmpat) <> Nil
                    THEN Push(Cmpat.UntLL,0,cvType,L);
		 { now stack the SET descriptor that follows }
		 TT := TypePtr(PtrAdjust(@Cmpat,SizeOf(T^.Cmpat)));
		 Push(FormLL(UImg,TT),0,cvType,L);
	      END; {CASE $0F}
      END;  {CASE tpTC}
   END;  {CoverType}

   PROCEDURE CoverDictStub(D : DNamePtr;			{.CP38}
                           S : DStubPtr; Owner : LL; L : Word);

   VAR T : TypePtr; H : HashPtr; I : Integer; LLDE : LL; C : Char;
   BEGIN {CoverDictStub}
      C := Public(D^.DForm);
      LLDE := FormLL(UImg,D);
      WITH S^ DO
      CASE C OF
         'P': IF AddrType(UImg,sPTD) <> Nil
                 THEN Push(sPTD.UntLL,0,cvType,L);
	 'Q': IF AddrType(UImg,sQTD) <> Nil
                 THEN Push(sQTD.UntLL,LLDE,cvType,L);
	 'X': IF AddrType(UImg,sQTD) <> Nil
                 THEN Push(sQTD.UntLL,0,cvType,L);
	 'R': IF AddrType(UImg,sRTD) <> Nil
                 THEN Push(sRTD.UntLL,0,cvType,L);
	 'S': BEGIN
	         IF sSHT <> 0 THEN Push(sSHT,LLDE,cvHash,L+1);
		 T := AddrProcType(S);
		 Push(FormLL(T,UImg),LLDE,cvType,L);
		 IF AddrType(UImg,T^.PFRes) <> Nil
                    THEN Push(T^.PFRes.UntLL,0,cvType,L);
		 { Handle Parameter List Entries Here }
		 FOR I := 1 TO T^.PNPrm DO WITH T^.PFPar[I] DO
		 IF AddrType(UImg,fPTD) <> Nil
                    THEN Push(fPTD.UntLL,0,cvType,L);
		 IF (sSTp AND $02) <> 0 THEN
		 Push(FormLL(UImg,@T^.PFPar[T^.PNPrm+1]),LLDE,cvINLN,L);
	      END; {CASE 'S'}

	 'Y': BEGIN
	         IF sYNU <> 0 THEN Push(sYNU,0,cvName,L);
		 IF sYPU <> 0 THEN Push(sYPU,0,cvName,L);
	      END; {CASE 'Y'}

      END; {CASE D^.DForm}
   END;  {CoverDictStub}

   PROCEDURE CoverDictHdr(Arg : CvrRec);			{.CP08}
   VAR D : DNamePtr; S : DStubPtr;
   BEGIN {CoverDictHdr}
      D := AddrDict(UImg,Arg.LocLL);
      S := AddrStub(D);
      CoverDictStub(D,S,Arg.LocLL,Arg.LocLvl);
      IF D^.HLink <> 0 Then Push(D^.HLink,Arg.LocOwn,cvName,Arg.LocLvl);
   END; {CoverDictHdr}

   PROCEDURE CoverHashTab(Arg : CvrRec);			{.CP09}
   VAR HLim, I : LL; H : HashPtr; L : Word;
   BEGIN {CoverHashTab}
      L := Arg.LocLvl + 1;
      H := AddrHash(UImg,Arg.LocLL);
      HLim := (H^.Bas DIV SizeOf(LL));
      WITH H^ DO FOR I := 0 TO HLim DO
           IF Slt[I] <> 0 THEN Push(Slt[I],Arg.LocOwn,cvName,L);
   END; {CoverHashTab}

Begin {CalcCovers}						{.CP25}

   If UImg <> Nil Then
   With UImg^ Do Begin
      Push(UHIHT,UHUDH,cvHash,0);         { INTERFACE Hash Table  }
      Push(UHUDH,0,cvName,1);             { Unit Dictionary Entry }
      IF UHIHT <> UHDHT
         THEN Push(UHDHT,UHDHT,cvHash,0); { Debug Rtn Hash Table  }
   End;

   If (CvrQuePtr <> Nil) AND (CvrStkPtr <> Nil) Then
   WITH CvrWork DO
   WHILE CvrStkTop > 0 DO BEGIN
      Pop(CvrWork);
      IF NOT Queued(LocLL) THEN
      BEGIN
         EnQueue(CvrWork);
         CASE LocTyp OF
             cvName: CoverDictHdr(CvrWork); {DictHdr}
	     cvHash: CoverHashTab(CvrWork); {HashTab}
	     cvType: CoverType(CvrWork);    {TypDesc}
         END; {CASE}
      END; {IF}
   END; {WHILE}
   CoverWrapUp;

End;  {CalcCovers}

                                                                {.PA} {
  The following method uses the output of method "CalcCovers" to browse the
  symbol dictionary and discover relations involving the CSeg Map, the PROC
  Map, the Global VAR DSeg Map and the Typed CONST DSeg Map.  The relations
  can involve Fix-Up data, the Trace Table, the Source File List, and the
  various code and data segments contained in the latter part of the unit
  file.  These relations are saved in the heap for later retrieval by the
  print routines.
}

Procedure TUnit.IndexMaps;					{.CP03}

Var  CodeBase, DataBase, FixCBase, FixDBase, NObj : Word;

   { This Procedure computes the size of each }			{.CP27}
   { PROC and adds the result to the Xref map }

   Procedure SizeProcs;
   Var CodeLimit, I, J, K : Word; Pc, Pp : MapTabPtr; Rp, Rc : RMapPtr;
   Begin
      I := 0;
      CodeLimit := (UImg^.UHENC+$F) AND $FFF0 + UImg^.UHZCS;
      Rp := CvrRMaps[rPROC];           { Get RMap Pro Pointer }
      If Rp <> Nil Then
      Begin
         Pp := Rp^.RMapTabPtr;            { Get Proc Ref Pointer }
         J  := Rp^.RMapTabSiz;            { Get Slot Count       }
      End Else
      Begin Pp := Nil; J := 0 End;
      Rc := CvrRMaps[rCSEG];           		{ Get RMap Cod Pointer }
      If Rc <> Nil Then Pc := Rc^.RMapTabPtr;   { Get CSeg Ref Pointer }
      If (J>0) AND (Rc <> Nil) Then
      While I < J-1 Do With Pp^[I] Do Begin
         If Pp^[I].MapCSM <> $FFFF Then
           If Pp^[I].MapCSM = Pp^[I+1].MapCSM
           Then Pp^[I].MapSiz := Pp^[I+1].MapEPT - Pp^[I].MapEPT
           Else Begin
             K := Pp^[I].MapCSM DIV SizeOf(CMapRec);
             Pp^[I].MapSiz := Pc^[K].MapLod + Pc^[K].MapSiz - Pp^[I].MapEPT;
           End;
         Inc(I);
      End;
      If (Pp <> Nil) AND (J>0) Then
      With Pp^[J-1] Do
      If MapCSM <> $FFFF
      Then MapSiz := Codelimit - MapEPT;
   End; {SizeProcs}

   { This Procedure Initializes the CSeg Xref Map }		{.CP28}
   { and sets CSeg Load Points and Fix-Up Offsets }

   Procedure PrimeCSegs;
   Var Cx, Cn, I, N : Word; D : DMapTabPtr;
       C : CMapTabPtr; P : PMapPtr; Rmt, Rmv : MapTabPtr;
   Begin
      Rmt := CvrRMaps[rCSEG]^.RMapTabPtr;
      N   := CvrRMaps[rCSEG]^.RMapTabSiz;
      Cn  := CountCMapSlots(UImg);
      C   := AddrCMapTab(UImg);

      If C <> Nil Then
      For Cx := 0 To Cn-1 Do    { First, we add Info from CSeg  }
      With C^[Cx], Rmt^[Cx] Do  { Map to our CSeg MapRefTab and }
      Begin                     { Calc Fix-Up Offsets           }
         MapTyp := mfCSEG;
         MapSrc := 0;
         MapLod := CodeBase;
         MapSiz := CSegCnt;
         Inc(CodeBase,CSegCnt);
         If CSegRel > 0 Then    { We Have Fix-Ups for this CSeg }
         Begin
            MapFxI := FixCBase;
            FixCBase := FixCBase + CSegRel;
            MapFxJ := FixCBase - SizeOf(FixUpRec);
         End;
      End;

      { Similarly for Typed Constant Data Segments }		{.CP40}

      Rmv := CvrRMaps[rCONS]^.RMapTabPtr;
      N   := CvrRMaps[rCONS]^.RMapTabSiz;
      D   := AddrDMapTab(UImg);

      If D <> Nil Then
      For Cx := 0 To N-1 Do     { First, we add Info from DSeg  }
      With D^[Cx], Rmv^[Cx] Do  { Map to our DSeg MapRefTab and }
      Begin                     { Calc Fix-Up Offsets           }
         If Cx = 0 Then MapTyp := mfPRUI; { flag unit init code }
         MapSrc := 0;
         MapSiz := DSegCnt;
         MapFxJ := DSegRel;
         If DSegOwn <> 0 Then
         Begin MapOwn := DSegOwn; MapTyp := mfTVMT End;
      End;

      { Now, we do a similar job for the PROC Map }

      Rmv := CvrRMaps[rPROC]^.RMapTabPtr;
      N   := CvrRMaps[rPROC]^.RMapTabSiz;
      P   := AddrPMapTab(UImg);

      If P <> Nil Then
      For Cx := 0 To N-1 Do
      With P^[Cx], Rmv^[Cx] Do
      Begin
         MapCSM := CSegOfs;
         MapEPT := CSegJmp;
         If MapCSM <> $FFFF Then
         Begin
            MapTyp := mfPROC;
            I := MapCSM DIV SizeOf(CMapRec);
            MapEPT := MapEPT + Rmt^[I].MapLod;  { Relocate Entry Point }
         End;
         MapSrc := 0;
      End;

   End; { PrimeCSegs }

   { This Proc updates the CSeg Xref Table with data from the }	{.CP57}
   { Trace and PROC Tables that allow us to determine which   }
   { source file furnished the CSeg for the map entry.        }

   Procedure FinalCSegs;
   Var Nc, I, Np, Sf, Sn: Word;
       Ps, Ph: SrcFilePtr; Pt: TraceRecPtr; PRc, PRp: MapTabPtr;
   Begin
      Ps := AddrSrcTabOff(UImg,0); Ph := Ps;	{ Source File List }
      Sf := 0; Sn := 0;  			{ Total Src, non-Obj Files }
      While Ps <> Nil Do Begin
         Inc(Sf);                               { Inc Total Source Files }
         If Ps^.SrcFlag <> $05 Then Inc(Sn);    { Inc Non-Obj File Count }
         Ps := AddrNxtSrc(UImg,Ps);             { point to next src ntry }
      End;
      NObj := Sf - Sn; { Total *.OBJ Files }      Ps := Ph; { Restore Ps }

      If (NObj > 0) AND (CvrRMaps[rCSEG] <> Nil) Then { have *.OBJ's in lst }
      Begin
         PRc:= CvrRMaps[rCSEG]^.RMapTabPtr;
         Nc := CvrRMaps[rCSEG]^.RMapTabSiz;
         For I := 1 to Sn Do Ps := AddrNxtSrc(UImg,Ps);
         For I := (Nc-NObj) To Nc-1 Do
         With PRc^[I] Do Begin
            MapSrc := FormLL(Ph,Ps);
            Ps := AddrNxtSrc(UImg,Ps);
         End;           { *.OBJ Handler }

      { If Pascal Include Files are present, Only the Trace Table Knows }
      { and this is noted only if these files contain PROCs.  This can  }
      { be used to get the source file (actual) in these cases.  Scan   }
      { the trace table and compare its PROC pointer with PROC Name LL  }
      { in our PROC Ref table.  If match, then trace entry has source   }
      { info that applies to this proc (which is part of some CSeg) and }
      { the PROC Ref entry has the CSeg Map Offset which we use to make }
      { the linkage to our CSeg Ref table to save source file offset.   }

         Pt := AddrTraceTab(UImg);
         If CvrRMaps[rPROC] <> Nil Then
         Begin
            PRp := CvrRMaps[rPROC]^.RMapTabPtr;
            Np  := CvrRMaps[rPROC]^.RMapTabSiz;
            While Pt <> Nil Do With Pt^ Do Begin      {For ALL Trace Entries}
               I := 0;
               While I < Np Do With PRp^[I] Do Begin  {For ALL PROC Entries }
                  If MapOwn = Trname Then             {Proc has Trace Entry }
                  Begin
                     PRc^[MapCSM DIV SizeOf(CMapRec)].MapSrc := Trfill;
                     I := Np;   {quit loop and try next trace entry}
                  End;
                  Inc(I);
               End;
               Pt := AddrNxtTrace(UImg,Pt);
            End;
         End;
      End;
   End;  {FinalCSegs}

   { This Procedure updates the CONST Xref Table with data from   }{.CP49}
   { various sources to get offsets to Fix-Up data and to try to  }
   { locate the file in the Source File List that contributed     }
   { this entry.  Any entry NOT defined in the Pascal Source will }
   { have mfNULL as its MapTyp.  We will change such entries to   }
   { mfXTRN and try to decide who spawned them.  This problem is  }
   { strictly undecidable.  We can guess that a Fix-Up in some    }
   { CSeg that references our entry is from the *.OBJ spawned the }
   { block, but that is the closest we can get to the truth.      }

   Procedure FinalCONST;
   Var I, N : Word; HaveXtrn : Boolean; Rmt : MapTabPtr;
   Begin
      If CvrRMaps[rCONS] <> Nil Then
      Begin
         Rmt := CvrRMaps[rCONS]^.RMapTabPtr;
      	 N   := CvrRMaps[rCONS]^.RMapTabSiz;
      	 HaveXtrn := False;

      	 If (N > 0) AND (Rmt <> Nil) Then
      	 Begin
            For I := 0 To N-1 Do With Rmt^[I] Do Begin
               MapLod := DataBase;
               DataBase := DataBase + MapSiz;
               If MapFxJ > 0 Then
               Begin
               	  MapFxI := FixDBase;
               	  Inc(FixDBase,MapFxJ);
               	  MapFxJ := FixDBase - SizeOf(FixUpRec);
               End;
               If NObj > 0 Then If MapTyp = mfNULL Then
               Begin
                  MapTyp := mfXTRN;
              	  HaveXtrn := True;
               End;
            End; {For}         { Fix-Up Offsets are now set }
            { Source File problem deferred until later }
      	 End;
      End;

      If CvrRMaps[rVARS] <> Nil Then
      Begin
      	Rmt := CvrRMaps[rVARS]^.RMapTabPtr;  { Classify VARS Too }
      	N   := CvrRMaps[rVARS]^.RMapTabSiz;
      	If (N > 0) AND (Rmt <> Nil) AND (NObj > 0)
	Then For I := 0 To N-1 Do With Rmt^[I] Do
             If MapTyp = mfNULL Then MapTyp := mfXTRN
      End;
   End;  {FinalCONST}

Var I, J, DHT, IHT : Word; C : Char;				{.CP33}
    Pn : DNamePtr; Ps : DStubPtr; Pv : VarStubPtr; Pm, Pc : RMapPtr;
    Pp : PMapRecPtr; Tc, Tv, Td : DMapRecPtr; V : CvrRec; Q, Qc : MapRefRec;
                     Ndx : MapClass; SystemUnit, InINTF : Boolean;
Begin {IndexMaps}

   For Ndx := rPROC To rCONS Do
       If CvrRMaps[Ndx] <> Nil Then CvrRMaps[Ndx]^.Done;

   CvrRMaps[rCONS] := New(RMapPtr,Init(UImg^.UHDMT-UImg^.UHTMT));
   CvrRMaps[rVARS] := New(RMapPtr,Init(UImg^.UHxxy-UImg^.UHDMT));
   CvrRMaps[rPROC] := New(RMapPtr,Init(UImg^.UHCMT-UImg^.UHPMT));
   CvrRMaps[rCSEG] := New(RMapPtr,Init(UImg^.UHTMT-UImg^.UHCMT));

   CodeBase   := (UImg^.UHENC + $F) AND $FFF0;
   DataBase   := (UImg^.UHZCS + CodeBase +$F) AND $FFF0;
   FixCBase   := (UImg^.UHZDT + DataBase +$F) AND $FFF0;
   DHT        :=  UImg^.UHDHT; IHT := UImg^.UHIHT;
   SystemUnit :=  IsSystemUnit(UImg);

   If CvrRMaps[rCSEG]^.RMapTabSiz > 0 { Initialize CSeg Map Refs }
   Then PrimeCSegs;

   FixDBase := (FixCBase +$F) AND $FFF0;  { VMT Fix-Ups Start Here }
   Pc := CvrRMaps[rCSEG];                 { Get Method Pointer }

   For I := 1 To CvrQueTail Do Begin    { Get CONST/VAR Mapping }
      V := CvrQuePtr^[I];
      If V.LocTyp = cvName Then
      Begin
         Tc := Ptr(Seg(UImg^),Ofs(UImg^)+UImg^.UHTMT); { CONS Map }
         Tv := Ptr(Seg(UImg^),Ofs(UImg^)+UImg^.UHDMT); { DSeg Map }
         Pn := Ptr(Seg(UImg^),Ofs(UImg^)+V.LocLL);
         Ps := AddrStub(Pn);  C := Public(Pn^.DForm);

         If C = 'R' Then    { a data instance of some kind }	{.CP37}
         Begin
            If Ps^.sRAM < $02 Then { a global variable or typed const }
            Begin
               Pv := @Ps^.sRVF;
               J := Pv^.TOB;
               InINTF := (IHT = DHT) OR SystemUnit OR (DHT > V.LocLL);

               If Ps^.sRAM = $00 Then
               Begin				{ it's a Global Variable }
                  Pm := CvrRMaps[rVARS];
                  Pm^.FetchRef(Q,Pv^.TOB);
                  Td := Ptr(Seg(Tv^),Ofs(Tv^)+J);
                  Q.MapSiz := Td^.DSegCnt;
                  If InINTF Then Q.MapTyp := mfINTF
                            Else Q.MapTyp := mfIMPL;
                  Pm^.StoreRef(Q,Pv^.TOB);
               End Else
               Begin				{ it's a Typed Constant  }
                  Pm := CvrRMaps[rCONS];
                  Pm^.FetchRef(Q,Pv^.TOB);
                  Td := Ptr(Seg(Tc^),Ofs(Tc^)+J);
                  If Td^.DSegOwn <> 0 Then Begin
                     Q.MapTyp := mfTVMT;
                     Q.MapOwn := Td^.DSegOwn;   { Owner is OBJECT Name  }
                  End Else
                  If V.LocLvl = 1
		  Then If InINTF Then Q.MapTyp := mfINTF
		  		 Else Q.MapTyp := mfIMPL
                  Else Begin
                     Q.MapTyp := mfNEST;
                     Q.MapOwn := V.LocOwn;      { Owner is PROC scope   }
                  End;
                  Pm^.StoreRef(Q,Pv^.TOB);
               End;   { Typed Constant    }
            End;      { Variable/Constant }
         End          { Type 'R' Stub     }

         Else                             { Check for PROC Map } {.CP20}
         If C = 'S' Then                  { It's a PROC ...... }
         If (Ps^.sSTP AND $02) = 0 Then   { ... AND NOT INLINE }
         Begin
            Pm := CvrRMaps[rPROC];        { Get Method Pointer }
            Pm^.FetchRef(Q,Ps^.sSPM);
            Q.MapOwn := V.LocLL;         { Get PROC Name Offset }
            Pm^.StoreRef(Q,Ps^.sSPM);
         End;  { Type 'S' Stub }
      End;     { DName Entry   }
   End;        { FOR           }

   If CvrRMaps[rCSEG]^.RMapTabSiz > 0 Then FinalCSegs; { Finish CSeg Refs }

   CvrRMaps[rPROC]^.SortPMap(CSegOrder);  	{ Sort PROCS in Load Order }
   SizeProcs;				  	{ Get Proc Size(Bytes)  }
   CvrRMaps[rPROC]^.SortPMap(PMapOrder);  	{ Sort PROCS in PMap Order }
   If CvrRMaps[rCONS] <> Nil Then FinalCONST;	{ Finish CONST Refs }

End; {IndexMaps}

      (*   E N D    M E T H O D S   *)

Function FindCover(U : UnitPtr) : TUnitPtr;			{.CP11}
Var S : TUnitPtr;
Begin
   FindCover := Nil; S := LstRoot;
   While S <> Nil Do
     If S^.UImg <> U Then S := S^.Link Else
     Begin
        FindCover := S;
        S := Nil
     End;
End; {FindCover}

PROCEDURE SortProcRefs  (Mode  : SortMode);			{.CP06}
Begin
   If LstRoot <> Nil Then
   If LstRoot^.CvrRMaps[rPROC] <> Nil
   Then LstRoot^.CvrRMaps[rPROC]^.SortPmap(Mode);
End;

PROCEDURE FetchMapRef  (VAR S : MapRefRec;			{.CP10}
			  C   : MapClass;
			Offset: Word);
Var Q : TUnitPtr;
Begin
   Q := LstRoot; S := NullMap;
   If Q <> Nil Then
   If Q^.CvrRMaps[C] <> Nil
   Then Q^.CvrRMaps[C]^.FetchRef(S,Offset);
End;

PROCEDURE FetchSurveyRec (VAR S : SurveyRec);			{.CP18}
Var Q : CvrRec;
Begin
   S.LocTyp := cvNULL; S.LocLL  := 0; S.LocOwn := 0; S.LocNxt := 0;
   If LstRoot <> Nil Then With LstRoot^ Do
   If UImg <> Nil    Then If CvrQuePtr <> Nil Then
   Begin
      If CvrQueHead < CvrQueTail Then
      Begin
         Inc(CvrQueHead);
         Q := CvrQuePtr^[CvrQueHead];
         S.LocTyp := Q.LocTyp; S.LocLL  := Q.LocLL;
         S.LocOwn := Q.LocOwn; S.LocNxt := UImg^.UHPMT
      End;
      If CvrQueHead < CvrQueTail
      Then S.LocNxt := CvrQuePtr^[CvrQueHead+1].LocLL;
   End;
End; {FetchSurveyRec}

Procedure PurgeAllUnits;					{.CP12}
Var P, Q: TUnitPtr;
Begin
   P := Nil; Q := LstRoot;
   While Q <> Nil Do
   Begin
      P := Q^.Link;
      Q^.Done;
      Q := P;
   End;
   LstRoot := Nil;
End; {PurgeAllUnits}

Function FindUnit(N: _UnitName) : UnitPtr;			{.CP12}
Var P : TUnitPtr; U : UnitPtr;
Begin
   U := Nil; P := LstRoot;
   While P <> Nil Do
      If P^.Name <> N Then P := P^.Link Else
      Begin
         U := P^.UImg;
         P := Nil
      End;
   FindUnit := U;
End;

PROCEDURE SurveyUnit(U : UnitPtr);				{.CP15}
Var S : TUnitPtr;
BEGIN  {SurveyUnit}
   S := FindCover(U);		{ Locate Proper TUnit     }
   If S <> Nil Then
   Begin
	S^.CalcCovers;		{ Analyze Dictionary      }
	S^.DisposeStack;	{ Release Cover Stack     }
	S^.PackQueue;		{ Trim Cover Queue        }
	If S = LstRoot Then	{ If Initial Unit Then    }
	   S^.IndexMaps;	{ Cross-Index All Maps    }
   End;
END;   {SurveyUnit}

PROCEDURE ResolveLG(N: _UnitName; L : LG; VAR R: RespLG);	{.CP20}
Var S : RespLG; U : UnitPtr; T : TUnitPtr; Q: CvrTabPtr;
    W : Word;
Begin
   S.Uptr := Nil; S.Ownr := $FFFF; U := FindUnit(N);
   If U <> Nil Then
   Begin
      T := FindCover(U);
      W := T^.QueuePos(L.UntLL);
      Q := T^.CvrQuePtr;
      If NOT (W > T^.CvrQueTail) Then
      If L.UntLL = Q^[W].LocLL Then
      Begin
         S.Uptr := U;
	 S.Ownr := Q^[W].LocOwn;
      End;
   End;
   R := S;
End;  { ResolveLG }

Var LoaderPath: _FileXpnd;

Procedure UnitLoader(	Path : Dos.PathStr;			{.CP12}
			Name : _UnitName;
			Optn : UnitMode;
		    VAR Core : Word;
		    VAR Locn : UnitPtr);

VAR  SaveMode,UnitVersion : Word;	U : UnitPtr;
     FileId   : _FileSpec;
     FileDir  : Dos.DirStr;	FileName : Dos.NameStr;
     FileExtn : Dos.ExtStr;	FilePath : Dos.PathStr;
     WorkArea : Array[0..3] Of _Paragraph;
     UnitFile : File;		EnvirPth : String;

     Function UnitSize( U : UnitPtr) : Word;			{.CP13}
     VAR EyeBall : String[4];
     Begin
        EyeBall[0] := Chr(SizeOf(EyeBall)-1);
        Move(U^,EyeBall[1],SizeOf(EyeBall)-1);
        If EyeBall <> _UnitEye
        Then UnitSize := 0
        Else
        UnitSize := ((U^.UHENC + $F) AND $FFF0) +
		    ((U^.UHZCS + $F) AND $FFF0) +
		    ((U^.UHZDT + $F) AND $FFF0) +
		    ((U^.UHZFA + $F) AND $FFF0) +
                    ((U^.UHZFT + $F) AND $FFF0);
     End; {UnitSize}

     Function FileExists( N : _FileSpec			{.CP13}
     			  {X : Dos.ExtStr}) : Boolean;
     Begin                           
        FilePath := FSearch(N,EnvirPth);
        If FilePath <> '' Then
        Begin
           FilePath := FExpand(FilePath);
           FSplit(FilePath,FileDir,FileName,FileExtn);
           FileId := N;
           FileExists := True
        End
        Else FileExists := False;
     End; {FileExists}

     Procedure OpenUnitFile(P : Dos.PathStr; N : _FileSpec);	{.CP08}
     Begin
        Assign(UnitFile,P+N);
        SaveMode := FileMode;
        FileMode := 0;
        Reset(UnitFile,SizeOf(_Paragraph));
        FileMode := SaveMode;
     End;

     Procedure InstallUnit(U : UnitPtr; N : _UnitName; Su : Word);{.CP24}
     Var Sk, Sr : Word; T, V : TUnitPtr;
     Begin
        Sk := Su; (*
        If Optn = Partial Then With U^ Do { Keep Only Dictionaries }
        Begin
           Sk := UHPMT;
           T := PtrNormal(Ptr(Seg(U^),Ofs(U^)+Sk));
           Sr := (Su - Sk) AND $FFF0;
           FreeMem(T,Sr);       { Release non-dictionary part of unit }
        End;       *)
        T := New(TUnitPtr,Init(N,U,Sk));        { build placeholder }
        If T <> Nil Then
        Begin
           If LstRoot = Nil
           Then LstRoot := T Else			{ add to chain	    }
           Begin
              V := LstRoot;
              While V^.Link <> Nil Do V := V^.Link;
              V^.Link := T;
           End;
           LoaderPath := FileDir+FileId;
           Core := Sk;             { Say How Much of Unit Loaded }
           Locn := T^.UImg;        { Point to Unit Load Address  }
        End;
     End; {InstallUnit}

     Procedure CheckLibrary(N : _UnitName);			{.CP26}
     Var U : UnitPtr; Su, Sf, Sk, Fp : Word; Ps : DStubPtr; Pn : DNamePtr;
     Begin
        OpenUnitFile(FileDir,FileId);
        Sf := FileSize(UnitFile);
        Fp := 0;
        While Fp < Sf Do Begin
           Seek(UnitFile,Fp);
           BlockRead(UnitFile,WorkArea,4);
           U := @WorkArea;
           Su := UnitSize(U);
           Sk := Su;
           If Optn = Partial Then Sk := (U^.UHPMT + $F) AND $FFF0;
           GetMem(U,Sk);
           If U <> Nil Then
	   Begin
              Seek(UnitFile,Fp);
              BlockRead(UnitFile,U^,Sk SHR 4);
              Pn := DNamePtr(Ptr(Seg(U^),Ofs(U^)+U^.UHUDH));
              Ps := AddrStub(Pn);
              If (N <> Pn^.DSymb) OR
              	((Optn = Partial) AND (Ps^.sYCS <> UnitVersion)) Then
              Begin
                 FreeMem(U,Sk);
                 Inc(Fp,Su SHR 4);
              End Else
              Begin
                 InstallUnit(U,N,Sk);
                 Fp := Sf
              End
           End Else Fp := Sf;
        End;
        Close(UnitFile);
     End; {CheckLibrary}

     Procedure FetchUnit(N : _UnitName);			{.CP17}
     Var U : UnitPtr; Su, Sf, Sk : Word; Ps : DStubPtr; Pn : DNamePtr;
     Begin
        OpenUnitFile(FileDir,FileId);
        Sf := FileSize(UnitFile) SHL 4;
        Seek(UnitFile,0);
        BlockRead(UnitFile,WorkArea,4);
        Seek(UnitFile,0);
        U := @WorkArea;
        Su := UnitSize(U);
        Sk := Su;
        If Optn = Partial Then Sk := (U^.UHPMT + $F) AND $FFF0;
        GetMem(U,Sk);
        If U <> Nil Then
        Begin
           BlockRead(UnitFile,U^,Sk SHR 4);
           Pn := DNamePtr(Ptr(Seg(U^),Ofs(U^)+U^.UHUDH));
           Ps := AddrStub(Pn);
           If (N <> Pn^.DSymb) OR
              ((Optn = Partial) AND (Ps^.sYCS <> UnitVersion))
           Then FreeMem(U,Sk)
           Else InstallUnit(U,N,Sk);
        End;
        Close(UnitFile);
     End; {FetchUnit}

VAR  I : Word;							{.CP10}
Begin {UnitLoader}
   UnitVersion := Core;
   Core := 0;
   Locn := Nil;
   LoaderPath := '';
   If Path = ''
     Then EnvirPth := GetEnv('PATH')
     Else EnvirPth := Path;
   If FileExists(Name+'.TPU')	Then FetchUnit(Name) Else
   If FileExists(_Library)	Then CheckLibrary(Name);
End;  {UnitLoader}

Function AnalyzeUnit(Name: _UnitName;				{.CP32}
		     Path: String):	UnitPtr;
Var U, Z: UnitPtr; N: DNamePtr; S: DStubPtr; USize: Word;
Begin
   UnitLoader(Path,Name,Entire,USize,U);	{ Load Entire  Unit }
   AnalyzeUnit := U;				{ Save Unit Pointer }
   If U <> Nil Then
   Begin
      PutTxt('Unit ('+Name+')');
      SetCol(17);
      PutTxt(' loaded from '+LoaderPath);
      SetCol(1);
      SurveyUnit(U);				{ Analyze Unit }
      N := DNamePtr(PtrAdjust(U,U^.UHUDH));	{ Point to its name }
      S := AddrStub(N);				{ Point to its stub }
      While S^.sYNU <> 0 Do			{ if successor unit }
      Begin
         N := DNamePtr(PtrAdjust(U,S^.sYNU));	    { Point to Name }
         S := AddrStub(N);			    { Point to Stub }
         USize := S^.sYCS;			    { Load Version  }
         UnitLoader(Path,N^.DSymb,Partial,USize,Z); { Load Partial  }
         If Z <> Nil Then
	 Begin
	    PutTxt('Unit ('+N^.DSymb+')');
	    SetCol(17);
	    PutTxt(' loaded from '+LoaderPath);
            SetCol(1);
	    SurveyUnit(Z);	    	{ Get its Cover }
         End;
      End;				{ Until all Units Handled }
   End;
End; {AnalyzeUnit}

End.