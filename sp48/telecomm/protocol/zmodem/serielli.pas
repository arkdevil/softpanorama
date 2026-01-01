(*************************************************************************)
(*                                                                       *)
(*  Unit SeriellInterface                                                *)
(*                                                                       *)
(*************************************************************************)
(*                                                                       *)
(* Programmierer ........ Stefan Graf / 4600 Dortmund 1 / BRD            *)
(*                                                                       *)
(* Programmiersprache ... Turbo-Pascal 5.0                               *)
(*                                                                       *)
(* Projekt .............. Verwaltung der ser. Schnittstellen im IBM      *)
(*                                                                       *)
(* Erststellt am ........ 02.07.89                                       *)
(*                                                                       *)
(* letzte Änderung am ... 06.04.90                                       *)
(*                                                                       *)
(* Revision ............. 1.13                                           *)
(*                                                                       *)
(*************************************************************************)
(*                                                                       *)
(* Beschreibung:                                                         *)
(*                                                                       *)
(* Programmierung und Verwaltung von bis zu 8 seriellen Schnittstellen   *)
(* im IBM XT/AT/386.                                                     *)
(* Alle Schnittstellen können bei Bedarf mit einer interrupt-gesteuerten *)
(* Empfangsroutinen betrieben werden.                                    *)
(* Die erweiterten Interrupt's des AT's oder der 386 werden unterstützt. *)
(*                                                                       *)
(* Änderungen                                                            *)
(*                                                                       *)
(*   1.01 Procedure SetStatusMask und Function SeriellStatus eingeführt  *)
(*                                                                       *)
(*   1.02 Parameter TransmitMask eingeführt.                             *)
(*                                                                       *)
(*   1.03 Beim Deinstallieren des Handlers werden nur noch die Leitungen *)
(*        die mit der <Transmittmaske> definiert werden, zurückgesetzt.  *)
(*                                                                       *)
(*   1.04 Neue Funktionen definiert.                                     *)
(*                                                                       *)
(*   1.10 Neue Funktionen definiert.                                     *)
(*                                                                       *)
(*************************************************************************)

{$R-}
{$S-}
{$O-}

UNIT SeriellInterface;

INTERFACE

(*************************************************************************)

  CONST
    DSRInput  = $20;
    CTSInput  = $10;
    CDInput   = $80;
    RIInput   = $40;
    DTROutput = $01;
    RTSOutput = $02;

    MaxKanal       = 8;      (* Max. sind acht Handler gleichzeitig nutzbar   *)

    NotInstall     = 20000;  (* Der Handler wurde noch nicht installiert      *)
    NoHandler      = 20001;  (* Es ist kein freier Handler mehr vorhanden     *)
    NoChip         = 20002;  (* An der Adresse liegt kein ser. Baustein       *)
    WrongHandler   = 20003;  (* Falsche Handlernummer ( 1 < kanal > MaxKanal) *)
    WrongBaudRate  = 20100;  (* Ungültige Baudrate                            *)
    WrongStopBit   = 20101;  (* Ungültige Anzahl Stopp-Bits                   *)
    WrongWordLen   = 20102;  (* Ungültige Übertragungswort-Länge              *)


(*************************************************************************)

  TYPE
    LineZustand  = (On,Off);
    ParityType   = (None,Even,Odd,Mark,Space);
    StopBitType  = 1..2;
    WordLenType  = 5..8;
    BaudRateType = 75..115200;


    SeriellBuffer = ARRAY [0..$7FFF] OF CHAR;

    SeriellDiscrType = RECORD
                         PortAdresse,                      (* Basis-Adresse des 8250               *)
                         PortIRQ        : WORD;            (* Interrupt-Kanal der Schnittstelle    *)
                         Transmit       : BOOLEAN;         (* FALSE, wenn Empfangspuffer fast voll *)
                         TransmitMask   : BYTE;            (* Maske für die Statusleitungen        *)
                         BufferSize,                       (* Grösse des Empfangspuffers in Byte   *)
                         BufferFull,                       (* Füll-Grenze für den Empfangspuffer   *)
                         Top,                              (* erstes Zeichen im Ringpuffers        *)
                         Bottom,                           (* letztes Zeichen im Ringpuffer        *)
                         Anzahl         : WORD;            (* Anzahl Zeichen im Ringpuffer         *)
                         Buffer         : ^SeriellBuffer;  (* Pointer auf den Ringpuffer im Heap   *)
                         Install        : BOOLEAN;         (* TRUE, wenn der Handler belegt ist    *)
                         PortInterrupt,                    (* Pointer auf die Interruptroutine     *)
                         OldVector      : POINTER;         (* Ursprünglicher Interrupt-Vektor      *)
                         LineMask,
                         OldIntMask,
                         OldMCR,
                         OldIER         : BYTE;
                         CountInt,
                         CountInChar,
                         CountOutChar,
                         CountError,
                         CountOverflow  : WORD;
                         NS16550Flag    : BOOLEAN;
                       END;  (* of RECORD *)


(*************************************************************************)

  VAR
    SeriellOk    : BOOLEAN;   (* TRUE, wenn kein Fehler erkannt wurde *)
    SeriellError : WORD;      (* <> 0, wenn ein Fehler erkannt wurde  *)

    FiFoAktiv    : BOOLEAN;


(*************************************************************************)

(* Einrichten eines neuen Handlers für eine serielle Schnittstelle *)
(* <adr>  = Basisadresse des 8250                                  *)
(* <irq>  = Interruptkanal für diesen Baustein                     *)
(*          Bei Kanal 0 wird keine Interruptroutine installiert    *)
(* <size> = Grösse des Empfangspuffers                             *)
(*                                                                 *)
(* Mit der Handlernummer <kanal> legt man bei allen Routinen fest, *)
(* welche Schnittstelle angesprochen wird.                         *)

PROCEDURE InstallSeriellHandler (adr,irq,size : WORD ; VAR kanal : WORD);


(* Den Handler eineer seriellen Schnittstelle freigeben.           *)
(* Die belegten Interrupt-Vektoren werden auf ihre alten Werte     *)
(* gesetzt und der Speicher auf dem Heap freigegeben.              *)

PROCEDURE DeInstallSeriellHandler (kanal : WORD);


(* Definition des Handlers <kanal> holen.                          *)

PROCEDURE GetHandlerInfo (kanal : WORD ; VAR adr,ir,buflen : WORD);


(* Lesen von einer seriellen Schnittstelle.                        *)
(* Die Handlernummer <kanal> gibt die Schnittstelle an.            *)

FUNCTION  SeriellRead (kanal : WORD) : CHAR;


(* Das nächste Zeichen im Buffer holen, aber nicht aus dem Buffer  *)
(* entfernen                                                       *)

PROCEDURE SeriellCheckRead (kanal : WORD ; VAR zeichen : CHAR ; VAR flag : BOOLEAN);


(* Lesen von einer seriellen Schnittstelle.                        *)
(* Die Handlernummer <kanal> gibt die Schnittstelle an.            *)

PROCEDURE SeriellWrite (kanal : WORD ; zeichen : CHAR);


(* Empfängerpuffer der Schnittstelle <kanal> leeren.               *)

PROCEDURE ClearSeriellBuffer (kanal : WORD);


(* Testen, ob für die Schnittstelle <kanal> ein Zeichen anliegt.   *)

FUNCTION  ReceiverReady (kanal : WORD) : BOOLEAN;


(* Testen, ob die Schnittstelle <kanal> ein Zeichen senden kann.   *)

FUNCTION  TransmitterReady (kanal : WORD) : BOOLEAN;


(* Testen, ob CTS-Leitung der Schnittstelle <kanal> aktiv ist.     *)

FUNCTION  ClearToSend (kanal : WORD) : BOOLEAN;


(* Testen, ob DSR-Leitung der Schnittstelle <kanal> aktiv ist.     *)

FUNCTION  DataSetReady (kanal : WORD) : BOOLEAN;


(* Teste, ob ein Break auf der Leitung erkannt wurde               *)

FUNCTION BreakDetected (kanal : WORD) : BOOLEAN;


(* Testen, ob CD-Leitung der Schnittstelle <kanal> aktiv ist.      *)

FUNCTION  CarrierDetector (kanal : WORD) : BOOLEAN;


(* Setzen oder rücksetzen der DTR-Leitung.                         *)

PROCEDURE DataTerminalReady (kanal : WORD ; zustand : LineZustand);


(* Setzen oder Rücksetzen der RTS-Leitung.                         *)

PROCEDURE RequestToSend (kanal : WORD ; zustand : LineZustand);


(* Break-Signal ausgeben                                           *)

PROCEDURE SendBreak (kanal : WORD);


(* Festlegen der Mask für die Auswertung der Statusleitungen der   *)
(* Schnittstelle.                                                  *)

PROCEDURE SetStatusMask (kanal,mask : WORD);


(* Festlegen der Mask für die Behandlung der Statusleitungen der   *)
(* Schnittstelle wenn der Puffer voll ist.                         *)
(* Zum Sperren des Senders werden die angegebenen Ausgänge auf 0   *)
(* gesetzt.                                                        *)

PROCEDURE SetTransmitMask (kanal,mask : WORD);


(* Testen, ob die Statusleitungen die mit SetStatusMask definiert  *)
(* wurden, gesetzt sind.                                           *)

FUNCTION SeriellStatus (kanal : WORD) : BOOLEAN;


(*******************************************************************)

(* Datenübertragungs-Parameter festlegen.                          *)

PROCEDURE SetParameter (kanal   : WORD;
                        rate    : BaudRateType;
                        parity  : ParitYType;
                        stopbit : StopBitType;
                        wordlen : WordLenType);


(* Baudrate der Schnittstelle <kanal> festlegen.                   *)
(* Für <baud> sind alle Werte zwischen 75 und 111500 gültig.       *)

PROCEDURE SetBaudrate (kanal : WORD ; rate : BaudRateType);


(* Aktuelle Baudrate der Schnittstelle <kanal> ermitteln           *)

FUNCTION  GetBaudrate (kanal : WORD) : BaudRateType;


(* Parityerzeugung und -Auswertung für die Schnittstelle <kanal>   *)
(* festlegen. Zugelassen sind None,Even oder Odd                   *)

PROCEDURE SetParity (kanal : WORD ; parity : ParityType);


(* Aktuelle Paritydefinitin der Schnittstelle <kanal< ermitteln    *)

FUNCTION  GetParity (kanal : WORD) : ParityType;


(* Anzahl der Stopp-Bit's für die Schnittstelle <kanal> festlegen. *)
(* Zugelassen sind die Werte 1 und 2.                              *)

PROCEDURE SetStopBit (kanal : WORD ; stopbit : StopBitType);


(* Aktuelle Anzahl Stopp-Bit's für die Schnittstelle <kanal>       *)
(* ermitteln                                                       *)

FUNCTION  GetStopBit (kanal : WORD) : StopBitType;


(* Wort-Länge für die Schnittstelle <kanal> festlegen.             *)
(* Mögliche Wort-Längen sind 5,6,7 und 8.                          *)

PROCEDURE SetWordLen (kanal : WORD ; wordlen : WordLenType);


(* Aktuelle Wort-Länge der Schnittstelle <kanal> ermitteln.        *)

FUNCTION  GetWordLen (kanal : WORD) : WordLenType;


(* Löschen der Schnittstellen-Statistik                            *)

PROCEDURE ClearHandlerStatistic (kanal : WORD);


(* Zähler für die Anzahl Interrupts an der Schnittstelle <kanal>   *)
(* einfragen.                                                      *)

FUNCTION GetIntCounter (kanal : WORD) : WORD;


(* Zähler für die Anzahl der empfangene Zeichen an der Schnitt-     *)
(* stelle <kanal> einfragen.                                        *)

FUNCTION GetReceiveCounter (kanal : WORD) : WORD;


(* Zähler für die Anzahl gesendeten Zeichen an der Schnitt-         *)
(* stelle <kanal> einfragen.                                        *)

FUNCTION GetSendCounter (kanal : WORD) : WORD;


(* Zähler für die Anzahl der Empfangsfehler an der Schnitt-         *)
(* stelle <kanal> einfragen.                                        *)

FUNCTION GetErrorCounter (kanal : WORD) : WORD;


(* Zähler für die Anzahl der Pufferüberläufe an der Schnitt-        *)
(* stelle <kanal> einfragen.                                        *)

FUNCTION GetOverflowCounter (kanal : WORD) : WORD;


(*************************************************************************)

IMPLEMENTATION

  USES Dos;

  CONST
    IntrCtrl1      = $20;    (* Basisadresse des ersten Interruptcontroler's  *)
    IntrCtrl2      = $A0;    (* Basisadresse des zweiten Interruptcontroler's *)


(*************************************************************************)

  VAR
    i,
    HandlerSize       : WORD;      (* Grösses eines Handler-Record's      *)

    altexitproc       : POINTER;   (* Pointer auf die alte Exit-Procedure *)

    SeriellDiscriptor : ARRAY [1..MaxKanal] OF SeriellDiscrType;

    Ticker            : LONGINT ABSOLUTE $40:$6C;


(*************************************************************************)

{$L RS232Pas }

PROCEDURE SeriellIntrProc1; External;  (* Definition der externen Interruptroutinen *)

PROCEDURE SeriellIntrProc2; External;

PROCEDURE SeriellIntrProc3; External;

PROCEDURE SeriellIntrProc4; External;

PROCEDURE SeriellIntrProc5; External;

PROCEDURE SeriellIntrProc6; External;

PROCEDURE SeriellIntrProc7; External;

PROCEDURE SeriellIntrProc8; External;


(*************************************************************************)


PROCEDURE DisableInterrupt; InLine ($FA);

PROCEDURE EnableInterrupt; InLine ($FB);


(*************************************************************************)

PROCEDURE ClearError;

BEGIN
  SeriellOk:=TRUE;
  SeriellError:=0;
END;  (* of ClearError *)


(*************************************************************************)

PROCEDURE SetError (err : WORD);

BEGIN
  SeriellOk:=FALSE;
  SeriellError:=err;
END;  (* of SetErrror *)


(*************************************************************************)

PROCEDURE InstallSeriellHandler;

  VAR
    dummy : BYTE;

    wert  : WORD;

BEGIN
  kanal:=1;
  WHILE (SeriellDiscriptor [kanal].Install = TRUE) AND (kanal <= MaxKanal) DO INC (kanal);
  IF (kanal <= MaxKanal) THEN BEGIN
    wert:=PORT [adr + $06];
    IF ((PORT [adr + $06] AND $0F) = 0) THEN BEGIN
      WITH SeriellDiscriptor [kanal] DO BEGIN

        Transmit:=TRUE;

        Top:=0;
        Bottom:=0;
        Anzahl:=0;

        CountInt:=0;
        CountInChar:=0;
        CountOutChar:=0;
        CountError:=0;
        CountOverflow:=0;

        TransmitMask:=RTSOutput;

        PortAdresse:=adr;
        PortIRQ:=irq;

        DisableInterrupt;

        OldIER:=PORT [PortAdresse + $01];

        adr:=PortAdresse + $04;
        OldMCR:=PORT [adr];
        PORT [adr]:=OldMCR AND $F7;            (* Alle Interrupts mit OUT 2 sperren  *)

        dummy:=PORT [PortAdresse + $02];
        IF ((dummy AND $C0) > 0) THEN
          NS16550Flag:=TRUE
        ELSE BEGIN
          PORT [PortAdresse + $02]:=$01;
          dummy:=PORT [PortAdresse + $02];
          NS16550Flag:=((dummy AND $C0) > 0);
        END;  (* of ELSE *)

        IF NS16550Flag THEN BEGIN
          IF FiFoAktiv THEN
            PORT [PortAdresse + $02]:=$E1
          ELSE PORT [PortAdresse + $02]:=0;
        END;  (* of IF *)

        dummy:=PORT [PortAdresse];
        dummy:=PORT [PortAdresse + $05];       (* Leitungsstatus-Register löschen    *)

        IF (PortIRQ <> 0) THEN BEGIN           (* Empfangsintr. nur bei IRQ <> 0 installieren *)

          IF (size > $7FFF) THEN size:=$7FFF;  (* Buffersize max. $7FFF            *)
          IF (MaxAvail < size) THEN            (* wenn zuwenig Platz auf dem Heap, *)
            BufferSize:=MaxAvail               (* dann wird der Buffer verkleinert *)
          ELSE BufferSize:=size;

          GetMem (Buffer,BufferSize);          (* Speicher für den Empfangsbuffer reservieren *)

          BufferFull:=WORD (LONGINT (BufferSize) * 90 DIV 100);
          IF (BufferFull < 10) THEN BufferFull:=10;

          PORT [PortAdresse + $01]:=$01;       (* Interrupt bei Empfang zulassen    *)

          adr:=PortAdresse + $04;
          wert:=PORT [adr];
          PORT [adr]:=wert OR TransmitMask OR $08;          (* Die Steuerleitungen setzen        *)

          IF (PortIRQ < 8) THEN BEGIN                        (* IRQ0 - IRQ7: erster 8259   *)
            GetIntVec ($08 + PortIRQ,OldVector);             (* Interrupt-Vektor retten    *)
            SetIntVec ($08 + PortIRQ,PortInterrupt);         (* und neu setzen             *)

            adr:=IntrCtrl1 + $01;
            OldIntMask:=PORT [adr];
            PORT [adr]:=OldIntMask AND ($FF XOR 1 SHL PortIRQ);
            OldIntMask:=OldIntMask AND (1 SHL PortIRQ);
          END  (* of IF THEN *)
          ELSE BEGIN                                         (* IRQ8 - IRQ15: zweiter 8259 *)
            GetIntVec ($70 + (PortIRQ - 8),OldVector);       (* Interrupt-Vektor retten    *)
            SetIntVec ($70 + (PortIRQ - 8),PortInterrupt);   (* und neu setzen             *)

            adr:=IntrCtrl2 + $01;
            OldIntMask:=PORT [adr];
            PORT [adr]:=OldIntMask AND ($FF XOR 1 SHL (PortIRQ - 8));
            OldIntMask:=OldIntMask AND (1 SHL (PortIRQ - 8));
          END;  (* of ELSE *)
        END  (* of IF THEN *)
        ELSE BEGIN
          Buffer:=NIL;                        (* Ohne Interrupt auch kein Puffer      *)
          OldIntMask:=$00;
        END;  (* of ELSE *)

        dummy:=PORT [PortAdresse];
        dummy:=PORT [PortAdresse + $05];       (* Leitungsstatus-Register löschen    *)

        EnableInterrupt;

        Install:=TRUE;                         (* Handler als belegt kennzeichenen     *)
        ClearError;
      END;  (* of WITH *)
    END  (* of IF THEN *)
    ELSE BEGIN
      kanal:=0;
      SetError (NoChip);
    END;  (* of ELSE *)
  END  (* of IF THEN *)
  ELSE BEGIN
    kanal:=0;                                  (* kanal = 0 wenn kein Handler frei ist *)
    SetError (NoHandler);
  END;  (* of ELSE *)
END;  (* of InstallSeriellHandler *)


(*************************************************************************)

PROCEDURE DeInstallSeriellHandler;

  VAR
    adr : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN          (* Nur gültige Handler bearbeiten     *)
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        IF (Buffer <> NIL) THEN BEGIN                        (* Wenn ein Empfangspuffer angelegt   *)
          FreeMem (Buffer,BufferSize);                       (* wurde, wird dieser vom Heap        *)
          Buffer:=NIL;                                       (* entfernt.                          *)
        END;  (* of IF *)

        DisableInterrupt;

        PORT [PortAdresse + $01]:=OldIER;                       (* alle Interrupts des 8250 sperren   *)

        PORT [PortAdresse + $04]:=OldMCR;

        IF (PortIRQ <> 0) THEN BEGIN                         (* Interrupt am 8259 sperren und den  *)
          IF (PortIRQ < 8) THEN BEGIN                        (* die Vektor-Adresse restaureien.    *)
            adr:=IntrCtrl1 + $01;
            PORT [adr]:=PORT [adr] OR OldIntMask;
            SetIntVec ($08 + PortIRQ,OldVector);
          END  (* of IF *)
          ELSE BEGIN
            adr:=IntrCtrl2 + $01;
            PORT [adr]:=PORT [adr] OR OldIntMask;
            SetIntVec ($70 + (PortIRQ - 8),OldVector);
          END;  (* of ELSE *)
        END;  (* of IF *)

        EnableInterrupt;

        Install:=FALSE;                        (* Handler freigeben                  *)
      END  (* of IF *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of DeInstallSeriellHandler *)


(*************************************************************************)

PROCEDURE GetHandlerInfo;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN          (* Nur gültige Handler bearbeiten     *)
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        adr:=PortAdresse;
        ir:=PortIRQ;
        buflen:=BufferSize;
      END  (* of IF *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of GetHandlerInfo *)


(*************************************************************************)

(* Lesen eines Zeichens vom seriellen Kanal <kanal> *)

FUNCTION SeriellRead; External;


(*************************************************************************)

(* Lesen eines Zeichens vom seriellen Kanal <kanal> *)

PROCEDURE SeriellCheckRead;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        IF (Anzahl > 0) THEN BEGIN
          zeichen:=Buffer^[Bottom];                (* Zeichen aus dem Puffer holen und     *)
          flag:=TRUE;
        END  (* of IF *)
        ELSE flag:=FALSE;

        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE SetError (WrongHandler);
END;  (* of SeriellCheckRead *)


(*************************************************************************)

PROCEDURE SeriellWrite; External;


(*************************************************************************)

PROCEDURE ClearSeriellBuffer;

  VAR
    adr : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        DisableInterrupt;

        Anzahl:=0;
        Top:=0;
        Bottom:=0;

        IF NOT (Transmit) THEN BEGIN                       (* Wenn der Puffer fast voll war,       *)
          IF (Anzahl < (BufferSize - $10)) THEN BEGIN      (* teste, ob wieder Platz vorhanden ist *)
            adr:=PortAdresse + $04;
            Port [adr]:=Port [adr] OR TransmitMask;        (* Wenn ja, Steuerleitungen setzen und  *)
            Transmit:=TRUE;                                (* das Flag für "Puffer voll" löschen.  *)
          END;  (* of IF *)
        END;  (* of IF *)

        EnableInterrupt;

        ClearError;
      END  (* of IF *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE SetError (WrongHandler);
END;  (* of ClearSeriellBuffer *)


(*************************************************************************)

FUNCTION ReceiverReady; External;


(*************************************************************************)

FUNCTION TransmitterReady;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        TransmitterReady:=((Port [PortAdresse + $05] AND $20) > 0);
      END  (* of IF *)
      ELSE TransmitterReady:=FALSE;
    END;  (* of WITH *)
    ClearError;
  END  (* of IF THEN *)
  ELSE BEGIN
    TransmitterReady:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of TransmitterReady *)


(*************************************************************************)

FUNCTION ClearToSend;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        ClearToSend:=((Port [PortAdresse + $06] AND $10) > 0);
      END  (* of IF *)
      ELSE ClearToSend:=FALSE;
    END;  (* of WITH *)
    ClearError;
  END  (* of IF *)
  ELSE BEGIN
    ClearToSend:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of ClearToSend *)


(*************************************************************************)

FUNCTION DataSetReady;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        DataSetReady:=((Port [PortAdresse + $06] AND $20) > 0);
      END  (* of IF *)
      ELSE DataSetReady:=FALSE;
    END;  (* of WITH *)
    ClearError;
  END  (* of IF *)
  ELSE BEGIN
    DataSetReady:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of DataSetReady *)


(*************************************************************************)

FUNCTION CarrierDetector;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        CarrierDetector:=((Port [PortAdresse + $06] AND $80) > 0);
      END  (* of IF *)
      ELSE CarrierDetector:=FALSE;
    END;  (* of WITH *)
    ClearError;
  END  (* of IF *)
  ELSE BEGIN
    CarrierDetector:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of CarrierDetector *)


(*************************************************************************)

FUNCTION BreakDetected;

  VAR
    adresse : WORD;

    break   : BOOLEAN;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        adresse:=PortAdresse + $05;
        break:=((Port [adresse] AND $08) > 0);
        IF break THEN Port [adresse]:=Port [adresse] AND $F7;
        BreakDetected:=break;
      END  (* of IF *)
      ELSE BreakDetected:=FALSE;
    END;  (* of WITH *)
    ClearError;
  END  (* of IF *)
  ELSE BEGIN
    BreakDetected:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of BreakDetected *)


(*************************************************************************)

PROCEDURE DataTerminalReady;

  VAR
    wert,
    adr   : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        adr:=PortAdresse + $04;
        wert:=PORT [adr];
        IF (zustand = On) THEN
          wert:=wert OR $01
        ELSE wert:=wert AND $FE;
        PORT [adr]:=wert;
        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of DataTerminalReady *)


(*************************************************************************)

PROCEDURE RequestToSend;

  VAR
    wert,
    adr   : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        adr:=PortAdresse + $04;
        wert:=PORT [adr];
        IF (zustand = On) THEN
          wert:=wert OR $02
        ELSE wert:=wert AND $FD;
        PORT [adr]:=wert;
        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of RequestToSend *)


(*************************************************************************)

PROCEDURE SendBreak;

  VAR
    breaktime : LONGINT;

    teiler,
    adr       : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        adr:=PortAdresse + $03;
        DisableInterrupt;
        PORT [adr]:=PORT [adr] OR $80;
        teiler:=PortW [PortAdresse];
        PORT [adr]:=PORT [adr] AND $7F;
        EnableInterrupt;
        breaktime:=teiler DIV 200;
        IF (breaktime < 1) THEN breaktime:=1;
        breaktime:=Ticker + breaktime;
        Port [adr]:=Port [adr] OR $40;
        REPEAT
        UNTIL (Ticker > breaktime);
        Port [adr]:=Port [adr] AND $BF;
        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SendBreak *)


(*************************************************************************)

PROCEDURE SetStatusMask;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    SeriellDiscriptor [kanal].LineMask:=(mask MOD $FF);
    ClearError;
  END  (* of IF THEN *)
  ELSE SetError (WrongHandler);
END;  (* of SetStatusMask *)


(*************************************************************************)

PROCEDURE SetTransmitMask;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    SeriellDiscriptor [kanal].TransmitMask:=(mask MOD $FF);
    ClearError;
  END  (* of IF THEN *)
  ELSE SetError (WrongHandler);
END;  (* of SetTransmitMask *)


(*************************************************************************)

FUNCTION SeriellStatus;

  VAR
    status : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        IF ((Port [PortAdresse + $05] AND $20) > 0) THEN
          SeriellStatus:=((Port [PortAdresse + $06] AND LineMask) = LineMask)
        ELSE SeriellStatus:=FALSE;
        ClearError;
      END  (* of IF *)
      ELSE BEGIN
        SeriellStatus:=FALSE;
        SetError (NotInstall);
      END;  (* of ELSE *)
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE BEGIN
    SeriellStatus:=FALSE;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of SeriellStatus *)


(*************************************************************************)

(* Vor Beendigung des Programmes werden alle noch installierten Handler *)
(* freigegeben.                                                         *)

{$F+}
PROCEDURE SeriellInterfaceExit;
{$F-}

   VAR
     adr : WORD;

BEGIN
  FOR i:=1 TO MaxKanal DO BEGIN
    WITH SeriellDiscriptor [i] DO BEGIN
      IF Install THEN BEGIN

        IF (Buffer <> NIL) THEN BEGIN                        (* Wenn ein Empfangspuffer angelegt   *)
          FreeMem (Buffer,BufferSize);                       (* wurde, wird dieser vom Heap        *)
          Buffer:=NIL;                                       (* entfernt.                          *)
        END;  (* of IF *)

        DisableInterrupt;

        PORT [PortAdresse + $01]:=OldIER;                       (* alle Interrupts des 8250 sperren   *)

        PORT [PortAdresse + $04]:=OldMCR;

        IF (PortIRQ <> 0) THEN BEGIN                         (* Interrupt am 8259 sperren und den  *)
          IF (PortIRQ < 8) THEN BEGIN                        (* die Vektor-Adresse restaureien.    *)
            adr:=IntrCtrl1 + $01;
            PORT [adr]:=PORT [adr] OR OldIntMask;
            SetIntVec ($08 + PortIRQ,OldVector);
          END  (* of IF *)
          ELSE BEGIN
            adr:=IntrCtrl2 + $01;
            PORT [adr]:=PORT [adr] OR OldIntMask;
            SetIntVec ($70 + (PortIRQ - 8),OldVector);
          END;  (* of ELSE *)
        END;  (* of IF *)

        EnableInterrupt;

        Install:=FALSE;                        (* Handler freigeben                  *)
      END;  (* of IF *)
    END;  (* of WITH *)
  END;  (* of FOR *)

  ExitProc:=altexitproc;
END;  (* of SeriellInterfaceExit *)


(*************************************************************************)

(* Programmieren der seriellen Übertragungsparameter. *)

PROCEDURE SetParameter;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        DisableInterrupt;
        basisadr:=PortAdresse;

        PORT[basisadr + 3]:=$80;
        wert:=WORD (115200 DIV rate);
        PORTW [basisadr]:=wert;

        wert:=0;

        CASE Parity OF
           Even : wert:=wert OR $18;
            Odd : wert:=wert OR $08;
           Mark : wert:=wert OR $28;
          Space : wert:=wert OR $38;
        END;  (* of CASE *)

        IF (stopbit = 2) THEN wert:=wert OR $04;

        wert:=wert + (wordlen - 5);

        Port [basisadr + $03]:=wert;

        wert:=Port [basisadr + $05];
        EnableInterrupt;
        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SetParameter *)


(*************************************************************************)

(* Programmieren der Baudrate <rate> der ser. Schnittstelle an  *)
(* der Basisadresse <basisadr>                                  *)

PROCEDURE SetBaudrate;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        DisableInterrupt;
        basisadr:=PortAdresse;
        PORT[basisadr + 3]:=PORT[basisadr + 3] OR $80;
        wert:=WORD (115200 DIV rate);
        PORTW [basisadr]:=wert;
        PORT[basisadr + 3]:=PORT[basisadr + 3] AND $7F;
        wert:=Port [basisadr + $05];
        ClearError;
        EnableInterrupt;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SetBaudrate *)


(*************************************************************************)

(* Ermitteln der Baudrate der ser. Schnittstelle an *)
(* der Basisdadresse <basisadr>.                    *)

FUNCTION GetBaudrate;

  VAR
    teiler,
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        DisableInterrupt;
        PORT [basisadr + 3]:=PORT [basisadr + 3] OR $80;
        teiler:=PORTW[basisadr];
        PORT [basisadr + 3]:=PORT [basisadr + 3] AND $7F;
        EnableInterrupt;
        IF (teiler <> 0) THEN
          GetBaudrate:=LONGINT (115200 DIV teiler)
        ELSE GetBaudrate:=75;
        ClearError;
      END  (* of IF *)
      ELSE BEGIN
        GetBaudrate:=75;
        SetError (NotInstall);
      END;  (* of ELSE *)
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE BEGIN
    GetBaudrate:=75;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetBaudrate *)


(*************************************************************************)

PROCEDURE SetParity;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        DisableInterrupt;
        wert:=Port [basisadr + $03];

        wert:=wert AND $C7;

        CASE Parity OF
           Even : wert:=wert OR $18;
            Odd : wert:=wert OR $08;
           Mark : wert:=wert OR $28;
          Space : wert:=wert OR $38;
        END;  (* of CASE *)

        Port [basisadr + $03]:=wert;

        wert:=Port [basisadr + $05];
        EnableInterrupt;
      END  (* of IF *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SetParity *)


(*************************************************************************)

FUNCTION GetParity;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        wert:=Port [basisadr + $03] AND $38;
        IF ((wert AND $08) > 0) THEN BEGIN
          wert:=wert SHR 4;
          CASE wert OF
            0 : GetParity:=Odd;
            1 : GetParity:=Even;
            2 : GetParity:=Mark;
            3 : GetParity:=Space;
          END;  (* of CASE *)
        END  (* of IF THEN *)
        ELSE GetParity:=None;
      END  (* of IF *)
      ELSE BEGIN
        GetParity:=None;
        SetError (NotInstall);
      END;  (* of ELSE *)
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE BEGIN
    GetParity:=None;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetParity *)


(*************************************************************************)

PROCEDURE SetStopBit;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        DisableInterrupt;
        wert:=Port [basisadr + $03];
        IF (stopbit = 2) THEN
          wert:=wert OR $04
        ELSE wert:=wert AND $FB;
        Port [basisadr + $03]:=wert;
        wert:=Port [basisadr + $05];
        EnableInterrupt;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE SetError (WrongHandler);
END;  (* of SetStopBit *)

(*************************************************************************)

FUNCTION GetStopBit;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        wert:=Port [basisadr + $03];
        IF ((wert AND $04) > 0) THEN
          GetStopBit:=2
        ELSE GetStopBit:=1;
      END  (* of IF *)
      ELSE BEGIN
        GetStopBit:=1;
        SetError (NotInstall);
      END;  (* of ELSE *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetStopBit:=1;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetStopBit *)


(*************************************************************************)

PROCEDURE SetWordLen;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        DisableInterrupt;
        wert:=Port [basisadr + $03];
        wert:=wert AND $FC;
        wert:=wert + (wordlen - 5);
        Port [basisadr + $03]:=wert;
        wert:=Port [basisadr + $05];
        EnableInterrupt;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SetWordLen *)

(*************************************************************************)

FUNCTION GetWordLen;

  VAR
    basisadr,
    wert      : WORD;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        basisadr:=PortAdresse;
        wert:=Port [basisadr + $03];
        GetWordLen:=(wert AND $03) + 5;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetWordLen:=5;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetWordLen:=5;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetWordLen *)


(*************************************************************************)

PROCEDURE ClearHandlerStatistic;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        CountInt:=0;
        CountInChar:=0;
        CountOutChar:=0;
        CountError:=0;
        CountOverflow:=0;
        ClearError;
      END  (* of IF THEN *)
      ELSE SetError (NotInstall);
    END;  (* of WITH *)
  END  (* of IF *)
  ELSE SetError (WrongHandler);
END;  (* of SetWordLen *)


(*************************************************************************)

FUNCTION GetIntCounter;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        GetIntCounter:=CountInt;
        ClearError;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetIntCounter:=0;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetIntCounter:=0;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetIntCounter *)


(*************************************************************************)

FUNCTION GetReceiveCounter;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        GetReceiveCounter:=CountInChar;
        ClearError;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetReceiveCounter:=0;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetReceiveCounter:=0;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetReceiveCounter *)


(*************************************************************************)

FUNCTION GetSendCounter;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        GetSendCounter:=CountOutChar;
        ClearError;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetSendCounter:=0;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetSendCounter:=0;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetSendCounter *)


(*************************************************************************)

FUNCTION GetErrorCounter;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        GetErrorCounter:=CountError;
        ClearError;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetErrorCounter:=0;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetErrorCounter:=0;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetErrorCounter *)


(*************************************************************************)

FUNCTION GetOverflowCounter;

BEGIN
  IF (kanal > 0) AND (kanal <= MaxKanal) THEN BEGIN
    WITH SeriellDiscriptor [kanal] DO BEGIN
      IF Install THEN BEGIN
        GetOverflowCounter:=CountOverflow;
        ClearError;
      END  (* of IF THEN *)
      ELSE BEGIN
        GetOverflowCounter:=0;
        SetError (NotInstall);
      END;  (* of IF *)
    END;  (* of WITH *)
  END  (* of IF THEN *)
  ELSE BEGIN
    GetOverflowCounter:=0;
    SetError (WrongHandler);
  END;  (* of ELSE *)
END;  (* of GetOverflowCounter *)


(*************************************************************************)

BEGIN
  HandlerSize:=SizeOf (SeriellDiscrType);

  FOR i:=1 TO MaxKanal DO BEGIN
    WITH SeriellDiscriptor [i] DO BEGIN
      Install:=FALSE;
      Buffer:=NIL;
      OldVector:=NIL;
    END;  (* of WITH *)
  END;  (* of FOR *)

  SeriellDiscriptor [1].PortInterrupt:=@SeriellIntrProc1;
  SeriellDiscriptor [2].PortInterrupt:=@SeriellIntrProc2;
  SeriellDiscriptor [3].PortInterrupt:=@SeriellIntrProc3;
  SeriellDiscriptor [4].PortInterrupt:=@SeriellIntrProc4;
  SeriellDiscriptor [5].PortInterrupt:=@SeriellIntrProc5;
  SeriellDiscriptor [6].PortInterrupt:=@SeriellIntrProc6;
  SeriellDiscriptor [7].PortInterrupt:=@SeriellIntrProc7;
  SeriellDiscriptor [8].PortInterrupt:=@SeriellIntrProc8;

  altexitproc:=ExitProc;
  ExitProc:=@SeriellInterfaceExit;

  SeriellError:=0;
  SeriellOk:=TRUE;
  FiFoAktiv:=TRUE;
END.  (* of UNIT SeriellInterface *)