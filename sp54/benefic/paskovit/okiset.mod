MODULE OKISet;

FROM	IO	IMPORT	WrStr, WrLn, KeyPressed, RdKey, RdReal, WrCard,
			RdLn;
FROM	Window	IMPORT	FullScreen, GotoXY, CursorOff, TextBackground,
			TextColor, Color, Clear, Open, WinDef, WinType,
			LightGray, Close, White, Black, DirectWrite,
			DelLine, Use, PutOnTop;
IMPORT	FIO;

CONST
	num	= 18;

TYPE
	str	= ARRAY [0..num] OF
		    ARRAY [0..37] OF CHAR;
	cn	= ARRAY [0..6] OF CHAR;
	cont	= ARRAY [0..num] OF cn;
CONST
	t	= str (	'CANCEL - Return to default setting    ',
			'DW     - Double width                 ',
			'UTIL   - Utility mode                 ',
			'NLQ    - Near letter quality          ',
			'PICA   - Pica : 10 CPI                ',
			'ELIT   - Elite : 12 CPI               ',
			'FINE   - Fine : 17 CPI                ',
			'6LPI   - 6 lines per inch             ',
			'7LPI   - 7 lines per inch             ',
			'8LPI   - 8 lines per inch             ',
			'ITA^   - Start Italics                ',
			'ITAv   - Stop Italics                 ',
			'ENH^   - Start Enhanced               ',
			'ENHv   - Stop Enhanced                ',
			'EMP^   - Start Emphasized             ',
			'EMPv   - Stop Emphasized              ',
			'UND^   - Start Underline              ',
			'UNDv   - Stop Underline               ',
			'LFT    - Set left margin :            ');
	can	= CHR (18H);
	us	= CHR (1FH);
	esc	= CHR (1BH);
	rs	= CHR (1EH);
	fs	= CHR (1CH);
	gs	= CHR (1DH);
	z	= CHR (0);
	u	= cont ( cn (can,z,z,z,z,z,z),
			 cn (us,z,z,z,z,z,z),
			 cn (esc,'0',z,z,z,z,z),
			 cn (esc,'1',z,z,z,z,z),
			 cn (rs,z,z,z,z,z,z),
			 cn (fs,z,z,z,z,z,z),
			 cn (gs,z,z,z,z,z,z),
			 cn (esc,'6',z,z,z,z,z),
			 cn (esc,'%','8',')',z,z,z),
			 cn (esc,'8',z,z,z,z,z),
			 cn (esc,'!','/',z,z,z,z),
			 cn (esc,'!','*',z,z,z,z),
			 cn (esc,'H',z,z,z,z,z),
			 cn (esc,'I',z,z,z,z,z),
			 cn (esc,'T',z,z,z,z,z),
			 cn (esc,'I',z,z,z,z,z),
			 cn (esc,'C',z,z,z,z,z),
			 cn (esc,'D',z,z,z,z,z),
			 cn (esc,'%','C',z,z,z,z));
	Wf	= WinDef ( 0,0,79,25,LightGray,Black,
			  FALSE,TRUE,FALSE,FALSE,'      ',Black,Black );
	Wm	= WinDef ( 0,2,36,2,Black,LightGray,
			  FALSE,TRUE,FALSE,FALSE,'      ',Black,Black );
	Ws	= WinDef ( 0,2,36,2,White,Black,
			  FALSE,TRUE,FALSE,FALSE,'      ',Black,Black );

VAR
	i, j, k	: CARDINAL;
	l	: CARDINAL;
	r	: REAL;
	w, ww	: WinDef;
	S1, S3	: WinType;
	S2	: ARRAY [0..num] OF WinType;
	c, ck	: CHAR;
	uv	: cn;

BEGIN
  S1 := Open (Wf); Clear; GotoXY (18, 0);
  WrStr ('SET OPTIONS FOR OKI MICROLINE PRINTER'); WrLn;
  i := 0; j := 0;
  WHILE i <= num DO
    WrLn; WrStr (t[i]); INC (i);
    IF i <= num THEN
      WrStr (t[i]); INC (i);
    END;
  END;
  w := Wm; i := 0;
  LOOP
    S3 := Open (w); DirectWrite (1, 1, ADR (t[i]), 38);
    WHILE ~KeyPressed () DO END;
    REPEAT
      c := RdKey ();
    UNTIL c # CHR (0);
    IF (c = CHR (48H)) OR (c = CHR (4BH)) OR (c = CHR (4DH))
       OR (c = CHR (50H)) OR (c = CHR (0DH)) THEN
      Close (S3);
      IF c = CHR (0DH) THEN
        RdLn;
        ww := Ws; ww.X1 := (i MOD 2) * 38; ww.Y1 := i DIV 2 + 2;
        ww.X2 := ww.X1 + 37; ww.Y2 := ww.Y1;
        S2[j] := Open (ww);
        DirectWrite (1, 1, ADR (t[i]), 38); c := CHR (4DH);
        uv := u[i];
        IF i = num THEN
	  Use (S1); GotoXY (0, 24);
	  WrStr ('Input number position when 10 CPI (REAL) : ');
	  r := RdReal ();
	  k := CARDINAL ((r - 1.0) * 12.0) + 1;
	  GotoXY (0, 24); DelLine;
	  FOR l := 0 TO j DO
	    PutOnTop (S2[l]);
	  END;
          GotoXY (28, 1); WrCard (CARDINAL (r + 0.5), 3);
          uv[3] := CHR ((k DIV 100) + 30H); k := k MOD 100;
          uv[4] := CHR ((k DIV 10) + 30H); k := k MOD 10;
          uv[5] := CHR (k + 30H);
        END;
	FIO.WrStr (4, uv);
        INC (j);
      END;
      IF c = CHR (48H) THEN
	IF i = 0 THEN
	  i := (num DIV 2) * 2;
	ELSIF i = 1 THEN
	  i := num - 1 + (num MOD 2);
	ELSE
	  DEC (i,2);
	END;
      ELSIF c = CHR (4BH) THEN
	IF i < 1 THEN
	  i := num;
	ELSE
	  DEC (i);
	END;
      ELSIF c = CHR (4DH) THEN
	IF i >= num THEN
	  i := 0;
	ELSE
	  INC (i);
	END;
      ELSIF c = CHR (50H) THEN
	IF i >= (num-1) THEN
	  DEC (i,num-1);
	ELSE
	  INC (i,2);
	END;
      END;
      w.X1 := (i MOD 2) * 38; w.Y1 := i DIV 2 + 2;
      w.X2 := w.X1 + 37; w.Y2 := w.Y1;
    ELSE
      EXIT;
    END;
  END;
  Close (S3);
  WHILE j # 0 DO
    DEC (j); Close (S2[j]);
  END;
  Close (S1);
END OKISet.
