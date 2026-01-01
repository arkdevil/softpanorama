; ╓────────────────────────────────────────────────────────────────────
; ║ ▌     Module name        : DSZ.ASM
; ║ ▌     Last revision date : 24.5.92
; ║ ▌     Subroutine(s)      : Main program, Print, ShowParam, UpCase
; ║ ▌
; ║ ▌                        Description
; ║ ▌
; ║ ▌              Directory Size - основной модуль
; ║ ▌                  (управляющая программа)
; ║ ▌
; ║ ▌      (C) Copyright by Al Snyatkov & Nick Velichko
; ╙────────────────────────────────────────────────────────────────────

	.Model  TINY
	
	JUMPS
	LOCALS  @@

DIR     =       00000001b
WILD    =       00000010b
VERB    =       00000100b

CR      =       13
LF      =       10
EOM     =       0

	.Data

_Who    Label   Byte
db      CR,LF,'Directory Size Version 1.00  '
db      '(c) Copyright 1992 by Al Snyatkov & Nick Velichko',LF

_CRLF   db      CR,LF,EOM

_Usage  Label   Byte
db      'Usage: DSZ directory_name [switches]',CR,LF,LF
db      'Determines size of files in ''directory_name'' with all its subdirectories.',13,10
db	'Type "DSZ ." to show current directory size.',CR,LF,LF
db      'Switches :',CR,LF
db      '    ?, /?, /H  - display this small help',CR,LF
db      '    /V         - verbose display',CR,LF
db      '    /Fwildcard - take into account sizes of only the files corresponding ',CR,LF
db      '                 to the ''wildcard''',CR,LF
db      'If no switch /F is given, /F*.* is assumed.',EOM

; --- Information messages ---------------------------------------------------
_DirName        db      'Directory name : ',EOM
_WildCard       db      CR,LF,'Wildcard       : ',EOM
_TotFiles       db      CR,LF,LF,'Total files : ',EOM
_TotDirs        db      CR,LF,'Total subdirectories : ',EOM
_TotSize        db      CR,LF,'Total size ( with all subdirectories ) : ',EOM
_Including      db      CR,LF,LF,'Including:',CR,LF,LF,EOM
_Bytes          db      ' byte(s) ',EOM
_In          	db      'in ',EOM
_Files          db      ' file(s)',CR,LF,EOM
_Occupied       db      CR,LF,LF,'Physically occupied disk space : ',EOM
_Clusters       db      ' cluster(s)',EOM
_Free           db      'free on drive '

DriveLetter     db      ' :',EOM
_HidMes         db      ' hidden',EOM
_SysMes         db      ' system',EOM
_ROMes          db      ' read-only',EOM

MessPtrs        dw      _HidMes,_SysMes,_ROMes

Flags           db      0
TotalSize       dd      0
FileCount       dw      0
DirCount        dw      0

VerbInfo        Label   Word
HDSize          dd      0
HDFiles         dw      0
SYSize          dd      0
SYFiles         dw      0
ROSize          dd      0
ROFiles         dw      0

OffSize         dw      0
OffFiles        dw      0

ClustSize       dw      0
ClustCnt        dw      0

; --- Error messages ----------------------------------------------------------
_BadKey                 db      ' - invalid switch.',EOM
_BadWildCard            db      ' - invalid wildcard.',EOM
_NotSpecifiedDir	db	'Directory name is not specified.' ,EOM
_IncorrectDir           db      ' - incorrect directory name.',EOM
_DirNotFound            db      ' - directory not found.',EOM
_TooManyWildCards       db      'Too many wildcards.',EOM
_TooManyDirs            db      'Too many directory names.',EOM
_Hint                   db      CR,LF,'Type ''DSZ ?'' for help.',EOM

	.Data?
	
SpltBuf db      256 dup (?)
WBuf    db      18 dup (?)
DirBuf  db      80 dup (?)
OffsEnd dw      ?
DirPtr  dw      ?
DirLen  dw      ?
WildPtr dw      ?
WildLen dw      ?
DiskSpace       dd      ?
$10Buff db      14 dup (?)

Show    Macro   String

	lea     si,String
	call    Print

	endm

	.Code
	.StartUp

	Show    _Who
	cld
	sub     cx,cx			; No terminators
	lea     si,SpltBuf		; Parameters will placed here
	call    CmdlSplit		; SPLIT command line !
	mov     cx,ax			; CX = Number of parameters

TreatCycle:				; Treat parameters cycle
	jcxz    JumpToCheckPars		; If no more parameters, jump out 
	sub     ax,ax
	dec     cx			; Decrease number of parameters
	lodsb
	mov     bx,ax			; BX = offset of parameter in the PSP
	lodsb
	mov     dx,ax			; DX = length of parameter
	mov     ax,[bx]			; Fetch first two bytes of parameter
	cmp     dx,1			; Length of parameter > 1 ?
	ja      Cont1			; Yes. Else it may be '?'
	cmp     al,'?'			; User want help ?
	je      Usage			; OK, give help

Cont1:  xchg    al,ah
	call    UpCase			; Convert to upper case
	cmp     dx,2			; Length > 2 ?
	ja      Cont2			; Yes. Else it may be key
	cmp     ax,'/?'			; Check on keys ...
	je      Usage
	cmp     ax,'/H'
	je      Usage
	cmp     ax,'/V'
	je      VerboseKey
Cont2:  cmp     ax,'/F'			; May be wildcard 
	je      WildCardKey		; Yes ...
	cmp     ah,'/'			; Unknown key ?
	je      EBadKey			; Yes ...
; Now this parameter can be only directory name ---------------------
	test    Flags,DIR		; Do we already have directory name ?
	jnz     ETooManyDirs		; Yes, error
	or      Flags,DIR		; Set flag
	mov     Word Ptr DirPtr,bx	; Save length of parameter and 
	mov     Word Ptr DirLen,dx	; its offset
	jmp     TreatCycle		; Continue treating ...
; --------------------------------------
JumpToCheckPars:
	jmp     CheckPars
; --------------------------------------
Usage:
	Show    _Usage
	jmp     Exit
; --------------------------------------
VerboseKey:
	or      Flags,VERB		; Set verbose info flag
	jmp     short   TreatCycle	; and continue treating
; --------------------------------------
WildCardKey:
	test    Flags,WILD		; Do we already have wildcard ?
	jnz     ETooManyWildCards	; Yes, error
	or      Flags,WILD		; Set wildcard flag
	mov     WildLen,dx		; Save parameter length 
	mov     WildPtr,bx		; and offset
	cmp     dx,2			; No wildcard (only '/F') ?
	jbe     EBadWildCard		; Yes, error
	dec     dx
	dec     dx
	cmp     dx,12			; Length of wildcard without '/F' > 12 ?
	ja      EBadWildCard		; Yes, error
	inc     bx
	inc     bx
	lea     di,WBuf

TransNext:                      	; Convert wildcard to upper case
	mov     al,[bx]
	call    UpCase
	stosb
	inc     bx
	dec     dx
	jnz     TransNext
	sub     ax,ax
	stosw
	jmp     TreatCycle		; Continue treating ...
; --------------- ERRORS ---------------
EBadKey:
	call    ShowParam
	Show    _BadKey
ShowHintAndExit:
	Show    _Hint
	jmp     Exit
ETooManyDirs:
	Show    _TooManyDirs
	jmp	ShowHintAndExit
ETooManyWildCards:
	Show    _TooManyWildCards
	jmp	ShowHintAndExit
EDirNotSpecified:
	Show	_NotSpecifiedDir
	jmp	ShowHintAndExit
EIncorrectDir:
	mov     bx,Word Ptr DirPtr
	mov     dx,Word Ptr DirLen
	call    ShowParam
	Show    _IncorrectDir
	jmp     Exit
EDirNotFound:
	Show    DirBuf
	Show    _DirNotFound
	jmp     Exit
EBadWildCard:
	call    ShowParam
	Show    _BadWildCard
	jmp     Exit
; --------------------------------------
CheckPars:				; Checking parameters
	test	Flags,DIR		; Is no directory name given ?
	jz	EDirNotSpecified	; Yes, error
	test    Flags,WILD		; Is wildcard given ?
	jnz     Cont3			; Yes,
	lea     di,WBuf			; Else make default ('*.*')
	mov     ax,'.*'
	stosw
	sub     ah,ah
	stosw
Cont3:  
	mov     si,Word Ptr DirPtr	; Make ASCIIZ-string from
	mov     bx,Word Ptr DirLen	; directory name
	mov     Byte Ptr [si + bx],0	;
	cmp     Byte Ptr [si + bx - 1],':' ; Is it only drive letter ?
	jne     NotOnlyDisk		; No.
	mov     Word Ptr [si + bx],'.'	; 60h function do not treat only drive
					; letter - append current directory
NotOnlyDisk:
	lea     di,DirBuf
	push    di
	mov     ah,60h          	; --- Parse path
	int     21h
	jc      EIncorrectDir   	; Directory name is not correct ...

	lea     si,WBuf			; Now see on wildcard ...
	mov     di,5Ch			; Use 1st FCB in the PSP
	mov     ax,2900h		; --- Parse filename
	int     21h
	cmp     Byte Ptr [si],0		; Successfully ?
	mov     bx,WildPtr
	mov     dx,WildLen
	jne     EBadWildCard		; No, error.
	
	pop     di
	sub     al,al
	mov     cx,-1
	repne   scasb			; Search end of the directory name
	dec     di
	cmp     Byte Ptr [di - 1],'\'	; If last symbol is backslash ?
	jne     Process			; No ...
	dec     di			; Else delete it
	mov     Byte Ptr [di],0
Process:
	mov     OffsEnd,di		; Save pointer to end of the dirname
	mov     dl,byte ptr DirBuf
	mov     DriveLetter,dl
	sub     dl,40h
	mov     ah,36h			; --- Get disk info
	int     21h
	mul     cx
	mov     ClustSize,ax
	mul     bx
	mov	word ptr DiskSpace  ,ax
	mov	word ptr DiskSpace+2,dx

	call    DirSize			; Get directory size
	jc      EDirNotFound		; Error ...

	mov	word ptr TotalSize  ,ax	; Save size
	mov	word ptr TotalSize+2,dx

; --- Now show information about specified directory
	Show    _DirName
	Show    DirBuf
	mov	bx,OffsEnd
	dec	bx
	cmp	byte ptr [bx],':'	; Is specified directory is root ?
	jne	@@1			; No, continue.
	mov     dl,'\'			; Else append '\' .
	int     21h
@@1:	Show    _WildCard
	Show    WBuf

	Show    _TotFiles
	sub     bp,bp
	lea     di,$10Buff
	sub     cx,cx
	mov     ax,FileCount
	call    _l10toa
	Show    $10Buff

	Show    _TotDirs
	mov     ax,DirCount
	call    _l10toa
	Show    $10Buff

	Show    _TotSize
	mov	ax,word ptr TotalSize
	mov	cx,word ptr TotalSize+2

	call    _l10toa
	Show    $10Buff
	Show    _Bytes
	test    Flags,VERB      	; Show verbose info ?
	jz      Exit            	; No, exit

	lea     di,VerbInfo
	mov     cx,3

TestCycle:                      	; Crazy cycle !!!
	push    cx di
	mov	ax,word ptr [di]
	mov	cx,word ptr [di+2]

	lea     di,$10Buff
	call    _l10toa
	cmp     ax,OffSize
	jb      @@1
	mov     OffSize,ax
  @@1:  pop     di
	add     di,4
	push    di
	sub     cx,cx
	mov     ax,[di]
	lea     di,$10Buff
	call    _l10toa
	cmp     ax,OffFiles
	jb      @@2
	mov     OffFiles,ax
  @@2:  pop     di cx
	inc     di
	inc     di
	loop    TestCycle

	mov     ax,OffFiles
	neg     ax
	add     ax,14
	mov     OffFiles,ax
	mov     ax,OffSize
	neg     ax
	add     ax,13
	mov     OffSize,ax
	
	Show    _Including
	lea     bx,MessPtrs
	lea     di,VerbInfo
	mov     cx,3
	mov     bp,14
ShowCycle:
	mov     ah,2
	mov     dl,' '
	int     21h
	int     21h
	int     21h
	int     21h
	push    cx di
	mov	ax,word ptr [di]
	mov	cx,word ptr [di+2]

	lea     di,$10Buff
	call    _l10toa
	mov     di,OffSize
	Show    $10Buff[di]
	pop     di
	add     di,4
	push    di
	Show    _Bytes
	Show    _In
	sub     cx,cx
	mov     ax,[di]
	lea     di,$10Buff
	call    _l10toa
	mov     di,OffFiles
	Show    $10Buff[di]
	mov     si,[bx]
	inc     bx
	inc     bx
	Show    [si]
	Show    _Files
	pop     di cx
	inc     di
	inc     di
	loop    ShowCycle

	cmp     ClustSize,0
	je      Exit
	Show    _Occupied
	mov     ax,ClustCnt
	mul     ClustSize
	mov     cx,dx
	lea     di,$10Buff
	sub     bp,bp
	call    _l10toa
	Show    $10Buff
	Show    _Bytes
	Show    _In
	mov     ax,ClustCnt
	sub     cx,cx
	call    _l10toa
	Show    $10Buff
	Show    _Clusters

	Show    _CRLF
	Show    _CRLF

	mov	ax,word ptr DiskSpace
	mov	cx,word ptr DiskSpace+2

	call    _l10toa
	Show    $10Buff
	Show    _Bytes
	Show    _Free
	
Exit:
	Show    _CRLF
	mov     ax,4C00h
	int     21h
	
Print   proc    near
; This subroutine dispalays ASCIIZ string from SI
	cld
	lodsb
	or      al,al
	jz      @@Exit
	mov     ah,2
	mov     dl,al
	int     21h
	jmp     short   Print
@@Exit: ret
	
Print   endp

ShowParam proc  near
; This subroutine displays command-line parameter (BX points to beginnig,
; CX contains length ) 
	mov     si,bx
	mov     cx,dx
	cld
@@next: lodsb
	mov     dl,al
	mov     ah,2
	int     21h
	loop    @@Next
	ret
	
ShowParam endp

UpCase  proc    near

	cmp     al,'a'
	jb      @@Exit
	cmp     al,'z'
	ja      @@Exit
	sub     al,20h
@@Exit: ret

UpCase  endp

	Include CMDSPLIT.ASM
	Include LTOA.ASM
	Include DIRSIZE.ASM

	End
	