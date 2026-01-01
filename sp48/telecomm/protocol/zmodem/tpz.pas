UNIT TPZ;

(*                           ZMODEM für Turbo-Pascal                           *)
(*                                                                             *)
(*                       Copywrite (c) by Stefan Graf 1990                     *)
(*                                                                             *)
(* Datenübertragung über die serielle Schnittstelle mit dem ZMODEM-Protokoll.  *)
(* Als Grundlage diente der Sourcecode TPZ.PAS von Philip R. Burn's PIPTERM.   *)
(* Die Unit ist in vielen Teilen überarbeitet und auf hohe Transferraten       *)
(* getrimmt worden.                                                            *)
(* In diversen Test's wurde mit 115200 Baud eine Übertragungsrate von mehr als *)
(* 5 kByte's pro Sekunde erreicht.                                             *)
(*                                                                             *)
(* Das Handling der ser. Schnittstelle erfolgt über die Unit SERIELLINTERFACE. *)
(*                                                                             *)
(* Die Transferroutinen erzeugen selber keinerlei Statusmeldungen. Diese über- *)
(* nehmen zwei, vom Benutzter zu erstellende parameterlose PROCEDUREN, die     *)
(* den aktuellen Status des Transfer's ausgeben. Diese Daten werden in der     *)
(* Variablen der Unit TRANSDATA abgelegt.                                      *)

INTERFACE

  CONST
    ProgramVersion = '2.22ß';


  VAR
    MakeCRC32,               (* TRUE, wenn 32-Bit-CRC benutzt werden darf  *)
    RecoverAllow : BOOLEAN;  (* TRUE, wenn das File-Recover zugelassen ist *)

(* Empfangen eines File mit dem ZMODEM-Protokoll *)

PROCEDURE ZmodemReceive (    path       : STRING;     (* Path für das File                      *)
                             baudrate   : LONGINT;    (* Aktuelle Baudrate auf der Telefonseite *)
                             kanal      : WORD;       (* Handlernummer für SeriellInterface     *)
                             startproc,               (* Adresse der Start-Anzeige-Procedure    *)
                             dispproc   : POINTER;    (* Adresse der Transfer-Anzeige-Procedure *)
                         VAR fehlerflag : BOOLEAN);   (* TRUE, wenn ein Fehler aufgetreten ist  *)

(* Senden eines Files mit dem ZMODEM-Protokoll *)

PROCEDURE ZmodemSend    (    pathname   : STRING;     (* Path und Filename                      *)
                             baudrate   : LONGINT;    (* Aktuelle Baudrate auf der Telefonseite *)
                             lastfile   : BOOLEAN;    (* TRUE, wenn keine weitere Übertragung   *)
                             kanal      : WORD;       (* Handlernummer für SeriellInterface     *)
                             startproc,               (* Adresse der Start-Anzeige-Procedure    *)
                             dispproc   : POINTER;    (* Adresse der Transfer-Anzeige-Procedure *)
                         VAR fehler     : WORD);      (* Bei Fehler in der Übertragung <> 0     *)


IMPLEMENTATION

  USES Crt,Dos,SeriellInterface,TransData,TPZFiles,TPZunix,TPZcrc;

CONST
   ZBUFSIZE = 1024;

   zbaud: LONGINT = 0;

   txtimeout = 10 * 18;

TYPE
   hdrtype = ARRAY[0..3] OF BYTE;
   buftype = ARRAY[0..ZBUFSIZE] OF BYTE;

CONST
   ZPAD = 42;  { '*' }
   ZDLE = 24;  { ^X  }
   ZDLEE = 88;
   ZBIN = 65;  { 'A' }
   ZHEX = 66;  { 'B' }
   ZBIN32 = 67;{ 'C' }
   ZRQINIT = 0;
   ZRINIT = 1;
   ZSINIT = 2;
   ZACK = 3;
   ZFILE = 4;
   ZSKIP = 5;
   ZNAK = 6;
   ZABORT = 7;
   ZFIN = 8;
   ZRPOS = 9;
   ZDATA = 10;
   ZEOF = 11;
   ZFERR = 12;
   ZCRC = 13;
   ZCHALLENGE = 14;
   ZCOMPL = 15;
   ZCAN = 16;
   ZFREECNT = 17;
   ZCOMMAND = 18;
   ZSTDERR = 19;
   ZCRCE = 104; { 'h' }
   ZCRCG = 105; { 'i' }
   ZCRCQ = 106; { 'j' }
   ZCRCW = 107; { 'k' }
   ZRUB0 = 108; { 'l' }
   ZRUB1 = 109; { 'm' }
   ZOK = 0;
   ZERROR = -1;
   ZTIMEOUT = -2;
   RCDO = -3;
   FUBAR = -4;
   GOTOR = 256;
   GOTCRCE = 360; { 'h' OR 256 }
   GOTCRCG = 361; { 'i' "   "  }
   GOTCRCQ = 362; { 'j' "   "  }
   GOTCRCW = 363; { 'k' "   "  }
   GOTCAN = 272;  { CAN OR  "  }

{ xmodem paramaters }

CONST
   ENQ = 5;
   CAN = 24;
   XOFF = 19;
   XON = 17;
   SOH = 1;
   STX = 2;
   EOT = 4;
   ACK = 6;
   NAK = 21;
   CPMEOF = 26;

{ byte positions }
CONST
   ZF0 = 3;
   ZF1 = 2;
   ZF2 = 1;
   ZF3 = 0;
   ZP0 = 0;
   ZP1 = 1;
   ZP2 = 2;
   ZP3 = 3;

{ bit masks for ZRINIT }
CONST
   CANFDX = 1;    { can handle full-duplex          (yes for PC's)}
   CANOVIO = 2;   { can overlay disk and serial I/O (ditto)       }
   CANBRK = 4;    { can send a break - True but superfluous       }
   CANCRY = 8;    { can encrypt/decrypt - not defined yet         }
   CANLZW = 16;   { can LZ compress - not defined yet             }
   CANFC32 = 32;  { can use 32 bit crc frame checks - true        }
   ESCALL = 64;   { escapes all control chars. NOT implemented    }
   ESC8 = 128;    { escapes the 8th bit. NOT implemented          }

{ bit masks for ZSINIT }
CONST
   TESCCTL = 64;
   TESC8 = 128;

{ paramaters for ZFILE }
CONST
{ ZF0 }
   ZCBIN = 1;
   ZCNL = 2;
   ZCRESUM = 3;
{ ZF1 }
   ZMNEW = 1;   {I haven't implemented these as of yet - most are}
   ZMCRC = 2;   {superfluous on a BBS - Would be nice from a comm}
   ZMAPND = 3;  {programs' point of view however                 }
   ZMCLOB = 4;
   ZMSPARS = 5;
   ZMDIFF = 6;
   ZMPROT = 7;
{ ZF2 }
   ZTLZW = 1;   {encryption, compression and funny file handling }
   ZTCRYPT = 2; {flags - My docs (03/88) from OMEN say these have}
   ZTRLE = 3;   {not been defined yet                            }
{ ZF3 }
   ZCACK1 = 1;  {God only knows...                               }

VAR
   {$IFDEF TPZLog}                (* Für Testzwecke kann man durch Setzen der    *)
     tpzlog     : FILE OF CHAR;   (* Definition TPZLog ein Protokoll aller ge-   *)
   {$ENDIF}                       (* sendeten und empfangenen Zeichen erzeugten. *)

   TimeCounter  : LONGINT ABSOLUTE $40:$6C;

   modemkanal   : WORD;

   rxpos        : LONGINT; {file position received from Z_GetHeader}
   rxhdr        : hdrtype;    {receive header var}
   rxtimeout,
   rxtype,
   rxframeind   : INTEGER;
   attn         : buftype;
   secbuf       : buftype;
   fname        : STRING;
   fmode        : INTEGER;
   ftime,
   fsize        : LONGINT;
   send32crc    : BOOLEAN;  (* TRUE, wenn 32-Bit-CRC benutzt werden darf *)
   zcps,
   zerrors      : WORD;
   txpos        : LONGINT;
   txhdr        : hdrtype;
   ztime        : LONGINT;

   zstartproc,
   zdispproc    : POINTER;

CONST
   lastsent: BYTE = 0;


(*************************************************************************)

(* Schnelles Aufrufen einer Procedure auf die der POINTER <proc> zeigt *)

PROCEDURE CallUserProcedure (proc : POINTER);

BEGIN
  InLine ($FF/$5E/< proc);
END;


(*************************************************************************)

(* Dem Modem die Empfangsbereitschaft anzeigen. *)
(* Dies geschiet durch Setzen der RTS-Leitung.  *)

Procedure ModemRun (kanal : WORD);

BEGIN
  RequestToSend (kanal,On);
END; (* of ModemRun *)


(*************************************************************************)

(* Dem Modem anzeigen, dass zur zeit keine Zeichen verarbeitet.    *)
(* werden können. Diese geschiet durch Rücksetzen der RTS-Leitung. *)

Procedure ModemStop (kanal : WORD);

BEGIN
  RequestToSend (kanal,Off);
END; (* of ModemStop *)


(*************************************************************************)

(* Berechnen der CRC-Summe eines Files *)

FUNCTION Z_FileCRC32 (VAR f: FILE): LONGINT;

VAR
   fbuf  : buftype;

   crc   : LONGINT;

   n,
   bread : INTEGER;

BEGIN
   crc := $FFFFFFFF;
   Seek(f,0);
   IF (IOresult <> 0) THEN
      {null};
   REPEAT
      BlockRead(f,fbuf,ZBUFSIZE,bread);
      FOR n := 0 TO (bread - 1) DO crc := UpdC32 (fbuf [n],crc)
   UNTIL (bread < ZBUFSIZE) OR (IOresult <> 0);
   Seek(f,0);
   IF (IOresult <> 0) THEN
      {null};
   Z_FileCRC32 := crc
END;


(*************************************************************************)

FUNCTION Z_GetByte (tenths : INTEGER) : INTEGER;

(* Reads a byte from the modem - Returns RCDO if *)
(* no carrier, or ZTIMEOUT if nothing received   *)
(* within 'tenths' of a second.                  *)

  VAR
    c    : INTEGER;

    time : LONGINT;

BEGIN
  IF ReceiverReady (modemkanal) THEN BEGIN
    c := ORD (SeriellRead (modemkanal));
    {$IFDEF TPZLog}
       Write (tpzlog,CHAR (c));
    {$ENDIF}
    Z_GetByte:=c;
  END  (* of IF THEN *)
  ELSE BEGIN
    time:=TimeCounter + tenths;
    REPEAT
      IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
         Z_GetByte := RCDO; { nobody to talk to }
         Exit;
      END  (* of IF THEN *)
      ELSE IF ReceiverReady (modemkanal) THEN BEGIN
         c := ORD (SeriellRead (modemkanal));
         {$IFDEF TPZLog}
           Write (tpzlog,CHAR (c));
         {$ENDIF}
         Z_GetByte:=c;
         Exit;
      END;

    UNTIL (TimeCounter > time);

    Z_GetByte := ZTIMEOUT        { timed out }
  END;  (* of ELSE *)
END;


(*************************************************************************)

FUNCTION Z_qk_read : INTEGER;

(* Just like Z_GetByte, but timeout value is in *)
(* global var rxtimeout.                        *)

  VAR
    stop : BOOLEAN;

    ch   : CHAR;

    c    : INTEGER;

    time : LONGINT;

BEGIN
  IF ReceiverReady (modemkanal) THEN BEGIN
    c:=ORD (SeriellRead (modemkanal));
    {$IFDEF TPZLog}
      Write (tpzlog,CHAR (c));
    {$ENDIF}
    Z_qk_read:=c;
  END  (* of IF THEN *)
  ELSE BEGIN
    time:=TimeCounter + rxtimeout;
    stop:=FALSE;
    REPEAT
      IF ReceiverReady (modemkanal) THEN BEGIN
        ch:=SeriellRead (modemkanal);
        {$IFDEF TPZLog}
          Write (tpzlog,ch);
        {$ENDIF}
        stop:=TRUE;
      END;  (* of IF *)
    UNTIL stop OR (TimeCounter > time) OR NOT (CarrierDetector (modemkanal));

    IF (TimeCounter > time) THEN
      c:=ZTIMEOUT
    ELSE IF NOT (CarrierDetector (modemkanal)) THEN
      c:=RCDO
    ELSE c:=ORD (ch);
    Z_qk_read := c;
  END;  (* of ELSE *)
END;

(*************************************************************************)

FUNCTION Z_TimedRead : INTEGER;

(* A Z_qk_read, that strips parity and *)
(* ignores XON/XOFF characters.        *)

VAR
   stop : BOOLEAN;

   ch   : CHAR;

   c    : INTEGER;

   time : LONGINT;

BEGIN
   time:=TimeCounter + rxtimeout;
   stop:=FALSE;
   REPEAT
     IF ReceiverReady (modemkanal) THEN BEGIN
       ch:=SeriellRead (modemkanal);
       {$IFDEF TPZLog}
         Write (tpzlog,ch);
       {$ENDIF}
       IF (ch <> CHR (XON)) AND (ch <> CHR (XOFF)) THEN stop:=TRUE;
     END;  (* of IF *)
   UNTIL stop OR (TimeCounter > time) OR NOT (CarrierDetector (modemkanal));

   IF (TimeCounter > time) THEN
     c:=ZTIMEOUT
   ELSE IF NOT (CarrierDetector (modemkanal)) THEN
     c:=RCDO
   ELSE c:=ORD (ch);
   Z_TimedRead := c
END;


(*************************************************************************)

(* Senden des Zeichen in <c>.                  *)
(* Es wird gewartet, bis das Modem bereit ist. *)

PROCEDURE Z_SendByte (c : INTEGER);

  VAR
    time : LONGINT;

BEGIN
  IF NOT (SeriellStatus (modemkanal)) THEN BEGIN
    time:=TimeCounter + txtimeout;
    REPEAT
    UNTIL SeriellStatus (modemkanal) OR (TimeCounter > time);
  END;  (* of IF *)

  SeriellWrite (modemkanal,CHAR (c));
END;  (* of Z_SendByte *)


(*************************************************************************)

PROCEDURE Z_SendCan;

(* Send a zmodem CANcel sequence to the other guy *)
(* 8 CANs and 8 backspaces                        *)

  VAR
    n: BYTE;

BEGIN
  ClearSeriellBuffer (modemkanal);
  FOR n := 1 TO 8 DO BEGIN
    Z_SendByte (CAN);
    Delay (100)        { the pause seems to make reception of the sequence }
  END;                 { more reliable                                     }

  FOR n := 1 TO 10 DO Z_SendByte (8)
END;


(*************************************************************************)

PROCEDURE Z_PutString (VAR p: buftype);

(* Outputs an ASCII-Z type string (null terminated) *)
(* Processes meta characters 221 (send break) and   *)
(* 222 (2 second delay).                            *)

  VAR
    n : WORD;

BEGIN
  n := 0;
  WHILE (n < ZBUFSIZE) AND (p [n] <> 0) DO BEGIN
    CASE p [n] OF
       221 : SendBreak (modemkanal);
       222 : Delay (2000)
      ELSE   Z_SendByte (p [n])
    END;
    INC (n)
  END;  (* of WHILE *)
END;  (* of Z_PutString *)


(*************************************************************************)

PROCEDURE Z_PutHex (b: BYTE);

(* Output a byte as two hex digits (in ASCII) *)
(* Uses lower case to avoid confusion with    *)
(* escaped control characters.                *)

CONST
   hex: ARRAY[0..15] OF CHAR = '0123456789abcdef';

BEGIN
   Z_SendByte (ORD (hex[b SHR 4]));  { high nybble }
   Z_SendByte (ORD (hex[b AND $0F])) { low nybble  }
END;

(*************************************************************************)

PROCEDURE Z_SendHexHeader (htype : BYTE ; VAR hdr : hdrtype);

(* Sends a zmodem hex type header *)

VAR
   crc : WORD;
   n,
   i   : INTEGER;

BEGIN
   Z_SendByte (ZPAD);                  { '*' }
   Z_SendByte (ZPAD);                  { '*' }
   Z_SendByte (ZDLE);                  { 24  }
   Z_SendByte (ZHEX);                  { 'B' }
   Z_PutHex (htype);

   crc := UpdCrc(htype,0);

   FOR n := 0 TO 3 DO BEGIN
      Z_PutHex (hdr [n]);
      crc := UpdCrc (hdr [n],crc)
   END;

   crc := UpdCrc (0,crc);
   crc := UpdCrc (0,crc);

   Z_PutHex (Lo (crc SHR 8));
   Z_PutHex (Lo (crc));

   Z_SendByte (13);                    { make it readable to the other end }
   Z_SendByte (10);                    { just in case                      }

   IF (htype <> ZFIN) AND (htype <> ZACK) THEN
      Z_SendByte (17);                 { Prophylactic XON to assure flow   }

END;


(*************************************************************************)

FUNCTION Z_PullLongFromHeader (VAR hdr : hdrtype) : LONGINT;

  TYPE
    longarray = ARRAY [0..3] OF BYTE;

  VAR
    l       : LONGINT;

    longptr : longarray ABSOLUTE l;

BEGIN
   longptr [0]:=hdr [ZP0];
   longptr [1]:=hdr [ZP1];
   longptr [2]:=hdr [ZP2];
   longptr [3]:=hdr [ZP3];

   Z_PullLongFromHeader := l
END;


(*************************************************************************)

PROCEDURE Z_PutLongIntoHeader (l : LONGINT);

  TYPE
    longarray = ARRAY [0..3] OF BYTE;

  VAR
    longptr : longarray ABSOLUTE l;

BEGIN
  txhdr [ZP0]:=longptr [0];
  txhdr [ZP1]:=longptr [1];
  txhdr [ZP2]:=longptr [2];
  txhdr [ZP3]:=longptr [3];
END;


(*************************************************************************)

FUNCTION Z_GetZDL : INTEGER;

(* Gets a byte and processes for ZMODEM escaping or CANcel sequence *)

  VAR
     c,
     d  : INTEGER;

BEGIN
   c := Z_qk_read;
   IF (c <> ZDLE) THEN BEGIN
     Z_GetZDL := c;
   END                                        {got ZDLE or 1st CAN}
   ELSE BEGIN
     c := Z_qk_read;
     IF (c = CAN) THEN BEGIN                  {got 2nd CAN}
       c := Z_qk_read;
       IF (c = CAN) THEN BEGIN                {got 3rd CAN}
         c := Z_qk_read;
         IF (c = CAN) THEN c := Z_qk_read;    {got 4th CAN}
       END;  (* of IF *)
     END;  (* of IF *)
                                              { Flags set in high byte }
     CASE c OF
          CAN : Z_GetZDL := GOTCAN;           {got 5th CAN}
        ZCRCE,                                {got a frame end marker}
        ZCRCG,
        ZCRCQ,
        ZCRCW : Z_GetZDL := (c OR GOTOR);
        ZRUB0 : Z_GetZDL := $007F;            {got an ASCII DELete}
        ZRUB1 : Z_GetZDL := $00FF             {any parity         }
        ELSE BEGIN
           IF (c < 0) THEN
              Z_GetZDL := c
           ELSE IF ((c AND $60) = $40) THEN   {make sure it was a valid escape}
              Z_GetZDL := c XOR $40
           ELSE Z_GetZDL := ZERROR
        END;  (* of ELSE *)
     END;  (* of CASE *)
   END;  (* of ELSE *)
END;


(*************************************************************************)

FUNCTION Z_GetHex: INTEGER;
(* Get a byte that has been received as two ASCII hex digits *)
VAR
   c, n: INTEGER;

BEGIN
   n := Z_TimedRead;
   IF (n < 0) THEN BEGIN
      Z_GetHex := n;
      Exit
   END;
   n := n - $30;                     {build the high nybble}
   IF (n > 9) THEN n := n - 39;
   IF (n AND $FFF0 <> 0) THEN BEGIN
      Z_GetHex := ZERROR;
      Exit
   END;
   c := Z_TimedRead;
   IF (c < 0) THEN BEGIN
      Z_GetHex := c;
      Exit
   END;
   c := c - $30;                     {now the low nybble}
   IF (c > 9) THEN c := c - 39;
   IF (c AND $FFF0 <> 0) THEN BEGIN
      Z_GetHex := ZERROR;
      Exit
   END;
   Z_GetHex := (n SHL 4) OR c        {Insert tab 'A' in slot 'B'...}
END;


(*************************************************************************)

FUNCTION Z_GetHexHeader(VAR hdr: hdrtype): INTEGER;

(* Receives a zmodem hex type header *)

  VAR
    crc : WORD;
    c,
    n   : INTEGER;

BEGIN
   c := Z_GetHex;
   IF (c < 0) THEN BEGIN
      Z_GetHexHeader := c;
      Exit
   END;

   rxtype := c;                        {get the type of header}
   crc := UpdCrc (rxtype,0);

   FOR n := 0 To 3 DO BEGIN            {get the 4 bytes}
      c := Z_GetHex;
      IF (c < 0) THEN BEGIN
         Z_GetHexHeader := c;
         Exit
      END;
      hdr[n] := Lo (c);
      crc := UpdCrc (Lo (c),crc)
   END;

   c := Z_GetHex;
   IF (c < 0) THEN BEGIN
      Z_GetHexHeader := c;
      Exit
   END;
   crc := UpdCrc (Lo (c),crc);

   c := Z_GetHex;
   IF (c < 0) THEN BEGIN
      Z_GetHexHeader := c;
      Exit
   END;
   crc := UpdCrc (Lo (c),crc);             {check the CRC}

   IF (crc <> 0) THEN BEGIN
      INC (TransferError);
      Z_GetHexHeader := ZERROR;
      Exit
   END;

   IF (Z_GetByte (2) = 13) THEN           {throw away CR/LF}
      c := Z_GetByte (2);
   Z_GetHexHeader := rxtype
END;


(*************************************************************************)

FUNCTION Z_GetBinaryHeader (VAR hdr: hdrtype) : INTEGER;

(* Same as above, but binary with 16 bit CRC *)

VAR
   crc : WORD;
   c,
   n   : INTEGER;

BEGIN
   c := Z_GetZDL;
   IF (c < 0) THEN BEGIN
      Z_GetBinaryHeader := c;
      Exit
   END;

   rxtype := c;
   crc := UpdCrc (rxtype,0);

   FOR n := 0 To 3 DO BEGIN
      c := Z_GetZDL;
      IF (Hi(c) <> 0) THEN BEGIN
         Z_GetBinaryHeader := c;
         Exit
      END;
      hdr[n] := Lo (c);
      crc := UpdCrc (Lo (c),crc)
   END;

   c := Z_GetZDL;
   IF (Hi (c) <> 0) THEN BEGIN
      Z_GetBinaryHeader := c;
      Exit
   END;
   crc := UpdCrc(Lo(c),crc);

   c := Z_GetZDL;
   IF (Hi(c) <> 0) THEN BEGIN
      Z_GetBinaryHeader := c;
      Exit
   END;
   crc := UpdCrc(Lo(c),crc);

   IF (crc <> 0) THEN BEGIN
      INC (TransferError);
      Exit
   END;
   Z_GetBinaryHeader := rxtype
END;


(*************************************************************************)

FUNCTION Z_GetBinaryHead32(VAR hdr: hdrtype): INTEGER;
(* Same as above but with 32 bit CRC *)
VAR
   crc: LONGINT;
   c, n: INTEGER;
BEGIN
   c := Z_GetZDL;
   IF (c < 0) THEN BEGIN
      Z_GetBinaryHead32 := c;
      Exit
   END;

   rxtype := c;
   crc := UpdC32 (rxtype,$FFFFFFFF);

   FOR n := 0 To 3 DO BEGIN
      c := Z_GetZDL;
      IF (Hi (c) <> 0) THEN BEGIN
         Z_GetBinaryHead32 := c;
         Exit
      END;
      hdr[n] := Lo (c);
      crc := UpdC32 (Lo (c),crc)
   END;

   FOR n := 0 To 3 DO BEGIN
      c := Z_GetZDL;
      IF (Hi (c) <> 0) THEN BEGIN
         Z_GetBinaryHead32 := c;
         Exit
      END;
      crc := UpdC32 (Lo (c),crc)
   END;

   IF (crc <> $DEBB20E3) THEN BEGIN   {this is the polynomial value}
      INC (TransferError);
      Z_GetBinaryHead32 := ZERROR;
      Exit
   END;

   Z_GetBinaryHead32 := rxtype
END;


(*************************************************************************)

FUNCTION Z_GetHeader (VAR hdr: hdrtype): INTEGER;

(* Use this routine to get a header - it will figure out  *)
(* what type it is getting (hex, bin16 or bin32) and call *)
(* the appropriate routine.                               *)

LABEL
   gotcan, again, agn2, splat, done;  {sorry, but it's actually eisier to}

VAR                                   {follow, and lots more efficient   }
   c, n, cancount: INTEGER;           {this way...                       }

BEGIN
   IF (zbaud > $3FFF) THEN
     n:=$7FFF
   ELSE n := zbaud * 2;               {A guess at the # of garbage characters}

   cancount:= 5;                      {to expect.                            }
   send32crc:=FALSE;                  {assume 16 bit until proven otherwise  }

again:

   IF (KeyPressed) THEN BEGIN                       {check for operator panic}
     IF (ReadKey = #27) THEN BEGIN                  {in the form of ESCape   }
       Z_SendCan;                                   {tell the other end,     }
       TransferMessage:='Cancelled from keyboard';  {the operator,           }
       Z_GetHeader := ZCAN;                         {and the rest of the     }
       Exit                                         {routines to forget it.  }
     END;  (* of IF *)
   END;  (* of IF *)

   rxframeind := 0;
   rxtype := 0;
   c := Z_TimedRead;

   CASE c OF
          ZPAD : {we want this! - all headers begin with '*'.} ;
          RCDO,
      ZTIMEOUT : GOTO done;
           CAN : BEGIN
gotcan:
                   DEC (cancount);
                   IF (cancount < 0) THEN BEGIN
                     c := ZCAN;
                     GOTO done
                   END;
                   c := Z_GetByte (2);
                   CASE c OF
                     ZTIMEOUT : GOTO again;
                        ZCRCW : BEGIN
                                  c := ZERROR;
                                  GOTO done
                                END;
                         RCDO : GOTO done;
                          CAN : BEGIN
                                  DEC (cancount);
                                  IF (cancount < 0) THEN BEGIN
                                    c := ZCAN;
                                    GOTO done
                                  END;
                                  GOTO again
                                END
                         ELSE   {fallthru}
              END {case}
           END {can}
      ELSE
agn2: BEGIN
         DEC (n);
         IF (n < 0) THEN BEGIN
            INC (TransferError);
            TransferMessage:='Header is FUBAR';
            Z_GetHeader := ZERROR;
            Exit
         END;

         IF (c <> CAN) THEN cancount := 5;

         GOTO again
      END
   END;           {only falls thru if ZPAD - anything else is trash}
   cancount := 5;
splat:
   c := Z_TimedRead;
   CASE c OF
          ZDLE : {this is what we want!} ;
          ZPAD : GOTO splat;   {junk or second '*' of a hex header}
          RCDO,
      ZTIMEOUT : GOTO done
          ELSE   GOTO agn2
   END; {only falls thru if ZDLE}
   c := Z_TimedRead;

   CASE c OF
       ZBIN32 : BEGIN
                  rxframeind := ZBIN32;          {using 32 bit CRC}
                  c := Z_GetBinaryHead32 (hdr)
                END;
         ZBIN : BEGIN
                  rxframeind := ZBIN;            {bin with 16 bit CRC}
                  c := Z_GetBinaryHeader (hdr)
                END;
         ZHEX : BEGIN
                  rxframeind := ZHEX;            {hex}
                  c := Z_GetHexHeader (hdr)
                END;
          CAN : GOTO gotcan;
         RCDO,
     ZTIMEOUT : GOTO done
         ELSE   GOTO agn2
   END; {only falls thru if we got ZBIN, ZBIN32 or ZHEX}

   rxpos := Z_PullLongFromHeader (hdr);       {set rxpos just in case this}
done:                                         {header has file position   }
   Z_GetHeader := c                           {info (i.e.: ZRPOS, etc.   )}
END;


(***************************************************)
(* RECEIVE FILE ROUTINES                           *)
(***************************************************)

CONST
   ZATTNLEN = 32;  {max length of attention string}
   lastwritten: BYTE = 0;

VAR
   t           : LONGINT;
   rzbatch     : BOOLEAN;
   outfile     : FILE;     {this is the file}
   tryzhdrtype : BYTE;
   rxcount     : INTEGER;
   filestart   : LONGINT;
   isbinary,
   eofseen     : BOOLEAN;
   zconv       : BYTE;
   zrxpath     : STRING;


(*************************************************************************)

(* Empfangen von Datenblöcken mit 16 o. 32-Bit-CRC *)

FUNCTION RZ_ReceiveData (VAR buf : buftype ; blength : INTEGER) : INTEGER;

  LABEL
    crcfoo;

  VAR
    c,
    d          : INTEGER;

    n,
    crc        : WORD;

    crc32      : LONGINT;

    done,
    badcrc,
    uses32crc  : boolean;

BEGIN
   IF (rxframeind = ZBIN32) THEN BEGIN
     crc32:=$FFFFFFFF;
     uses32crc:=TRUE;
     TransferCheck:='CRC-32';
   END  (* of IF THEN *)
   ELSE BEGIN
     crc:=0;
     uses32crc:=FALSE;
     TransferCheck:='CRC-16';
   END;  (* of ELSE *)

   rxcount := 0;
   done:=FALSE;

   REPEAT
      c := Z_GetZDL;

      IF (Hi (c) <> 0) THEN BEGIN
         IF KeyPressed THEN BEGIN
           IF (ReadKey = #27) THEN BEGIN
             Z_SendCan;
             TransferMessage:='Cancelled from keyboard';
             RZ_ReceiveData := ZCAN;
             Exit;
           END;  (* of IF *)
         END;  (* of IF *)

         done:=TRUE;
crcfoo:
         CASE c OF
            GOTCRCE,
            GOTCRCG,
            GOTCRCQ,
            GOTCRCW: BEGIN
                        d:=c;
                        IF uses32crc THEN BEGIN
                          crc32:=UpdC32 (Lo (c),crc32);
                          FOR n:=0 TO 3 DO BEGIN
                            c := Z_GetZDL;
                            IF (Hi (c) <> 0) THEN GOTO crcfoo;
                            crc32:=UpdC32 (Lo (c),crc32)
                          END;
                          badcrc:=(crc32 <> $DEBB20E3);
                        END  (* of IF THEN *)
                        ELSE BEGIN
                          crc := UpdCrc (Lo (c),crc);
                          c:=Z_GetZDL;
                          IF (Hi (c) <> 0) THEN GOTO crcfoo;
                          crc := UpdCrc (Lo (c),crc);
                          c:=Z_GetZDL;
                          IF (Hi (c) <> 0) THEN GOTO crcfoo;
                          crc := UpdCrc (Lo (c),crc);

                          badcrc:=(crc <> 0);
                        END;  (* of ELSE *)

                        IF badcrc THEN BEGIN
                          INC (TransferError);
                          RZ_ReceiveData := ZERROR;
                        END  (* of IF THEN *)
                        ELSE RZ_ReceiveData := d;
                     END;
            GOTCAN : BEGIN
                       TransferMessage:='Got CANned';
                       RZ_ReceiveData := ZCAN;
                     END;
          ZTIMEOUT : BEGIN
                       TransferMessage:='Timeout';
                       RZ_ReceiveData := c;
                     END;
              RCDO : BEGIN
                       TransferMessage:='Lost carrier';
                       RZ_ReceiveData := c;
                     END
              ELSE   BEGIN
                       TransferMessage:='Debris';
                       ClearSeriellBuffer (modemkanal);
                       RZ_ReceiveData := c;
                     END
         END;  (* of CASE *)
      END  (* of IF THEN *)
      ELSE BEGIN
         DEC (blength);
         IF (blength < 0) THEN BEGIN
           TransferMessage:='Long packet';
           RZ_ReceiveData := ZERROR;
           done:=TRUE;
         END  (* of IF THEN *)
         ELSE BEGIN
           buf [INTEGER (rxcount)]:=Lo (c);
           INC (rxcount);
           IF uses32crc THEN
             crc32:= UpdC32 (Lo (c),crc32)
           ELSE crc := UpdCrc (Lo (c),crc);
         END;  (* of ELSE *)
      END;  (* of ELSE *)
   UNTIL done;
END;


(*************************************************************************)

PROCEDURE RZ_AckBibi;

(* ACKnowledge the other ends request to terminate cleanly *)

  VAR
    n : INTEGER;

BEGIN
   Z_PutLongIntoHeader (rxpos);
   n := 4;
   ClearSeriellBuffer (modemkanal);
   REPEAT
      Z_SendHexHeader (ZFIN,txhdr);
      CASE Z_GetByte (2) OF
         ZTIMEOUT,
             RCDO : Exit;
               79 : BEGIN
                      ClearSeriellBuffer (modemkanal);
                      n:=0;
                    END
             ELSE   BEGIN
                      ClearSeriellBuffer (modemkanal);
                      DEC (n)
                    END;
      END;  (* of CASE *)
   UNTIL (n <= 0);
END;


(*************************************************************************)

FUNCTION RZ_InitReceiver: INTEGER;

  VAR
     c,
     n,
     errors : INTEGER;

     stop,
     again  : BOOLEAN;

BEGIN
   FillChar (attn,SizeOf (attn),0);

   n:=10;
   stop:=FALSE;

   WHILE (n > 0) AND NOT (stop) DO BEGIN
     IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
       TransferMessage:='Lost carrier';
       RZ_InitReceiver := ZERROR;
       Exit
     END;

     Z_PutLongIntoHeader (LONGINT (0));

     txhdr [ZF0]:=CANFDX OR CANOVIO OR CANBRK;         (* Full dplx, overlay I/O *)
     IF MakeCRC32 THEN BEGIN                           (* 32-Bit-CRC zulassen    *)
       txhdr [ZF0]:=txhdr [ZF0] OR CANFC32;
     END;  (* of IF *)

     Z_SendHexHeader (tryzhdrtype,txhdr);

     IF (tryzhdrtype = ZSKIP) THEN
        tryzhdrtype := ZRINIT;

        again:=FALSE;
        REPEAT
          c := Z_GetHeader (rxhdr);
          CASE c OF
             ZFILE : BEGIN
                       zconv:=rxhdr [ZF0];
                       tryzhdrtype:=ZRINIT;

                       c := RZ_ReceiveData (secbuf,ZBUFSIZE);

                       IF (c = GOTCRCW) THEN BEGIN
                         RZ_InitReceiver := ZFILE;
                         stop:=TRUE;
                       END  (* of IF THEN *)
                       ELSE BEGIN
                         Z_SendHexHeader (ZNAK,txhdr);
                         again:=TRUE;
                       END;  (* of ELSE *)
                     END;
            ZSINIT : BEGIN
                       c := RZ_ReceiveData (attn,ZBUFSIZE);
                       IF (c = GOTCRCW) THEN
                           Z_SendHexHeader (ZACK,txhdr)
                       ELSE Z_SendHexHeader (ZNAK,txhdr);
                       again:=TRUE;
                     END;
          ZFREECNT : BEGIN
                       Z_PutLongIntoHeader (DiskFree (0));
                       Z_SendHexHeader (ZACK,txhdr);
                       again:=TRUE;
                    END;
         ZCOMMAND : BEGIN
                       c := RZ_ReceiveData (secbuf,ZBUFSIZE);
                       IF (c = GOTCRCW) THEN BEGIN
                          Z_PutLongIntoHeader (LONGINT (0));
                          errors:=0;
                          REPEAT
                             Z_SendHexHeader (ZCOMPL,txhdr);
                             INC (errors)
                          UNTIL (errors > 10) OR (Z_GetHeader(rxhdr) = ZFIN);
                          RZ_AckBibi;
                          RZ_InitReceiver := ZCOMPL;
                          stop:=TRUE;
                       END  (* of IF THEN *)
                       ELSE BEGIN
                         Z_SendHexHeader (ZNAK,txhdr);
                         again:=TRUE;
                       END;  (* of ELSE *)
                    END;
           ZCOMPL,
             ZFIN : BEGIN
                      RZ_InitReceiver := ZCOMPL;
                      stop:=TRUE;
                    END;
             ZCAN,
             RCDO : BEGIN
                      RZ_InitReceiver := c;
                      stop:=TRUE;
                    END
       END;  (* of CASE *)
     UNTIL NOT (again) OR stop;

     DEC (n);
   END;  (* of WHILE *)

   IF NOT (stop) THEN BEGIN
     TransferMessage:='Timeout';
     RZ_InitReceiver := ZERROR;
   END;  (* of IF *)
END;


(*************************************************************************)

FUNCTION RZ_GetHeader: INTEGER;

  VAR
    returncode,
    e,
    p,
    n,
    i          : INTEGER;

    makefile   : BOOLEAN;

    multiplier : LONGINT;

    s,
    tname      : STRING;

    ttime,
    tsize      : LONGINT;

BEGIN
   isbinary := TRUE;    {Force the issue!}

   p := 0;
   s := '';
   WHILE (p < 255) AND (secbuf [p] <> 0) DO BEGIN
     s := s + UpCase (Chr (secbuf [p]));
     INC (p)
   END;
   INC (p);

   (* get rid of drive & path specifiers *)

   WHILE (Pos (':',s) > 0) DO Delete (s,1,Pos (':',s));
   WHILE (Pos ('\',s) > 0) DO Delete (s,1,Pos ('\',s));
   fname := s;

   TransferName:=fname;

(**** done with name ****)

   fsize := LONGINT (0);
   WHILE (p < ZBUFSIZE) AND (secbuf[p] <> $20) AND (secbuf[p] <> 0) DO BEGIN
      fsize := (fsize *10) + Ord(secbuf[p]) - $30;
      INC (p)
   END;
   INC (p);

   TransferSize:=fsize;

(**** done with size ****)

   s := '';
   WHILE (p < ZBUFSIZE) AND (secbuf [p] IN [$30..$37]) DO BEGIN
      s := s + Chr (secbuf[p]);
      INC (p)
   END;
   INC (p);
   ftime := Z_FromUnixDate (s);

(**** done with time ****)

   TransferMessage:='receive data';
   returncode:=ZOK;
   makefile:=FALSE;

   IF RecoverAllow AND (Z_FindFile (zrxpath + fname,tname,tsize,ttime)) THEN BEGIN
      IF (ttime = ftime) THEN BEGIN
        IF (zconv = ZCRESUM) AND (fsize = tsize) THEN BEGIN
           TransferCount:=fsize;
           TransferMessage:='File is already complete';
           returncode := ZSKIP;
        END  (* of IF THEN *)
        ELSE IF (fsize > tsize) THEN BEGIN
           filestart:=tsize;
           TransferCount:=tsize;

           IF (NOT Z_OpenFile (outfile,zrxpath + fname)) THEN BEGIN
              TransferMessage:='Error opening ' + fname;
              returncode := ZERROR;
           END  (* of IF THEN *)
           ELSE BEGIN
             IF (NOT Z_SeekFile (outfile,tsize)) THEN BEGIN
               TransferMessage:='Error positioning file';
               returncode := ZERROR;
             END  (* of IF THEN *)
             ELSE FileAddition:=RecoverFile;
           END;  (* of ELSE *)
        END  (* of ELSE IF THEN *)
        ELSE BEGIN
          makefile:=TRUE;
          FileAddition:=ReplaceFile;
        END;  (* of ELSE *)
      END  (* of IF THEN *)
      ELSE BEGIN
        makefile:=TRUE;
        FileAddition:=ReplaceFile;
      END;  (* of ELSE *)
   END
   ELSE BEGIN
     makefile:=TRUE;
     FileAddition:=NewFile;
   END;  (* of ELSE *)

   IF makefile THEN BEGIN
     filestart:=0;
     TransferCount:=0;
     IF (NOT Z_MakeFile(outfile,zrxpath + fname)) THEN BEGIN
       TransferMessage:='Unable to create ' + fname;
       returncode := ZERROR;
     END;  (* of IF THEN *)
   END;  (* of IF *)

   RZ_GetHeader := returncode;
END;  (* of RZ_GetHeader *)


(*************************************************************************)

FUNCTION RZ_SaveToDisk (VAR rxbytes : LONGINT) : INTEGER;

BEGIN
   ModemStop (modemkanal);
   IF (NOT Z_WriteFile (outfile,secbuf,rxcount)) THEN BEGIN
     TransferMessage:='Disk write error';
     RZ_SaveToDisk := ZERROR
   END
   ELSE RZ_SaveToDisk := ZOK;
   ModemRun (modemkanal);
   INC (rxbytes,rxcount);
END;


(*************************************************************************)

FUNCTION RZ_ReceiveFile : INTEGER;

  LABEL
    err, nxthdr, moredata;

  VAR
    c,
    n       : INTEGER;

    rxbytes : LONGINT;

    sptr    : STRING;

    done    : BOOLEAN;

    numstr  : STRING [10];


  (***********************************************************************)

  FUNCTION SaveDataBlock : INTEGER;

    VAR
      c : INTEGER;

  BEGIN
    n := 10;
    c := RZ_SaveToDisk (rxbytes);
    TransferBytes:=rxbytes - TransferCount;
    SaveDataBlock:=c;
  END;  (* of SaveDataBlock *)


  (***********************************************************************)

BEGIN
   done := TRUE;
   eofseen := FALSE;

   c := RZ_GetHeader;

   IF (c <> ZOK) THEN BEGIN
     IF (c = ZSKIP) THEN tryzhdrtype := ZSKIP;
     RZ_ReceiveFile := c;
     IF (zstartproc <> NIL) THEN CallUserProcedure (zstartproc);
     Exit
   END;

   c := ZOK;
   n := 10;
   rxbytes := filestart;
   rxpos := filestart;
   ztime := TimeCounter DIV 18;
   zcps := 0;

   TransferCount:=rxbytes;
   TransferBytes:=0;
   TransferTotalTime:=(TransferSize - filestart) DIV (zbaud DIV 10);
   TransferMessage:='receive data';

   IF (zstartproc <> NIL) THEN CallUserProcedure (zstartproc);

   REPEAT
      Z_PutLongIntoHeader (rxbytes);
      Z_SendHexHeader (ZRPOS,txhdr);

nxthdr:

      c := Z_GetHeader (rxhdr);

      CASE c OF
         ZDATA: BEGIN
                   IF (rxpos <> rxbytes) THEN BEGIN
                     DEC (n);
                     INC (TransferError);
                     IF (n < 0) THEN GOTO err;
                     TransferMessage:='Bad position';
                     Z_PutString (attn)
                   END  (* of IF THEN *)
                   ELSE BEGIN
moredata:
                      IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

                      c := RZ_ReceiveData (secbuf,ZBUFSIZE);
                      TransferBlockSize:=rxcount;

                      CASE c OF
                             ZCAN,
                             RCDO : GOTO err;
                           ZERROR : BEGIN
                                      DEC (n);
                                      INC (TransferError);
                                      Str (TransferCount + TransferBytes,numstr);
                                      TransferMessage:=numstr + ' : Bad CRC';
                                      IF (n < 0) THEN GOTO err;
                                    END;
                         ZTIMEOUT : BEGIN
                                      DEC (n);
                                      INC (TransferError);
                                      Str (TransferCount + TransferBytes,numstr);
                                      TransferMessage:=numstr + ' : Timeout';
                                      IF (n < 0) THEN GOTO err
                                    END;
                          GOTCRCW : BEGIN
                                      c:=SaveDataBlock;
                                      IF (c <> 0) THEN Exit;

                                      Z_PutLongIntoHeader (rxbytes);
                                      Z_SendHexHeader (ZACK,txhdr);

                                      GOTO nxthdr;
                                    END;
                          GOTCRCQ : BEGIN
                                      c:=SaveDataBlock;
                                      IF (c <> 0) THEN Exit;

                                      Z_PutLongIntoHeader (rxbytes);
                                      Z_SendHexHeader (ZACK,txhdr);

                                      GOTO moredata;
                                    END;
                          GOTCRCG : BEGIN
                                      c:=SaveDataBlock;
                                      IF (c <> 0) THEN Exit;

                                      GOTO moredata;
                                    END;
                          GOTCRCE : BEGIN
                                      c:=SaveDataBlock;
                                      IF (c <> 0) THEN Exit;

                                      GOTO nxthdr;
                                    END;
                      END {case}
                   END;  (* of IF *)
                END; {case of ZDATA}
         ZNAK,
         ZTIMEOUT: BEGIN
                     DEC (n);
                     IF (n < 0) THEN GOTO err;
                     TransferBytes:=rxbytes - TransferCount;
                   END;
           ZFILE : c := RZ_ReceiveData (secbuf,ZBUFSIZE);
            ZEOF : IF (rxpos = rxbytes) THEN BEGIN
                     RZ_ReceiveFile := c;
                     Exit
                   END
                   ELSE GOTO nxthdr;
          ZERROR : BEGIN
                     DEC (n);
                     IF (n < 0) THEN GOTO err;
                     TransferBytes:=rxbytes - TransferCount;
                     Z_PutString (attn)
                  END
           ELSE   BEGIN
                    c := ZERROR;
                    GOTO err
                  END
      END; {case}

      IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

   UNTIL (NOT done);

err:

   IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

   RZ_ReceiveFile := ZERROR
END;


(*************************************************************************)

FUNCTION RZ_ReceiveBatch : INTEGER;

  VAR
    s    : STRING;
    c    : INTEGER;
    done : BOOLEAN;

BEGIN
   done := FALSE;

   WHILE NOT (done) DO BEGIN

      IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
        RZ_ReceiveBatch := ZERROR;
        Exit
      END;

      c := RZ_ReceiveFile;

      Z_CloseFile (outfile);
      Reset (outfile);
      IF (IOResult = 0) THEN BEGIN
        SetFTime (outfile,ftime);
        Close (outfile);
      END;  (* of IF *)

      CASE c OF
         ZEOF,
         ZSKIP : BEGIN
                   c := RZ_InitReceiver;
                   CASE c OF
                       ZFILE : BEGIN
                                 TransferCount:=0;
                                 TransferBytes:=0;
                                 TransferError:=0;
                                 TransferCheck:='';
                                 TransferMessage:='';
                                 TransferTime:=TimeCounter;
                                 TransferMessage:='Wait for File';
                                 FileAddition:=NewFile;
                               END;
                      ZCOMPL : BEGIN
                                 RZ_AckBibi;
                                 RZ_ReceiveBatch := ZOK;
                                 TransferMessage:='Transfer complet';
                                 Exit
                               END;
                        ELSE   BEGIN
                                 RZ_ReceiveBatch := ZERROR;
                                 Exit
                               END
                   END;  (* of CASE *)
                 END
          ELSE   BEGIN
                   RZ_ReceiveBatch := c;
                   Exit
                  END
      END;  {case}

      IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

   END;  {while}
END;


(*************************************************************************)

PROCEDURE ZmodemReceive;

VAR
   i: INTEGER;

BEGIN
   TransferCount:=0;
   TransferError:=0;
   TransferBlockSize:=0;
   TransferCheck:='';
   TransferMessage:='';

   zstartproc:=startproc;
   zdispproc:=dispproc;

   IF (kanal <> 0) THEN BEGIN
     IF (baudrate <> 0) THEN
       zbaud := baudrate
     ELSE zbaud:=GetBaudrate (kanal);

     modemkanal:=kanal;
     zrxpath := path;
     IF (zrxpath [Length (zrxpath)] <> '\') AND (zrxpath <> '') THEN zrxpath:=zrxpath + '\';

     rxtimeout := 10 * 18;
     tryzhdrtype := ZRINIT;

     {$IFDEF TPZLog}
       Assign (tpzlog,'TPZR.LOG');
       Rewrite (tpzlog);
     {$ENDIF}

     i := RZ_InitReceiver;

     TransferTime:=TimeCounter;

     IF (i = ZCOMPL) OR ((i = ZFILE) AND (RZ_ReceiveBatch = ZOK)) THEN BEGIN
       fehlerflag := TRUE
     END
     ELSE BEGIN
       Z_SendCan;
       fehlerflag := FALSE;
     END;

     {$IFDEF TPZLog}
       Close (tpzlog);
     {$ENDIF}

   END  (* of IF THEN *)
   ELSE BEGIN
     TransferMessage:='no seriell port';
     fehlerflag:=FALSE;
   END;  (* of ELSE *)

   IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);
END;


(*######### SEND ROUTINES #####################################*)

VAR
   infile     : FILE;
   strtpos    : LONGINT;
   rxbuflen   : INTEGER;
   txbuf      : buftype;
   blkred     : INTEGER;

   fheaderlen : WORD;


PROCEDURE SZ_Z_SendByte(b: BYTE);

BEGIN
  IF ((b AND $7F) IN [16,17,19,24]) OR (((b AND $7F) = 13) AND ((lastsent AND $7F) = 64)) THEN BEGIN
    Z_SendByte (ZDLE);
    lastsent := (b XOR 64)
  END
  ELSE lastsent := b;
  Z_SendByte (lastsent)
END;


(*************************************************************************)

PROCEDURE SZ_SendBinaryHeader (htype : BYTE ; VAR hdr : hdrtype);

  VAR
    crc   : WORD;

    crc32 : LONGINT;

    n     : INTEGER;

BEGIN
  Z_SendByte (ZPAD);
  Z_SendByte (ZDLE);

  IF send32crc THEN BEGIN
    Z_SendByte (ZBIN32);
    SZ_Z_SendByte (htype);

    crc32 := UpdC32 (htype,$FFFFFFFF);

    FOR n := 0 TO 3 DO BEGIN
       SZ_Z_SendByte (hdr [n]);
       crc32:=UpdC32 (hdr [n],crc32)
    END;

    crc32:=NOT (crc32);

    FOR n := 0 TO 3 DO BEGIN
      SZ_Z_SendByte (BYTE (crc32));
      crc32 := (crc32 SHR 8)
    END;

  END  (* of IF THEN *)
  ELSE BEGIN
    Z_SendByte (ZBIN);
    SZ_Z_SendByte (htype);

    crc := UpdCrc (htype,0);

    FOR n := 0 TO 3 DO BEGIN
       SZ_Z_SendByte (hdr [n]);
       crc:=UpdCrc (hdr [n],crc)
    END;

    crc := UpdCrc (0,crc);
    crc := UpdCrc (0,crc);

    SZ_Z_SendByte (Lo (crc SHR 8));
    SZ_Z_SendByte (Lo (crc));
  END;  (* of ELSE *)

  IF (htype <> ZDATA) THEN Delay (500)
END;


(*************************************************************************)

PROCEDURE SZ_SendData (VAR buf : buftype ; blength : INTEGER ; frameend : BYTE);

  VAR
    crc   : WORD;

    crc32 : LONGINT;

    t     : INTEGER;

BEGIN
  IF send32crc THEN BEGIN
    crc32 := $FFFFFFFF;

    FOR t := 0 TO (blength - 1) DO BEGIN
      SZ_Z_SendByte (buf [t]);
      crc32 := UpdC32 (buf [t],crc32)
    END;

    crc32 := UpdC32 (frameend,crc32);
    crc32 := (NOT crc32);

    Z_SendByte (ZDLE);
    Z_SendByte (frameend);

    FOR t := 0 TO 3 DO BEGIN
      SZ_Z_SendByte (BYTE (crc32));
      crc32 := (crc32 SHR 8)
    END;  (* of FOR *)
  END  (* of IF THEN *)
  ELSE BEGIN
    crc := 0;

    FOR t := 0 TO (blength - 1) DO BEGIN
      SZ_Z_SendByte (buf [t]);
      crc := UpdCrc (buf [t],crc)
    END;

    crc := UpdCrc(frameend,crc);

    Z_SendByte (ZDLE);
    Z_SendByte (frameend);

    crc := UpdCrc (0,crc);
    crc := UpdCrc (0,crc);

    SZ_Z_SendByte (Lo (crc SHR 8));
    SZ_Z_SendByte (Lo (crc));

  END;  (* of ELSE *)

  IF (frameend = ZCRCW) THEN BEGIN
    Z_SendByte (17);
    Delay (500)
  END;  (* of IF *)

END;  (* of SZ_SendData *)


(*************************************************************************)

PROCEDURE SZ_EndSend;

  VAR
    done : BOOLEAN;

BEGIN
   done := FALSE;
   REPEAT
      Z_PutLongIntoHeader (txpos);
      SZ_SendBinaryHeader (ZFIN,txhdr);
      CASE Z_GetHeader (rxhdr) OF
             ZFIN : BEGIN
                      Z_SendByte (Ord ('O'));
                      Z_SendByte (Ord ('O'));
                      Delay (500);
                      Exit
                    END;
             ZCAN,
             RCDO,
            ZFERR,
         ZTIMEOUT : Exit
      END {case}
   UNTIL (done);
END;


(*************************************************************************)

FUNCTION SZ_GetReceiverInfo: INTEGER;

  VAR
    n,
    c,
    rxflags : INTEGER;

BEGIN
   FOR n := 1 TO 10 DO BEGIN
      c := Z_GetHeader (rxhdr);
      CASE c OF
         ZCHALLENGE: BEGIN
                       Z_PutLongIntoHeader (rxpos);
                       Z_SendHexHeader (ZACK,txhdr)
                     END;
           ZCOMMAND: BEGIN
                       Z_PutLongIntoHeader (LONGINT (0));
                       Z_SendHexHeader (ZRQINIT,txhdr)
                     END;
             ZRINIT: BEGIN
                       rxbuflen := (WORD (rxhdr [ZP1]) SHL 8) OR rxhdr [ZP0];
                       send32crc:=MakeCRC32 AND ((rxhdr [ZF0] AND CANFC32) <> 0);
                       IF send32crc THEN
                         TransferCheck:='CRC-32'
                       ELSE TransferCheck:='CRC-16';
                       SZ_GetReceiverInfo := ZOK;
                       Exit
                     END;
           ZCAN,
           RCDO,
           ZTIMEOUT: BEGIN
                       SZ_GetReceiverInfo := ZERROR;
                       Exit
                     END
           ELSE      IF (c <> ZRQINIT) OR (rxhdr [ZF0] <> ZCOMMAND) THEN Z_SendHexHeader (ZNAK,txhdr)
      END {case}
   END; {for}
   SZ_GetReceiverInfo := ZERROR
END;


(*************************************************************************)

FUNCTION SZ_SyncWithReceiver: INTEGER;

  VAR
    c,
    num_errs : INTEGER;

    numstr   : STRING [10];

    done     : BOOLEAN;

BEGIN
   num_errs := 7;
   done := FALSE;

   REPEAT
      c := Z_GetHeader (rxhdr);
      ClearSeriellBuffer (modemkanal);
      CASE c OF
         ZTIMEOUT : BEGIN
                      DEC (num_errs);
                      IF (num_errs < 0) THEN BEGIN
                        TransferMessage:='Timeout';
                        SZ_SyncWithReceiver := ZERROR;
                        Exit
                      END
                    END;
             ZCAN,
           ZABORT,
             ZFIN,
             RCDO : BEGIN
                      TransferMessage:='Abord';
                      SZ_SyncWithReceiver := ZERROR;
                      Exit
                    END;
            ZRPOS : BEGIN
                      IF NOT (Z_SeekFile (infile,rxpos)) THEN BEGIN
                        TransferMessage:='File seek error';
                        SZ_SyncWithReceiver := ZERROR;
                      END  (* of IF THEN *)
                      ELSE BEGIN
                        Str (rxpos,numstr);
                        TransferMessage:=numstr + ' : Bad CRC';
                        txpos := rxpos;
                        SZ_SyncWithReceiver := c;
                      END;  (* of ELSE *)
                      Exit
                    END;
            ZSKIP,
           ZRINIT,
             ZACK : BEGIN
                      TransferMessage:='Wait for file';
                      SZ_SyncWithReceiver := c;
                      Exit
                    END
             ELSE   BEGIN
                      TransferMessage:='I dunno what happened';
                      SZ_SendBinaryHeader (ZNAK,txhdr)
                    END
      END {case}
   UNTIL (done)
END;


(*************************************************************************)

FUNCTION SZ_SendFileData: INTEGER;

LABEL
   waitack, somemore;

VAR
   c,e        : INTEGER;

   newcnt,
   blklen,
   blkred,
   maxblklen,
   goodblks,
   goodneeded : WORD;

   ch         : CHAR;

   stop,
   chflag     : BOOLEAN;

BEGIN
   goodneeded := 1;

   IF (zbaud < 300) THEN
      maxblklen := 128
   ELSE maxblklen := (WORD (zbaud) DIV 300) * 256;

   IF (maxblklen > ZBUFSIZE) THEN maxblklen:=ZBUFSIZE;
   IF (rxbuflen > 0) AND (rxbuflen < maxblklen) THEN maxblklen:=rxbuflen;

   blklen := maxblklen;

   TransferBlockSize:=blklen;

   ztime := TimeCounter DIV 18;

somemore:

   stop:=FALSE;

   REPEAT
     SeriellCheckRead (modemkanal,ch,chflag);
     IF chflag THEN BEGIN
       IF (ch = CHR (XOFF)) OR (ch = CHR (XON)) THEN BEGIN
         ch:=SeriellRead (modemkanal);
         {$IFDEF TPZLog}
           Write (tpzlog,CHAR (c));
         {$ENDIF}
       END  (* of IF THEN *)
       ELSE stop:=TRUE;
     END  (* of IF THEN *)
     ELSE stop:=TRUE;
   UNTIL stop;

   IF chflag THEN BEGIN

WaitAck:

      c := SZ_SyncWithReceiver;

      CASE c OF
          ZSKIP : BEGIN
                    SZ_SendFileData := ZSKIP;
                    Exit
                  END;
           ZACK : {null};
          ZRPOS : BEGIN
                    INC (TransferError);
                    IF ((blklen SHR 2) > 32) THEN
                       blklen := (blklen SHR 2)
                    ELSE blklen := 32;
                    goodblks := 0;
                    goodneeded := (goodneeded SHL 1) OR 1;
                    TransferBlockSize:=blklen;
                  END;
         ZRINIT : BEGIN
                    SZ_SendFileData := ZOK;
                    Exit
                  END
           ELSE   BEGIN
                    SZ_SendFileData := ZERROR;
                    Exit
                  END
      END {case};

      WHILE ReceiverReady (modemkanal) DO BEGIN
         CASE Z_GetByte (2) OF
            CAN,
            ZPAD: GOTO waitack;
            RCDO: BEGIN
                    SZ_SendFileData := ZERROR;
                    Exit
                  END
         END {case}
      END;  (* of WHILE *)
   END; {if char avail}

   newcnt:=rxbuflen;
   Z_PutLongIntoHeader (txpos);
   SZ_SendBinaryHeader (ZDATA,txhdr);

   REPEAT
      IF (KeyPressed) THEN BEGIN
        IF (ReadKey = #27) THEN BEGIN
          TransferMessage:='Aborted from keyboard';
          SZ_SendFileData := ZERROR;
          Exit
        END;
      END;  (* of IF *)

      IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
        TransferMessage:='Carrier lost';
        SZ_SendFileData := ZERROR;
        Exit;
      END;  (* of IF *)

      IF NOT (Z_ReadFile (infile,txbuf,blklen,blkred)) THEN BEGIN
        TransferMessage:='Error reading disk';
        SZ_SendFileData := ZERROR;
        Exit
      END;

      IF (blkred < blklen) THEN
        e := ZCRCE
      ELSE IF (rxbuflen <> 0) AND ((newcnt - blkred) <= 0) THEN BEGIN
        newcnt := (newcnt - blkred);
        e := ZCRCW
      END
      ELSE e := ZCRCG;

      SZ_SendData (txbuf,blkred,e);
      INC (txpos,blkred);

      INC (goodblks);
      IF (blklen < maxblklen) AND (goodblks > goodneeded) THEN BEGIN
        IF ((blklen SHL 1) < maxblklen) THEN
          blklen := (blklen SHL 1)
        ELSE blklen := maxblklen;
        goodblks := 0
      END;  (* of IF *)

      TransferBlockSize:=blklen;
      TransferBytes:=txpos - TransferCount;

      IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

      IF (e = ZCRCW) THEN GOTO waitack;

      WHILE ReceiverReady (modemkanal) DO BEGIN
         CASE Z_GetByte (2) OF
            CAN,
            ZPAD : BEGIN
                     TransferMessage:='Trouble';
                     SZ_SendData (txbuf,0,ZCRCE);
                     GOTO waitack
                   END;
            RCDO : BEGIN
                     SZ_SendFileData := ZERROR;
                     Exit
                   END
         END; {case}
      END; (* of WHILE *)

   UNTIL (e <> ZCRCG);

   stop:=FALSE;
   REPEAT
      Z_PutLongIntoHeader (txpos);
      SZ_SendBinaryHeader (ZEOF,txhdr);
      c := SZ_SyncWithReceiver;
      CASE c OF
           ZACK : stop:=TRUE;
          ZRPOS : GOTO somemore;
         ZRINIT : BEGIN
                    SZ_SendFileData := ZOK;
                    TransferMessage:='Transfer complet';
                    stop:=TRUE;
                  END;
          ZSKIP : BEGIN
                    SZ_SendFileData := c;
                    TransferMessage:='Skip file';
                    stop:=TRUE;
                  END
         ELSE     BEGIN
                    SZ_SendFileData := ZERROR;
                    stop:=TRUE;
                  END
      END; {case}

      IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);

   UNTIL (c <> ZACK)
END;


(*************************************************************************)

FUNCTION SZ_SendFile : INTEGER;

  VAR
    c    : INTEGER;
    done : BOOLEAN;

BEGIN
   TransferError:=0;
   TransferBytes:=0;

   done := FALSE;

   REPEAT
      IF (KeyPressed) THEN BEGIN
        IF (ReadKey = #27) THEN BEGIN
          TransferMessage:='Aborted from keyboard';
          SZ_SendFile := ZERROR;
          Exit
        END;
      END;  (* of IF *)

      IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
        TransferMessage:='Lost carrier';
        SZ_SendFile := ZERROR;
        Exit
      END;

      FillChar (txhdr,4,0);

      txhdr [ZF0] := ZCRESUM;                       (* Recover zulassen *)

      SZ_SendBinaryHeader (ZFILE,txhdr);

      SZ_SendData (txbuf,fheaderlen,ZCRCW);

      Delay (500);

      REPEAT
         c := Z_GetHeader (rxhdr);
         CASE c OF
            ZCAN,
            RCDO,
            ZTIMEOUT,
            ZFIN,
            ZABORT: BEGIN
                       SZ_SendFile := ZERROR;
                       Exit
                    END;
            ZRINIT : {null - this will cause a loopback};
              ZCRC : BEGIN
                       Z_PutLongIntoHeader (Z_FileCRC32 (infile));
                       Z_SendHexHeader (ZCRC,txhdr)
                     END;
             ZSKIP : BEGIN
                       SZ_SendFile := c;
                       Exit
                     END;
             ZRPOS : BEGIN
                       IF (NOT Z_SeekFile (infile,rxpos)) THEN BEGIN
                          TransferMessage:='File positioning error';
                          Z_SendHexHeader (ZFERR,txhdr);
                          SZ_SendFile := ZERROR;
                          Exit
                       END;

                       IF (rxpos = 0) THEN FileAddition:=NewFile ELSE FileAddition:=RecoverFile;

                       TransferCount:=rxpos;
                       IF (zstartproc <> NIL) THEN CallUserProcedure (zstartproc);
                       strtpos := rxpos;
                       txpos := rxpos;
                       SZ_SendFile := SZ_SendFileData;
                       Exit;
                    END
         END {case}
      UNTIL (c <> ZRINIT);
   UNTIL (done);
END;


(*************************************************************************)

PROCEDURE ZmodemSend;

VAR
   s: STRING;
   n: INTEGER;

BEGIN
   TransferError := 0;
   TransferTime:=0;
   TransferCount:=0;
   TransferBytes:=0;
   TransferName:='';
   TransferCheck:='';
   TransferSize:=0;
   TransferBlockSize:=0;
   TransferMessage:='';
   FileAddition:=NewFile;

   zstartproc:=startproc;
   zdispproc:=dispproc;

   IF (kanal <> 0) THEN BEGIN
     IF (baudrate <> 0) THEN
       zbaud := baudrate
     ELSE zbaud:=GetBaudrate (kanal);

     modemkanal:=kanal;
     IF NOT (CarrierDetector (modemkanal)) THEN BEGIN
       TransferMessage:='Lost carrier';
       IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);
       fehler:=103;
       Exit
     END;

     IF (NOT Z_FindFile(pathname,fname,fsize,ftime)) THEN BEGIN
       TransferMessage:='Unable to find/open file';
       IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);
       fehler:=10;
       Exit
     END;

     TransferName:=fname;
     TransferSize:=fsize;
     TransferTotalTime:=fsize DIV (zbaud DIV 10);

     Str (fsize,s);
     s:=fname + #0 + s + ' ';
     s:=s + Z_ToUnixDate (ftime);
     FOR n:=1 TO Length (s) DO BEGIN
       IF (s [n] IN ['A'..'Z']) THEN s [n]:=Chr (Ord (s [n]) + $20)
     END;


     FillChar (txbuf,ZBUFSIZE,0);
     Move (s [1],txbuf [0],Length (s));
     fheaderlen:=Length (s);

     IF (zbaud > 0) THEN
        rxtimeout := INTEGER ((614400 DIV zbaud) * 10) DIV 18
     ELSE rxtimeout := 180;
     IF (rxtimeout < 180) THEN rxtimeout := 180;

     attn [0] := Ord('r');
     attn [1] := Ord('z');
     attn [3] := 13;
     attn [4] := 0;

     {$IFDEF TPZLog}
       Assign (tpzlog,'TPZS.LOG');
       Rewrite (tpzlog);
     {$ENDIF}

     Z_PutString (attn);
     FillChar (attn,SizeOf (attn),0);
     Z_PutLongIntoHeader (LONGINT (0));

     TransferTime:=TimeCounter;

     Z_SendHexHeader (ZRQINIT,txhdr);

     IF (SZ_GetReceiverInfo = ZERROR) THEN BEGIN
       fehler:=102;
     END  (* of IF THEN *)
     ELSE BEGIN
       IF NOT (Z_OpenFile (infile,pathname)) THEN BEGIN
         IF (IOresult <> 0) THEN BEGIN
           TransferMessage:='Failure to open file';
           Z_SendCan;
           fehler:=101;
         END;  (* of IF *)
       END  (* of IF THEN *)
       ELSE BEGIN
         n := SZ_SendFile;
         Z_CloseFile (infile);

         CASE n OF
           ZSKIP : fehler:=9;
             ZOK : fehler:=0;
            ZCAN : fehler:=8;
         END;  (* of CASE *)

         IF (n = ZERROR) THEN
           Z_SendCan
         ELSE IF lastfile THEN SZ_EndSend;

       END;  (* of ELSE *)

     END;  (* of ELSE *)

     {$IFDEF TPZLog}
       Close (tpzlog);
     {$ENDIF}

   END  (* of IF THEN *)
   ELSE BEGIN
     TransferMessage:='no seriell port';
     fehler:=105;
   END;  (* of ELSE *)

   IF (zdispproc <> NIL) THEN CallUserProcedure (zdispproc);
END;


(*************************************************************************)

BEGIN
  MakeCRC32:=TRUE;
  RecoverAllow:=TRUE;
END.