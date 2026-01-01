;VACUUM.ASM -- program to direct read all sectors on a floppy
;in drive B, writing 90 sectors per file to a series of output
;files, 1.FIX, 2.FIX, etc., on the default drive.  Sectors
;are processed in order of logical number.  Sectors consisting
;entirely of the same byte are not included in the output.
;
cr        equ       0dh
lf        equ       0ah
;
cseg      segment   para     public     'CODE'
          org       100h
          assume cs:cseg, ds:cseg,es:cseg,ss:cseg
vacuum    proc      near
          jmp       start
;
mess1     db        7,'THE VACUUM CLEANER Ver. 1.0  1/24/87',cr,lf
          db        ' by D. Seidman',cr,lf
          db        ' Damaged disk in drive B. Output '
          db        'to default drive.',cr,lf,' Press any'
          db        ' alpha key to start.',cr,lf,'$'
handle    dw        ?
filename  db        '1.FIX',0
mess2     db        7,'File creation failure. Aborting.','$'
mess3     db        7,'Insert another disk in default drive,',cr,lf
          db        'then press any alpha key.',cr,lf,'$'
sectot    dw        0
sector    db        512 dup (?)
divider   db        cr,lf,'END SECTOR '
secno     db        4 dup (?)
          db        cr,lf,'$'
secount   db        0
;
start:    mov       dx, offset mess1    ;intro message
          mov       ah, 9               ;output string
          int       21h
          mov       ah, 0ch
          mov       al, 8               ;wait for keypress
          int       21h
          call      open
again:    inc       sectot              ;sector to read
          cmp       sectot, 721
          je        done
          mov       al,1                ;read drive B. Or 0 for drive A,etc.
          mov       cx,1                ;read one sector only
          mov       dx, sectot          ;this sector
          mov       bx, offset sector   ;into here
          int       25h                 ;sector read
          add       sp, 2               ;clean up after the read
          jc        again               ;if error, skip over it
          cld
          mov       al, sector          ;get first char of sector
          mov       cx, 512             ;check a whole sector
          mov       di, offset sector   ;start address
repe      scasb                         ;check for equal bytes
          je        again               ;if equal at end, no good
                                        ;now save it
;this tries to write the number in hex
          lea       di, secno           ;where to put number
          mov       ax, sectot          ;for call
          call      conv_word
;end attempt
          mov       ah, 40h             ;write file
          mov       bx, handle
          mov       cx, 531             ;size of sector plus divider
          mov       dx, offset sector   ;what to write
          int       21h                 ;write it
;assuming no error here
          inc       secount             ;sectors in this file
          cmp       secount, 90         ;90 sectors per file
          jne       again               ;recycle is not done
          mov       ah, 3eh             ;close file
          mov       bx, handle          ;should be unnecessary
          int       21h
          mov       secount, 0          ;reset counter
          cmp       sectot, 720         ; don't open another file
                                        ;if finished.
          je        done
          call      open
          jmp       again
done:     int       20h
vacuum    endp
;
open      proc      near
;opens files, dies with message if error
;check to see if enough space, assuming 512 byte sectors
;and two sectors per cluster, which is wrong for hard disks.
          mov       ah, 36h             ;call for free disk space
          mov       dl, 0               ;using default drive
          int       21h
          cmp       bx, 48              ; 48 clusters needed for a file
          ja        enough
          mov       dx, offset mess3    ;need another disk
          mov       ah, 9
          int       21h
          mov       ah, 0ch             ;wait for keypress
          mov       al, 08h
          int       21h
enough:   mov       ah, 3ch
          xor       cx, cx
          mov       dx, offset filename
          int       21h
          jnc       opened
          mov       dx, offset mess2
          mov       ah, 9
          int       21h
          int       20h                 ;quit if error
opened:   mov       handle,ax
          inc       filename            ;that is supposed to increment
                                        ;the first byte of thefilename
          ret
open      endp

conv_word proc      near                ;convert 16-bit binary word
                                        ;  to hex ASCII
                                        ;call with AX = binary value
                                        ;          DI =addr to store
                                        ;returns AX,DI,CX destroyed
                                        ;(c) 1984 by Ray Duncan.
                                        ;Published in Advanced MS-DOS
          push      ax
          mov       al,ah
          call      conv_byte           ;convert upper byte
          pop       ax
          call      conv_byte           ;convert lower byte
          ret
conv_word endp

conv_byte proc      near                ;convert binary byte to hex ASCII
                                        ;call with AL = binary value
                                        ;       DI = addr to store string
                                        ;returns AX, DI, CX modified
          sub       ah,ah               ;clear upper byte
          mov       cl, 16
          div       cl                  ;divide binary data by 16
          call      ascii               ;quotient becomes the first
          stosb                         ;ascii character
          mov       al,ah
          call      ascii               ;remainder becomes the
          stosb                         ;second ASCII character
          ret
conv_byte endp

ascii     proc      near                ;convert value 0-0FH in AL
          add       al, '0'             ;into a "hex ascii" character
          cmp       al, '9'
          jle       ascii2              ;jump if in range 0-9
          add       al,'A'-'9'-1        ;offset into range A-F
ascii2:   ret                           ;return ASCII char in AL
ascii     endp
;
cseg      ends
          end       vacuum




