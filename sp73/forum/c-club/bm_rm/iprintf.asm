MASM51
QUIRKS
;iprintf() - Integer version of C runtime library routine, printf()
;
;This routine is a fast, limited version of printf() that is suitable for
;most system utilities.  It supports format specifications of the form:
;
;  %[sign][width][L]type
;
;where sign is '+' or '-', width is an integer output field width, L is 'l' or 
;'L' (signifying a long integer argument) and type is one of the following 
;output types:
;               b = unsigned binary integer
;               c = character
;               o = unsigned octal integer
;               d = signed decimal integer
;               s = ASCIIZ character string
;               u = unsigned decimal integer
;               x = unsigned hexadecimal integer
;
;Note: '+' is ignored.
;      '-' means to left-justify the field.
;
;Brian B. McGuinness     V1.1     March, 1990     Borland Turbo Assembler 1.01
;
;The double word unsigned integer division routine is based on a routine in the
;book PC & XT Assembly Language: A Guide for Programmers by Leo J. Scanlon,
;Robert J. Brady Co. (Bowie, MD: 1983).
;
;The code near the label "getnum" assumes that 'd' is the only format type that
;displays signed values.
;
;Note: this version was only tested for the small model.

        DOSSEG
        .MODEL small,C

;Get the sizes of various pointers for the current memory model.

if @CodeSize              ;Get the size, in bytes, of a jump address.
        ADDRSIZE = 4
else
        ADDRSIZE = 2
endif

if @DataSize              ;Get the size, in bytes, of a data pointer.
        PTRSIZE = 4
else
        PTRSIZE = 2
endif

        FIRSTARG = ADDRSIZE + 2         ;Offset of first argument from SP.

        .CODE

;Note: 'base' must be a word (16-bit) value.

outdev    dw 1            ;Handle to write output to 
longint?  db 0            ;Nonzero if current argument is a long integer
sign      db ' '          ;'-' if the number is negative
base      dw 10           ;Radix to use when displaying a number
outbuf$   db 130 dup (?)  ;Output buffer
outend    label byte
padchar   db ' '          ;Character for padding fields: ' ' or '0'
padlocn   db 0            ;0 to pad at beginning (default), 1 to pad at end (-)
iperror   db 0            ;Nonzero if error occurred writing output.

digit$    db '0123456789ABCDEF'

iprintf proc, x:ptr       ;Specify argument so start & end code is inserted.

        mov outdev,1      ;Write output to the standard output device.

        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es

;Initialize pointers.  The first argument is a pointer to the format string.

        add bp,FIRSTARG         ;Point BP to the first argument.
        mov si,[bp]             ;Point SI to the format string.
        add bp,PTRSIZE          ;Point BP to next argument in list.

        mov di,offset outbuf$   ;Point ES:DI to the output buffer.
        push cs
        pop es

        mov iperror,byte ptr 0  ;Clear the error flag.

;Process each character in the format string.

nextch: lodsb
        or al,al        ;Zero byte marks end of format string.
        jz @exit
        cmp al,'%'      ;Check for '%' at beginning of format specification.
        jne @2
        cmp [si],byte ptr '%'   ;'%%' means to print one '%'.
        je @1

        call prtarg     ;Process format specification & print next argument.
        jmp short nextch

@1:     inc si          ;(So we don't read the second '%' next time)

@2:     cmp al,10       ;If it's a linefeed (C language '\n'), 
        jne @3          ;then print a carriage return before printing it.
        push ax
        mov al,13
        call output
        pop ax
@3:     call output     ;Copy char to output buffer.
        jmp short nextch

;Dump remaining buffer contents, if any.  Then restore registers and exit.

@exit:  call dumpbuf

        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

iprintf endp

;-------------------------------------------------------------------------------
;Copy the char in AL to the output buffer.  If the buffer is full, dump it.

output  proc
        cld
        stosb                   ;Write character to buffer.
        cmp di,offset outend    ;Is buffer full?
        jne @exit
        call dumpbuf            ;If so, dump the buffer.
@exit:
        ret
output endp

;-------------------------------------------------------------------------------
;Dump the contents of the output buffer to the proper output device.

dumpbuf proc
        push cx                 ;Save padding width.

        cmp iperror,byte ptr 0  ;Check for previous error.
        jne @exit

        mov bx,outdev           ;Get handle to write to.
        mov dx,offset outbuf$   ;Get address of output buffer.
        mov cx,di               ;Get number of chars to write.
        sub cx,dx
        jz @exit
        push ds
        push es
        pop ds
        mov ah,40H              ;Write the data.
        int 21H
        pop ds
        jc @error               ;Check for error signalled by DOS error flag.
        cmp ax,cx               ;Check if correct # bytes were writtten.
        je @reset

@error: mov iperror,1           ;Flag the error.

@reset: mov di,offset outbuf$   ;Reset the buffer pointer.

@exit:  pop cx
        ret
dumpbuf endp

;-------------------------------------------------------------------------------
;Decode output specifications and perform the specified operations.

prtarg  proc
        mov longint?,0          ;0 for 16-bit integer, 1 for 32-bit integer
        mov sign,' '            ;'-' if number is negative
        mov base,10             ;radix to display value in
        mov padchar,' '         ;char used to pad field
        mov padlocn,0           ;0 = right-justify, 1 = left-justify
        mov cx,0                ;field width (0 if not specified)

;Read & decode format specification until we see one of 'odxcs\0'.

nextch: lodsb
        or al,al                ;Watch out for unexpected end of string.
        jnz @plus
        jmp @exit

@plus:  cmp al,'+'              ;Ignore plus signs.
        je nextch

@minus: cmp al,'-'              ;Pad on the right (left-justify value)
        jne @width
        mov padlocn,1
        jmp short nextch

@width: cmp al,'0'              ;'0'-'9': Decode field width
        jb @1
        je @w2
        cmp al,'9'
        ja @1

@w1:    sub al,'0'              ;CX <- CX * 10 + AL - '0'
        xor ah,ah
        xchg ax,cx
        mul base                ;At this point, base = 10.
        add cx,ax
        jmp short nextch

@w2:    cmp cx,0                ;Leading zero --> pad with '0'
        ja @w1
        mov padchar,'0'
        jmp short nextch

@1:     or al,32                ;Assume it's a letter & force lower case.

        cmp al,'l'              ;Check for 'l' (signals a long integer).
        jne @b
        mov longint?,1
        jmp short nextch

@b:     cmp al,'b'              ;Check for 'b' (binary).
        jne @2
        mov base,2
        jmp getnum

@2:     cmp al,'o'              ;Check for 'o' (octal).
        jne @3
        mov base,8
        jmp getnum

@3:     cmp al,'d'              ;Check for 'd' (signed decimal).
        je getnum               ;(base was initialized to 10)

        cmp al,'u'              ;Check for 'u' (unsigned decimal).
        je getnum

        cmp al,'x'              ;Check for 'x' (hexadecimal).
        je @b16
        jmp @c
@b16:   mov base,16

getnum: mov bl,al               ;Save output format type.

        cmp longint?,1          ;Is it a long (32-bit) integer?
        je @n1
        mov ax,[bp]             ;No, it is a 16-bit integer.
        cwd                     ;Convert to long integer in DX:AX (extend sign).
        cmp bl,'d'              ;If format isn't 'd', zero the high word.
        je @n0
        xor dx,dx
@n0:    add bp,2                ;Point BP to next argument in list.
        jmp short @n2

@n1:    mov ax,[bp]             ;Get low word of long integer.
        mov dx,[bp+2]           ;Get high word of long integer.
        add bp,4                ;Point BP to next argument in list.

@n2:    cmp bl,'d'              ;For signed decimal, convert negative number
        jne @n3                 ;to positive and store the sign.
        cmp dx,0                ;Is the number negative?
        jge @n3
        dec cx                  ;Decrement padding count to allow room for sign.
        mov sign,'-'            ;Note that the number is negative.
        not dx                  ;Make the (2's complement) number positive.
        not ax
        add ax,1
        adc dx,0

@n3:    xor bx,bx               ;Push a zero word to mark top of stack.
        push bx

        mov bx,ax               ;Save low word for later use.
@div0:  mov ax,dx               ;Divide high word: DX <- rem, AX <- quotient
        xor dx,dx
        div base
        xchg ax,bx              ;Save quotient, retrieve low word.
        div base                ;Divide remainder & low word.
        xchg dx,bx              ;DX:AX <- full quotient, BX <- remainder.
        push word ptr digit$[BX];Convert remainder (digit) to char & store it.
        dec cx                  ;Decrement # pad characters needed (fld size).
        mov bx,ax               ;If quotient is not zero, get next digit.
        or ax,dx
        jnz @div0

        cmp padchar,'0'
        je @n4
        cmp padlocn,0           ;Pad with ' ' at beginning, if needed.
        jne @n4
        call pad
@n4:    cmp sign,' '            ;Store minus sign, if needed.
        je @n5
        xchg al,sign
        call output
@n5:    cmp padchar,'0'
        jne @n6
        cmp padlocn,0           ;Pad with '0' at beginning, if needed.
        jne @n6
        call pad

@n6:    pop ax                  ;Pop (next) digit char.
        or al,al                ;If it's zero, we're done.
        jz @exit
        call output             ;Otherwise, write it and go back for next char.
        jmp short @n6

@c:     cmp al,'c'              ;'C': Print one character.
        jne @s
        dec cx                  ;Allow 1 space for char.
        cmp padlocn,0           ;Pad at beginning, if needed.
        jne @c1
        call pad
@c1:    mov ax,[bp]             ;Get char to be printed.
        add bp,2                ;Point BP to next argument in list.
        call output             ;Print the char.
        jmp short @exit

@s:     cmp al,'s'
        jne @exit               ;If unknown format spec, ignore it.

        push si                 ;Save current location in format string.

if @DataSize                    ;Get pointer to string to be written.
        push ds
        lds si,[bp]
else
        mov si,[bp]
endif
        add bp,PTRSIZE          ;Point BP to next argument in list.

        push si                 ;Get length of ASCIIZ string in BX.
@s1:    lodsb
        or al,al
        jnz @s1
        mov bx,si
        pop si
        sub bx,si
        dec bx
        sub cx,bx               ;Calculate amount of padding required.
        cmp padlocn,0           ;Pad at beginning, if needed.
        jne @s2
        call pad
@s2:    lodsb                   ;Copy string to output, one char at a time.
        or al,al
        jz @s3
        call output
        jmp short @s2
@s3:

if @DataSize
        pop ds
endif
        pop si                  ;Restore current location in format string.

;Pad on right side, if needed, and exit.  If padding was already done on the 
;left side, then CX was already decremented to zero by the "pad" routine and no 
;more padding will be done.

@exit:
        call pad
        ret
prtarg  endp

;-------------------------------------------------------------------------------
;Pad a field with CX occurrances of padchar.

pad     proc
        cmp cx,0
        jle @exit
        mov al,padchar
@pad1:  call output
        loop @pad1
@exit:
        ret
pad     endp
        end
