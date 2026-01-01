UNIT TPZFiles;
(* File manipulation routines for Turbo Pascal Zmodem *)
(* (c)1988 by J.R.Louvau                              *)
INTERFACE
USES Dos;

FUNCTION  Z_OpenFile(VAR f: FILE; pathname: STRING): BOOLEAN;
(* Return true if able to open an existing file *)
FUNCTION  Z_MakeFile(VAR f: FILE; pathname: STRING): BOOLEAN;
(* Return true if able to create a file *)
PROCEDURE Z_CloseFile(VAR f: FILE);
(* Closes a file and ignores errors *)
FUNCTION  Z_SeekFile(VAR f: FILE; fpos: LONGINT): BOOLEAN;
(* Find a byte position within a file *)
FUNCTION  Z_WriteFile(VAR f: FILE; VAR buff; bytes: WORD): BOOLEAN;
(* Read a specified number of bytes from a file *)
FUNCTION  Z_ReadFile(VAR f: FILE; VAR buff; btoread: WORD; VAR bread: WORD): BOOLEAN;
(* Search for a named file *)
FUNCTION  Z_FindFile(pathname: STRING; VAR name: STRING; VAR size, time: LONGINT): BOOLEAN;
(* Set time and date of a file *)
PROCEDURE Z_SetFTime(VAR f: FILE; time: LONGINT);

IMPLEMENTATION

  CONST
    DiskBufferSize = $7FFF;

  VAR
    diskbuffer : ARRAY [0..DiskBufferSize] OF CHAR;

    bufferpos  : WORD;


(*************************************************************************)

FUNCTION Z_OpenFile(VAR f: FILE; pathname: STRING): BOOLEAN;
BEGIN {$I-}
   Assign(f,pathname);
   Reset(f,1);
   bufferpos:=0;
   Z_OpenFile := (IOresult = 0);
END; {$I+}

FUNCTION Z_MakeFile(VAR f: FILE; pathname: STRING): BOOLEAN;
BEGIN {$I-}
   Assign(f,pathname);
   ReWrite(f,1);
   bufferpos:=0;
   Z_MakeFile := (IOresult = 0)
END; {$I+}

PROCEDURE Z_CloseFile(VAR f: FILE);
BEGIN {$I-}
   IF (bufferpos > 0) THEN BEGIN
     BlockWrite (f,diskbuffer,bufferpos);
     IF (IOResult <> 0) THEN;
   END;  (* of IF *)
   Close(f);
   IF (IOresult <> 0) THEN
      { ignore this error }
END; {$I+}

FUNCTION Z_SeekFile(VAR f: FILE; fpos: LONGINT): BOOLEAN;
BEGIN {$I-}
   Seek(f,fpos);
   Z_SeekFile := (IOresult = 0)
END; {$I+}

FUNCTION Z_WriteFile(VAR f: FILE; VAR buff; bytes: WORD): BOOLEAN;

BEGIN {$I-}
   IF ((bufferpos + bytes) > DiskBufferSize) THEN BEGIN
     BlockWrite(f,diskbuffer,bufferpos);
     bufferpos:=0;
   END;  (* of IF *)
   Move (buff,diskbuffer [bufferpos],bytes);
   INC (bufferpos,bytes);
   Z_WriteFile := (IOresult = 0)
END; {$I+}

FUNCTION Z_ReadFile(VAR f: FILE; VAR buff; btoread: WORD; VAR bread: WORD): BOOLEAN;
BEGIN {$I-}
   BlockRead(f,buff,btoread,bread);
   Z_ReadFile := (IOresult = 0)
END; {$I+}

FUNCTION Z_FindFile(pathname: STRING; VAR name: STRING; VAR size, time: LONGINT): BOOLEAN;
VAR
   sr: SearchRec;
BEGIN {$I-}
   FindFirst(pathname,Archive,sr);
   IF (DosError <> 0) OR (IOresult <> 0) THEN BEGIN
      Z_FindFile := FALSE;
      Exit
   END;
   name := sr.Name;
   size := sr.Size;
   time := sr.Time;
   Z_FindFile := TRUE
END; {$I+}

PROCEDURE Z_SetFTime(VAR f: FILE; time: LONGINT);
BEGIN {$I-}
   SetFTime(f,time);
   IF (IOresult <> 0) THEN
      {null}
END; {$I+}

END.
