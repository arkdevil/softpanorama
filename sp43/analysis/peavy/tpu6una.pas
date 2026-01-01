UNIT TPU6UNA;

(*****************)
(**) INTERFACE (**)             USES TPU6EQU, TPU6AMS;
(*****************)

TYPE
	OprStr = String[32];

	CpuGate = (C086,C186,C286,C386);

	ObjArg =
		RECORD
			Obj  : Word;    { Offset of text to Unassemble }
			Lim  : Word;	{ Max Bytes to Examine  }
			TCpu : CpuGate; { Cpu code to handle }
			Locn : Word;	{ Code Offset }
			Code : OprStr;	{ Object Text in ASCII }
			Mnem : OprStr;	{ Mnemonic(s) in ASCII }
			Opr1 : OprStr;	{ ASCII Operand 1 }
			Opr2 : OprStr;	{ ASCII Operand 2 }
			Opr3 : OprStr;	{ ASCII Operand 3 }
		END;

CONST	SegDBit : Boolean = FALSE; { Assume 16-Bit Addressing }

PROCEDURE UnAssemble(U : UnitPtr; VAR P : ObjArg);

(**********************)
(**) IMPLEMENTATION (**)
(**********************)

TYPE	{ Types Below Used For Quick Classification of Op-Codes }

   Gating =
	(G_RM1,	 G_RM2,	 G_RM3,	 G_RM4,	 G_RM5,
	 G_RM6,	 G_RM7,	 G_RM8,	 G_RM9,		{ modR/M Has op bits }
	 G_Hit,    { defined operation }
	 G_0Fx,    { 0F-type operation }
	 G_387,    { escapes to 80387  }
	 G_Pfx,    { prefix  operation }
	 G_ooo);   { invalid operation }

   Gate_2 =        { 2nd-level gates for G_0Fx Operations }
	(Row_0,
	 Row_2,
	 Row_8,
	 Row_9,
	 Row_A,
	 Row_B,
	 Row_X);   { invalid otherwise }

   TAdr = (Adr16,Adr32);	{16-bit or 32-bit Addressing}
   WBitStatus = (W0,W1);	{W1 = W-bit ON, else W0}
   REGString = String[3];
   TagRec =
	RECORD
		A : Char;	{tells type of operand}
		V : Byte        {gives width/value etc}
	END;
   TagGrp = ARRAY[1..3] OF TagRec;

   CpuVec =
	RECORD
		F,	{Bit Flags for Processing Options}
			{1xxx xxxx = alternate Mnemonic at M+1  }
			{x1xx xxxx = 32-bit if OpSiz Prefix     }
			{xx1x xxxx = 16-bit normally            }
			{xxx1 xxxx = sign-extend immediates     }
			{xxxx 1xxx = Op has modR/M field        }
			{---- -ccc = Cpu Required for Op	}

		M,	{8086  Mnemonic Index}
		T	{Operand Format Index}
							: Byte
	END;

   MpuVec =					{.CP27}
	RECORD
		F,	{ Flag Bits (see below)
			0000 0000 = INVALID operation
			0010 xxxx = Entire modR/M byte defines op-code
			0001 xxxx = modR/M REG field defines op-code

			xxxx 0000 = no explicit operand(s) coded
			xxxx 0001 = operand is "AX"
			xxxx 0010 = operand is "Bcd80"
			xxxx 0011 = operand is "Ea" (no size implied)
			xxxx 0100 = operand is "Ew" (16-bit word)
			xxxx 0101 = operand is "Int16"
			xxxx 0110 = operand is "Int32"
			xxxx 0111 = operand is "Int64"
			xxxx 1000 = operand is "Real32"
			xxxx 1001 = operand is "Real64"
			xxxx 1010 = operand is "Real80"
			xxxx 1011 = operand is "ST(i)"
			xxxx 1100 = operand is "ST(i),ST"
			xxxx 1101 = operand is "ST,ST(i)"
			xxxx 1110 = reserved
			xxxx 1111 = reserved
			}
		M	{ index to mnemonic table }
				: Byte
	END;


   TMrm =
	RECORD
		D,       { Size in Bytes of Displacement Field}
		SIB,     { 1 -> SIB field present, else no SIB}
		rS,      { index to Segment Register String   }
		rB,      { index to  Base   Register String   }
		rX       { index to  Index  Register String   }
			: Byte
	END;

   SibRec =
	RECORD
		D,      { displacement width (bytes) }
		rS,     { default segment register   }
		rB      { default base register      }
			: Byte
	END;

   sxRec =
	RECORD
		rX,  { to index reg name }
		sF   { multiplier; if 0, ss must be too or illegal}
			: Byte
	END;
{$I TPU6UNA.INC}

VAR									{.CP32}
	Is_386Xtnsn,	Is_32BitMax,	Is_16BitMin,	Is_SignXtnd,
	Is_MODrmFld,	HaveSizePfx,	HaveAddrPfx,	HaveMRM,
	HaveSIB,	FetchFailure,	DSiz32,		ASiz32,
	HaveSegPfx,	HaveInstPfx,	HaveMemOprnd	: Boolean;

	CpuAuth		: CpuGate;

	CodeByte,	PfxMax,		OprBytes,	DataByte,
	DLoc,		mrmMOD,		mrmREG,		mrmRM,
	IPfx,		sibSS,		sibNDX,		sibBAS,
	EmuFlag,	SPfx					: Byte;

	BytesFetched,	BytesRemaining,	PrefixBytes,	CodeSeg,
	CodeOfs,	VirtualIP				: Word;

	REGOperand,	REGSeg,		REGBase,
	REGIndex,	REGSegOvr			: REGString;

	EAOperand,	CodeText,	Mnemonic	: OprStr;

	CodeStack	: ARRAY[1..16] OF Byte;
	Opnd 		: ARRAY[1..3]  OF OprStr;
	ActGroup	: CpuVec;
	OpTags		: TagGrp;
	NdxSF		: String[2];

	ByteGate	: Gating;
	AddrMode	: TAdr;
	WBitMode	: WBitStatus;

	{ --------------------------------------------- } {.CP19}
	{ Fetches a Byte and stacks it for Disassembler }
	{ --------------------------------------------- }

FUNCTION FetchByte : Byte;
BEGIN
	FetchFailure := BytesRemaining = 0;
	IF NOT FetchFailure THEN
	BEGIN
		Inc(BytesFetched);
		{$R+}
		CodeStack[BytesFetched] := Mem[CodeSeg:CodeOfs];
		{$R-}
		Dec(BytesRemaining);
		Inc(CodeOfs);
	END;
        FetchByte := CodeStack[BytesFetched]
END;

	{ ----------------------------------------------- } {.CP14}
	{ Undoes the Fetch Byte Process - Pops From Stack }
	{ ----------------------------------------------- }

PROCEDURE UnFetchCodeByte;
BEGIN
	IF BytesFetched > 0 THEN
	BEGIN
		Dec(BytesFetched);
		Inc(BytesRemaining);
		Dec(CodeOfs);
	END
END;

	{ ------------------------------------------------- } {.CP13}
	{ Formats a Sequence of Stacked Bytes as printable  }
	{ Hex in "logical" order - not processor order, and }
	{ appends a Padding String and a Blank		    }
	{ ------------------------------------------------- }

PROCEDURE FormatText(Locn, SLen:Byte; Pad : String);
VAR  W : OprStr; i : Byte;
BEGIN
	W := '';
	FOR i := Locn TO Locn+SLen-1 DO W := HexB(CodeStack[i]) + W;
	CodeText := CodeText + W + Pad + ' ';
END;

	{ ------------------- }	{.CP11}
	{ Unpacks modR/M Byte }
	{ ------------------- }

PROCEDURE UnPackModRM(modRM : Byte);
BEGIN
	HaveMRM := True;
	mrmMOD := (modRM SHR 6) AND $03;
	mrmREG := (modRM SHR 3) AND $07;
	mrmRM  :=  modRM AND $07;
END;

	{ ---------------- } {.CP11}
	{ Unpacks SIB Byte }
	{ ---------------- }

PROCEDURE UnPackSIB(sib : Byte);
BEGIN
	HaveSIB := True;
	sibSS   := (sib SHR 6) AND $03;
	sibNDX  := (sib SHR 3) AND $07;
	sibBAS  :=  sib AND $07;
END;

PROCEDURE MergeActGrp(VAR Z : CpuVec);				{.CP10}
VAR I,J : Byte;
BEGIN
	ActGroup.M := Z.M;
	IF Z.T <> 0 THEN ActGroup.T := Z.T;
	I := ActGroup.F AND $7;
	J := Z.F AND $7;
	IF I < J THEN I := J;
	ActGroup.F := ((ActGroup.F OR Z.F) AND $F8) OR I;
END;

	{ ------------------------------------------------- } {.CP52}
	{ Formats a Sequence of Stacked Bytes as printable  }
	{ Hex in "logical" order - not processor order for  }
	{ use in Operand Expressions.  Lead zero suppressed }
	{ May be SIGNED or UN-SIGNED                        }
	{ ------------------------------------------------- }

PROCEDURE FormatDispl(VAR Sx:OprStr; Locn, SLen:Byte; Signed:Boolean);
TYPE
  MyWord = RECORD
	CASE Byte OF
		0: (Ds : ShortInt);
		1: (Db : Byte);
		2: (Dw : Word);
		3: (Di : Integer);
		4: (Dd : LongInt);
		5: (Dv : ARRAY[1..4] OF Byte);
	END;

VAR	W, X : MyWord; I : Byte; P : ^MyWord; Signit : Char;
BEGIN
	Sx := '';
	IF SLen IN [1,2,4] THEN
	BEGIN
		P := @ CodeStack[Locn];
		W.Dd := 0; X := W;
		WITH P^ DO
		IF Signed THEN
		BEGIN			{ sign extend for next step }
			CASE SLen OF
				1: W.Dd := Ds;
				2: W.Dd := Di;
				4: W.Dd := Dd
			END;
			X.Dd := Abs(W.Dd)
		END ELSE
		BEGIN			{ zero extend for next step }
			CASE SLen OF
				1: W.Dd := Db;
				2: W.Dd := Dw;
				4: W.Dd := Dd
			END;
			X.Dd := W.Dd
		END;
		FOR i := 1 TO SLen DO Sx := HexB(X.Dv[i]) + Sx;
		IF X.Dd <> W.Dd
			THEN Signit := '-'
			ELSE Signit := '+';
		Sx := Sx + 'h';
		IF Signed THEN Sx := Signit + Sx;
	END;
END; {FormatDispl}

	{ ------------------------------------ }  {.CP24}
	{ ERROR - Stacked Code printed as DB's }
	{ ------------------------------------ }

PROCEDURE EmitConstants;
VAR c : Char;
BEGIN
	WHILE BytesFetched > 1 DO UnFetchCodeByte;
	Mnemonic := 'DB';
	CodeText := '';
	HaveInstPfx := False;
	c := Char(CodeStack[1]);
	CodeText := HexB(Byte(c));
	CASE c OF
		' '..'&',
		'('..#$7F:	Opnd[1] := '''' + c + '''';
		ELSE		Opnd[1] := '0' + CodeText + 'h';
	END;
	Opnd[2] := '';
	Opnd[3] := '';
	{ Ready to Build and Print Line }
END;

	{ --------------------- } {.CP08}
	{ Returns Register Name }
	{ --------------------- }

FUNCTION ExtractReg(Am : TAdr; Wbit : WBitStatus; Arg : Byte) : RegString;
BEGIN
	ExtractReg := RegList[RegDecode[Am,Wbit,Arg]]
END;

	{ ----------------------------------- } {.CP12}
	{ Fetches Displacement/Immediate Data }
	{ ----------------------------------- }

FUNCTION FetchDispl(Width:Byte) : Byte; { Index to LSB of Displ }
VAR i, j : Byte;
BEGIN
	FOR i := 1 TO Width DO j := FetchByte;
	IF FetchFailure
		THEN FetchDispl := 0
		ELSE FetchDispl := BytesFetched + 1 - Width;
END;

	{ ------------------------------- } {.CP05}
	{ Decodes and Stacks Prefix Bytes }
	{ ------------------------------- }

PROCEDURE HandlePrefix;

	PROCEDURE StowPrefix;                             {.CP45}
	CONST PfxFlg : ARRAY[1..4] OF CHAR = '>||:';
	VAR PfxCls : 1..4; i : Byte;
	BEGIN
		CASE CodeByte OF
		   $F0,	$F2..$F3:	BEGIN	{LOCK/REPE/REPNE}
						PfxCls := 1;
						IPfx := CodeByte;
						HaveInstPfx := True;
					END;
			$67:		BEGIN   {Address Size Prefix}
						PfxCls := 2;
						ASiz32 := NOT SegDBit;
						HaveAddrPfx := True;
					END;
			$66:		BEGIN   {Operand Size Prefix}
						PfxCls := 3;
						DSiz32 := NOT SegDBit;
						HaveSizePfx := True;
					END;
			$26,$2E,
			$36,$3E:	BEGIN   {Segment Prefix ES,CS,SS,DS}
						PfxCls := 4;
						SPfx := BytesFetched;
						HaveSegPfx := True;
						i := CodeByte SHR 3 AND $03;
						REGSegOvr := RegList[i + 24];
					END;
			$64,$65:	BEGIN   {Segment Prefix FS,GS}
						PfxCls := 4;
						SPfx := BytesFetched;
						HaveSegPfx := True;
						i := CodeByte AND $07;
						REGSegOvr := RegList[i + 24];
					END;
		END;
		IF PfxCls > PfxMax THEN
		BEGIN
			Inc(PrefixBytes);
			PfxMax := PfxCls;
			FormatText(BytesFetched,1,PfxFlg[PfxCls]);
		END ELSE
		BEGIN
			UnFetchCodeByte;   { will fetch again later  }
			EmitConstants;     { emit code stack as DB's }
			PrefixBytes := 0; PfxMax := 0;
			HaveAddrPfx := False; HaveSizePfx := False;
		END;
	END; {StowPrefix}

BEGIN {HandlePrefix}				{.CP05}
	IF NOT FetchFailure THEN
	IF (ActLvl1[CodeByte].F AND $7) > Ord(CpuAuth) THEN
	BEGIN   EmitConstants; ByteGate := G_ooo END ELSE
	BEGIN
		StowPrefix;
		CodeByte := FetchByte;
		IF NOT FetchFailure
			THEN ByteGate := GateLvl1[CodeByte]
			ELSE ByteGate := G_ooo;
	END;
END; {HandlePrefix}

	{ -------------------------------------- } {.CP44}
	{ Interprets modR/M and optional SIB to  }
	{ get operand strings.  Fetches required }
	{ displacement fields if any.		 }
	{ -------------------------------------- }

PROCEDURE DecodeModRM(W :WBitStatus);
VAR wmrm : TMrm; wsib : SibRec; wsx : sxRec; Sx : OprStr;
BEGIN
	IF mrmMOD = 3 THEN EAOperand := ExtractReg(AddrMode,W,mrmRM)
	ELSE
	BEGIN
		wmrm     := MrmTab[AddrMode,mrmMOD,mrmRM];
		IF wmrm.SIB = 1 THEN
		BEGIN
			DataByte := FetchByte;
			FormatText(BytesFetched,1,'');
			UnPackSIB(DataByte);
			wsib := SibTab[mrmMOD,sibBAS];
			wsx  := sxTAB[sibSS,sibNDX];
			wmrm.D := wsib.D;
			wmrm.rS := wsib.rS;
			wmrm.rB := wsib.rB;
			wmrm.rX := wsx.rX;
			IF wsx.SF = 0 THEN
			BEGIN
				NdxSF := '';
				wmrm.rX := 30     { null register string }
			END
			ELSE NdxSF := '*'+Chr(Ord('0')+wsx.SF);
                END;

		DLoc := FetchDispl(wmrm.D);
		FormatText(DLoc,wmrm.D,'');
		FormatDispl(Sx,DLoc,wmrm.D,True);
		REGSeg   := RegList[wmrm.rS];
		REGBase  := RegList[wmrm.rB];
		REGIndex := RegList[wmrm.rX];
		EAOperand := REGBase;
		IF Length(REGIndex) > 0
		THEN EAOperand := EAOperand + '+' + REGIndex + NdxSF;
		IF wmrm.D > 0 THEN  EAOperand := EAOperand + Sx;
	END;
	REGOperand := ExtractReg(AddrMode,W,mrmREG);
END;

	{ ---------------------------------- }			{.CP08}
	{ Main Driver for 80386 Operand Edit }
	{ ---------------------------------- }

PROCEDURE Edit386Ops;
VAR
	OpEdit		: TagRec;	Sx	: OprStr;
	i               : Byte;

	PROCEDURE EditSplRegs(j : Byte); { CRx,DRx,TRx }	{.CP04}
	BEGIN
		Opnd[j] := OpEdit.A + 'R' + Chr(Ord('0')+mrmREG);
	END;

	PROCEDURE EditDblRegs(j : Byte); { EAX..EDI }		{.CP04}
	BEGIN
		Opnd[j] := RegList[16+mrmREG];
	END;

	PROCEDURE EditSegRegs(j : Byte); { ES:..GS: }		{.CP04}
	BEGIN
		Opnd[j] := RegList[24+mrmREG];
	END;

	PROCEDURE EditLiteral(j : Byte); { literal data }	{.CP04}
	BEGIN
		Opnd[j] := RegList[OpEdit.V];
	END;

	PROCEDURE EditGprRegs(j : Byte); { Gb,Gw,Gd,Gv }	{.CP04}
	BEGIN
		Opnd[j] := REGOperand;
	END;

	PROCEDURE EditJmpDspl(j : Byte); { Jb, Jv }		{.CP17}
        TYPE
          MyWord = RECORD
		CASE Byte OF
		0: (Ds : ShortInt);
		1: (Db : Byte);
		2: (Dw : Word);
		3: (Di : Integer);
		4: (Dd : LongInt);
		5: (Dv : ARRAY[1..4] OF Byte);
		END;

	VAR P : ^MyWord; i,k : Byte; l : LongInt;
	BEGIN
		IF RegList[OpEdit.V][1] = 'b' THEN
		BEGIN
			i := FetchDispl(1);
                        FormatText(i,1,'');
			P := @ CodeStack[i];
			l := CodeOfs + P^.Ds;
			P := @l;
			Opnd[j] := 'SHORT ' + HexB(Hi(P^.Dw))+HexB(Lo(P^.Dw))+'h';
		END ELSE
		BEGIN
			IF ASiz32 THEN k := 4 ELSE k := 2;
			i := FetchDispl(k);		{ Displacement }
			FormatText(i,k,'');
                        P := @ CodeStack[i];
                        IF ASiz32
			   THEN l := CodeOfs + P^.Dd
			   ELSE l := CodeOfs + P^.Di;
			P := @l;
			Opnd[j] := 'h';
			FOR i := 1 TO k DO
				Opnd[j] := HexB(P^.Dv[i]) + Opnd[j]
		END;
	END;

	PROCEDURE EditPointer(j : Byte); { Ap }			{.CP13}
	VAR i,k : Byte;
	BEGIN
		IF ASiz32 THEN k := 4 ELSE k := 2;
		i := FetchDispl(k);			{ Displacement }
		FormatText(i,k,'r');
		FormatDispl(Sx,i,k,False);
		k := 2;
		i := FetchDispl(k);			{ Selector }
		FormatText(i,k,'s');
		FormatDispl(Opnd[j],i,k,False);
		Opnd[j] := Opnd[j] + ':' + Sx;
	END;

	PROCEDURE EditImmData(j : Byte);  { Ib, Iv, Iw }	{.CP17}
	VAR i,k : Byte;
	BEGIN
		CASE RegList[OpEdit.V][1] OF
			'b':	k := 1;
			'w':	k := 2;
			'v':	IF DSiz32 THEN k := 4 ELSE k := 2;
			ELSE	k := 0
		END; {CASE}
		IF k > 0 THEN
		BEGIN
			i := FetchDispl(k);
			FormatText(i,k,'');
			FormatDispl(Sx,i,k,Is_SignXtnd);
			Opnd[j] := Sx;
		END;
	END;

	PROCEDURE EditMemAddr(j : Byte);			{.CP04}
	BEGIN
		Opnd[j] := '';
		IF HaveSegPfx   THEN Opnd[j] := REGSegOvr + ': ';
		Opnd[j] := '['+ Opnd[j] + EAOperand + ']';
		HaveMemOprnd := True;
	END;

	PROCEDURE EditOfsDspl(j : Byte); { Ob, Ov }		{.CP16}
	VAR i,k : Byte;
	BEGIN
		CASE RegList[OpEdit.V][1] OF
			'b':	k := 2;
			'v':	IF ASiz32 THEN k := 4 ELSE k := 2;
			ELSE	k := 0
		END; {CASE}
		IF k > 0 THEN
		BEGIN
			i := FetchDispl(k);		{ Offset }
			FormatText(i,k,'');
			FormatDispl(Sx,i,k,False);
			IF HaveSegPfx AND (mrmMOD <> 3)
				THEN Sx := REGSegOvr + ': ' + Sx;
			Opnd[j] := '[' + Sx + ']';
			HaveMemOprnd := True;
		END;
	END;

	PROCEDURE EditEffAddr(j : Byte); { Eb, Ew, Ev, Ep }	{.CP22}
	BEGIN
		Sx := '';
		IF mrmMOD <> 3 THEN
		IF j = 1 THEN
		CASE RegList[OpEdit.V][1] OF
			'b':	Sx := 'BYTE';
			'w':	Sx := 'WORD';
			'v':	IF DSiz32
				THEN Sx := 'DWORD'
				ELSE Sx := 'WORD';
			'p':	IF ASiz32
				THEN Sx := 'FWORD'
				ELSE Sx := 'DWORD';
			'q':	Sx := 'QWORD';
			't':	Sx := 'TBYTE';
			'd':	Sx := 'DWORD';
		END; {CASE}
		IF Sx <> '' THEN Sx := Sx + ' PTR ';
		IF HaveSegPfx AND (mrmMOD <> 3)
			THEN Sx := REGSegOvr + ': ' + Sx;
		Opnd[j] := Sx + EAOperand;
		IF mrmMOD <> 3
		THEN BEGIN
			Opnd[j] := '[' + Opnd[j] + ']';
			HaveMemOprnd := True;
		     END;
	END;

	PROCEDURE EditVarRegs(j : Byte); { eAX..eDI }		{.CP04}
	BEGIN
		Opnd[j] := RegList[OpEdit.V+(Ord(DSiz32) SHL 3)];
	END;

BEGIN   {Edit386Ops}                                    	{.CP22}

	FOR i := 1 TO 3 DO BEGIN
		OpEdit := OpTags[i];
		Opnd[i] := '';
		CASE OpEdit.A OF
			'C',
			'D',
			'T':	EditSplRegs(i);
			'A':	EditPointer(i);
			'R':	EditDblRegs(i);
			'S':	EditSegRegs(i);
			'G':	EditGprRegs(i);
			'J':	EditJmpDspl(i);
			'I':	EditImmData(i);
			'M':	EditMemAddr(i);
			'O':	EditOfsDspl(i);
			'E':	EditEffAddr(i);
			'e':	EditVarRegs(i);
			'r':	EditLiteral(i);
		END; {CASE}
	END;
END; {Edit386Ops}

PROCEDURE RemovePrefix;
BEGIN
	WHILE BytesFetched > SPfx DO UnFetchCodeByte;
	IF SPfx <> 1 THEN
	BEGIN
		UnFetchCodeByte;
		EmitConstants;
	END ELSE
	BEGIN
		CodeByte := CodeStack[SPfx];
		CodeText := '';
		FormatText(SPfx,1,'');
		ActGroup := ActLvl1[CodeByte];
		Opnd[1] := '';
		Opnd[2] := '';
		Opnd[3] := '';
		Mnemonic := Mnem386[ActGroup.M];
	END;
END;

	{ ---------------------------------- } {.CP05}
	{ Main Driver for 80386 Instructions }
	{ ---------------------------------- }

PROCEDURE Handle386Op;
VAR i : Byte; OGate : Gating;

	PROCEDURE UpdateTags(n : Byte);
	VAR i : Byte;
	BEGIN
	  FOR i := 1 TO 3 DO
		IF OpType386[n,i].A <> ' ' THEN OpTags[i] := OpType386[n,i];
	END;

	PROCEDURE HandleOpMRM; 				{.CP17}
	BEGIN
		DataByte := FetchByte;
		IF NOT FetchFailure THEN
		BEGIN
			FormatText(BytesFetched,1,'');
			UnPackModRM(DataByte);
			OGate := ByteGate;
			ByteGate := GateLvl3[ByteGate,mrmREG];
			IF ByteGate = G_Hit THEN
			BEGIN
				MergeActGrp(ActLvl3[OGate,mrmREG]);
				UpdateTags(ActGroup.T);
			END;
		END;
	END; {HandleOpMRM}

	PROCEDURE HandleOp0Fx;          		{.CP19}
	VAR RowNdx : Gate_2; ColNdx : $0..$F;
	BEGIN
		CodeByte := FetchByte;
		IF NOT FetchFailure THEN
		BEGIN
			FormatText(BytesFetched,1,'');
			RowNdx := GateLvX2[(CodeByte SHR 4) AND $0F];
			ColNdx := CodeByte AND $0F;
			ByteGate := GateLvl2[RowNdx,ColNdx];
			CASE ByteGate OF
			   G_Hit: BEGIN
					MergeActGrp(ActLvl2[RowNdx,ColNdx]);
					UpdateTags(ActGroup.T);
				  END;
			   G_RM6..G_RM8: HandleOpMRM;
			END; {CASE}
		END;
	END; {HandleOp0FX}

BEGIN  {Handle386Op}				{.CP34}
	FormatText(BytesFetched,1,'');
	WITH ActLvl1[CodeByte] DO BEGIN
		ActGroup.F := F;
		ActGroup.M := M;
		ActGroup.T := T;
		OpTags := OpType386[ActGroup.T];
	END;
	Case ByteGate OF
		G_RM1..G_RM9:	HandleOpMRM;
		G_0Fx:		HandleOp0Fx;
		G_Hit:;
	END;
	IF (ActGroup.F AND $7) > Ord(CpuAuth) THEN ByteGate := G_ooo;
	IF NOT FetchFailure AND (ByteGate <> G_ooo) THEN
	BEGIN
		Is_386Xtnsn := (ActGroup.F AND _386Xtnsn) = _386Xtnsn;
		Is_32BitMax := (ActGroup.F AND _32BitMax) = _32BitMax;
		Is_16BitMin := (ActGroup.F AND _16BitMin) = _16BitMin;
		Is_SignXtnd := (ActGroup.F AND _SignXtnd) = _SignXtnd;
		Is_MODrmFld := (ActGroup.F AND _MODrmFld) = _MODrmFld;
		IF Is_MODrmFld AND NOT HaveMRM THEN
		BEGIN
			CodeByte := FetchByte;
			IF NOT FetchFailure THEN UnPackModRM(CodeByte);
			FormatText(BytesFetched,1,'');
		END;
		IF Is_32BitMax OR Is_16BitMin THEN WBitMode := W1;
	END;
	IF FetchFailure OR (ByteGate = G_ooo) OR (ActGroup.M = 0)
	THEN EmitConstants ELSE
	BEGIN
		IF DSiz32 AND Is_386Xtnsn
			THEN Mnemonic := Mnem386[ActGroup.M+1]
			ELSE Mnemonic := Mnem386[ActGroup.M];
		IF HaveMRM THEN DecodeModRM(WBitMode);
		Edit386Ops;
		IF HaveSegPfx AND (NOT HaveMemOprnd)
		THEN RemovePrefix ELSE
		BEGIN
			EmuFlag := 0;
			IF (BytesFetched = 2) AND (CodeStack[1] = $CD) THEN
				CASE CodeStack[2] OF
					$34..$3B,
					$3E: BEGIN
						EmuFlag := CodeStack[2];
						Opnd[3] := '; F-P Emulator Linkage';
					     END;
					$3C: BEGIN
						EmuFlag := CodeStack[2];
						Opnd[3] := '; Emulated SEG Prefix';
					     END;
					$3D: Opnd[3] := '; Emulated FWAIT ';
				END;
		END;
		{ emit instruction }
	END;
END; {Handle386Op}

	{ ----------------------------------------- }		{.CP50}
	{ Main driver for Co-Processor Instructions }
	{ ----------------------------------------- }

PROCEDURE Handle387Op(Emulation : Boolean);
CONST T : ARRAY[2..10] OF Byte = (41,37,39,39,35,40,35,40,41);
VAR esc,flaga,flagop :byte; MpuAux : MpuVec;
    stkr : char;

BEGIN
	esc := CodeByte AND $07;
	IF NOT Emulation THEN FormatText(BytesFetched,1,'');
	CodeByte := FetchByte;
	IF NOT FetchFailure THEN UnPackModRM(CodeByte);
	FormatText(BytesFetched,1,'');
	IF mrmMOD = 3 THEN
	BEGIN
		MpuAux   := MpuM11[esc,mrmREG];    {flags,link}
		MpuAux.M := MpuOv[MpuAux.M,mrmRM]  { mnemonic }
	END
	ELSE
		MpuAux   := MpuEA[esc,mrmREG];     {flags,mnemonic}

	flaga  := MpuAux.F SHR 4;
	IF flaga = 0 THEN EmitConstants ELSE
	BEGIN
		flagop := MpuAux.F AND $0F;
		stkr   := Chr(Ord('0')+mrmRM);
		CASE flagop OF
			 0:     Opnd[1] := '';
			 1:     Opnd[1] := 'AX';
		     2..10: 	BEGIN
					DecodeModRM(W0);
					OpTags := OpType386[96];
					OpTags[1].V := T[flagop];
					Edit386Ops;
				END;
			11:     Opnd[1] := 'ST('+stkr+')';
			12:     Opnd[1] := 'ST('+stkr+'),ST';
			13:     Opnd[1] := 'ST,ST('+stkr+')';
		END;
		Mnemonic := Mnem387[MpuAux.M];
		Opnd[2] := '';
		Opnd[3] := '';
		{ Emit Instruction Here }
	END;
END; {Handle387Op}

	{ ----------------------------------------- } 	{.CP17}
	{ Main Driver for ALL Instruction Sequences }
	{ ----------------------------------------- }

PROCEDURE HandleInstruction;
BEGIN
	ByteGate := GateLvl1[CodeByte];
	WHILE ByteGate = G_Pfx DO HandlePrefix;
	IF ASiz32 THEN AddrMode := Adr32 ELSE AddrMode := Adr16;
	IF NOT FetchFailure	THEN
		CASE ByteGate OF
			G_RM1..G_0Fx:	Handle386Op;  {Get Op and modR/M}
			G_387: 		Handle387Op(False); { Ndp Ops   }
			ELSE		EmitConstants {Invalid Op Codes }
		END;
END;

	{ -------------------------------- }		{.CP34}
	{ Initialize for Instruction Fetch }
	{ -------------------------------- }

PROCEDURE StartOpFetch; { Initializes for next Instruction }
BEGIN
	Is_386Xtnsn	:= False;	Is_32BitMax	:= False;
	Is_16BitMin	:= False;	Is_SignXtnd 	:= False;
	Is_MODrmFld 	:= False;
	HaveSizePfx	:= False;	HaveAddrPfx 	:= False;
	HaveMRM     	:= False;	HaveSIB		:= False;
	FetchFailure	:= False;       HaveMemOprnd	:= False;
	HaveInstPfx	:= False;	HaveSegPfx	:= False;
	ASiz32		:= SegDBit;	DSiz32		:= SegDBit;

	CodeByte	:= 0;		OprBytes	:= 0;
	BytesFetched	:= 0;		mrmMOD		:= 0;
	mrmREG		:= 0;		mrmRM		:= 0;
	sibSS		:= 0;		sibNDX		:= 0;
	sibBAS		:= 0;		PfxMax      	:= 0;
	PrefixBytes	:= 0;		DLoc		:= 0;
	SPfx		:= 0;

	CodeText	:= '';		NdxSF		:= '';
	EAOperand	:= '';		REGSeg		:= '';
	REGBase		:= '';		REGIndex	:= '';
	REGOperand	:= '';		REGSegOvr	:= '';

	WBitMode	:= W0;		AddrMode	:= Adr16;
	ActGroup.F	:= 0;		ActGroup.M	:= 0;
	ActGroup.T	:= 0;           VirtualIP	:= CodeOfs;

	CodeByte := FetchByte;
END;

	{ ------------------------------------- }	{.CP11}
	{ Prototype For Disassembly of One Line }
	{ ------------------------------------- }

PROCEDURE DisassembleLine;
BEGIN
	StartOpFetch;
	CASE EmuFlag OF           {Handle Turbo F-P Emulator Expansions}
		$34..$3B : BEGIN
				UnFetchCodeByte;
				CodeByte := EmuFlag + $A4;
				Handle387Op(True);
				Mnemonic := 'EMU_'+Mnemonic;
				EmuFlag := 0;
				Opnd[3] := '; Emulated Operation';
			   END;
		$3C:	   BEGIN
				HaveSegPfx := True;
				REGSegOvr := RegList[24+(CodeByte SHR 6 XOR 3)];
				Handle387Op(False);
				Mnemonic := 'EMU_'+Mnemonic;
				EmuFlag := 0;
				Opnd[3] := '; Emulated Operation';
			   END;
		$3E:	   BEGIN  { DB xxH for parameters }
				EmitConstants;
				Opnd[3] := '; Fast Path Emulations ';
				EmuFlag := 0;
			   END;
		ELSE BEGIN
			HandleInstruction;
			IF HaveInstPfx
			THEN
			  Mnemonic := Mnem386[ActLvl1[IPfx].M] + ' ' + Mnemonic;
		     END
	END; {CASE}
END;

PROCEDURE UnAssemble(U : UnitPtr; VAR P : ObjArg);
BEGIN
	WITH P DO BEGIN
		IF NOT (TCpu IN [C086..C386]) THEN TCpu := C086;
		CpuAuth := TCpu;
		CodeSeg := Seg(BufPtr(U)^.BufByt[Obj]);
		CodeOfs := Ofs(BufPtr(U)^.BufByt[Obj]);
		BytesRemaining := Lim;
		VirtualIP := Obj;
		Locn := 0;
		Code := '';
		Mnem := '';
		Opr1 := '';
		Opr2 := '';
		Opr3 := '';
	END;
	DisAssembleLine;
	WITH P DO BEGIN
		Obj  := Obj+BytesFetched;
		Lim  := BytesRemaining;
		Code := CodeText;
		Mnem := Mnemonic;
		Opr1 := Opnd[1];
		Opr2 := Opnd[2];
		Opr3 := Opnd[3];
		Locn := VirtualIP;
	END;
END;
BEGIN
	EmuFlag := $0;	{No Borland/Microsoft F-P Emulator in Progress}
END.
