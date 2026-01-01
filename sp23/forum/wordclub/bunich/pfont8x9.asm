         page  60,132
;==========================================================
; загрузка 40 кириллических символов, матрица 8x9
; Л.З.Альперович - Л.Г.Бунич (28.11.89) 
;==========================================================
        .model small
        .stack 128
        .code
main    proc  near
        push  cs
        pop   ds

        mov   cx,end_stream - stream
        mov   si,offset stream
mgo:    mov   al,[si]
        xor   ah,ah
        xor   dx,dx
        int   17h
        inc   si
        loop  mgo

        lea   dx,notify
        mov   ah,9
        int   21H

        mov   ax,4c00h        ; завершить программу
        INT   21h

notify  db    0dh,0ah,"Cyrillic font loaded"
        db    0dh,0ah,'$'
stream  db    1Bh,40h,0Fh     ; reset + compressed

 db 27,121,81h, 0,0FEh,0,92h,0,92h,0,92h,0Ch         ; Б
 db 27,121,83h, 0FEh,0,80h,0,80h,0,80h,0,0C0h        ; Г
 db 27,121,84h, 3,0,7Eh,80h,2,80h,7Eh,0,3            ; Д
 db 27,121,86h, 82h,44h,28h,10h,0EEh,10h,28h,44h,82h ; Ж
 db 27,121,88h, 0,0FEh,0,4,8,10h,20h,0,0FEh          ; И
 db 27,121,8Bh, 2,0,2,7Ch,80h,0,80h,0,0FEh           ; Л
 db 27,121,8Fh, 0,0FEh,0,80h,0,80h,0,0FEh,0          ; П
 db 27,121,93h, 0,0E2h,10h,2,10h,2,10h,2,0FCh        ; У
 db 27,121,94h, 70h,88h,0,8Ah,74h,8Ah,0,88h,70h      ; Ф
 db 27,121,96h, 0FEh,0,2,0,2,0,0FEh,0,3              ; Ц
 db 27,121,97h, 0,0E0h,10h,0,10h,0,10h,0,0FEh        ; Ч
 db 27,121,98h, 0FEh,0,2,0,0FEh,0,2,0,0FEh           ; Ш
 db 27,121,99h, 0FCh,2,0,0FEh,0,2,0FCh,0,3           ; Щ
 db 27,121,9Dh, 0,44h,92h,0,92h,0,92h,44h,38h        ; Э
 db 27,121,9Eh, 0FEh,0,10h,0,0FEh,0,82h,0,0FEh       ; Ю
 db 27,121,9Fh, 0,62h,90h,4,90h,8,90h,0,0FEh         ; Я

 db 27,121,0A1h, 0,1Ch,42h,30h,42h,10h,42h,10h,4Ch   ; б
 db 27,121,0A2h, 0,22h,1Ch,22h,8,22h,8,22h,1Ch       ; в
 db 27,121,0A3h, 0,3Eh,0,20h,0,20h,0,30h,0           ; г
 db 27,121,0A4h, 3,0,1Eh,20h,2,20h,1Eh,0,3           ; д
 db 27,121,0A6h, 22h,14h,8,0,3Eh,0,8,14h,22h         ; ж
 db 27,121,0A7h, 0,14h,0,22h,0,2Ah,0,2Ah,14h         ; з
 db 27,121,0A8h, 3Eh,0,4,8,10h,20h,0,3Eh,0           ; и
 db 27,121,0A9h, 3Eh,0,84h,48h,90h,20h,0,3Eh,0       ; й
 db 27,121,0AAh, 0,3Eh,0,8,0,14h,0,22h,0             ; к
 db 27,121,0ABh, 0,2,0,2,1Ch,20h,0,20h,1Eh           ; л
 db 27,121,0ACh, 3Eh,0,10h,8,4,8,10h,0,3Eh           ; м
 db 27,121,0ADh, 3Eh,0,8,0,8,0,8,0,3Eh               ; н
 db 27,121,0E2h, 20h,0,20h,0,3Eh,0,20h,0,20h         ; т
 db 27,121,0E4h, 1Ch,22h,0,22h,1Dh,22h,0,22h,1Ch     ; ф
 db 27,121,0E6h, 3Eh,0,2,0,2,0,3Eh,0,3               ; ц
 db 27,121,0E7h, 0,30h,8,0,8,0,8,0,3Eh               ; ч
 db 27,121,0E8h, 3Eh,0,2,0,3Eh,0,2,0,3Eh             ; ш
 db 27,121,0E9h, 3Ch,2,0,3Eh,0,2,3Ch,0,3             ; щ
 db 27,121,0EBh, 3Eh,0,0Ah,0,0Ah,4,0,0,3Eh           ; ы
 db 27,121,0ECh, 0,3Eh,0,0Ah,0,0Ah,0,0Ah,4           ; ь
 db 27,121,0EDh, 22h,0,2Ah,0,2Ah,0,2Ah,14h,8         ; э
 db 27,121,0EEh, 3Eh,0,8,0,3Eh,0,22h,0,3Eh           ; ю
 db 27,121,0EFh, 10h,2Ah,4,28h,0,28h,0,3Eh,0         ; я
;
end_stream label byte
main     endp

         end main

