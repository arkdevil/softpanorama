{$D+,S+,L+,R-,I+}

UNIT TPU6RPT;

(*****************)
(**) INTERFACE (**)
(*****************)

USES Dos;
CONST
	Ctl_CRLF = ^M^J;	{ "new-line" sequence for MS/PC Dos }
	Ctl_FF   = ^L;		{ "new-page" sequence for MS/PC Dos }

TYPE  FileFlags = (FileActive,FileQuiet,FileFailure);

VAR	LinesRemaining,		{ on current page }
	ColumnsRemaining,	{ on current line }
	ColumnsUsed		{ on current line }
			: LongInt;
	FileStatus 	: FileFlags;

PROCEDURE PutTxt(S : String);
PROCEDURE PutCtl(S : String);
PROCEDURE SetCol(I : Integer);
PROCEDURE NewTxtLine;
PROCEDURE NewTxtPage;
PROCEDURE OpenTxt(S : String; LineMax, ColumnMax : Integer);
PROCEDURE CloseTxt;

(**********************)
(**) IMPLEMENTATION (**)
(**********************)

CONST
	Ctl_EOF  = ^Z;	{ "end-file" sequence for MS/PC Dos }
	Ctl_CR   = ^M;	{ "Carriage-Return"                 }
	Ctl_LF   = ^J;	{ "Line-Feed"                       }

VAR	MaxLinesOnPage,
	MaxColsPerLine,
	CurrentLine,
	CurrentColumn : LongInt;

	NoLineWrap, NoPageBreak : Boolean;

	FileState : FileFlags;
	TextFile  : Text;
        Spaces    : String;

PROCEDURE FeedBack;
BEGIN
	IF NOT (FileState = FileActive) THEN
	BEGIN
		LinesRemaining   := 0;
		ColumnsRemaining := 0;
		ColumnsUsed      := 0;
	END ELSE
	BEGIN
		LinesRemaining   := MaxLinesOnPage + 1 - CurrentLine;
		ColumnsRemaining := MaxColsPerLine + 1 - CurrentColumn;
		ColumnsUsed      := CurrentColumn  - 1;
	END;
	FileStatus := FileState;
END;	{FeedBack}

PROCEDURE PutCR;
BEGIN
	PutCtl(Ctl_CR);
	CurrentColumn := 1;
END;

PROCEDURE PutLF;
BEGIN
	IF NoPageBreak
	THEN PutCtl(Ctl_LF)
	ELSE
		IF CurrentLine = MaxLinesOnPage THEN
		BEGIN
			PutCtl(Ctl_FF);
			CurrentLine := 0
		END
		ELSE    PutCtl(Ctl_LF);

	Inc(CurrentLine);
END;

PROCEDURE PutCRLF;
BEGIN	PutCR;	PutLF;	END;

PROCEDURE PutFF;
BEGIN	PutCtl(Ctl_FF);	CurrentLine := 1;	END;

PROCEDURE PutEOF;
BEGIN	PutCtl(Ctl_EOF);	END;

FUNCTION ScanCtls(S : String):Integer;
LABEL Found;
VAR J : Integer; I, L : Byte;
BEGIN
	J := 0; L := Length(S);
	FOR I := 1 TO L DO
		IF S[I] in [Ctl_EOF,Ctl_FF,Ctl_LF,Ctl_CR]
		THEN BEGIN
			J := I; GOTO Found
		END;
Found:
	ScanCtls := J
END;

PROCEDURE PutTxt(S : String);
VAR CtlPos, Slice : Integer;
BEGIN
	CtlPos := ScanCtls(S);
	WHILE Length(S) > 0 DO BEGIN
		IF CurrentColumn > MaxColsPerLine THEN PutCRLF;
		IF CurrentLine   > MaxLinesOnPage THEN PutFF;
		Slice := Length(S);
		IF CtlPos = 0
		THEN CtlPos := Slice + 1
		ELSE
			IF Slice > CtlPos
			THEN Slice := CtlPos - 1;
		IF Slice > MaxColsPerLine THEN Slice := MaxColsPerLine;
		IF Slice > 0 THEN
		BEGIN
			PutCtl(Copy(S,1,Slice));
			Delete(S,1,Slice);
			CtlPos := CtlPos - Slice;
			CurrentColumn := CurrentColumn + Slice
		END ELSE
		BEGIN
			IF S[1] = Ctl_EOF THEN PutEOF ELSE
			IF S[1] = Ctl_FF  THEN PutFF  ELSE
			IF S[1] = Ctl_LF  THEN PutLF  ELSE
			IF S[1] = Ctl_CR  THEN PutCR;
			Delete(S,1,1);
			IF Length(S) > 0 THEN CtlPos := ScanCtls(S);
		END;
	END; {WHILE}
	FeedBack;
END;

PROCEDURE PutCtl(S : String);
BEGIN
	IF FileState = FileActive THEN
	BEGIN
		{$I-} Write(TextFile,S); {$I+}
		IF IOResult <> 0 THEN CloseTxt
	END;
END;

PROCEDURE NewTxtLine;
BEGIN
	PutCRLF;
	FeedBack;
END;

PROCEDURE NewTxtPage;
BEGIN
	IF CurrentColumn > 1 THEN PutCRLF;
	IF CurrentLine > 1 THEN PutFF;
	FeedBack;
END;

PROCEDURE OpenTxt(S : String; LineMax, ColumnMax : Integer);
BEGIN
	IF FileState = FileActive THEN CloseTxt;

	Assign(TextFile,S);
	NoPageBreak := (LineMax < 1) OR (LineMax > 255);
	IF NoPageBreak
		THEN MaxLinesOnPage := MaxLongInt
		ELSE MaxLinesOnPage := LineMax;
	NoLineWrap  := (ColumnMax < 1) OR (ColumnMax > 255);
	IF NoLineWrap
		THEN MaxColsPerLine := MaxLongInt
		ELSE MaxColsPerLine := ColumnMax;
	CurrentLine    := 1;
	CurrentColumn  := 1;
	FileState      := FileActive;

	{$I-} ReWrite(TextFile); {$I+}

	IF IOResult <> 0 THEN FileState := FileFailure;
	IF FileState = FileFailure
	THEN CloseTxt
	ELSE FeedBack;
END;

PROCEDURE SetCol(I : Integer);
Var J : Integer;
BEGIN
	IF FileState = FileActive THEN
	IF MaxColsPerLine > I   THEN
	BEGIN
		IF CurrentColumn  > I THEN PutCRLF;
                J := I - CurrentColumn;
                IF J < SizeOf(Spaces) THEN
                BEGIN
                   Spaces[0] := Chr(J);
                   PutTxt(Spaces);
                END ELSE
		WHILE CurrentColumn < I DO PutTxt(' ')
	END;
	FeedBack;
END;

PROCEDURE CloseTxt;
BEGIN
	IF FileState = FileActive THEN
	BEGIN
	{	PutEOF; }
		{$I-} Close(TextFile); {$I+}
		MaxLinesOnPage := 0;
		MaxColsPerLine := 0;
		CurrentLine    := 0;
		CurrentColumn  := 0;
		FileState      := FileQuiet;
		NoLineWrap     := True;
		NoPageBreak    := True;
		FeedBack;
	END;
END;

BEGIN	{ UNIT INITIALIZATION CODE }

        FillChar(Spaces,SizeOf(Spaces),' ');
	MaxLinesOnPage := 0;
	MaxColsPerLine := 0;
	CurrentLine    := 0;
	CurrentColumn  := 0;
	FileState      := FileQuiet;
	FeedBack;
END.