; Cофтпанорама 1990, No.6 (10) ** ASM-CLUB **  Составитель: Н.Н. БЕЗРУКОВ
; ***********************************************************************
;                                       Приводимые в данном разделе замет-
;                                  ки  выражают  мнение авторов,  которое,
;                                  естественно, может не совпадать с  точ-
;                                  кой зрения составителя.
; ***********************************************************************
;
;==============================================
;    Faster string routine to substitute the POS()
;    function in Turbo Pascal 4 or 5. Based on the Boyer-Moore
;    algorithm.
;    Declare as follows:
;    {$F+}
;    {$L search.obj
;    function posbm(pat,str,:string):byte;external;
;    Call as follows from Turbo 4 or Turbo 5
;    location :=posbm(pat,str);
;=================================================

skiparrlength equ 256                 ; Length of the skip array

; Function work stack
dstk    struc
patlen  dw      ?                    ; pattern length (also BP base work area)
strlen  dw      ?                    ; string length
skiparr db      skiparrlength dup(?) ; skip array
pattxt  dd      0                    ; pattern address
strtxt  dd      0                    ; string text address
dstk    ends

; Total stacks (Callers plus work stack)
cstk    struc
ourdata db      size dstk dup(?)    ; work stack size
bpsave  dw      0                   ; save bp here
retaddr dd      0                   ; points to return address
straddr dd      0                   ; points to string address
pataddr dd      0                   ; points to pattern address
cstk    ends

paramsize equ size pataddr + size straddr ; size of parameter list

public posbm                       ; Function name declaration

code segment para public 'code'
     assume cs:code

;
;----- Entry point to POSBM function
;

posbm proc far
      push  bp                     ; Save BP
      sub   sp,size dstk           ; Create work area
      mov   bp,sp                  ; Adjust our base pointer

      push  ds                     ; Save callers data segment

      xor   ah,ah                  ; Clear register and
      cld                          ; Set direction flag

; Get and save the length and address of the pattern
      lds   si,[bp.pataddr]
      mov   word ptr [bp.pattxt][2],ds
      lodsb                        ; Get length of pattern (1 byte)
      or    al,al                  ; If pattern length is null then exit
      jne   notnullp
      jmp   nomatch

notnullp:
      mov   cx,ax                  ; Save length to check if 1 later

      mov   [bp.patlen],ax         ; Save length of pattern
      mov   word ptr [bp.pattxt],si; Save address

; Get and save the length and address of the string text
      lds   si,[bp.straddr]
      mov   word ptr [bp.strtxt][2],ds
      lodsb                        ; Get length of string
      or    al,al                  ; If string text is null then exit
      jne   notnulls
      jmp   nomatch

notnulls:
      mov   [bp.strlen],ax         ; Save length of string
      mov   word ptr [bp.strtxt],si; Save address

      cmp   cx,1                   ; Is length of pattern 1 char?
      jne   do_boyer_moore         ; NO - Do Boyer-Moore.
      lds   si, [bp.pattxt]        ; Yes - Do a straight search.
      lodsb                        ; Get the single character pattern.
      les   di, [bp.strtxt]        ; Get the address of the string.
      mov   cx, [bp.strlen]        ; Get length of string.
      repne scasb                  ; Search.
      jz    match1                 ; Found - adjust last DI pos.
      jmp   nomatch                ; Not Found - Exit.
match1:
      mov   si, di                 ; Transfer DI pos to SI.
      sub   si, 2                  ; Adjust SI position.
      jmp   exactmatch             ; Determin offset.

do_boyer_moore:

; Fill the ASCII character skiparray with the
; length of the pattern
      lea   di, [bp.skiparr]       ; Get skip array address
      mov   dx, ss
      mov   es, dx
      mov   al,byte ptr [bp.patlen]; Get size of pattern
      mov   ah,al                  ; Put in to AH as well
      mov   cx, skiparrlength / 2  ; Get size of array
      rep   stosw                  ; Fill with length of pat

; Replace in the ascii skiparray the corresponding
; character offset from the pattern minus 1
      lds   si, [bp.pattxt]        ; Get pattern adress
      lea   bx, [bp.skiparr]       ; Get skip array adress
      mov   cx, [bp.patlen]        ; Get length minus 1
      dec   cx
      mov   bx,bp                  ; save BP
      lea   bp, [bp.skiparr]       ; Get skip array adress
      xor   ah, ah
fill_skiparray:
      lodsb                        ; get character from pattern
      mov   di, ax                 ; Use it as an index
      mov   [bp+di], cl            ; Store its offset in to skip array
      loop  fill_skiparray

      lodsb
      mov   di, ax
      mov   [bp+di], cl            ; Store the last skip value
      mov   bp, bx                 ; recover BP

; Now initialize our pattern and string text pointers to
; start searching
      lds   si, [bp.strtxt]        ; Get string adress
      lea   di, [bp.skiparr]       ; Get skip array adress
      mov   dx, [bp.strlen]        ; Get string length minus 1
      dec   dx                     ;  for eos check
      mov   ax, [bp.patlen]        ; Get the pattern length
      dec   ax                     ; Starting skip value
      xor   bh, bh                 ; zero high of BX
      std                          ; Set to rverse compare

; Get character from text. use the character as an index
; in to the skip array, looking for a skip value of 0.
; If found, execute a brute force search on the pattern.
searchlast:
      sub   dx, ax                 ; Check if string axhausted
      jc    nomatch                ; Yes - no match
      add   si, ax                 ; No - slide pattern with skip value
      mov   bl, [si]               ; Get character, use as an index
      mov   al, ss:[di+bx]         ;    and get the new skip value
      or    al, al                 ; If 0, then possible match
      jne   searchlast             ;  try again by sliding to right

; we have a possible match, therefore
; do the reverse Brute-force compare
      mov   bx, si                 ; Save string adress
      mov   cx, [bp.patlen]        ; Get pattern length
      les   di, [bp.pattxt]        ; Get pattern addres
      dec   di                     ;  adjust
      add   di, cx                 ;  and add to point to eos.
      repe  cmpsb                  ; Do reverse compare.
      je    exactmatch             ; If equal we found a match
      mov   ax, 1                  ;  else set skip array.
      lea   di, [bp.skiparr]       ; Get address of skip array.
      mov   si, bx                 ; Get address of string.
      xor   bh, bh                 ; No - Zero high of BX.
      jmp   short searchlast       ; Try again.

exactmatch:
      mov   ax,si                  ; Save current position in string.
      lds   si, [bp.strtxt]        ; Get stert of strtxt.
      sub   ax,si                  ; Substract and add 2 to get position
      add   ax,2                   ;  in strtxt where pattern is found.
      jmp   short endsearch        ; Exit function

nomatch:
      xor   ax,ax                  ; No match, return a 0

endsearch:
      cld
      pop   ds                     ; recover DS for Turbo Pascal

      mov   sp, bp                 ; Recover last stack position.
      add   sp,size dstk           ; Clear up work area.
      pop   bp                     ; Recover BP.
      ret   paramsize              ; Return with ax the POSBM value.
posbm endp

code  ends
end
