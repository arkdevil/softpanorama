;E 1.0.  Copyright (C) David Nye, 1990, all rights reserved.
;Assemble with TASM.  Link: tlink /t e (makes a .COM file).

IDEAL
;Constants

LINEWIDTH       EQU 80          ;Length of string storage for line
SCREENLENGTH    EQU 24          ;Number of rows in display window
MAXLINES        EQU 8096        ;Size of arrays of line pointers
BUFFERLENGTH    EQU 1200h       ;Length of file buffer
STACKSIZE       EQU 50h         ;Length of stack
BELL            EQU 7           ;Some non-printing chars
BS              EQU 8
HT              EQU 9
LF              EQU 10
CR              EQU 13
CRLF            EQU 0A0Dh
CTRL_Z          EQU 26
ESCAPE          EQU 27
DEL             EQU 127
PROGLENGTH = EndOfProgram - Orig + 100h  ;Length of .COM file


;Create a named string
MACRO String Name, Text
        LOCAL LL
Name    db LL-Name-1, Text
LL:
ENDM

;Make <Name> a byte ptr to <Length> bytes of storage after end of code.
;Like a .DATA? segment for .COM file, so uninitialized data doesn't take up
;room in the .COM file.
MACRO B? Name, Length
        LOCAL where
        where = EndOfProgram + BuffersCount
Name    EQU BYTE PTR where
        BuffersCount = BuffersCount + Length
ENDM

;Like B? but for word storage
MACRO W? Name, Length
        LOCAL where
        where = EndOfProgram + BuffersCount
Name    EQU WORD PTR where
        BuffersCount = BuffersCount + Length + Length
ENDM

BuffersCount = 0


MODEL TINY
CODESEG
ORG 100h
Orig:
jmp Start

String copyRight 'E 1.0.  Copyright (C) David Nye, 1990.  All rights reserved.'

;Some defaults, use Debug to change

colorAttributes dw 1770h        ;Default status, text color video attributes
tabSize         db 4            ;Tab increment
inserting?      db -1           ;True if in insert mode
autoIndent?     db -1           ;True if in autoindent mode
startInText?    db 0            ;Set to true to start up in text mode
zLMargin        db 8            ;Left margin setting for Alt Z
zRMargin        db LINEWIDTH-8  ;Right margin setting for Alt Z


;Strings

String cantOpenMsg,     "Can't open file."
String rdErrorMsg,      'Error reading file.'
String fileErrorMsg,    'File error.'
String noRoomMsg,       'Out of memory.'
String notMarkingMsg,   'Not marking.'
String setLabelMsg,     'Label (0-9): '
String setTabsMsg,      'Tab width: '
String newFileMsg,      'File name: '
String gotoMsg          'Jump to what line? '
String editingMsg       <'Help F1',186,'Editing: '>
String findMsg          'Find: '
String replaceMsg       'Replace with: '
String notFoundMsg      'No more matching strings found.'
String anyKeyMsg        'Press any key to continue.'
String ctrlCMsg         '*Break*'
String cancelledMsg     'Cancelled.'
BAK                     db  '.BAK', 0
comspec$                db  'COMSPEC='
helpMsg                 db 'CURSOR left           left arrow, ^S    '
                        db 'BLOCK begin                 @B          '
                        db '  right               right arrow, ^D   '
                        db '  copy block to buffer      @C *        '
                        db '  word left           ^left arrow, ^A   '
                        db '  delete block to buffer    @D *        '
                        db '  word right          ^right arrow, ^F  '
                        db '  insert block from buffer  @I *        '
                        db '  tab right, left     Tab, Shift Tab    '
                        db '  empty block buffer        @E *        '
                        db '  start, end of line  Home, End         '
                        db '  unmark                    @U          '
                        db '  line up             up arrow, ^E      '
                        db 'FIND                        @F +        '
                        db '  line down           down arrow, ^X    '
                        db '  replace                   @R +        '
                        db '  page up             PgUp, ^R          '
                        db '  find/replace all          @A +        '
                        db '  page down           PgDn, ^C          '
                        db 'SAVE and continue           @S          '
                        db '  start of file       ^PgUp             '
                        db '  save and exit             @X          '
                        db '  end of file         ^PgDn             '
                        db '  kill (no save at exit)    @K          '
                        db 'DELETE                Del               '
                        db '  open another file         @O          '
                        db '  backspace           Backspace         '
                        db 'JUMP to line #              @J          '
                        db '  delete word left    ^[                '
                        db '  set, goto label (0-9)     @L, @G      '
                        db '  delete word right   ^], ^T            '
                        db 'MARGIN set L, R             ^Home, ^End '
                        db '  delete rest of line ^\                '
                        db '  wrap paragraph            @W          '
                        db '  delete line         ^-, ^Y            '
                        db '  set tabs                  @T          '
                        db '  undelete line       ^^                '
                        db '  toggle autoindent         ^@          '
                        db 'INSERT mode toggle    Ins               '
                        db '  toggle text/prog mode     @Z          '
                        db '  insert raw char     @= (+80h w shift) '
                        db 'SHELL to DOS, run EFn.BAT   F2, F3-F6 * '
                        db 80 dup (' ')
                        db '@ = Alt, ^ = Ctrl, * = to/from file if s'
                        db 'hifted, + = use last string if shifted. '
                        db 'Status line flags:  Insert  Overwrite  C'
                        db 'hanged  AutoIndent  [ LMargin  ] RMargin'


;EXEC function parameter block

EXECParams      dw 0
EXECCmdLineOff  dw 0
EXECCmdLineSeg  dw 0, -1, -1 , -1 , -1
EXECBAT         db 0, '/c EF'
EXECFnumber     db 'x.BAT '
EXECFileName    db 20 dup (0)

;Variables

newFile?        db 0            ;True if new file
marking?        db 0            ;True if marking text
changed?        db 0            ;True if original file has been changed
isBAKed?        db 0            ;True if .BAK file already written
needCopies?     db -1           ;True unless lines in buffer were just deleted
autoReplace?    db 0            ;-1 if auto-replace with shift, 1 without shift
noEscape?       db 0            ;True if prompt demands response
labelTable      dw 10 dup (0)   ;Table of line pointers assigned to labels

;These variables and buffers are allocated space following .COM file
W? sstack, STACKSIZE            ;Stack goes here
STACKTOP = EndOfProgram + BuffersCount
B? attribNl, 1                  ;Text and status line attributes
B? attribInv, 1
W? cursorShape, 1               ;Line cursor parameters for color or mono
B? fName?, 1                    ;True if file name given on command line
B? justFound?, 1                ;True if no other commands since last Find
B? swapped?, 1                  ;True if edited file swapped out during EXEC
W? lMargin, 1                   ;Current margins
W? rMargin, 1
W? fHandle, 1                   ;File handle
W? lastLine, 1                  ;Index of last line in file
W? blockPtrsLast, 1             ;Index of last line in block buffer
W? top, 1                       ;Index of first line on screen
W? bottom, 1                    ;Index of last line on screen
W? mark, 1                      ;Start of marking for block command
W? here, 1                      ;Temporaries
W? spTemp, 1
W? comspecPtrOff, 1             ;Pointer to COMSPEC value: offset, segment
W? comspecPtrSeg, 1
W? bufferPtr, 1                 ;Multipurpose buffer pointer
W? hereCol, 1
W? topSegPtr, 1
W? topSeg, 1
W? topIndex, 1
W? videoSegment, 1              ;Segment of system's video memory
W? heapStart, 1                 ;Segment of start of heap
W? heapPtr, 1                   ;Segment pointer to next free paragraph in heap
B? fName, 20                    ;File name in ASCIIZ format
ESSENTIALS = BuffersCount       ;Buffers above here not saved with shell + swap
B? fNameBAK, LINEWIDTH          ;Current file with .BAK extension added
B? fNameTemp, LINEWIDTH         ;File name for block read/writes, shell
B? pad, LINEWIDTH               ;Scratch buffer
B? findString, LINEWIDTH        ;Search string for Find command
B? replaceString, LINEWIDTH     ;New string for Replace command
W? linePtrs, MAXLINES           ;List of line pointers
W? blockPtrs, MAXLINES          ;Line pointers for block or line deletes
B? buffer, BUFFERLENGTH         ;File buffer
ENDFBUFFER = BuffersCount

;Jump tables:   ^ = Ctrl, @ = Alt, # = Shift.
ctrlTable       dw na           ;Undefined
                dw WordLeft     ;^A
                dw na           ;^B
                dw PageDown     ;^C
                dw Right        ;^D
                dw Up           ;^E
                dw WordRight    ;^F
                dw na           ;^G or BEL
                dw BackSpace    ;^H or BS
                dw Tab          ;^I or HT
                dw na           ;^J or LF
                dw na           ;^K or VT
                dw na           ;^L or FF
                dw CRet         ;^M or CR
                dw na           ;^N or SO
                dw na           ;^O or SI
                dw na           ;^P
                dw na           ;^Q or DC1
                dw PageUp       ;^R or DC2
                dw Left         ;^S or DC3
                dw DeleteWordR  ;^T or DC4
                dw na           ;^U
                dw na           ;^V
                dw na           ;^W
                dw Down         ;^X or CAN
                dw DeleteLine   ;^Y
                dw na           ;^Z
                dw DeleteWordL  ;^[
                dw DeleteToEOL  ;^\
                dw DeleteWordR  ;^]
                dw UndeleteLine ;^^
                dw DeleteLine   ;^-

auxTable        dw 3 DUP (na)   ;Undefined
                dw AutoIndent   ;^@ or NUL
                dw 11 DUP (na)  ;Undefined
                dw ReverseTab   ;#Tab
                dw na           ;@Q
                dw Wrap         ;@W
                dw EmptyBuffer  ;@E
                dw Replace      ;@R
                dw SetTabs      ;@T
                dw na           ;@Y
                dw Unmark       ;@U
                dw InsertBlock  ;@I
                dw OtherFile    ;@O
                dw na           ;@P
                dw 4 DUP (na)   ;Undefined
                dw ReplaceAll   ;@A
                dw Save         ;@S
                dw DeleteBlock  ;@D
                dw Find         ;@F
                dw GotoLabel    ;@G
                dw Help         ;@H
                dw Jump         ;@J
                dw Kill         ;@K
                dw SetLabel     ;@L
                dw 5 DUP (na)   ;Undefined
                dw ToggleWPMode ;@Z
                dw Exit         ;@X
                dw Copy         ;@C
                dw na           ;@V
                dw BeginBlock   ;@B
                dw na           ;@N
                dw na           ;@M
                dw 8 DUP (na)   ;Undefined
                dw Help         ;F1
                dw Shell        ;F2
                dw F3BAT        ;F3
                dw F4BAT        ;F4
                dw F5BAT        ;F5
                dw F6BAT        ;F6
                dw na           ;F7
                dw na           ;F8
                dw na           ;F9
                dw na           ;F10
                dw 2 DUP (na)   ;Undefined
                dw HomeLine     ;Home
                dw Up           ;Up arrow
                dw PageUp       ;PgUp
                dw na           ;Undefined
                dw Left         ;Left arrow
                dw na           ;Undefined
                dw Right        ;Right arrow
                dw na           ;Undefined
                dw EndLine      ;End
                dw Down         ;Down arrow
                dw PageDown     ;PgDn
                dw ToggleIns    ;Ins
                dw Delete       ;Del
                dw na           ;#F1
                dw Shell        ;#F2
                dw F3BAT        ;#F3
                dw F4BAT        ;#F4
                dw F5BAT        ;#F5
                dw F6BAT        ;#F6
                dw na           ;#F7
                dw na           ;#F8
                dw na           ;#F9
                dw na           ;#F10
                dw 20 DUP (na)  ;[^Fn, @Fn]
                dw na           ;^PrtSc
                dw WordLeft     ;^Left arrow
                dw WordRight    ;^Right arrow
                dw SetRMargin   ;^End
                dw BottomFile   ;^PgDn
                dw SetLMargin   ;^Home
                dw 10 DUP (na)  ;[Alt numbers]
                dw na           ;@-
                dw InsertRaw    ;@=
                dw TopFile      ;^PgUp

;******************************************************************************

Start:
  mov ax, cs
  mov ds, ax
  mov es, ax
  mov [EXECCmdLineSeg], ax      ;Store current segment for EXEC function
  add ax, ((PROGLENGTH + ENDFBUFFER) SHR 4) + 1
  mov [heapStart], ax           ;Compute start of free memory in paragraphs
  mov sp, OFFSET STACKTOP
  mov si, 80h                   ;Make pointer to command tail
  mov cl, [si]                  ;Get filename length
  sub ch, ch
  mov [fName?], cl              ;Save a copy
  mov al, ' '                   ;Skip leading blanks
@@L1:
  inc si
  cmp al, [si]
  loope @@L1
  inc cx
  mov di, OFFSET fName          ;Move command tail to FName
  rep movsb
  sub al, al                    ;Make ASCIIZ string
  stosb
  mov ax, 2523h                 ;Redirect Ctrl C handler
  mov dx, OFFSET Cancel
  int 21h
  mov ah, 0Fh                   ;Set defaults for color or mono adapter
  int 10h
  mov bx, 0B000h                ;If mode 7 (= MDA or Herc), video seg=B000h,
  mov cx, 0770h                 ;Use nl, inv video for text, status line
  mov dx, 0C0Dh                 ;Set cursor shapes for mono
  cmp al, 7
  je @@L2
  mov bx, 0B800h                ;Otherwise video seg=B800h,
  mov cx, [colorAttributes]     ;Use default color attributes,
  mov dx, 0607h                 ;Color cursor size
@@L2:
  xor ax, ax                    ;Code to allow E to run under DESQview,
  mov es, ax                    ; contributed by Mike Robertson (bix:seamus)
  mov ah, 0FEh
  int 10
  or al, al
  jne @@L3a
  mov ax, es
  or ax, ax
  je @@L3a
  mov bx, es
@@L3a:
  mov [videoSegment], bx
  mov [attribNl], ch
  mov [attribInv], cl
  mov [cursorShape], dx
  mov es, [2Ch]                 ;Find COMSPEC
  sub di, di
@@L3:
  mov si, OFFSET comspec$
  mov cx, 8
  repe cmpsb
  jne @@L3
  mov [comspecPtrOff], di
  mov [comspecPtrSeg], es

InitFile:
  mov dx, OFFSET fName          ;Open file and set up list of line pointers
  cmp [fName?], 0               ;If no file name specified on command line,
  jne @@L0
  mov [noEscape?], -1           ;Prompt for it
  call GetFileName
@@L0:
  call OpenFile
  mov [lMargin], 0              ;Set initial margins
  mov [rMargin], LINEWIDTH - 1
  cmp [startInText?], 0
  je NextKey
  call ToggleWPMode

NextKey:
  call Redraw                   ;Redraw screen, status line
NextNoRedraw:
  call DrawCursor               ;Place cursor
  sub ah, ah                    ;Get keypress to AL
  int 16h
  or al, al                     ;Check for control codes
  je IsAux
  cmp al, ' '
  jb IsCtrl
  call Insert                   ;Insert or overwrite if none
  jmp NextKey

IsAux:
  xchg al, ah                   ;Get aux code
  cmp al, 132
  ja NextKey
  mov si, OFFSET auxTable       ;Jump indirect to appropriate routine
DoTableJump:
  shl ax, 1
  add si, ax
  call [WORD si]
  jmp NextKey

IsCtrl:
  mov si, OFFSET ctrlTable      ;Jump to routine through table
  sub ah, ah
  jmp DoTableJump

InsertRaw:
  call Shifted?                 ;Set flag if shifted
  mov dl, al
  sub ah, ah                    ;Get keypress to AL
  int 16h
  or al, al                     ;Check for aux code, ignore InsertRaw if found
  je IsAux
  cmp dl, 0                     ;If shift was down set high bit
  jz @@L1
  or al, 80h
@@L1:
  call Insert                   ;Insert
  jmp NextKey

OtherFile:
;Open another file
  call Save                     ;Save current file if altered
  mov ax, [blockPtrsLast]       ;If block buffer is empty,
  sub ax, OFFSET blockPtrs
  jne @@L2
  mov ax, [heapStart]           ; reset heap pointer to start
  mov [heapPtr], ax
  jmp GetOther                  ; prompt for new file name
@@L2:
  shr ax, 1                     ;Else move lines with pointers in block buffer
  mov cx, ax                    ; to start of heap (load new file above them)
  mov dl, 5
  mul dl
  add ax, [heapStart]           ;Calculate upper limit of target zone
  mov [heapPtr], ax             ; which will also be new value of heap pointer
  mov bx, OFFSET blockPtrs      ;For each pointer in block buffer,
@@L3:
  cmp [bx], ax                  ;If its line is already within target zone,
  jae @@L4
  mov es, [bx]                  ;Set high bit of first char in line to mark it
  or [byte es:0], 80h           ; (we won't need to move these lines)
@@L4:
  inc bx                        ;Next pointer
  inc bx
  loop @@L3
  push ds
  mov bx, OFFSET blockPtrs      ;For each pointer in block buffer:
  mov es, [heapStart]
@@L4a:
  test [byte es:0], 80h         ;If high bit set in target line,
  jne @@L7                      ; line already in use, try next target line
  mov ds, [cs:bx]               ;If high bit set in source line,
  test [byte 0], 80h
  je @@L5                       ; don't need to move it (already there)
  inc bx                        ; Next source line, same target line
  inc bx
  jmp SHORT @@L8
@@L5:
  mov cx, 40                    ;Else move one line
  sub si, si
  sub di, di
  rep movsw
  mov [cs:bx], es               ;Update pointer
@@L6:
  inc bx                        ;Next block pointer
  inc bx
@@L7:
  mov ax, es                    ;Next target line
  add ax, 5
  mov es, ax
@@L8:
  segcs                         ;Loop until all lines moved
  cmp bx, [blockPtrsLast]
  jb @@L4a
  pop ds
  mov bx, OFFSET blockPtrs      ;Reset high bits of all first chars set high
@@L9:
  mov es, [bx]
  and [byte es:0], 7Fh
  inc bx
  inc bx
  cmp bx, [blockPtrsLast]
  jb @@L9
GetOther:
  mov [noEscape?], -1
  mov dx, OFFSET fName          ;Prompt for new file name
  call GetFileName
  jmp SHORT OpenFile1           ;Read in new file above block buffer lines

OpenFile:
;Open file, load if found, then close.  Call with dx -> ASCIIZ file name.
  mov ax, OFFSET blockPtrs      ;Reset block buffer pointer
  mov [blockPtrsLast], ax
  mov ax, [heapStart]           ;Begin loading at start of heap
  mov [heapPtr], ax
OpenFile1:
  mov [newFile?], 0
  mov [changed?], 0
  mov ax, 3D80h                 ;Try to open file
  int 21h
  jnc OldFile
  mov [newFile?], -1            ;If no such file, remind me to create a new one
OpenNewFile:
  call NewFile
  jmp XOpenFile
OldFile:
  mov [fHandle], ax             ;Else save file handle
  mov bx, OFFSET linePtrs       ;Read file in
  mov dx, ax
  call ReadFile
  dec bx
  dec bx
  mov [lastLine], bx            ;Save index of last line
  mov bx, [fHandle]             ;Close file
  mov ah, 3Eh
  int 21
XOpenFile:
  mov bx, OFFSET linePtrs       ;Reset row, screen pointers
  mov [top], bx
  mov es, [bx]
  sub di, di
  ret

GetFileName:
;Prompt for file name.  Abort if null name.  Call with buffer address in DX.
  push si
  push dx
  mov si, OFFSET newFileMsg     ;Print prompt
  call Prompt
  pop dx
  call GetString                ;Get file name
  mov si, dx                    ;Convert to ASCIIZ
  add si, ax
  mov [BYTE si], 0
  pop si
  ret

GetString:
;Get string to [DX], return count (minus CR/LF) in AX.  Abort if null string.
  push bx
  push cx
  push si
  push di
  push es
  push dx
@@L2:
  mov dx, OFFSET pad            ;Get string
  mov ah, 3Fh
  sub bx, bx
  mov cx, 20
  int 21h
  dec ax                        ;Strip CR/LF
  dec ax
  jnz @@L1                      ;Abort if null string
  cmp [noEscape?], 0            ; unless escape precluded
  je @@L0
  call Beep
  mov si, OFFSET newFileMsg
  call Prompt
  jmp @@L2
@@L0:
  mov si, OFFSET cancelledMsg
  jmp Abort
@@L1:
  mov cx, ax                    ;Copy temporary copy of string to [DX]
  pop dx
  push ax
  mov ax, ds
  mov es, ax
  mov si, OFFSET pad
  mov di, dx
  rep movsb
  pop ax
  pop es
  pop di
  pop si
  pop cx
  pop bx
  mov [noEscape?], 0
  ret

ReadFile:
;Load file with handle in DX, assigning segment pointers starting at BX
  push es
  mov ax, [heapPtr]
  mov es, ax
  sub cx, cx
  sub di, di
FillBuffer:
  push bx                       ; Fill buffer
  push cx
  push dx
  mov bx, dx
  mov ah, 3Fh
  mov cx, BUFFERLENGTH
  mov dx, OFFSET buffer
  int 21h
  jnc @@L1                      ; Check for read error
  jmp ReadError
@@L1:
  pop dx
  pop cx
  pop bx
  mov si, OFFSET buffer         ; Set pointers
  add ax, si
  mov [bufferPtr], ax
  cmp ax, OFFSET buffer         ;Exit if empty buffer
  je EndOfFile
  cmp [byte si], LF             ;Skip LF if first char in buffer
  jne SHORT NextLine
  inc si
NextLine:
  mov al, [si]                  ;Get next char
  cmp al, CR                    ;If char is CR, end of line
  jne @@L2
  inc si                        ; move past CR
  cmp [byte si], LF             ; and LF if present
  jne @@L1
  inc si
@@L1:
  call EndOfLine                ; pad out line with spaces and save it
  jmp SHORT @@L3
@@L2:
  cmp al, HT                    ;Else if a tab, expand it
  jne @@L2a
  push cx
  mov al, ' '
  mov cl, [tabSize]
  sub ch, ch
  rep stosb
  pop cx
  sub cl, [tabSize]
  sbb ch, 0
  inc si
  jmp SHORT @@L3
@@L2a:
  movsb                         ;Else add char to line
  dec cx
@@L3:
  cmp si, [bufferPtr]           ;Loop until end of buffer
  jb NextLine
  cmp si, OFFSET ENDFBUFFER     ;If buffer less than full, indicates end of file
  jae FillBuffer
EndOfFile:
  call EndOfLine                ;Finish up present line
  mov [heapPtr], es             ;Update pointer to start of free heap space
  pop es
  ret

EndOfLine:
  add cx, LINEWIDTH             ;Pad to end with spaces
  jle @@L1                      ;Truncate lines longer than LINEWIDTH chars
  mov al, ' '
  rep stosb
@@L1:
  mov [bx], es                  ;Store segment of this line
  mov ax, es                    ;Next line
  add ax, 5
  cmp ax, 0A000h                ;Out of room?
  jb SHORT @@L2
  jmp NoRoom
@@L2:
  mov es, ax
  inc bx
  inc bx
  sub di, di
  sub cx, cx
Ret3:
  ret

Redraw:
;Redraw screen and status line
  mov [here], bx
  mov [hereCol], di
  push bx
  push di
  push ds
  push es
  push di
  mov es, [videoSegment]        ;Get segment for display
  mov si, OFFSET editingMsg     ;Refresh status line:  "Editing ..."
  call Prompt
  mov di, 34                    ;Tab to column 17
  mov si, OFFSET fName          ; <file name>
  mov ah, [attribInv]
@@S1:
  lodsb
  or al, al
  je @@S2
  stosw
  jmp @@S1
@@S2:
  add di, 6                     ;3 spaces
  mov al, 'L'                   ;"L" <line #>
  stosw
  inc di
  inc di
  mov ax, bx
  sub ax, OFFSET linePtrs
  shr ax, 1
  inc ax
  call PrintInt
  add di, 4                     ;2 spaces
  mov al, 'C'                   ;"C" <column number>
  mov ah, [attribInv]
  stosw
  inc di
  inc di
  pop ax                        ;Get copy of DI as cursor row
  inc ax
  call PrintInt
  mov di, LINEWIDTH * 2 - 12    ;Tab to start of status chars display
  mov al, 'I'                   ;Insert/Overwrite status
  mov ah, [attribInv]
  test [inserting?], -1
  jne @@S3
  mov al, 'O'
@@S3:
  stosw
  mov al, 'C'                   ;Changed status
  test [changed?], -1
  jne @@S5
  mov al, ' '
@@S5:
  stosw
  mov al, 'A'                   ;Autoinsert status
  test [autoIndent?], -1
  jne @@S6
  mov al, ' '
@@S6:
  stosw
  mov al, ' '                   ;L margin set?
  cmp [lMargin], 0
  je @@S7
  mov al, '['
@@S7:
  stosw
  mov al, ' '                   ;R margin set?
  cmp [rMargin], LINEWIDTH - 1
  je @@S8
  mov al, ']'
  stosw
@@S8:
  segcs
  mov al, [attribNl]            ;Mark margins as non-inv chars in status line
  mov di, [lMargin]
  add di, di
  je @@S8a
  inc di
  stosb
@@S8a:
  mov di, [rMargin]
  cmp di, LINEWIDTH - 1
  je @@S8b
  add di, di
  inc di
  stosb
@@S8b:
  mov di, LINEWIDTH * 2         ;Move to next display line
  mov ax, [top]                 ;Compute bottom of screen
  mov bx, ax
  add ax, (SCREENLENGTH - 1) * 2
  cmp ax, [lastLine]            ;If at end of file,
  jle @@L0
  mov ax, [lastLine]            ; stop at lastLine
@@L0:
  mov [bottom], ax
@@L1:                           ;For each row
  mov cx, LINEWIDTH             ;Count of chars per row
  mov ds, [cs:bx]               ;Get pointer to screen line
  sub si, si                    ;Initialize column counter
  segcs
  mov ah, [attribNl]            ;Attribute = inverse video if Marked
  test [cs:marking?], -1
  je @@L2
  segcs
  cmp bx, [mark]
  je @@L1b
  jb @@L1a
  segcs
  cmp bx, [here]
  jbe @@L1b
  jmp SHORT @@L2
@@L1a:
  segcs
  cmp bx, [here]
  jb @@L2
@@L1b:
  segcs
  mov ah, [attribInv]
@@L2:                           ;For each char, write char and attribute
  lodsb
  stosw
  loop @@L2                     ;Next char
  inc bx                        ;Next row
  inc bx
  segcs
  cmp bx, [bottom]              ;Stop if screen full
  jle @@L1
  mov cx, LINEWIDTH * 2 * (SCREENLENGTH + 1)  ;Fill out screen with blanks
  sub cx, di
  shr cx, 1
  segcs
  mov ah, [attribNl]
  mov al, ''
  rep stosw
@@L3:
  pop es
  pop ds
  pop di
  pop bx
  ret

DrawCursor:
;Set cursor shape and place it on screen
  push bx
  mov cx, [cursorShape]         ;Set cursor shape: line for insert mode,
  test [Inserting?], -1
  jne @@L1
  sub ch, ch                    ;Block for overwrite
@@L1:
  mov ah, 1
  int 10h
  sub bx, [top]                 ;Show cursor at current row, column
  shr bx, 1
  inc bx
  mov dh, bl
  mov ax, di
  mov dl, al
  mov ah, 2
  mov bh, 0
  int 10h
  pop bx
  ret

Print0:
  call ClearStatus              ;Blank status line
  sub di, di                    ;Starting at beginning of line ...

Print:
;Print string pointed to by SI on status line in inverse video, starting at DI
  push es
  mov es, [videoSegment]
  lodsb                         ;Get count of string to be printed
  mov cl, al
  sub ch, ch
  mov ah, [attribInv]            ;Attribute = inverse video
@@L1:
  lodsb
  stosw
  loop @@L1
  pop es
  ret

ClearStatus:
;Inverse-blank status line
  push di
  push es
  mov es, [videoSegment]
  mov ah, [attribInv]
  mov al, ' '
  mov cx, 80
  sub di, di
  rep stosw
  pop es
  pop di
  ret

Cancel:
;Ctrl C routine
  mov si, OFFSET ctrlCMsg       ;Abort with message ...

Abort:
;Print counted string pointed to by SI on status line and abort
  call Print0                   ;Print error message ...

na:
;Unassigned key or other error.  Beep and abort.
  call Beep                     ;Beep
  mov sp, OFFSET STACKTOP       ;Reset stack pointer to top
  mov bx, [here]                ;Retrieve cursor position in case it was trashed
  mov di, [hereCol]
  call DrawCursor
  jmp NextNoRedraw              ;Restart main editing loop

Beep:
  mov ah, 2                     ;Output a BELL
  mov dl, BELL
  int 21h
  ret

Prompt:
  push di
  call Print0                   ;Print string at start of line
  mov dx, di                    ;Set cursor to end of printed string ...
  shr dl, 1
  sub dh, dh
  pop di

GotoXY:
;Position cursor at row, column given by DL, DH
  push bx
  mov ah, 2
  sub bx, bx
  int 10h
  pop bx
  ret

PrintInt:
;Print to ES:DI in inverse video the unsigned decimal integer in AX
  sub dx, dx                    ;Start stack with a null
  push dx
  mov cx, 10                    ;Get remainders of successive divisions by 10
@@L1:
  div cx
  add dl, '0'                   ;Convert to ASCII
  mov dh, [attribInv]           ;Attribute is reverse video
  push dx
  sub dx, dx
  or ax, ax
  jne @@L1
  pop ax                        ;Pop and print remainders in reverse order
@@L2:
  stosw
  pop ax
  or ax, ax
  jne @@L2
  ret

NewLineC:
;Jump here if file is changed by a command
  mov [changed?], -1
NewLine:
  mov [justFound?], 0
NewLine0:
  cmp bx, OFFSET linePtrs       ;Check bounds, adjust if necessary
  jge @@L1
  mov bx, OFFSET linePtrs
@@L1:
  cmp bx, [lastLine]
  jle @@L2
  mov bx, [lastLine]
@@L2:
  mov ax, [top]
  cmp bx, ax
  jge @@L3
  mov [top], bx
@@L3:
  add ax, (SCREENLENGTH-1)*2
  cmp bx, ax
  jle @@L4
  mov ax, bx
  sub ax, (SCREENLENGTH-1)*2
  mov [top], ax
@@L4:
  mov es, [bx]                  ;Adjust ES to point to new line
  ret

Left:
  or di, di                     ;If at start of line,
  jne @@L1
  call Up                       ; move to end of line above
  jmp EndLine
@@L1:
  dec di                        ; else just decrement cursor
CursorMoved:
  mov [justFound?], 0
  ret

Right:
  cmp di, LINEWIDTH - 1         ;If at end of line,
  jne @@L1
  sub di, di                    ; move to start of line below
  jmp Down
@@L1:
  inc di                        ; else just increment cursor
  jmp SHORT CursorMoved

LScanE:
;Scan left past first non-space or start of line
  mov al, ' '
  mov cx, di
  inc cx
  std
  repe scasb
  cld
  ret

LScanNE:
;Scan left past first space or start of line
  mov al, ' '
  mov cx, di
  inc cx
  std
  repne scasb
  cld
  ret

RScanE:
;Scan right past first non-space or end of line
  mov al, ' '
  mov cx, LINEWIDTH
  sub cx, di
  repe scasb
  ret

RScanNE:
;Scan right past first space or end of line
  mov al, ' '
  mov cx, LINEWIDTH
  sub cx, di
  repne scasb
  ret

WordLeft:
;Move left one word
  or di, di                     ;Do nothing if at start of line
  je @@Lx
  mov [justFound?], 0
  dec di                        ;Else starting at char to left,
  call LScanE                   ; skip spaces until non-space
  inc di
  je @@Lx                       ; or start of line,
  call LScanNE                  ; then scan to next space or start of line
  jne @@L1
  inc di
@@L1:
  inc di
@@Lx:
  ret

WordRight:
;Move right one word
  cmp di, LINEWIDTH - 1         ;Do nothing if at end of line
  je @@Lx
  mov [justFound?], 0
  call RScanNE                  ;Skip non-spaces until space
  jne @@L1                      ; or end of line,
  dec di
  call RScanE                   ; then scan to next non-space or end of line
@@L1:
  dec di
@@Lx:
  ret

HomeLine:
;Move cursor to L margin
  mov di, [lMargin]
  mov [justFound?], 0
  ret

EndLine:
;Move cursor to R margin or end of text on line (but not left of L margin)
  push cx
  mov [justFound?], 0
  mov di, [rMargin]             ;Start at R margin
  cmp [BYTE es:di], ' '         ;If non-blank, stop here
  jne @@L2
  call LScanE                   ;Skip all spaces until non-space
  je @@L1                       ; or beginning of line
  inc di
@@L1:
  inc di
@@L2:
  cmp di, [lMargin]             ;If left of L margin, set to L margin
  jae @@L3
  mov di, [lMargin]
@@L3:
  pop cx
Ret2:
  ret

Up:
;Move cursor up one line
  cmp bx, OFFSET linePtrs       ;If at top of file already, do nothing
  je Ret2
  dec bx
  dec bx
  jmp NewLine

Down:
;Move cursor down one line
  cmp bx, [lastLine]            ;If at last line already, do nothing
  je Ret2
  inc bx
  inc bx
  jmp NewLine

PageUp:
;Move cursor up one page
  sub bx, (SCREENLENGTH-1)*2
  jmp NewLine

PageDown:
;Move cursor down one page
  add bx, (SCREENLENGTH-1)*2
  jmp NewLine

TopFile:
;Move cursor to top of file
  mov bx, OFFSET linePtrs
  mov [top], bx
  call HomeLine
  jmp NewLine

BottomFile:
;Move cursor to bottom of file
  mov bx, [lastLine]
  mov es, [bx]
  mov ax, bx
  sub ax, (SCREENLENGTH-1)*2
  cmp ax, OFFSET linePtrs
  ja @@L1
  mov ax, OFFSET linePtrs
@@L1:
  mov [top], ax
  call EndLine
  jmp NewLine

Tab:
;Tab right
  mov [justFound?], 0
  mov ax, di                    ;Advance di to next tab stop
  mov cl, [tabSize]
  div cl
  sub cl, ah
  sub ch, ch
  add di, cx
  cmp di, LINEWIDTH             ;If past end of line,
  jl @@L1
  mov di, LINEWIDTH - 1         ;Set cursor at end of line
@@L1:
  ret

ReverseTab:
;Tab left
  mov [justFound?], 0
  mov ax, di                    ;Decrement di to nearest tab stop
  dec al
  div [tabSize]
  mov al, ah
  sub ah, ah
  inc al
  sub di, ax
  jnc @@L1                      ;Set to start of line if past start
  sub di, di
@@L1:
  ret

SetLMargin:
;Toggle left margin between 0 and present cursor setting
  cmp [lMargin], 0
  je @@L1
  mov [lMargin], 0
  ret
@@L1:
  mov [lMargin], di
  ret

SetRMargin:
;Toggle right margin between LINEWIDTH-1 and present cursor setting
  cmp [rMargin], LINEWIDTH-1
  je @@L1
  mov [rMargin], LINEWIDTH-1
  ret
@@L1:
  mov [rMargin], di
  ret

ToggleWPMode:
;Toggle word processing and programming defaults
  cmp [lMargin], 0
  jne @@L1
  cmp [rMargin], LINEWIDTH-1
  jne @@L1
  sub ah, ah
  mov al, [zLMargin]
  mov [lMargin], ax
  mov al, [zRMargin]
  mov [rMargin], ax
  mov [autoIndent?], 0
  jmp HomeLine
@@L1:
  mov [lMargin], 0
  mov [rMargin], LINEWIDTH-1
  mov [autoIndent?], -1
  jmp HomeLine

CRet:
;Split line at cursor
  push ds
  push es
  push di
  push es
  call AddBlankLine             ;Start a new line below current one, ->ES:DI
  pop ds                        ;DS:SI := current cursor position
  pop si
  push di
  mov cx, LINEWIDTH             ;CX := # chars left on line
  sub cx, si
  je @@L2
@@L1:
  movsb                         ;Split line,
  mov [byte si - 1], ' '        ; blank original to end from cursor
  loop @@L1
@@L2:
  pop di
  pop es
  pop ds
  jmp NewLineC

AddBlankLine:
;Insert a new blank line below current one
  mov cx, 1                     ;Make room for new entry in linePtr
  call OpenRow
  inc bx
  inc bx
  mov ax, [heapPtr]
  jmp SHORT BlankLine

NewFile:
;Set up initial blank line of a new file
  mov ax, [heapStart]           ;Set ES and [bx] to available heap
  mov bx, OFFSET linePtrs
  mov [lastLine], bx
BlankLine:
  mov [bx], ax
  mov es, ax
  add ax, 5
  mov [heapPtr], ax             ;Update heap pointer (segment value only)
BlankThisLine:
  sub di, di                    ;Blank new line
  mov cx, LINEWIDTH
  mov al, ' '
  rep stosb
  mov di, [lMargin]             ;Home cursor on new line
  test [autoIndent?], -1        ; or if in autoindent mode,
  je @@Lx
  cmp bx, OFFSET linePtrs       ; and this is not first line in file,
  je @@Lx
  mov es, [bx - 2]              ; line up with first char of line above
  call RScanE
  mov es, [bx]
  je @@L1                       ; unless above line is blank
  dec di
  cmp di, [lMargin]             ; or first char is left of L margin
  jae @@Lx
@@L1:
  mov di, [lMargin]             ; in which case use L margin
@@Lx:
  ret

OpenRow:
;Open CX lines at BX in linePtrs
  push cx
  push di
  push es
  mov ax, ds                    ;DS, ES -> data segment (for linePtr)
  mov es, ax
  mov si, [lastLine]            ;SI points to last line's segment pointer
  mov di, si                    ;DI points CX lines beyond that
  add di, cx
  add di, cx
  mov [lastLine], di            ;Point lastLine to new last line
  mov cx, si                    ;Count = # lines from here to end
  sub cx, bx
  shr cx, 1
  inc cx
  std
  rep movsw                     ;Move array elements up
  cld
  pop es
  pop di
  pop cx
  ret

Backspace:
;Delete char to left of cursor
  mov ax, di                    ;Unless at first character of file,
  add ax, bx
  sub ax, OFFSET linePtrs
  jz Ret1                       ; do Left then Delete
  mov [justFound?], 0
  push di
  call Left
  pop ax                        ;Don't do Join if already at end of line ...
  or ax, ax
  jne Delete0

Delete:
;Delete char at cursor
  mov dx, di                    ;Save cursor column
  cmp [BYTE es:di], ' '         ;If deleting a space at end of line,
  jne Delete0
  call RScanE
  mov di, dx                    ; join line below
  je Join
Delete0:
  push di                       ; else slide text left
  push cx
  push ds
  mov cx, LINEWIDTH - 1
  sub cx, di
  mov si, di
  inc si
  mov ax, es
  mov ds, ax
  rep movsb
  mov [BYTE di], ' '            ;Blank last character on line
  pop ds
  pop cx
  pop di
  mov [changed?], -1
Ret1:
  ret

UndeleteLine:
  mov bp, [blockPtrsLast]       ;Abort if no lines are in buffer
  cmp bp, OFFSET blockPtrs
  ja @@L0
  jmp Beep
@@L0:
  dec bp                        ;Else move pointer to top line of delete buffer
  dec bp
  mov [blockPtrsLast], bp
  cmp di, [lMargin]             ;If cursor is at or before L margin,
  ja @@L1
  mov cx, 1
  call OpenRow                  ;Start new row below current one
  mov [bx+2], es                ;Swap rows to insert undeleted above current
  mov ax, [bp]                  ;Retrieve and store pointer to undeleted line
  mov [bx], ax
  jmp NewLine
@@L1:
  mov cx, LINEWIDTH             ;Cursor past start of line
  sub cx, di                    ;Copy popped line over current one
  push di
  push ds
  mov ds, [bp]
  sub si, si
  rep movsb
  pop ds
  pop di
  ret

Join:
;Join lower line to current line at cursor
  cmp bx, [lastLine]            ;Abort if this is the last line of the file
  je @@Lx
  push di                       ;Save registers
  push ds
  push di
  push es
  mov es, [bx + 2]              ;Get next line's segment
  push es                       ;Save a copy
  mov dx, di                    ;Get length of lower line:
  call EndLine                  ;Find first non-space char from end
  add dx, di                    ;If concatenated line is too long, abort.
  cmp dx, LINEWIDTH
  jbe @@L0
  call Beep
  pop ax
  pop es
  pop di
  pop ds
  pop ax
  jmp Ret1
@@L0:
  mov cx, di                    ;Count = lower line length
  sub si, si                    ;Source = start of lower line
  pop ds
  pop es                        ;Destination = present cursor location
  pop di
  rep movsb                     ;Concatenate lines
  pop ds
  inc bx                        ;Delete lower line
  inc bx
  call DeleteLineNS
  cmp bx, [lastLine]
  je @@L1
  dec bx
  dec bx
@@L1:
  pop di                        ;Restore pointers and return
@@Lx:
  jmp NewLine

Insert:
;Insert or overwrite at cursor
  mov [justFound?], 0
  test [inserting?], -1         ;If inserting, open up space for new character
  jz Insert1
  mov si, [RMargin]             ;If line is full, split it
  cmp [BYTE es:si], ' '
  je Insert0
  push ax
  push bx
  push di
  call CRet
  pop di
  pop bx
  call NewLine
  pop ax
  jmp SHORT Insert1
Insert0:
  push ax
  push cx
  push ds
  mov ax, es
  mov ds, ax
  mov si, LINEWIDTH - 1
  mov cx, si
  sub cx, di
  mov di, si
  dec si
  std
  rep movsb
  cld
  pop ds
  pop cx
  pop ax
Insert1:
  stosb                         ;Add character
  mov [changed?], -1
  cmp di, [rMargin]             ;Wrap if at R margin
  ja WrapLine
  ret

WrapLine:
;Wrap last word on current line
  cmp [BYTE es:di-1], ' '
  je @@L1
  call WordLeft
@@L1:
  call CRet
  jmp EndLine

Wrap:
;Wrap paragraph starting at present line
  mov di, [rMargin]             ;Start at R margin of present line
  cmp bx, [lastLine]            ;Quit if we're at end of file
  je @@Lx
@@L1:
  mov dx, di
  call RScanE                   ;Is there text between here and end of line?
  cmp di, LINEWIDTH
  mov di, dx
  je @@L2
  call LScanNE                  ;Yes.  Is there a space at which to split line?
  or di, di
  mov di, dx
  jle @@Lx                      ;No, stop wrapping
  call FindBreak                ;Yes, split this line, drop to lower line
  call CRet
  jmp Wrap
@@L2:
  call EndLine                  ;Put cursor after end of text on line.
  mov al, [es:di-1]             ;If last char is in {.;:!?}, add two spaces
  cmp al, 40h
  jae @@L2b
  cmp al, '.'
  je @@L2a
  cmp al, ';'
  je @@L2a
  cmp al, ':'
  je @@L2a
  cmp al, '!'
  je @@L2a
  cmp al, '?'
  jne @@L2b
@@L2a:
  inc di
@@L2b:
  inc di                        ;After other chars, just add one space
  mov dx, [rMargin]             ;Calculate spaces remaining on upper line ->DX
  sub dx, di
  ja @@L3                       ;If no room for more text, next line
  call Down
  call KeepWrapping?
  jnc @@Lx
  jmp Wrap
@@L3:
  mov [topSegPtr], bx           ;Save pointers for this line
  mov [topSeg], es
  mov [topIndex], di
  call Down                     ;Drop down to next line
  call KeepWrapping?            ;Does text start at L margin?
  jc @@L4
@@Lx:
  jmp NewLine                   ;No, we're done
@@L4:
  add di, dx                    ;Yes, move words up from lower line
  call FindBreak                ;Find right place to break line
  mov dx, di                    ;Set up pointers and count for move
  mov si, [lMargin]
  sub bp, si
  jnz @@L4a                     ;If nothing will fit, next line
  jmp Wrap
@@L4a:
  mov ax, es
  mov di, [topIndex]
  mov es, [topSeg]
  mov bx, [topSegPtr]
  mov ds, ax
  mov cx, bp
  rep movsb                     ;Move part of lower line up
  mov cx, cs
  mov ds, cx
  cmp dx, LINEWIDTH - 1         ;If nothing left on lower line,
  jne @@L5
  call Down
  call DeleteLine               ;Delete it
  cmp bx, [lastLine]            ;Done if that was last line
  je @@Lx
  mov es, [topSeg]              ;Get top line back and keep wrapping
  mov bx, [topSegPtr]
  jmp Wrap
@@L5:
  call Down                     ;Else slide lower line left
  mov si, dx
  mov di, [lMargin]
  call CloseGap
  jmp Wrap                      ;Continue wrapping with lower line

KeepWrapping?:
;Set DI to L margin.  Return C = 1 if line <- BX has text starting at L margin.
  mov di, [lMargin]
  cmp [BYTE es:di], ' '         ;Fail if space at margin
  je @@Lx
  or di, di
  je @@L1
  push di
  dec di                        ; or chars before margin
  call LScanE
  pop di
  jne @@Lx
@@L1:
  stc                           ; else return C = 1
  db 3Ch                        ;'cmp al, ?' trick to skip one byte
@@Lx:
  clc
  ret

FindBreak:
;Find place to break line while wrapping.  Return BP = last char to move.
  cmp [BYTE es:di], ' '
  je @@L1
  inc di
  call WordLeft
  mov bp, di
  ret
@@L1:
  mov bp, di
  jmp WordRight

DeleteToEOL:
;Delete from cursor to end of line
  mov [justFound?], 0
  push bx                       ;Save regs to return to current cursor position
  push di
  push es
  push [word autoIndent?]       ;Turn autoIndent off
  mov [autoIndent?], 0
  call Cret                     ;Do Enter then delete lower line
  call DeleteWordL
  call DeleteLine
  pop [word autoIndent?]
  pop es
  pop di
  pop bx
  jmp NewLine

DeleteLine:
;Delete cursor line and append to buffer
  mov [changed?], -1
  cmp bx, [lastLine]            ;If last line of file, just blank it
  jne @@L1
  jmp BlankThisLine
@@L1:
  mov bp, [blockPtrsLast]       ;Save segment of current line in delete buffer
  mov [bp], es
  inc bp
  inc bp
  mov [blockPtrsLast], bp
DeleteLineNS:                   ;Enter here if we don't want to save line
  mov di, bx                    ;Delete line:  destination = this line
  mov si, di                    ;Source = next line
  inc si
  inc si
  mov cx, [lastLine]            ;Count = number of lines from here to end
  mov ax, cx
  dec ax
  dec ax
  mov [lastLine], ax
  sub cx, bx
  shr cx, 1
  mov ax, ds                    ;Move line segment values above cursor down
  mov es, ax
  rep movsw
  mov di, [lMargin]             ;Home cursor on new line
  jmp NewLine

DeleteWordL:
;Delete left to space or column zero
  mov ah, 2                     ;Check for Ctrl key down.  ^[ or ESC?
  int 16h                       ;If ^[, delete word left (ignore ESC)
  and al, 4
  je DWLx
  mov si, di                    ;Save cursor column
  call WordLeft                 ;Tab left one word
CloseGap:
  push di                       ;Close gap between di and si cursor positions
  mov cx, LINEWIDTH
  sub cx, si
  push ds
  mov ax, es
  mov ds, ax
  rep movsb
  mov cx, LINEWIDTH             ;Pad end of line with spaces
  sub cx, di
  mov al, ' '
  rep stosb
  pop ds
  pop di
  mov [changed?], -1
DWLx:
  ret

DeleteWordR:
;Delete right to space or end of line
  mov si, di                    ;Save cursor
  push di
  call WordRight                ;Tab right one word
  xchg si, di                   ;Close up space between si and di
  pop di
  jmp CloseGap

ToggleIns:
  not [inserting?]
  ret

Jump:
;Jump to line number n
  mov si, OFFSET gotoMsg
  call Prompt
  call GetInt
  dec ax
  shl ax, 1
  mov bx, ax
  add bx, OFFSET linePtrs
  mov [justFound?], 0
  jmp JL1                       ;Jump to address

GetInt:
;Get a decimal integer from keyboard to AX.  Carry set on improper input.
;Abort if null input.
  push bx
  push cx
  push dx
  push si
  mov dx, OFFSET buffer
  call GetString                ;Input a string
  mov cx, ax                    ;Construct integer a digit at a time
  mov si, OFFSET buffer
  sub ax, ax
  mov bh, 10
@@L1:
  mov bl, [si]                  ;Get next char
  inc si
  sub bl, '0'
  jc @@Lx                       ;Exit with carry set if not a digit
  cmp bl, '9'
  cmc
  jc @@Lx
  mul bh                        ;AX := AX + (new digit - '0')
  add al, bl
  adc ah, 0
  jc @@Lx                       ;Check for overflow
  loop @@L1                     ;Next char
@@Lx:
  pop si                        ;Return with int in AX, carry set if error
  pop dx
  pop cx
  pop bx
  ret
@@La:
  mov si, OFFSET cancelledMsg
  jmp Abort

SetLabel:
;Set label 0-9 at current line
  call GetLabel
  mov [si], bx
  ret

GotoLabel:
;Goto label 0-9 previously set by SetLabel
  call GetLabel
  cmp [WORD si], 0              ;Cancel if label not assigned
  je JLx
  mov bx, [si]                  ;Retrieve address
  mov [justFound?], 0
JL1:
  mov ax, bx
  sub ax, 8                     ;Make cursor line fifth from top
  cmp ax, OFFSET linePtrs
  jge @@L1
  mov ax, OFFSET linePtrs
@@L1:
  mov [top], ax
JLx:
  jmp NewLine0

GetLabel:
  mov si, OFFSET setLabelMsg
  call Prompt
  mov ah, 8                     ;Get char from keyboard
  int 21h
  mov dl, al                    ;Save copy to echo
  sub al, '0'                   ;Don't accept input if not a digit
  jl GetLabel
  cmp al, 9
  jg GetLabel
  mov ah, 2
  mov cl, al
  int 21h
  mov si, OFFSET LabelTable     ;Form index into LabelTable
  shl cl, 1
  sub ch, ch
  add si, cx                    ;Return address of label storage in SI
  ret

SetTabs:
;Set tab width
  mov si, OFFSET setTabsMsg
  call Prompt
  call GetInt
  mov [tabSize], al
  ret

AutoIndent:
;Toggle autoindent mode
  not [autoIndent?]
  ret

Kill:
;Clear changed? flag so file changes will be discarded on exit
  mov [changed?], 0
  ret

Save:
;Write lines to file, renaming old version with .BAK extension
  cmp [changed?], 0             ;If no changes, done.
  je XSave
  push dx
  push di
  push es
  push bx
  mov al, [newFile?]            ;If a new file, create it first
  or al, [isBAKed?]             ;If already BAKed up, no .BAK needed
  jnz DoSave
  mov ax, ds                    ;Else make new ASCIIZ str with .BAK extension
  mov es, ax
  mov si, OFFSET fName
  mov di, OFFSET fNameBAK
@@L1:
  lodsb
  cmp al, '.'
  je @@L2
  or al, al
  je @@L2
  stosb
  jmp SHORT @@L1
@@L2:
  mov cx, 5
  mov si, OFFSET BAK
  rep movsb
  mov ah, 41h                   ;Delete old back-up copy if present
  mov dx, OFFSET fNameBAK
  int 21h
  mov dx, OFFSET fName          ;Rename current file to file.BAK
  mov di, OFFSET fNameBAK
  mov ah, 56h
  int 21h
DoSave:
  mov ah, 3Ch                   ;CREATe new file with old name
  sub cx, cx
  mov dx, OFFSET fName
  int 21h
  jc CantOpen
  mov [fHandle], ax
  mov [isBAKed?], -1            ;Set flag so we only make .BAK file once
  mov bx, OFFSET linePtrs       ;Write file
  call WriteFile
  mov ah, 3Eh                   ;Close file
  mov bx, [fHandle]
  int 21h
  pop bx
  pop es
  pop di
  pop dx
  mov [changed?], 0
XSave:
  ret

WriteFile:
;Write lines out to file [fHandle] starting at BX and ending at [lastLine]
  push es
  push di
  mov di, OFFSET buffer
@@L1:
  mov si, di                    ;Preserve file buffer pointer
  mov es, [bx]                  ;Strip trailing blanks
  mov cx, LINEWIDTH
  mov di, LINEWIDTH - 1
  mov al, ' '
  std
  repe scasb
  cld
  je @@L1a
  inc cx
@@L1a:
  mov ax, ds                    ;Copy line to file buffer
  mov dx, es
  mov es, ax
  mov ds, dx
  mov di, si
  sub si, si
  rep movsb
  mov ax, CRLF                  ;Stick a CRLF on the end
  stosw
  mov ax, ds
  mov dx, es
  mov es, ax
  mov ds, dx
  cmp di, OFFSET Buffer + BUFFERLENGTH - 80  ;If buffer is almost full,
  jl @@L2
  call WriteBuffer              ; write it
@@L2:
  inc bx                        ;Next line, loop until all lines are written
  inc bx
  cmp bx, [lastLine]
  jle @@L1
  dec di                        ;Delete last CR, LF
  dec di
  call WriteBuffer              ;Write final partial buffer to file and exit
  pop di
  pop es
  ret

FileError:
  mov si, OFFSET fileErrorMsg
  jmp Abort
CantOpen:
  mov si, OFFSET cantOpenMsg
  jmp Abort
NoRoom:
  mov si, OFFSET noRoomMsg
  jmp Abort
ReadError:
  mov si, OFFSET rdErrorMsg
  jmp Abort

WriteBuffer:
;Write text in buffer to disk
  push bx
  mov ah, 40h
  mov bx, [fHandle]
  mov cx, di
  mov dx, OFFSET Buffer
  sub cx, dx
  jz @@L1
  int 21h
  jc FileError
  mov di, OFFSET Buffer
@@L1:
  pop bx
  ret

Exit:
  call Save                     ;Save file if changed
  call RestoreCursor
  mov ax, 4C00h                 ;Bye!
  int 21h

RestoreCursor:
  mov cx, [cursorShape]         ;Restore standard cursor size
  mov ah, 1
  int 10h
  mov dx, 1800h                 ;Put cursor at bottom of screen
  sub bh, bh
  mov ah, 2
  int 10h
  ret

BeginBlock:
;Start marking block for block operation
  mov [marking?], -1
  mov [mark], bx
  ret

Unmark:
;Clear marking
  mov [marking?], 0
  ret

InsertBlock:
;Insert from buffer or named file
  push bx
  call FileOrBuffer?            ;From file or buffer?
  je InsertBuffer
  mov dx, OFFSET fNameTemp      ;If file, open it
  mov ax, 3D00h
  int 21h
  jnc @@L1
  jmp CantOpen
@@L1:
  mov dx, ax                    ;Load file
  mov bx, OFFSET blockPtrs
  mov di, bx
  call ReadFile
  mov cx, bx
  mov bx, dx                    ;Close file
  mov ah, 3Eh
  int 21h
  jmp SHORT DoInsert
InsertBuffer:                   ;Insert from buffer
  mov bp, [blockPtrsLast]       ;Abort if empty
  cmp bp, OFFSET blockPtrs
  jne @@L0
  pop bx
  jmp na
@@L0:
  test [needCopies?], -1        ;If not just moving lines, need to duplicate
  jz @@L2
  push bx
  push es
  push ds
  mov bx, bp
  mov dx, [heapPtr]
@@L1:
  dec bx                        ;Copy contents of buffered lines to new ones
  dec bx
  mov ds, [cs:bx]
  sub si, si
  mov es, dx
  sub di, di
  mov [cs:bx], es
  mov cx, LINEWIDTH
  rep movsb
  add dx, 5
  cmp dx, 0A000h
  jb @@L1a
  jmp NoRoom
@@L1a:
  cmp bx, OFFSET blockPtrs
  ja @@L1
  pop ds
  pop es
  pop bx
  mov [heapPtr], dx
@@L2:
  mov [needCopies?], -1
  mov cx, bp
DoInsert:
  pop bx
  sub cx, OFFSET blockPtrs      ;Get count of lines to move
  shr cx, 1
  call OpenRow                  ;Open that much room in array of seg pointers
  mov si, OFFSET blockPtrs      ;Copy new lines into opening
  mov di, bx
  mov ax, ds
  mov es, ax
  rep movsw
  sub di, di
  jmp NewLineC

FileOrBuffer?:
;Prompt for file name if Shift is down, put it in fNameTemp.
;If return with Z set, Shift was up, indicating buffer is to be used.
  call Shifted?                 ;If shift is down, prompt for file name
  jz Ret4
  mov dx, OFFSET fNameTemp
  call GetFileName
  jnz Ret4                      ;If null string returned, abort
  mov si, OFFSET cancelledMsg
  jmp Abort

Shifted?:
;Get shift key status, returned in AL.  Z set if no shift.
  mov ah, 2
  int 16h
  and al, 3
Ret4:
  ret

EmptyBuffer:
;If Shifted, write block buffer to file, else discard
  mov bp, [blockPtrsLast]       ;Abort if buffer is empty
  cmp bp, OFFSET blockPtrs
  jne @@L0
  jmp Beep
@@L0:
  call Shifted?                 ;If shifted, write to file
  je @@L1
  push bx
  mov dx, OFFSET fNameTemp
  call GetFileName
  mov si, OFFSET blockPtrs
  mov bx, bp
  dec bx
  dec bx
  call WriteBlock
  pop bx
@@L1:
  mov ax, OFFSET blockPtrs      ;Else just reset buffer pointer
  mov [blockPtrsLast], ax
@@Lx:
  ret

WriteBlock:
;Write block to file.  SI -> starting seg pointer, BX -> ending seg pointer.
  push [lastLine]               ;Copy block buffered lines to file:
  push [fHandle]
  mov ah, 3Ch                   ;CREATe file
  sub cx, cx
  mov dx, OFFSET fNameTemp
  int 21h
  jnc @@L1
  jmp CantOpen
@@L1:
  mov [fHandle], ax             ;Write it
  mov [lastLine], bx
  mov bx, si
  call WriteFile
  mov bx, [fHandle]             ;Close it
  mov ah, 3Eh
  int 21h
  pop [fHandle]
  pop [lastLine]
  ret

Copy:
;Copy marked lines, to file if shift is down, otherwise to buffer.
  test [marking?], -1          ;Abort with a beep if not already marking,
  jnz @@L1
  mov si, OFFSET notMarkingMsg
  jmp Abort
@@L1:
  mov si, [mark]
  cmp bx, si                    ;If mark comes after here, exchange
  jae @@L2
  xchg bx, si
  mov [mark], si                ; save in this order for possible delete
@@L2:
  push bx
  push di
  push es
  call FileOrBuffer?            ;If Shift key was down when command entered,
  je @@L4
  call WriteBlock
  mov di, OFFSET blockPtrs
  jmp @@Lx
@@L4:
  mov cx, bx                    ;If no Shift, move marked lines to buffer
  sub cx, si
  shr cx, 1
  inc cx
  mov di, OFFSET blockPtrs
  mov ax, ds
  mov es, ax
  rep movsw
@@Lx:
  mov [blockPtrsLast], di       ;Save pointer to last line
  pop es
  pop di
  pop bx
  mov [marking?], 0
  ret

DeleteBlock:
;Do a Copy, then delete copied lines
  call Copy                     ;Copy block to file or buffer
  mov si, bx                    ;Close up copied lines:
  inc si                        ;SI = cursor line + 2
  inc si
  mov di, [mark]                ;DI = start of marking
  mov cx, [lastLine]            ;CX = number of lines from here to end
  sub cx, bx
  push es
  mov ax, ds
  mov es, ax
  rep movsb
  pop es
  dec di
  dec di
  cmp di, OFFSET linePtrs       ;If whole file deleted, start new file
  jae @@L1
  call NewFile
  jmp NewLineC
@@L1:
  mov [lastLine], di            ;Else store index of new last line
  mov di, [lMargin]             ;Point cursor to start of old marked line
  mov bx, [mark]
  mov [needCopies?], 0
  jmp NewLineC

Find:
;Prompt for and find next <string>.  If Shifted, reuse last <string>.
  push bx
  push es
  push di
  call Right
  test [autoReplace?], -1       ;If doing replace all, bypass shift check
  js @@L0
  jnz @@L1
  call Shifted?                 ;If Shifted,
  jnz @@L1
@@L0:
  mov si, OFFSET findMsg        ;Get search string
  mov dx, OFFSET findString
  call GetCountedString
@@L1:
  mov si, OFFSET findString
  lodsw
  dec al
  mov dl, al
  mov al, ah
  mov cx, LINEWIDTH
  sub cx, di
FindLoop:
  repne scasb                   ;Scan for first char of Find string
  jne FindNextLine
  push di                       ;Once found, compare rest of string
  mov dh, cl
  mov cl, dl
  mov si, OFFSET findString + 2
  repe cmpsb
  je Found
  pop di                        ;Match failed.  Scan again for 1st char.
  mov cl, dh
  jmp FindLoop
FindNextLine:
  inc bx                        ;Search next line (until EOF)
  inc bx
  mov es, [bx]
  sub di, di
  mov cl, LINEWIDTH
  cmp bx, [lastLine]
  jbe FindLoop
  mov si, OFFSET notFoundMsg    ;Not found
  test [autoReplace?], -1       ;If doing auto-replace, return
  jz @@L1
  mov [autoReplace?], 0
  pop di
  pop es
  pop bx
  ret
@@L1:
  call Print0                   ;Else restore cursor, abort with error message
  pop di
  pop es
  pop bx
  jmp na
Found:
  pop di
  dec di
  add sp, 6
  mov [justFound?], -1
  mov ax, bx                    ;Show found line 5 below top of screen
  jmp JL1

GetCountedString:
;Print prompt string at [SI], read counted string into [DX].
;Returns count (minus CR/LF) in AL.  DX is advanced one to start of string.
  push di
  push dx
  call Prompt                   ;Display prompt
  pop dx
  mov di, dx
  inc dx
  call GetString                ;Get input string
  mov [di], al                  ;Store count in front of string
  pop di
  ret

Replace:
  push di
  test [autoReplace?], -1       ;If using auto-replace command,
  jz @@L0
  jns @@L2                      ;Skip shift check
  mov [autoReplace?], 1
  jmp SHORT @@L1a               ;Get replace string if shifted and first pass
@@L0:
  test [justFound?], -1         ;Beep if not immediately preceded by a Find
  jnz @@L1
@@LE:
  pop di
  jmp na
@@L1:
  call Shifted?                 ;If not Shifted, prompt for replace string
  jnz @@L2
@@L1a:
  mov si, OFFSET replaceMsg
  mov dx, OFFSET replaceString
  call GetCountedString
@@L2:
  mov si, OFFSET replaceString
  lodsb
  sub ah, ah
  mov dx, si
  push ax
  push dx
  sub ch, ch                    ;Compare lengths of find and replace strings
  mov cl, al
  sub cl, [byte findString]     ;If replace string is longer,
  je @@L6
  jb @@L4
  xchg dx, di
  call EndLine                  ; make sure there will be enough room on line
  xchg dx, di
  add dl, cl
  cmp dl, LINEWIDTH
  ja @@LE
@@L3:
  call Insert0                  ; then insert extra characters
  loop @@L3
  jmp SHORT @@L6
@@L4:
  neg cl                        ;If shorter, delete difference
@@L5:
  call Delete0
  loop @@L5
@@L6:
  pop si                        ;Now copy new string over old
  pop cx
  sub ch, ch
  pop di
  rep movsb
  jmp NewLineC

ReplaceAll:
;Find and replace all.  If shift not down, prompt for strings.
  push [top]
  push es
  push di
  push bx
  mov [autoReplace?], 1         ;Set flag: 1 = no shift, -1 = shift
  call Shifted?
  jne @@L1
  mov [autoReplace?], -1
@@L1:
  call Find                     ;Find/replace until flag reset by not found
  test [autoReplace?], -1
  jz @@Lx
  call Replace
  jmp @@L1
@@Lx:
  pop bx                        ;Restore original position
  pop di
  pop es
  pop [top]
  push si
  call ReDraw                   ;Refresh screen with any changes
  pop si
  push di
  call Print0                   ;Show notFoundMsg and exit
  pop di
  jmp NextNoRedraw

Help:
  push es
  push di
  mov es, [videoSegment]
  mov di, 160
  mov si, OFFSET helpMsg
  mov cx, 80 * 24
  mov ah, [attribNl]
@@L1:
  lodsb
  stosw
  loop @@L1
  mov si, OFFSET anyKeyMsg
  call Print0
  sub ah, ah
  int 16h
  pop di
  pop es
  ret

F3BAT:
  mov dl, '3'
  jmp SHORT FnBAT

F4BAT:
  mov dl, '4'
  jmp SHORT FnBAT

F5BAT:
  mov dl, '5'
  jmp SHORT FnBAT

F6BAT:
  mov dl, '6'

FnBAT:
;Execute 'EFn.BAT f'  where n = DL and f = current file name minus extension
  push es
  push di
  call Save                     ;Save work
  mov [EXECFNumber], dl         ;Which .BAT file?
  mov ax, cs                    ;Copy file name to command line string
  mov es, ax
  mov di, OFFSET EXECFileName
  mov si, OFFSET fName
  sub cl, cl
@@L1:
  lodsb
  or al, al                     ; up to '.' or null (ie, omit extension)
  je @@L2
  cmp al, '.'
  je @@L2
  stosb
  inc cl
  jmp @@L1
@@L2:
  mov al, CR
  stosb
  add cl, 11
  mov [EXECBAT], cl             ;Store count to include file name
  pop di
  pop es
  mov ax, OFFSET EXECBAT
  jmp SHORT Shell1

Shell:
;Shell to DOS
  mov ax, OFFSET EXECParams     ;Point to null command line tail
Shell1:
  mov [EXECCmdLineOff], ax
  push bx                       ;Save regs
  push es
  push di
  call Shifted?                 ;If shift is down,
  jz @@L1
  call Save                     ; save file being edited and release its RAM
  mov bx, ((PROGLENGTH + ESSENTIALS) SHR 4) + 1
  mov [swapped?], -1
  jmp SHORT @@L2
@@L1:
  mov bx, [heapPtr]             ; else keep file and buffers in memory
  mov ax, cs
  sub bx, ax
  mov [swapped?], 0
@@L2:
  mov ax, cs                    ;Free all unneeded memory
  mov es, ax
  mov ah, 4Ah
  int 21h
  call RestoreCursor            ;Restore cursor
  mov [SPTemp], sp              ;Do EXEC fn
  mov dx, [comspecPtrOff]
  mov ds, [comspecPtrSeg]
  mov bx, OFFSET EXECParams
  mov ax, 4B00h
  int 21h
  mov ax, cs                    ;Reclaim memory
  mov ds, ax
  mov ss, ax
  mov sp, [spTemp]
  mov ah, 4Ah
  mov bx, -1
  int 21h
  mov ah, 4Ah
  int 21h
  cmp [swapped?], 0             ;If edited file was swapped out,
  je XEXEC
  mov dx, OFFSET fName          ;Read it back in
  call OpenFile
XEXEC:
  pop di                        ;Restore regs and return
  pop es
  pop bx
  ret

EndOfProgram:
END Orig