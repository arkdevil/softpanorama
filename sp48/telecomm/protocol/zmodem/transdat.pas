UNIT TransData;

INTERFACE

VAR
  TransferTime,               (* Startzeitpunkt der Übertragung in Tick's   *)
  TransferSize,               (* Grösse des zu übertragenden Files          *)
  TransferCount,              (* Anzahl der schon übertragenen Zeichen      *)
  TransferBytes : LONGINT;    (* aktuelle Anzahl übertragene Zeichen        *)

  TransferName,               (* Name des zu übertragenen Files             *)
  TransferCheck,              (* Bezeichnung des Checksummen-Verfahrens     *)
  TransferMessage : STRING;   (* Meldungen der Transferroutine              *)

  TransferTotalTime,          (* Voraussichtliche Übertragungsdauer in Sek. *)
  TransferBlockSize,          (* Grösse des letzen Datenblockes             *)
  TransferError : WORD;       (* Anzahl der erkannten Übertragungsfehler    *)

  FileAddition : (NewFile,RecoverFile,ReplaceFile);

IMPLEMENTATION

END.
