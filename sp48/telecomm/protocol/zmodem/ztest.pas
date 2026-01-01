PROGRAM ZTest;

  USES Crt,
       SeriellInterface,TransData,Tpz;

  VAR
    TimeCounter  : LONGINT ABSOLUTE $40:$6C;

    send,
    fehler       : BOOLEAN;

    i,
    errnr,
    kanal        : WORD;

    zeile,
    fname        : STRING;

    taste        : CHAR;

    time,
    baudrate,
    transferrate : LONGINT;


(*************************************************************************)

FUNCTION WordToString (wert,stellen : WORD) : STRING;

  VAR
    i    : WORD;

    line : STRING [10];

BEGIN
  Str (wert:stellen,line);
  FOR i:=1 TO Length (line) DO IF (line[i] = ' ') THEN line [i]:='0';
  WordToString:=line;
END;  (* of WordToString *)


(*************************************************************************)

FUNCTION LongIntToString (wert : LONGINT ; stellen : WORD) : STRING;

  VAR
    i    : WORD;

    line : STRING [10];

BEGIN
  Str (wert:stellen,line);
  FOR i:=1 TO Length (line) DO IF (line[i] = ' ') THEN line [i]:='0';
  LongIntToString:=line;
END;  (* of WordToString *)


(*************************************************************************)

{$F+}
PROCEDURE DisplayFileData;

BEGIN
  HighVideo;
  GotoXY (20,1);
  Write (TransferName);

  CASE FileAddition OF
        NewFile : Write (' (New)');
    ReplaceFile : Write (' (Replace)');
    RecoverFile : Write (' (Recover)');
  END;  (* of CASE *)

  ClrEol;

  GotoXY (20,3);
  Write (TransferCheck);
  GotoXY (20,4);
  Write (WordToString (TransferTotalTime DIV 60,2));
  Write (':');
  Write (WordToString (TransferTotalTime MOD 60,2));
  GotoXY (20,5);
  Write ('00:00');
  GotoXY (20,6);
  Write (TransferError:5);
  GotoXY (40,5);
  Write (TransferSize:7);
  GotoXY (40,6);
  Write (TransferCount + TransferBytes:7);
  IF (Length (TransferMessage) > 0) THEN BEGIN
    GotoXY (10,8);
    ClrEol;
    Write (TransferMessage);
    TransferMessage:='';
  END;  (* of IF *)
  LowVideo;
END;  (* of DisplayTransferData *)
{$F-}


(*************************************************************************)

{$F+}
PROCEDURE DisplayTransferData;

  VAR
    p,
    rate : WORD;

    time : LONGINT;

BEGIN
  time:=(TimeCounter - TransferTime) DIV 18;

  IF (time > 0) THEN
    rate:=WORD (TransferBytes DIV time)
  ELSE rate:=0;

  p:=WORD (LONGINT (rate) * 100 DIV LONGINT (transferrate DIV 10));
  IF (p > 9999) THEN p:=9999;

  HighVideo;
  GotoXY (20,5);
  Write (WordToString (time DIV 60,2));
  Write (':');
  Write (WordToString (time MOD 60,2));
  GotoXY (20,6);
  Write (TransferError:5);
  GotoXY (42,3);
  Write (TransferBlockSize:5);
  GotoXY (42,4);
  Write (rate:5);
  GotoXY (50,4);
  Write (p:4);
  GotoXY (40,6);
  Write (TransferCount + TransferBytes:7);
  IF (Length (TransferMessage) > 0) THEN BEGIN
    GotoXY (10,8);
    ClrEol;
    Write (TransferMessage);
    TransferMessage:='';
  END;  (* of IF *)
  LowVideo;
END;  (* of DisplayTransferData *)
{$F-}


(*************************************************************************)

BEGIN
  baudrate:=38400;
  MakeCRC32:=FALSE;
  ClrScr;
  InstallSeriellHandler ($3F8,4,2048,kanal);
  IF (kanal <> 0) THEN BEGIN
    SetParameter (kanal,baudrate,None,1,8);

    DataTerminalReady (kanal,On);
    RequestToSend (kanal,On);

    SetTransmitMask (kanal,RTSOutput);
    SetStatusMask (kanal,CTSInput);

    Write ('S)enden  E)mpfangen  ... ');
    REPEAT
      taste:=UpCase (ReadKey);
    UNTIL (taste = 'E') OR (taste = 'S') OR (taste = #27);

    IF (taste <> #27) THEN BEGIN
      WriteLn (taste);
      IF (taste = 'S') THEN send:=TRUE ELSE send:=FALSE;

      IF send THEN BEGIN
        Write ('Filename ...  ');
        ReadLn (fname);
      END;  (* of IF *)

      transferrate:=baudrate;

      HighVideo;
      zeile:='';
      FOR i:=1 TO 41 DO zeile:=zeile + '═';
      GotoXY (10,10);
      IF send THEN
        Write ('╔' + zeile + ' Download  ZModem ' + '═╗')
      ELSE Write ('╔' + zeile + ' Upload  ZModem ' + '═══╗');
      GotoXY (10,19);
      Write ('╚' + '═══════════════════' + zeile + '╝');
      FOR i:=1 TO 8 DO BEGIN
        GotoXY (10,10 + i);
        Write ('║');
        GotoXY (71,10 + i);
        Write ('║');
      END;  (* of FOR *)
      zeile:='╟';
      FOR i:=1 TO 60 DO zeile:=zeile + '─';
      zeile:=zeile + '╢';
      GotoXY (10,12);
      Write (zeile);
      GotoXY (10,17);
      Write (zeile);
      LowVideo;

      Window (11,11,70,19);

      GotoXY (10,1);
      Write ('File .... ');
      IF send THEN BEGIN
        HighVideo;
        Write (fname);
        LowVideo;
      END;  (* of IF *)
      GotoXY (10,3);
      Write ('Check....');
      GotoXY (10,4);
      Write ('Time ....');
      GotoXY (10,5);
      Write ('Time ....');
      GotoXY (10,6);
      Write ('Errors ..');
      GotoXY (30,3);
      Write ('Blk-Size ');
      GotoXY (30,4);
      Write ('CPS .....');
      GotoXY (55,4);
      Write ('%');
      GotoXY (30,5);
      Write ('Size ....');
      GotoXY (30,6);
      Write ('Bytes ...');

      IF send THEN BEGIN
        ZmodemSend (fname,transferrate,TRUE,kanal,@DisplayFileData,@DisplayTransferData,errnr);
        fehler:=(errnr = 0);
      END  (* of IF THEN *)
      ELSE ZmodemReceive ('',transferrate,kanal,@DisplayFileData,@DisplayTransferData,fehler);

      Window (1,1,80,25);

      GotoXY (1,20);
      Write (#7);

      taste:=ReadKey;
      IF (taste = #0) AND KeyPressed THEN taste:=ReadKey;

      IF NOT (fehler) THEN Write ('Übertragungsfehler');
      WriteLn;
      WriteLn;
    END;  (* of IF *)
    DeInstallSeriellHandler (kanal);
  END  (* of IF THEN *)
  ELSE WriteLn ('8250 nicht gefunden');
END.
