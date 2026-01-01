{$D-,L-,S+,R-,E-,N-}
PROGRAM TPU6;
USES TPU6EQU, TPU6UTL, TPU6AMS, TPU6RPT, TPU6UNA,Dos,Crt;

TYPE
   MethodName	= String[127];
   HeadProc	= PROCEDURE;
   LGClass   = (
   		LG_ABSQ,		{Absolute Equivalence}
                LG_ARBC,		{Array Bounds}
                LG_ASGN,		{Biggest Assgn Compat Type}
                LG_BASE,		{Base Type}
   	        LG_CONS,		{Const Type}
                LG_FUNR,		{Function Result}
                LG_OBJP,		{Parent Object}
                LG_PARM,		{Formal Parameter}
                LG_TYPE			{Named Type, Xtrn Var}
                );
   LGString	= String[21];

VAR
   CSegOrg,	CSegEnd,     NextLL,	LastLL		: Word;
   TabStop,	NoteX,	     NoteY	                : Integer;
   NoteTime, JobTime     : LongInt;	CPUType: CPUGate;
   DisAssembly	: Boolean;
   SurveyWork   : SurveyRec;
   Map          : MapRefRec;

CONST
   TypTxt : Array[0..15] of String[11] = (
   	{ $0} 'untyped', { $1} 'ARRAY', { $2} 'RECORD',	{ $3} 'OBJECT',
        { $4} 'FILE',	 { $5} 'TEXT',  { $6} 'proc',	{ $7} 'SET',
        { $8} 'POINTER', { $9} 'STRING',{ $A} '8087 float',
	{ $B} '6-byte real',		{ $C} 'fixed-point',
	{ $D} 'boolean', { $E} 'char',	{ $F} 'enumeration');

PROCEDURE NoteBegin(S:String);                                  {.CP08}
VAR HH,MM,SS,CS : Word;
BEGIN
	NoteX := WhereX; NoteY := WhereY; ClrEol;
	GetTime(HH,MM,SS,CS);
	NoteTime := (LongInt(HH*60+MM)*60+SS)*100+CS;
	If S <> '' Then Write(S);
END;

PROCEDURE PageOverFlow(Lines : Word; CallProc : HeadProc);      {.CP09}
BEGIN
	IF LinesRemaining < Lines THEN
	BEGIN
		NewTxtPage;
		CallProc;
	END
	ELSE	NewTxtLine;
END;

PROCEDURE NoteEnd;						{.CP11}
VAR HH,MM,SS,CS : Word; SF : String[3];  I : Integer;
BEGIN
	GetTime(HH,MM,SS,CS);
	NoteTime := ((LongInt(HH*60+MM)*60+SS)*100+CS) - NoteTime;
        Str(NoteTime MOD 100 + 100:3,SF);
        I := NoteTime DIV 100;
	Write(', Finished in ',I,'.',Copy(SF,2,2),' seconds');
	Delay(1000);
	GoToXY(NoteX,NoteY);
END;

FUNCTION NameOfMethod(U:UnitPtr;UsrDE:LL):MethodName;	        {.CP20}
VAR DS, DC : DNamePtr; S : DStubPtr; T : TypePtr; N, M : String[64];
BEGIN
	N := ''; M := '???';
	IF UsrDE <> $FFFF THEN
	BEGIN
		DS := DNamePtr(PtrAdjust(U,UsrDE));
		M  := DS^.DSymb;
		S  := AddrStub(DS);
		IF Public(DS^.DForm) = 'S' THEN   {ensure subprogram entry}
		IF (S^.sSTp AND $10) <> 0 THEN {get OBJECT Name Qualifier}
		IF  S^.sSPS <> 0 THEN
		BEGIN
			T  := TypePtr(PtrAdjust(U,S^.sSPS));	{to Object TD}
			DC := DNamePtr(PtrAdjust(U,T^.ObjtName)); {to Object DE}
			N  := DC^.Dsymb+'.';
		END
	END;
	NameOfMethod := N + M
END;   {NameOfMethod}

PROCEDURE PrintTitleBlk(S : String; LinesNeeded : Integer);	{.CP11}
BEGIN {PrintTitleBlk}
	IF LinesRemaining < LinesNeeded+3
		THEN NewTxtPage	ELSE SetCol(1);
	PutTxt('----');
	NewTxtLine;
	PutTxt('- ' + S);
	NewTxtLine;
	PutTxt('----');
	SetCol(1);
END; {PrintTitleBlk}

PROCEDURE PrintAddress(Arg : LL);				{.CP06}
BEGIN
	IF ColumnsUsed <> 0 THEN NewTxtLine;
	PutTxt(HexW(Arg));
	SetCol(7);
END; {PrintAddress}

PROCEDURE PrintByteList(U : UnitPtr; Count, Space : Word);	{.CP11}
BEGIN
	WITH BufPtr(U)^ DO
	WHILE Count > 0 DO
	BEGIN
		PutTxt(HexB(BufByt[NextLL]));
		SetCol(ColumnsUsed+Space+1);
		Inc(NextLL);
		Dec(Count);
	END
END; {PrintByteList}

PROCEDURE PrintWd(U : UnitPtr; S : String);			{.CP07}
BEGIN
	PrintAddress(NextLL);
	PrintByteList(U,2,1);
	SetCol(TabStop);
	PutTxt(S);
END; {PrintWd}

PROCEDURE PrintDWd(U : UnitPtr; S : String);			{.CP07}
BEGIN
	PrintAddress(NextLL);
	PrintByteList(U,4,1);
	SetCol(TabStop);
	PutTxt(S);
END; {PrintDWd}

PROCEDURE PrintLL(U : UnitPtr; S : String);			{.CP07}
BEGIN
	PrintAddress(NextLL);
	PrintByteList(U,2,1);
	SetCol(TabStop);
	PutTxt('LL('+S+')');
END; {PrintLL}

PROCEDURE PrintSoloByte(U : UnitPtr; S : String);		{.CP08}
VAR B : Byte;
BEGIN
	PrintAddress(NextLL);
	PrintByteList(U,1,0);
	SetCol(TabStop);
	PutTxt(S);
END; {PrintSoloByte}

PROCEDURE PrintBytes(U : UnitPtr; Count, Limit : Word);	        {.CP12}
VAR I : Integer;
BEGIN
	I := 0;
	WITH BufPtr(U)^ DO WHILE Count > 0 DO BEGIN
		I := I MOD Limit;
		IF I = 0 THEN PrintAddress(NextLL);
		PrintByteList(U,1,1);
		Inc(I);
		Dec(Count);
	END;
END; {PrintBytes}

FUNCTION NilLG(L: LG) : Boolean;		                {.CP02}
BEGIN NilLG := (L.UntLL = 0) AND (L.UntId = 0) END;

Function GetArrayBounds(U: UnitPtr; Arg: LG):String;		{.CP14}
Var Tp: TypePtr; V: DNamePtr; Tu: UnitPtr; R: RespLG; Bl,Bu: String[12];
Begin
   GetArrayBounds := '';
   V := AddrLGUnit(U,Arg);		{Point to Host Unit Name}
   ResolveLG(V^.DSymb,Arg,R);		{Find Unit in Heap}
   Tu := R.Uptr;                        {Get Ptr to Host Unit}
   If Tu <> Nil Then
   Begin
      Tp := TypePtr(PtrAdjust(Tu,Arg.UntLL)); {to bounds descriptor}
      Str(Tp^.LoBnd, Bl); Str(Tp^.HiBnd, Bu);
      GetArrayBounds := Bl + '..' + Bu;
   End;
End; {GetArrayBounds}

PROCEDURE PrintLG(U : UnitPtr; LGS: LGClass; S : String);	{.CP34}
CONST
   LG_Txt : Array[LGClass] Of LGString =
   	   ({LG_ABSQ} 'ABSOLUTE Target-Stub',
	    {LG_ARBC} 'Array[',		{LG_ASGN} 'Assgn Cmpat Type',
	    {LG_BASE} 'Base Type',	{LG_CONS} 'CONST Cmpat Type',
	    {LG_FUNR} 'Return Result',	{LG_OBJP} 'Ancestor Object',
	    {LG_PARM} 'Parm ',		{LG_TYPE} 'Named Type');

VAR L: LG; V : DNamePtr; R: RespLG; X: _UnitName; W : String;
BEGIN
        L := LG(Ptr(Seg(U^),Ofs(U^)+NextLL)^);
	IF NOT NilLG(L) THEN
	BEGIN
             V := AddrLGUnit(U,L);		{point to Unit Entry}
	     X := '';				{its name}
             R.Ownr := $FFFF;
             If V <> Nil Then
	     Begin
	        X := V^.DSymb;
		ResolveLG(X,L,R)
             End;
             If (R.Ownr <> $FFFF) AND (R.Ownr <> 0) Then
	     Begin
	     	W := X + '.' + NameOfMethod(R.Uptr,R.Ownr);
                If LGS <> LG_PARM Then S := '' End
             Else  W := 'in [' + X + '] ';
	     W := 'LG(' + W + ') ' + LG_Txt[LGS];
             If LGS = LG_ARBC
	     Then W := W + GetArrayBounds(U,L) +']'
	     Else W := W + S;
             S := W;
	END Else S := 'LG(nil type) ' + S;
	PrintAddress(NextLL);
	PrintByteList(U,4,1);
	SetCol(TabStop);
	PutTxt(S);
END; {PrintLG}

PROCEDURE BoundaryAlign(UH : UnitPtr);			        {.CP12}
VAR I : Integer;
BEGIN {BoundaryAlign}
	I := ((NextLL + 15) AND $FFF0) - NextLL;
	IF I > 0 THEN
	BEGIN
		PrintBytes(UH,I,8);
		SetCol(36);
		PutTxt('Align to Paragraph Boundary');
		NewTxtLine
	END;
END;  {BoundaryAlign}

PROCEDURE PrintOffset(Base: Word);				{.CP06}
BEGIN
     IF ColumnsUsed <> 0 THEN NewTxtLine;
     PutTxt(HexW(NextLL));SetCol(6);
     PutTxt('[+'+HexW(NextLL-Base)+'] ');
END;

PROCEDURE PrintCodeBytes(U : UnitPtr; Count,Limit,Base: Word;X : Boolean); {.CP34}
CONST Xlat : SET OF Char = [' '..Chr($7E)];
VAR I : Integer; j,k : Word; S : String;  C : ^Char;
BEGIN
	I := 0; j := 0; k := Limit*3 + 17; S := '';
	WITH BufPtr(U)^ DO WHILE Count > 0 DO BEGIN
		I := I MOD Limit;
		IF I = 0 THEN
		BEGIN
			IF X THEN
			BEGIN
				SetCol(K);
				PutTxt(S);
				S := '';
			END;
			PrintOffset(Base);
		END;
		IF X THEN
		BEGIN
			C :=Ptr(Seg(U^),Ofs(U^)+NextLL);
			IF C^ IN Xlat THEN S := S + C^
				      ELSE S := S + '.'
		END;
		PrintByteList(U,1,1);
		Inc(I);
		Dec(Count);
	END;
	IF X THEN
	BEGIN
		SetCol(K);
		PutTxt(S);
		S := '';
	END;
END; {PrintCodeBytes}

PROCEDURE PrintUnknowns(U : UnitPtr; Till:LL);		        {.CP06}
BEGIN {PrintUnknowns}
	PrintTitleBlk('The Purpose of the data below is Unknown',1);
	PrintBytes(U,Till-NextLL,8);
	NewTxtLine;
END;  {PrintUnknowns}

PROCEDURE FormatHeader(U : UnitPtr);			        {.CP38}
VAR I : Integer;
BEGIN
	NoteBegin('Formatting Unit Header');
	PrintAddress(NextLL);
	FOR I := 0 TO 3 DO PutTxt(HexB(Byte(U^.UHEYE[I]))+' ');
	SetCol(TabStop);
	PutTxt('=''');
	FOR I := 0 TO 3 DO PutTxt(U^.UHEYE[I]);
	PutTxt('''');
	NewTxtLine;
	Inc(NextLL,4);
	PrintAddress(NextLL);
	FOR I := 0 TO 3 DO PutTxt(HexB(Byte(U^.UHxxx[I]))+' ');
	NewTxtLine;
	Inc(NextLL,4);
	PrintLL(U,'Dict Hdr-This Unit');
	PrintLL(U,'INTERFACE Hash Table');
	PrintLL(U,'PROC Map');
	PrintLL(U,'CSEG Map');
	PrintLL(U,'DSEG Map-Typed CONST''s');
	PrintLL(U,'DSEG Map-Global VARs');
	PrintWd(U,'Usage Unknown');
	PrintLL(U,'Donor Unit List');
	PrintLL(U,'Source File List');
        With U^ Do If UHDBT = UHENC
        Then PrintWd(U,'No Trace Table')
	Else PrintLL(U,'Debug TRACE Table');
	PrintLL(U,'end NON-CODE part of Unit');
	PrintWd(U,'CSEG Size (Aggregate)');
	PrintWd(U,'DSEG Size (Typed CONST''s)');
	PrintWd(U,'Fix-Up List Size (CSegs)');
	PrintWd(U,'Fix-Up List Size (Typed CONST''s)');
	PrintWd(U,'DSEG Size (Global VARs)');
	PrintLL(U,'DEBUG Hash Table');
        If U^.UHSOV = 0
        Then PrintWd(U,'No Overlay')
        Else PrintWd(U,'Overlay Involved');
	NewTxtLine;
	IF NextLL < U^.UHIHT THEN PrintUnknowns(U,U^.UHIHT);
	NoteEnd;
END; {FormatHeader}

PROCEDURE FormatDictionary(U : UnitPtr);			{.CP19}

   PROCEDURE PrintDictEntry;
   VAR D, DB: DNamePtr; S: DStubPtr; I: Integer; It: Byte;
       RP: VarStubPtr; DF: Char; DFM: String[8];
       T : String[44]; W : String;
   BEGIN {PrintDictEntry}
      D := AddrDict(U,SurveyWork.LocLL); S := AddrStub(D);
      RP := @S^.sRVF;
      WITH SurveyWork, D^, S^ DO
      BEGIN
         DF := Public(DForm);
         IF DF <> DForm Then DFM := 'Private ' Else DFM := '';
         I := 4+(Length(DSymb) SHR 4);
	 CASE DF OF 'R','Y': Inc(I,4);
                        'S': Inc(I,6);
	                'P': Inc(I,2);
           'Q','O','T'..'X': Inc(I);
	 END; {CASE}
	 W := '';				                {.CP12}
	 IF DF = 'R' THEN
              Case sRAM Of
		  $08: IF SurveyWork.LocOwn <> 0
		       THEN W := NameOfMethod(U,SurveyWork.LocOwn);
                  $10,$01,$00: ;
		  ELSE IF RP^.ROB <> 0 THEN W := NameOfMethod(U,RP^.ROB);
              End; {Case}
	 IF W = '???' THEN W := '' ELSE
	 IF W <> ''   THEN W := W + '.';
	 PrintTitleBlk('Dictionary Entry For: "'+ W +
	 NameOfMethod(U,SurveyWork.LocLL)+'"',I);
	 IF HLink <> 0                                          {.CP06}
	    THEN PrintLL(U,AddrDict(U,HLink)^.DSymb)
	    ELSE PrintWd(U,'(no backward link)');
	 PrintBytes(U,1,1);
	 SetCol(TabStop);
	 PutTxt(DFM+'Type "'+DF+'" -> ');
	 CASE DF OF                                             {.CP18}
	   'O': PutTxt('GOTO Label');  'P': PutTxt('Un-Typed CONST');
	   'Y': PutTxt('Unit');        'T': PutTxt('Built-In Procedure');
	   'W': PutTxt('Port Array');  'U': PutTxt('Built-In Function');
	   'Q': PutTxt('Named Type');  'V': PutTxt('Built-In "NEW"');
	   'X': PutTxt('MEM_ Array');
	   'R': CASE sRAM OF
	          $00: PutTxt('Global VAR');
		  $01: PutTxt('Typed CONST');
		  $02: PutTxt('Local VAR (on Stack)');
                  $03: PutTxt('Absolute VAR [Seg:Ofs]');
		  $06: PutTxt('Self VAR (ADDR on Stack)');
		  $08: PutTxt('Record/Object Field');
                  $10: PutTxt('Absolute VAR (Equated)');
                  $22: PutTxt('VALUE Arg on Stack');
                  $26: PutTxt('VAR Arg on Stack');
                  Else PutTxt('New Data Type');
	        END; {CASE sRAM}
	   'S': IF sSVM = 0 Then                                {.CP12}
                   Case (sSTp AND $70) Of
                     $10: PutTxt('Method');
                     $30: PutTxt('Constructor');
                     $50: PutTxt('Destructor');
                     Else PutTxt('Subprogram')
                   End
                Else PutTxt('Virtual Method');
	 END; {CASE DF OF}
	 PrintBytes(U,Length(DSymb)+1,16);
	 SetCol(TabStop); PutTxt('="'+DSymb+'"');
	 NewTxtLine;
	 CASE DF OF { Format the Stub Part }                    {.CP13}
	   'O': PrintWd(U,'Unknown purpose)');
	   'P': BEGIN
		   PrintLG(U,LG_CONS,'');
		   PrintBytes(U,LastLL-NextLL,8); {Temporary Fix}
		   {since value can be a string, we really need to check
		    the type descriptor out but that usually lies in the
		    system unit.  We circumvent for now by relying on the
		    distance to the next structure to determine the size
		    of the constant data for print purposes }
		   SetCol(TabStop); PutTxt('Constant Value');
		   NewTxtLine;
	        END; {CASE 'P'}
	   'Y': BEGIN                                           {.CP07}
                   PrintWd(U,'TURBO Work?');
		   PrintWd(U,'Unit Version Number???');
		   PrintLL(U,'next unit in list');
		   PrintLL(U,'prior unit in list');
		   NewTxtLine;
	        END; {CASE 'Y'}
	   'T','U','V': BEGIN                                   {.CP04}
	                   PrintWd(U,'Meaning Unknown');
			   NewTxtLine;
	                END;
	   'W': BEGIN                                           {.CP04}
		   PrintSoloByte(U,'0=byte array, 1=word array');
		   NewTxtLine;
	        END;
	   'Q','X': BEGIN                                       {.CP04}
	               PrintLG(U,LG_TYPE,'');
		       NewTxtLine;
	            END;
	   'R': BEGIN                                           {.CP49}
                   It := sRAM AND $1F;
		   CASE sRAM OF
                      $00: T := 'Global VAR in DS';
                      $01: T := 'Typed CONST in DS';
                      $02: IF RP^.ROfs > $7FFF
			     THEN T := 'Local VAR on Stack'
                             ELSE T := 'VALUE(Stack)';
                      $03: T := 'Absolute [Seg:Ofs]';
                      $06: T := 'ADDR(Self) on Stack';
                      $08: T := 'Record/Object Field';
                      $10: T := 'Absolute Equivalence';
                      $22: T := 'Arg On Stack (VALUE)';
                      $26: T := 'Arg On Stack (VAR)';
                      ELSE T := '**** NEW CODE TO CHECK ****'
		   END; {CASE sRAM}
		   PrintSoloByte(U,T);
		   T := '';
                   Case It Of
                     $03: Begin
                             PrintWd(U,'Absolute Offset');
                             PrintWd(U,'Absolute Segment');
                          End;
                     $10: PrintLG(U,LG_ABSQ,'');
                     Else
                     Begin
			IF (It = $2) OR (It = $6) THEN With RP^ DO
			IF RP^.ROfs > $7FFF
			   THEN T := 'BP-'+HexW($10000-ROfs)
			   ELSE T := 'BP+'+HexW(ROfs)
			ELSE T := 'bytes';
			PrintWd(U,'allocation offset ('+T+')');
			CASE It OF
                          $0: T := 'Entry offset in VAR DSeg Map';
                          $1: T := 'Entry offset in CON DSeg Map';
                          $2,$6:
                                IF RP^.ROB = 0
				THEN T := 'no containing scope'
				ELSE T := 'LL(containing Scope)';
			  $8: IF RP^.ROB = 0
                              THEN T := 'no successor field/method'
                              ELSE T := 'LL(successor field/method)';
			  ELSE T := 'Usage Unknown'
			END; {CASE It}
			PrintWd(U,T);
                     End {Case It}
                   End; {Case sRAM}
		   PrintLG(U,LG_BASE,'');
	        END; {CASE 'R'}
	   'S': BEGIN                                           {.CP37}
		   T := '';
		   IF ((sSTp AND $01) = 0) AND ((sSTp AND $16) = 0)
                   THEN T := '+NEAR'
                   ELSE IF  (sSTp AND $10) <> 0 THEN
		            CASE (sSTp AND $60) OF
			      $00: T := '+Method';
                              $20: T := '+Constructor';
			      $40: T := '+Destructor';
			      ELSE T := '+Method?'
		            END;
		   IF (sSTp AND $08) <> 0 THEN T := T + '+EXTERNAL';
		   IF (sSTp AND $01) <> 0 THEN T := T + '+FAR';
		   IF (sSTp AND $02) <> 0 THEN T := T + '+INLINE';
                   IF (sSTp AND $04) <> 0 THEN T := T + '+INTERRUPT';
                   IF (sSTp AND $80) <> 0 THEN T := T + '+ASSEMBLER';
		   IF Length(T) > 0 THEN Delete(T,1,1);
		   PrintSoloByte(U,T);
                   PrintSoloByte(U,'Usage Unknown');
		   IF (sSTp AND $02) <> 0  THEN T := 'INLINE Code Bytes'
			                   ELSE T := 'offset in PROC Map';
		   PrintWd(U,T);
		   IF sSPS = 0 THEN T := 'no containing scope'
			       ELSE T := 'LL(containing scope)';
		   PrintWd(U,T);
		   IF sSHT = 0 THEN T := 'no local Hash Table'
			       ELSE T := 'LL(local scope Hash Table)';
		   PrintWd(U,T);
                   IF sSVM = 0
                   THEN PrintWd(U,'Not Used')
                   ELSE PrintWd(U,'Method Ptr Offset in VMT');
                   SetCol(1);
	        END; {CASE 'S'}
	 END; {CASE DF OF}
      END; {WITH}

   END;  {PrintDictEntry}

   PROCEDURE PrintTypeEntry;					{.CP51}
   VAR T : TypePtr; W : String[64]; D : DNamePtr; I : Integer;

   BEGIN {PrintTypeEntry}
      T := TypePtr(PtrAdjust(U,SurveyWork.LocLL)); I := 0;
      CASE T^.tpTC OF
        $01, $02, $09: I := 2; $04, $05, $07, $08: I := 1;
             $0C..$0F: I := 3; $03: I := 10;  $06: I := 7 + 2*T^.PNPrm;
      END; {CASE}
      W := '';
      IF SurveyWork.LocOwn <> 0
      THEN W := NameOfMethod(U,SurveyWork.LocOwn) ELSE
      IF T^.tpTC = $03 THEN W := NameOfMethod(U,T^.ObjtName);
      IF (W <> '') AND (W <> '???') THEN W := ' For: "' + W + '"';
      PrintTitleBlk('Type Descriptor' + W,I+2);
      WITH T^ DO BEGIN
         PrintBytes(U,2,8);SetCol(TabStop);
         CASE tpTC OF
           $00: W := 'un-typed';  $01: W := 'Array';
           $02: W := 'Record';    $03: W := 'Object';
           $04: W := 'File';      $05: W := 'Text';
           $06: If NilLG(PFRes)
		Then W := 'Procedure'
		Else W := 'Function';
           $07: W := 'Set';
           $08: W := 'Pointer';   $09: W := 'String';
           $0A: CASE tpTQ OF
                  $00: W := 'Single'; $02: W := 'Extended';
		  $04: W := 'Double'; $06: W := 'Comp';
		  ELSE W := '8087-Floating?'
	        END; {CASE tpTQ}
           $0B: W := 'Real';
           $0C: CASE tpTQ OF
		  $00: W := 'un-named byte integer';  $01: W := 'ShortInt';
                  $02: W := 'Byte';      $04: W := 'un-named word integer';
                  $05: W := 'Integer';   $06: W := 'Word';
                  $0C: W := 'un-named DWORD integer';
                  $0D: W := 'LongInt';
                  ELSE W := 'unknown integer type';
                END; {CASE tpTQ}
           $0D: W := 'Boolean';     $0E: W := 'Char';
           $0F: W := 'enumeration';
           ELSE W := 'unknown type code';
         END; {CASE tpTC OF}
         PutTxt('Type='+W);
         PrintWd(U,'Storage Width (bytes)');
         If tpML = 0
           Then If tpTC = $06
                Then PrintWd(U,'NO Next Method')
                Else PrintWd(U,'Usage Unknown')
           Else PrintLL(U,'Dict Hdr, Next Method');
         CASE tpTC OF						{.CP05}
           $01: BEGIN
		   PrintLG(U,LG_BASE,'');
		   PrintLG(U,LG_ARBC,'');
		END;
	   $02: BEGIN						{.CP04}
		   PrintLL(U,'Field List Hash Table');
		   PrintLL(U,'Dict Entry of 1st Field');
		END;
	   $03: BEGIN						{.CP19}
		   PrintLL(U,'Field/Method Hash Table');
		   PrintLL(U,'Field/Method Dictionary');
		   IF NilLG(ObjtOwnr)
			THEN PrintDWd(U,'nothing inherited')
			ELSE PrintLG(U,LG_OBJP,'');
		   PrintWd(U,'Size of VMT (bytes)');
		   IF ObjtDMap = $FFFF
			THEN PrintWd(U,'there is no VMT')
			ELSE PrintWd(U,'DSeg Map Offset of VMT Template');
		   IF ObjtVMTO = $FFFF
			THEN PrintWd(U,'Object has no VIRTUAL Methods')
			ELSE PrintWd(U,'Offset in Object to VMT Pointer');
		   D := AddrDict(U,ObjtName);
		   PrintLL(U,'Dict Entry ('+D^.DSymb+')');
                   PrintBytes(U,8,8);
                   SetCol(TabStop);
                   PutTxt('Usage Unknown');
		END;
	   $06: BEGIN						{.CP21}
	   	   IF NilLG(PFRes)
		   THEN PrintDWd(U,'Procedures have no Result')
		   ELSE PrintLG(U,LG_FUNR,'');
		   IF PNPrm = 0 THEN PrintWd(U,'no parameter list') ELSE
		   BEGIN
		      Str(PNPrm,W); W := W + ' Formal Parameter';
		      IF PNPrm > 1 THEN W := W + 's';
		      PrintWd(U,W);
		      FOR I := 1 TO PNPrm DO WITH PFPar[I] DO BEGIN
			Str(I,W);
			PrintLG(U,LG_PARM,W);
			IF fPAM = $02
			THEN W := 'Pass VALUE on Stack'
			ELSE IF fPAM = $06
				THEN W := 'Pass ADDRESS on Stack'
				ELSE W := '**** NEW CODE VALUE ***';
			PrintSoloByte(U,W)
		      END; {FOR}
		   END;
		END;  { CASE $06 }
	   $04: PrintLG(U,LG_BASE,' FILE');			{.CP08}
	   $05: PrintLG(U,LG_BASE,' TEXT');
	   $07: PrintLG(U,LG_BASE,' SET');
	   $08: PrintLG(U,LG_BASE,' POINTER');
	   $09: BEGIN
		   PrintLG(U,LG_BASE,'STRING');
		   PrintLG(U,LG_ARBC,'');
		END;
	   $0C..						{.CP12}
	   $0F: BEGIN
	   	   PrintBytes(U,SizeOf(T^.LoBnd),8);
		   SetCol(TabStop);PutTxt('Subrange Lower Bound');
		   PrintBytes(U,SizeOf(T^.HiBnd),8);
		   SetCol(TabStop);PutTxt('Subrange Upper Bound');
		   PrintLG(U,LG_ASGN,'');
	   	END; { $0C,$0D,$0E,$0F}
	 END; {CASE tpTC OF}
      END; {WITH}

   END;  {PrintTypeEntry}

   PROCEDURE PrintHashEntry;					{.CP22}
   VAR H : HashPtr;

	FUNCTION PrintEmptyHash(Bot,Top:Word):Word;
	VAR  I, J, K : Word;
	BEGIN
	   I := Bot;
	   WITH H^ DO REPEAT
	   	IF Slt[I] = 0
		THEN Inc(I)
		ELSE Top := I-1;
	   UNTIL Top < I;
	   K := 0;
	   WITH H^ DO FOR J := Bot TO Top DO BEGIN
	      IF (K AND $3)=0 THEN PrintAddress(NextLL);
	      PutTxt(HexB(LO(Slt[J]))+' ');
	      PutTxt(HexB(HI(Slt[J]))+' ');
	      Inc(NextLL,2);
	      Inc(K);
	   END;
	   PrintEmptyHash := I
	END; {PrintEmptyHash}

   VAR  D : DNamePtr; I, J, K, N : Word; W : String[44];	{.CP26}

   BEGIN {PrintHashEntry}
   	H := AddrHash(U,SurveyWork.LocLL);
	N := H^.Bas DIV 2;
	W := '';
	IF SurveyWork.LocLL = U^.UHIHT
	THEN W := '- INTERFACE Dictionary'	ELSE
	IF SurveyWork.LocLL = U^.UHDHT
	THEN W := '- Turbo DEBUG Dictionary'	ELSE
	IF SurveyWork.LocOwn <> 0
	THEN W := 'Owned By: "'+NameOfMethod(U,SurveyWork.LocOwn)+'"';
	PrintTitleBlk('Hash Table '+W,3);
	PrintWd(U,'Bytes in Hash Table - 2');
	SetCol(1);PutTxt('----');
	I := 0;

	WITH H^ DO REPEAT
	   IF Slt[I] <> 0 THEN
	   BEGIN
	      PrintLL(U,AddrDict(U,Slt[I])^.DSymb);
	      Inc(I)
	   END ELSE I := PrintEmptyHash(I,N);
	UNTIL I > N;
	NewTxtLine;
   END;  {PrintHashEntry}

   PROCEDURE PrintInLineEntry;					{.CP15}
   VAR D : DNamePtr; S : DStubPtr; I : Integer;  T : TypePtr;

   BEGIN {PrintInLineEntry}
      D := AddrDict(U,SurveyWork.LocOwn);   { Procedure  Header }
      S := AddrStub(D);                     { Procedure  Stub   }
      T := AddrProcType(S);                 { Type Descriptor   }
      WITH SurveyWork, T^ DO BEGIN
	 I := (S^.sSPM+15) SHR 4;
	 PrintTitleBlk('INLINE Code Bytes FOR: "'+
	 		NameOfMethod(U,SurveyWork.LocOwn)+'"',I);
	 PrintBytes(U,S^.sSPM,16);
	 SetCol(1);
      END;
   END;  {PrintInLineEntry}

VAR I : Word; BU : SurveyRec; DoneDict,DoneHash : Boolean; BUL : LL;  {.CP30}
BEGIN {FormatDictionary}
	NoteBegin('Formatting Dictionary');
	DoneHash := False; DoneDict := False;
        FetchSurveyRec(SurveyWork);
	WITH SurveyWork DO
	While LocTyp <> cvNULL DO BEGIN
                LastLL := LocNxt;
		BU := SurveyWork;
		IF NextLL < LocLL THEN
		IF NOT DoneHash THEN PrintUnknowns(U,LocLL) ELSE
                IF DoneDict     THEN PrintUnknowns(U,LocLL) ELSE
		BEGIN
			BUL := LastLL;
			LocLL := NextLL; LastLL := BU.LocLL;
			LocOwn := 0; LocTyp := cvType;
			PrintTypeEntry;
			SurveyWork := BU; LastLL := BUL;
		END;
		CASE LocTyp OF
		     cvName: BEGIN PrintDictEntry; DoneDict := True END;
		     cvType: PrintTypeEntry;
		     cvHash: BEGIN PrintHashEntry; DoneHash := True END;
		     cvINLN: PrintInLineEntry;
		END; {CASE}
                FetchSurveyRec(SurveyWork);
	END;   {While}
	IF NextLL < U^.UHPMT THEN PrintUnknowns(U,U^.UHPMT);
	NoteEnd;
END;  {FormatDictionary}

FUNCTION NameOfObject(U:UnitPtr;UsrDE:LL):_LexName;		{.CP15}
VAR D : DNamePtr; T : TypePtr;
BEGIN
   NameOfObject := '???';
   IF UsrDE <> $0000 THEN
   BEGIN
	T  := TypePtr(PtrAdjust(U,UsrDE));	{to Object TD}
	D  := Nil;
	IF T^.tpTC = $03 THEN
	BEGIN
	   D  := DNamePtr(PtrAdjust(U,T^.ObjtName)); {to Object DE}
	   NameOfObject := D^.Dsymb
	END
   END
END;  {NameOfObject}

PROCEDURE CSegHeadings; Far;					{.CP45}
BEGIN
   SetCol(7);
   PutTxt('Entry  Turbo Segmt FixUp Trace : Source File   Load [Fix-Ups]');
   SetCol(7);
   PutTxt('Offset Work? Bytes Bytes Entry : For CODE Seg  ADDR 1''st last');
   SetCol(7);
   PutTxt('------ ----- ----- ----- ----- : ------------  ---- ---- ----');
END; {CSegHeadings}

PROCEDURE FormatCSegMap(UPt:UnitPtr);				{.CP35}

VAR	C : CMapTabPtr; SF : SrcFilePtr;
	OldTabSet, Base, Cx, NMapC : Word;
BEGIN
	NoteBegin('Formatting CSeg Map');
	OldTabSet := TabStop;
	TabStop := 40;
        NMapC := Upt^.UHTMT-Upt^.UHCMT; Cx := 0;

	IF NMapC > 0 THEN	{ make sure CSeg Map non-empty }
	BEGIN
		PrintTitleBlk('CSeg Map Table',7);
		NextLL := Upt^.UHCMT;
		CSegHeadings;  Base := NextLL;
		REPEAT
			PageOverFlow(6,CSegHeadings);
                        FetchMapRef(Map,rCSEG,Cx);
			SF := AddrSrcTabOff(UPt,Map.MapSrc);
			PrintCodeBytes(UPt,8,8,Base,False);
			SetCol(TabStop);
			PutTxt(SF^.SrcName);
			SetCol(TabStop+14);
			PutTxt(HexW(Map.MapLod)+' ');
			IF Map.MapFxJ <> 0 THEN
			BEGIN
				PutTxt(HexW(Map.MapFxI)+' ');
				PutTxt(HexW(Map.MapFxJ));
			END;
			Inc(Cx,SizeOf(CMapRec));
		UNTIL Cx > NMapC-1;
	END;
	TabStop := OldTabSet;
	NoteEnd;
END;  { FormatCSegMap }

PROCEDURE ProcHeadings; Far;                                    {.CP38}
BEGIN
  SetCol(7); PutTxt('Entry  Turbo Turbo CSeg  PROC  : Jump Byte   Name Of');
  SetCol(7); PutTxt('Offset Work? Work? Map^  Ofset : Addr Cnt   Procedure');
  SetCol(7); PutTxt('------ ----- ----- ----- ----- : ---- ----  ----------');
END; {ProcHeadings}

PROCEDURE FormatProcMap(UPt:UnitPtr);	                        {.CP31}
VAR 	Base, I, J, OldTabStop : Word;
BEGIN {FormatProcMap}
	NoteBegin('Formatting PROC Map');
	OldTabStop := TabStop;
	TabStop := 40;
	SetCol(1);
	IF CountPMapSlots(UPt) > 0 THEN  { Make Sure PROC Map not empty }
	BEGIN
		PrintTitleBlk('PROC Map Table',7);
		NextLL := Upt^.UHPMT;
		I := 0; Base := NextLL;
		ProcHeadings;
		REPEAT
			PageOverFlow(3,PROCHeadings);
                        FetchMapRef(Map,rPROC,I);
			PrintCodeBytes(UPt,8,8,Base,False);
			SetCol(TabStop);
			PutTxt(HexW(Map.MapEPT)+' ');
			PutTxt(HexW(Map.MapSiz)+'  ');
			IF I = 0 THEN
				IF Map.MapCSM = $FFFF
				THEN PutTxt('Not Used (No Unit Init Code)')
				ELSE PutTxt('Unit Init Code')
			ELSE PutTxt(NameOfMethod(UPt,Map.MapOwn));
			Inc(I,SizeOf(PMapRec));
		UNTIL NextLL >= Upt^.UHCMT;
	END;
	TabStop := OldTabStop;
	NoteEnd;
END; {FormatProcMap}

PROCEDURE CONSTHeadings; Far;                                   {.CP51}
BEGIN
  SetCol(7); PutTxt('Entry  Turbo Segmt FixUp  VMT  : Load [Fix-Ups]');
  SetCol(7); PutTxt('Offset Work? Bytes Bytes Owner : ADDR 1''st last');
  SetCol(7); PutTxt('------ ----- ----- ----- ----- : ---- ---- ----');
END; {CONSTHeadings}

PROCEDURE FormatTypedConMap(UPt:UnitPtr);			{.CP44}
VAR I, J, K : Integer; Sofs, Base : Word;
BEGIN { FormatTypedConMap }
	NoteBegin('Formatting CONST DSeg Map');
	J := CountDMapSlots(UPt);
	IF J > 0 THEN
	BEGIN
		PrintTitleBlk('CONST DSeg Map Table',7);
		K := TabStop;
		TabStop := 56;
		NextLL := Upt^.UHTMT;
		Base := NextLL; Sofs := 0;
		CONSTHeadings;
		FOR I := 0 TO J-1 DO
		BEGIN
			PageOverFlow(7,ConstHeadings);
                        FetchMapRef(Map,rCONS,Sofs);
			PrintCodeBytes(UPt,8,8,Base,False);
                        PutTxt('  '+HexW(Map.MapLod)+' ');
                        If Map.MapFxJ > 0 Then
                        Begin
                             PutTxt(HexW(Map.MapFxI)+' ');
                             PutTxt(HexW(Map.MapFxJ));
                        End;
			SetCol(TabStop);
			IF (Map.MapTyp = mfTVMT)
			THEN PutTxt('VMT For: '+NameOfObject(UPt,Map.MapOwn)) ELSE
                        Begin
                           PutTxt('From: ');
                           Case Map.MapTyp Of
                             mfXTRN: PutTxt('Linked File');
                             mfINTF: PutTxt('_INTERFACE');
                             mfIMPL: PutTxt('_IMPLEMENTATION');
                             mfNEST: PutTxt('PROC('
                                     +NameOfMethod(Upt,Map.MapOwn)+')');
                             Else    PutTxt('???');
                           End;
                        End;
                        Inc(Sofs,SizeOf(DMapRec));
		END; { FOR }
		TabStop := K;
	END; { IF }
	NoteEnd;
END;  { FormatTypedConMap }

PROCEDURE VARHeadings; Far;                                     {.CP42}
BEGIN
	SetCol(7); PutTxt('Entry  Turbo Segmt Usage Usage');
	SetCol(7); PutTxt('Offset Work? Bytes  ???   ??? ');
	SetCol(7); PutTxt('------ ----- ----- ----- -----');
END; {VARHeadings}

PROCEDURE FormatGlobalVarMap(U : UnitPtr);

VAR Base, Sofs, I : Word; SaveTab : Integer;
BEGIN
	NoteBegin('Formatting Global VAR Map');
	SaveTab := TabStop;
	TabStop := 40;
	IF U^.UHDMT <> U^.UHLDU THEN
	BEGIN
		I := 0;
		PrintTitleBlk('Global VAR DSeg Map Table',5);
		VARHeadings;
		NextLL := U^.UHDMT;
		Base := NextLL;
                Sofs := 0;
		WHILE U^.UHLDU > NextLL DO
		BEGIN
			PageOverFlow(5,VARHeadings);
			PrintCodeBytes(U,8,8,Base,False);
			SetCol(TabStop);
                        FetchMapRef(Map,rVARS,Sofs);
                        PutTxt('From: ');
                        Case Map.MapTyp Of
                          mfXTRN: PutTxt('Linked File');
                          mfINTF: PutTxt('_INTERFACE');
                          mfIMPL: PutTxt('_IMPLEMENTATION');
                          Else    PutTxt('???');
                        End;
                        Inc(Sofs,SizeOf(DMapRec));
			Inc(I);
		END;
	END;
	TabStop := SaveTab;
	NoteEnd;
END; {FormatGlobalVarMap}

PROCEDURE FormatUnitDonorList(U : UnitPtr);			{.CP22}
VAR UCP : UDonorPtr; UNE : LL;
BEGIN
	NoteBegin('Formatting Donor Unit List');
	SetCol(1);
	IF U^.UHLSF <> NextLL THEN
	BEGIN
		PrintTitleBlk('Code/Data Donor Unit List',2);
		UCP := UDonorPtr(PtrAdjust(U,U^.UHLDU));
		WHILE NextLL <> U^.UHLSF DO WITH UCP^ DO BEGIN
			IF LinesRemaining < 2 THEN NewTxtPage;
			UNE := FormLL(U,UCP)+SizeOf(UCP^.UDExxx) + 1 + Ord(UDEnam[0]);
			PrintWd(U,'Offset='+HexW(NextLL-U^.UHLDU)+', TURBO Work?');
			PrintBytes(U,1+Ord(UDEnam[0]),9);
			SetCol(TabStop);
			PutTxt('=''' + UDEnam + '''');
			SetCol(1);
			UCP := UDonorPtr(PtrAdjust(U,UNE));
		END;
	END;
	NoteEnd;
END; {FormatUnitDonorList}

PROCEDURE FormatSourceFileList(U : UnitPtr);                    {.CP52}
VAR S : SrcFilePtr; SLL : LL; StA : String[10]; StW : String[4];
	OldTabStop : Integer;

	PROCEDURE FormatTime(Time : Word);
	VAR I : Integer;
	BEGIN
		Str( Time SHR 11:2,StA);         StA := StA + ':';
		Str((Time AND 2047) SHR 5:2,StW);StA := StA + StW + ':';
		Str((Time AND 31) SHL 1:2,StW);  StA := StA + StW;
		FOR I := 1 TO 7 DO IF StA[I] = ' ' THEN StA[I] := '0';
	END; {FormatTime}

	PROCEDURE FormatDate(Date : Word);
	VAR I : Integer;
	BEGIN
		Str((Date AND 511)SHR 5:2,StA); StA := StA + '/';
		Str( Date AND 31:2,StW);        StA := StA + StW + '/';
		Str((Date SHR 9) + 1980:4,StW); StA := StA + StW;
		FOR I := 1 TO 4 DO IF StA[I] = ' ' THEN StA[I] := '0';
	END; {FormatDate}

BEGIN {FormatSourceFileList}
	NoteBegin('Formatting Source File List');
	OldTabStop := TabStop;
	TabStop := 48;
	PrintTitleBlk('Source File List',5);
	SLL := U^.UHDBT;
	S := SrcFilePtr(PtrAdjust(U,NextLL));
	WHILE SLL <> NextLL DO WITH S^ DO BEGIN
		IF LinesRemaining < 5 THEN NewTxtPage;
		PrintSoloByte(U,'Flag');
		PrintWd(U,'TURBO Work?');
		CASE SrcFlag OF
			$03,$04:         { .PAS OR .INC file }
				BEGIN
					FormatTime(SrcTime); PrintWd(U,'Time-Stamp='+StA);
					FormatDate(SrcDate); PrintWd(U,'Date-Stamp='+StA);
				END
			ELSE    BEGIN
					PrintBytes(U,4,9);SetCol(TabStop);
					PutTxt('NO Time, Date-Stamps');
				END
		END;   { CASE }
		PrintBytes(U,1+Ord(SrcName[0]),13);
		SetCol(TabStop);PutTxt('='''+SrcName+'''');
		SetCol(1);
		S := AddrNxtSrc(U,S);
	END;
	TabStop := OldTabStop;
	NoteEnd;
END; {FormatSourceFileList}

PROCEDURE FormatTraceTable(U : UnitPtr);                        {.CP38}
VAR	T : TraceRecPtr; S,X : String[6]; I,J, Limit : Word;
BEGIN
	NoteBegin('Formatting Trace Table');
	SetCol(1);
	T := AddrTraceTab(U);
	IF T <> Nil THEN
	BEGIN
		Limit := GetTrExecSize(T);
		PrintTitleBlk('Trace Table for Turbo Debugger is Next (LL at 001A)',
				7+(Limit SHR 3));
		WHILE T <> Nil DO WITH T^ DO BEGIN
			Limit := GetTrExecSize(T);
			IF LinesRemaining < (7+Limit SHR 3) THEN NewTxtPage;
			IF TrName <> 0
			THEN PrintLL(U,NameOfMethod(U,TrName))
			ELSE PrintWd(U,'Unit Init Code Block');
			PrintWd(U,'Src File: "' + AddrSrcTabOff(U,TrFill)^.SrcName + '"');
			Str(T^.TrPfx,S);  PrintWd(U,S+' Data bytes precede Code');
			Str(T^.TrBeg,S);  PrintWd(U,'BEGIN Stmt at Line # '+S);
			Str(T^.TrLNos,S); PrintWd(U,S+' Lines of Code to Execute');
			I := 1;
			WHILE I <= Limit DO BEGIN
				J := I + 7;
				IF J > Limit THEN J := Limit;
				Str(I-1+TrBeg,S); Str(J-1+TrBeg,X);
				PrintBytes(U,J+1-I,8);
				SetCol(TabStop);
				PutTxt('Code Bytes in Lines '+S+' Thru '+X);
				NewTxtLine;
				I := J + 1;
			END;
			T := AddrNxtTrace(U,T);
			NewTxtLine;
		END;
	END;
	NoteEnd;
END; {FormatTraceTable}

PROCEDURE FormatEndNonCode(U : UnitPtr);                        {.CP05}
BEGIN
	PrintTitleBlk('End Non-Code Part Of Unit (LL at 001C)',0);
	BoundaryAlign(U);
END; {FormatEndNonCode}

PROCEDURE FormatObjectCode(UH : UnitPtr);			{.CP07}
VAR
   HexOff: Word;  MyFil, MyOrg, MyEnd, MyTrc: LL; SaveTab: Word;
   CMaps, CXs, I, J: Integer; SF: Byte;
   PM: MapRefRec; SP: SrcFilePtr; R: FixUpPtr;

   PROCEDURE DisplayCode(U : UnitPtr; Count: Word;TrcNdx:LL);

	PROCEDURE DisplayCodeLine(VAR P : ObjArg);		{.CP19}
	BEGIN
	   WITH P DO WHILE Lim > 0 DO BEGIN
	      UnAssemble(U,P);
	      NextLL := Locn;
	      PrintOffset(HexOff);
	      SetCol(14);	PutTxt(Code);
	      SetCol(37);	PutTxt(Mnem);
	      SetCol(53);	PutTxt(Opr1);
	      IF Length(Opr2) > 0 THEN PutTxt(','+Opr2);
	      IF Length(Opr3) > 0 THEN
	      BEGIN
	         IF Opr3[1] <> ';' THEN PutTxt(',')
		 		   ELSE PutTxt(' ');
		 PutTxt(Opr3)
	      END;
	      NewTxtLine;
	   END;
	END;	{DisplayCodeLine}

   VAR P: ObjArg; I, J, K, L: Word; Limit, IP: LL;		{.CP42}
       T: TraceRecPtr; S: String[6];
   BEGIN   {DisplayCode}
      IF Count > 0 THEN
      BEGIN
         Limit := Count;
	 IP  := NextLL;
	 P.TCpu := CPUType;
	 T := AddrTraceTab(U);
	 IF (T = Nil) OR (TrcNdx = $FFFF) THEN
	 BEGIN
	    P.Lim := Limit;
	    P.Obj := IP;
	    DisplayCodeLine(P);
	    IP  := P.Obj;
	 END ELSE
	 BEGIN
	    T := Ptr(Seg(T^),Ofs(T^)+TrcNdx);
	    L := T^.TrBeg;
	    K := GetTrExecSize(T);
	    P.Obj := IP;
	    I := 1;
	    WHILE I <= K DO BEGIN
		IF T^.TrExec[I] = $80 THEN Inc(I);
		P.Lim := T^.TrExec[I];
		IF P.Lim > 0 THEN
		BEGIN
		   PutTxt('; ------------> Code From Line: ');
		   Str(L,S);
		   PutTxt(S);
		   IF I = 1 THEN PutTxt('  ("BEGIN" Statement)') ELSE
		   IF I = K THEN PutTxt('  ("END" Statement)');
		   NewTxtLine;
		   DisplayCodeLine(P);
		END;
		Inc(L); Inc(I);
	    END;
	    IP := P.Obj;
	 END;
	 NextLL := IP;
      END;
   END; {DisplayCode}

   PROCEDURE UnAssembleCode(Hash: LL; SF: Byte;			{.CP31}
		      Org, Limit: Word;
   			  TrcNdx: LL; Comment: Boolean; MT:MapFlags);
   VAR Stopper : LL;
   BEGIN
      IF LinesRemaining < 4 THEN NewTxtPage;
      Stopper := Limit-Org;
      IF NextLL > Org THEN Stopper := Limit-NextLL;
      IF (Stopper > 0) THEN
      BEGIN
	IF Comment THEN {Allow Remarks}
	BEGIN
	   SetCol(7); PutTxt('Code For ');
	   IF SF < $05
	   THEN
	     IF (Hash <> $FFFF) AND (Hash <> 0)
	     THEN PutTxt('PROC "'+NameOfMethod(UH,Hash)+'"')
	     ELSE If MT = mfPRUI
	          Then PutTxt('Unit Initialization')
                  Else PutTxt('Implementation PROC')
	   ELSE
	     IF (Hash <> $FFFF) AND (Hash <> 0)
	     THEN PutTxt('PUBLIC "'+NameOfMethod(UH,Hash)+'"')
	     ELSE PutTxt('PRIVATE or Un-named PUBLIC');
	   PutTxt(' starts at '+HexW(NextLL));
	   NewTxtLine;NewTxtLine;
	END;
	IF DisAssembly
	THEN DisplayCode(UH,Stopper,TrcNdx)
	ELSE PrintCodeBytes(UH,Stopper,16,HexOff,True);
	NewTxtLine;NewTxtLine;
      END;
   END;  {UnAssembleCode}

   PROCEDURE UnAssembleData(S: MapRefRec; SF: Byte);		{.CP13}
   BEGIN
     SetCol(7);
     IF SF <> $05
     THEN PutTxt('(Preamble Data Begins at ')
     ELSE PutTxt('(PRIVATE Code or Data Begins at ');
     PutTxt(HexW(NextLL)+')');
     NewTxtLine;NewTxtLine;
     IF SF <> $05
     THEN PrintCodeBytes(UH,S.MapEPT-NextLL,16,HexOff,True)
     ELSE UnAssembleCode(S.MapOwn,SF,NextLL,S.MapEPT,$FFFF,False,S.MapTyp);
     NewTxtLine;NewTxtLine;
   END;  {UnAssembleData}

BEGIN  {FormatObjectCode}                                       {.CP53}
   NoteBegin('Formatting CODE Segments');
   IF UH^.UHCMT < UH^.UHTMT THEN
   BEGIN
      SaveTab := TabStop;
      TabStop := 55;
      R := AddrFixUps(UH);
      PrintTitleBlk('Object Code Begins Here',0);
      CMaps := CountCMapSlots(UH)  *SizeOf(CMapRec);   { Code Segments }
      CXs := (CountPMapSlots(UH)-1)*SizeOf(PMapRec);
      SortProcRefs(CSegOrder);
      FetchMapRef(Map,rPROC,CXs);
      IF (Map.MapEPT = $FFFF)        { remove unused init proc  }
      THEN Dec(CXs,SizeOf(PMapRec));
      I := 0;                        { Track PMRefs Table           }
      J := 0;                        { Track CSeg Map Table     }

      REPEAT
         NewTxtLine;
         FetchMapRef(Map,rCSEG,J);
         FetchMapRef(PM,rPROC,I);
	 WHILE PM.MapCSM < J DO Begin
            Inc(I,SizeOf(PMapRec));
            FetchMapRef(PM,rPROC,I);
         End;
	 MyOrg := Map.MapLod;			{ Segment Load Point }
	 MyEnd := MyOrg + PM.MapSiz;		{ Next Segment Start }
	 MyFil := Map.MapSrc;			{ Segment Source Fil }
	 MyTrc := AddrCMapTab(UH)^[PM.MapCSM DIV SizeOf(CMapRec)].CsegTrc;
	 SP := AddrSrcTabOff(UH,MyFil);
	 PutTxt('----  Code Segment at '+HexW(NextLL)+' Found In "');
	 PutTxt(SP^.SrcName+'"');
	 NewTxtLine; NewTxtLine;
	 HexOff := NextLL;
	 SF := SP^.SrcFlag;
	 IF (PM.MapEPT <> NextLL)
	 THEN UnAssembleData(PM,SF);
	 WHILE (I <= CXs) AND (PM.MapCSM = J) DO BEGIN
         WITH PM DO
	    UnAssembleCode(MapOwn,SF,MapEPT,MapEPT+MapSiz,MyTrc,True,MapTyp);
	    Inc(I,SizeOf(PMapRec));
            FetchMapRef(PM,rPROC,I);
	 END;
	 Inc(J,SizeOf(CMapRec));
      UNTIL (J >= CMaps);

      TabStop := SaveTab;
      SetCol(1);PutTxt('----  END OF ALL OBJECT CODE');
      NewTxtLine;NewTxtLine;
      BoundaryAlign(UH);
   END;
   NoteEnd;
END; {FormatObjectCode}

PROCEDURE FormatDataAreas(UH : UnitPtr);			{.CP44}
VAR	PD : DMapTabPtr; SaveTab : Word; T : TypePtr;
	I, MapEnd,Base : Word; EndLL : LL; S : MapRefRec;
BEGIN
   NoteBegin('Formatting CONST Data Segments');
   SaveTab := TabStop;
   EndLL := NextLL + UH^.UHZDT;
   IF EndLL <> NextLL THEN
   BEGIN
      PrintTitleBlk('CONST Data Segments Follow',5);
      WITH UH^ DO MapEnd := (UHDMT-UHTMT) DIV SizeOf(DMapRec);
      PD := AddrDMapTab(UH);
      FOR I := 0 TO MapEnd-1 DO WITH PD^[I] DO BEGIN
	 NewTxtLine;
	 SetCol(7);
	 IF DSegOwn <> 0 THEN
	 BEGIN
	    T := TypePtr(PtrAdjust(UH,DSegOwn));
	    PutTxt('VMT Template for "');
	    PutTxt(AddrDict(UH,T^.ObjtName)^.DSymb+'"');
	 END ELSE
         Begin
            FetchMapRef(S,rCONS,SizeOf(DMapRec)*I);
            PutTxt('Typed CONST''s From: ');
            Case S.MapTyp Of
               mfXTRN: PutTxt('Linked File');
               mfINTF: PutTxt('_INTERFACE');
               mfIMPL: PutTxt('_IMPLEMENTATION');
               mfNEST: PutTxt('PROC('+NameOfMethod(UH,S.MapOwn)+')');
               Else    PutTxt('???');
            End;
         End;
	 Base := NextLL;
	 SetCol(1);
	 PrintCodeBytes(UH,DSegCnt,16,Base,True);
	 SetCol(1);
      END; {FOR}
      NewTxtLine;PutTxt('----  END OF ALL DATA SEGMENTS');
      NewTxtLine;NewTxtLine;
   END; {IF}
   TabStop := SaveTab;
   BoundaryAlign(UH);
   NoteEnd;
END; {FormatDataAreas}

PROCEDURE FixUpHeadings; Far;					{.CP06}
BEGIN
   SetCol(7); PutTxt('Un Fl  Map  E-Adr Patch : Ptch Type Refers');
   SetCol(7); PutTxt('it ag Ofset Ofset Ofset : Size  Map To Unit');
   SetCol(7); PutTxt('-- -- ----- ----- ----- : ---- ---- --------');
END; {FixUpHeadings}

PROCEDURE FormatFixUpList(UH : UnitPtr);			{.CP02}
TYPE Remark = String[8]; T4 = String[4]; T8 = String[8];

	PROCEDURE FixUpIdentify(	R : FixUpRec;           {.CP17}
				VAR S2, S1 : T4; VAR S3 : T8);
	VAR PU : UDonorPtr;
	BEGIN  {FixUpIdentify}
	   CASE (R.FixFlg SHR 6) AND $3 OF
	   	0: S1 := 'PROC';	1: S1 := 'CSeg';
		2: S1 := 'DATA';	3: S1 := 'CONS';
	   END;
	   CASE (R.FixFlg SHR 4) AND $3 OF
	   	0: S2 := 'WORD';	1: S2 := 'WD+E';
		2: S2 := 'SEG ';	3: S2 := 'FPTR';
	   END;
	   IF (R.FixFlg AND $F) <> 0 THEN
	   BEGIN S1 := '??? ';	S2 := '????';  END;
	   PU := UDonorPtr(PtrAdjust(UH,UH^.UHLDU+R.FixDnr));
	   S3 := PU^.UDENam;
	END;   {FixUpIdentify}

VAR  R: FixUpPtr; T: TypePtr; PU: UDonorPtr; S: MapRefRec;	{.CP47}
     RR: FixUpRecPtr; EndS, EndLL: LL; S1, S2: T4; S3: T8;
     I, J, K, MapEnd: Word; SaveTab: Word; OV: HeadProc;
BEGIN
   NoteBegin('Formatting Fix-Up List');
   SaveTab := TabStop;
   TabStop := 33;
   EndLL := NextLL + UH^.UHZFA;
   IF EndLL <> NextLL THEN WITH UH^ DO
   BEGIN
      PrintTitleBlk('Fix-Up List Follows',7);
      SetCol(1);
      J := 0;
      R := FixUpPtr(PtrAdjust(UH,NextLL));
      IF UHCMT < UHTMT THEN
      BEGIN
         MapEnd := UHTMT-UHCMT; I := 0;
	 While I < MapEnd DO Begin
            FetchMapRef(Map,rCSEG,I);
	    IF Map.MapFxJ <> 0 THEN
	    BEGIN
	       SetCol(1);
	       IF LinesRemaining < 9 THEN NewTxtPage
	       			     ELSE NewTxtLine;
	       SetCol(7);
	       EndS := Map.MapLod;
	       PutTxt('Segment Load Addr = ' + HexW(EndS));
               SetCol(7);
	       EndS := EndS + Map.MapSiz;
	       PutTxt('Fix-Up''s For CSeg Map Entry at ' + HexW(I + UHCMT));
	       SetCol(1);NewTxtLine;
	       FixUpHeadings;
               K := Map.MapFxI;
	       While K <= Map.MapFxJ DO BEGIN
                  RR := PtrAdjust(UH,K);
		  PageOverFlow(2,FixUpHeadings);
		  FixUpIdentify(RR^,S1,S2,S3);
		  PrintBytes(UH,8,8);
		  SetCol(TabStop);   PutTxt(S1);
		  SetCol(TabStop+5); PutTxt(S2);
		  SetCol(TabStop+10);PutTxt(S3);
		  Inc(K,SizeOf(FixUpRec));
	       END; {While}
            End; {IF}
            Inc(I,SizeOf(CMapRec));
	 END;  {While}
      END;   { IF CSeg Map non-Empty }

      IF UHTMT < UHDMT THEN	{DSeg Map non-Empty}		{.CP58}
      BEGIN
	NewTxtLine;NewTxtLine;
	BoundaryAlign(UH);
	K := NextLL;
	MapEnd := UHDMT-UHTMT;
	EndS := 0;
        I := 0;
	While I < MapEnd DO Begin
           FetchMapRef(Map,rCONS,I);
	   IF Map.MapFxJ <> 0 THEN
	   BEGIN
	      SetCol(1);
	      IF LinesRemaining < 9 THEN NewTxtPage
	      			    ELSE NewTxtLine;
	      SetCol(7);
              If Map.MapTyp = mfTVMT
	      THEN PutTxt('VMT Fix-Up''s For: '+NameOfObject(UH,Map.MapOwn))
              Else Begin
                PutTxt('Typed CONST Fix-Up''s for: ');
                Case Map.MapTyp Of
                   mfXTRN: PutTxt('Linked File');
                   mfINTF: PutTxt('_INTERFACE');
                   mfIMPL: PutTxt('_IMPLEMENTATION');
                   mfNEST: PutTxt('PROC('+NameOfMethod(UH,Map.MapOwn)+')');
                   Else    PutTxt('???');
                End {case}
              End;
              NewTxtLine;NewTxtLine;
              EndS := Map.MapLod;
	      PutTxt('Seg Load Addr = ' + HexW(EndS) + ' --');
              Inc(EndS,Map.MapSiz);
	      PutTxt(' CONST DSeg Map Entry at '+ HexW(I+UHTMT));
	      SetCol(1);NewTxtLine;
	      FixUpHeadings;
	      K := Map.MapFxI;
	      WHILE K <= Map.MapFxJ DO BEGIN
	         PageOverFlow(2,FixUpHeadings);
                 RR := PtrAdjust(UH,K);
		 FixUpIdentify(RR^,S1,S2,S3);
		 PrintBytes(UH,8,8);
		 SetCol(TabStop);   PutTxt(S1);
		 SetCol(TabStop+5); PutTxt(S2);
		 SetCol(TabStop+10);PutTxt(S3);
		 Inc(K,SizeOf(FixUpRec));
	      END; {WHILE}
	   END; {If Fixups to print}
           Inc(I,SizeOf(DMapRec));
        End; {While}
      END;   { IF DSeg Map non-Empty }
      NewTxtLine;NewTxtLine;
      PutTxt('----  END OF FIX-UP LIST');
      NewTxtLine;NewTxtLine;
   END;   {IF FixUp List non-Empty}
   TabStop := SaveTab;
   BoundaryAlign(UH);
   NoteEnd;
END; {FormatFixUpList}

PROCEDURE DocumentUnit(P : UnitPtr);				{.CP16}
BEGIN
	FormatHeader(P);
	FormatDictionary(P);		{ PRINT the Dictionary     }
	FormatProcMap(P);               { PRINT the PROC Map       }
	FormatCSegMap(P);               { PRINT the CSeg Map       }
	FormatTypedConMap(P);		{ PRINT the CONST Map      }
	FormatGlobalVarMap(P);		{ PRINT the VAR Map        }
	FormatUnitDonorList(P);		{ PRINT the Donor Unit Tab }
	FormatSourceFileList(P);	{ PRINT the Source Files   }
	FormatTraceTable(P);		{ PRINT the Trace Table    }
	FormatEndNonCode(P);		{ PRINT separator          }
	FormatObjectCode(P);		{ PRINT CODE Segments      }
	FormatDataAreas(P);		{ PRINT CONST Segment Data }
	FormatFixUpList(P);		{ PRINT LINKER FixUp Data  }
END; {DocumentUnit}

VAR i,j : integer; P: UnitPtr; Module: String[8]; c: char;	{.CP50}
    K: LongInt;   NS: String[5];

BEGIN       { Main Program }
	ClrScr;
	Write('Enter Name of Unit to Document: ');ReadLn(Module);
	i := WhereX; j := WhereY;
	REPEAT
		GoToXY(i,j);ClrEol;
		Write('Do You Want Dis-Assembly of Code? [Y|N] ');
		ReadLn(c);
	UNTIL UpCase(c) IN ['Y','N'];
	DisAssembly := UpCase(c) = 'Y';
	i := WhereX; j := WhereY;
        IF DisAssembly Then Begin
	   REPEAT
		GoToXY(i,j);ClrEol;
		Write('What CPU? (0=8086,1=80186,2=80286,3=80386) ');
		ReadLn(c);
	   UNTIL c IN ['0'..'3'];
	   Case C Of '0': CPUType := C086; '1': CPUType := C186;
           	     '2': CPUType := C286; '3': CPUType := C386;
           End; {Case}
        End;
	FOR I := 1 TO Length(Module) DO Module[I] := UpCase(Module[I]);
	TabStop := 36;
	OpenTxt(Module+'.LST',59,80);
        NoteBegin(''); JobTime := NoteTime;
        NoteBegin('Starting Analysis of "'+Module+'"');
        P := AnalyzeUnit(Module,'');
        NoteEnd;
	IF P <> Nil THEN
	BEGIN
		PutTxt('==========================');   NewTxtLine;
		PutTxt('* Analysis of: "'
		+ DNamePtr(PtrAdjust(P,P^.UHUDH))^.DSymb + '"'); NewTxtLine;
		PutTxt('==========================');   NewTxtLine;
		NextLL := 0;
		DocumentUnit(P); NewTxtPage;
	END ELSE
        BEGIN
        	WriteLn;
		WriteLn('Unit "',module,'" Not Found!');
                WriteLn;
        End;

        PutTxt('Heap Utilization Summary');NewTxtLine;
        K := PtrDelta(HeapEnd,HeapOrg);
	Str(K/1024.0:5:1, NS);
        NewTxtLine; PutTxt(NS+' Kb Available at Start');
        K := PtrDelta(_HeapHighWaterMark,_HeapOriginalMark);
	Str(K/1024.0:5:1, NS);
        NewTxtLine; PutTxt(NS+' Kb used during Analyses');
        K := PtrDelta(HeapPtr,HeapOrg);
	Str(K/1024.0:5:1, NS);
        NewTxtLine; PutTxt(NS+' Kb in use during print');
        PurgeAllUnits;
        NewTxtLine; PutTxt('---- End Report');
        NewTxtPage;
	CloseTxt;
        NoteBegin('');
        Write('End of Job');
        NoteTime := JobTime;
        NoteEnd;
END.