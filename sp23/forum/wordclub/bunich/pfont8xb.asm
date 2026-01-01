               page 60,132
;============================================================================
; загрузка pусского шpифта печати в RAM
; Л.З.Альперович - Л.Г.Бунич (08.01.90) 
;============================================================================
stek           segment  STACK
               dw    100 dup(?)
stek           ends

code_seg       segment
               assume cs:code_seg, ds:code_seg
begin:         jmp   init_vectors

inst1_prn      db    "Cyrillic font loaded"
               db    0dh,0ah,'$'
mas   db  1Bh,40h,1Bh,3Ah,00h,00h,00h  ; копирование в РАМ стандарт РОМ
      db  12h                          ; set pica

      db  01Bh,026h,00h,03fh,03fh,8Bh,000h,01Eh,020h,048h,080h,008h,080h,048h,020h,01Eh,000h ; А
      db  01Bh,026h,00h,040h,040h,8Bh,000h,082h,07Ch,082h,010h,082h,010h,082h,010h,00Ch,000h ; Б
      db  01Bh,026h,00h,041h,041h,8Bh,000h,082h,07Ch,082h,010h,082h,010h,082h,010h,06Ch,000h ; В
      db  01Bh,026h,00h,042h,042h,8Bh,000h,0FEh,000h,080h,000h,080h,000h,080h,000h,0C0h,000h ; Г
      db  01Bh,026h,00h,043h,043h,8Bh,003h,000h,03Eh,040h,082h,000h,082h,040h,03Eh,000h,003h ; Д
      db  01Bh,026h,00h,044h,044h,8Bh,000h,0FEh,000h,092h,000h,092h,000h,092h,000h,082h,000h ; Е
      db  01Bh,026h,00h,045h,045h,8Bh,000h,0C6h,028h,010h,000h,0FEh,000h,010h,028h,0C6h,000h ; Ж
      db  01Bh,026h,00h,046h,046h,8Bh,000h,044h,000h,082h,000h,082h,010h,082h,010h,06Ch,000h ; З
      db  01Bh,026h,00h,047h,047h,8Bh,000h,0FEh,000h,004h,008h,010h,020h,040h,000h,0FEh,000h ; И
      db  01Bh,026h,00h,048h,048h,8Bh,000h,0FEh,000h,004h,088h,010h,0A0h,040h,000h,0FEh,000h ; Й
      db  01Bh,026h,00h,049h,049h,8Bh,000h,0FEh,000h,010h,000h,028h,000h,044h,000h,082h,000h ; К
      db  01Bh,026h,00h,04ah,04ah,8Bh,000h,01Eh,020h,040h,080h,000h,080h,040h,020h,01Eh,000h ; Л
      db  01Bh,026h,00h,04bh,04bh,8Bh,000h,0FEh,000h,040h,020h,010h,020h,040h,000h,0FEh,000h ; М
      db  01Bh,026h,00h,04ch,04ch,8Bh,000h,0FEh,000h,010h,000h,010h,000h,010h,000h,0FEh,000h ; Н
      db  01Bh,026h,00h,04dh,04dh,8Bh,000h,07Ch,082h,000h,082h,000h,082h,000h,082h,07Ch,000h ; О
      db  01Bh,026h,00h,04eh,04eh,8Bh,000h,0FEh,000h,080h,000h,080h,000h,080h,000h,0FEh,000h ; П
      db  01Bh,026h,00h,04fh,04fh,8Bh,000h,0FEh,000h,090h,000h,090h,000h,090h,000h,060h,000h ; Р

      db  01Bh,026h,00h,050h,050h,8Bh,000h,07Ch,082h,000h,082h,000h,082h,000h,082h,044h,000h ; С
      db  01Bh,026h,00h,051h,051h,8Bh,000h,080h,000h,080h,000h,0FEh,000h,080h,000h,080h,000h ; Т
      db  01Bh,026h,00h,052h,052h,8Bh,000h,0E0h,010h,002h,010h,002h,010h,002h,0FCh,000h,000h ; У
      db  01Bh,026h,00h,053h,053h,8Bh,000h,038h,000h,044h,000h,0FEh,000h,044h,000h,038h,000h ; Ф
      db  01Bh,026h,00h,054h,054h,8Bh,000h,000h,082h,044h,028h,010h,028h,044h,082h,000h,000h ; Х
      db  01Bh,026h,00h,055h,055h,8Bh,000h,0FEh,000h,002h,000h,002h,000h,0FEh,000h,003h,000h ; Ц
      db  01Bh,026h,00h,056h,056h,8Bh,000h,0E0h,010h,000h,010h,000h,010h,000h,0FEh,000h,000h ; Ч
      db  01Bh,026h,00h,057h,057h,8Bh,000h,0FEh,000h,002h,000h,0FEh,000h,002h,000h,0FEh,000h ; Ш
      db  01Bh,026h,00h,058h,058h,8Bh,0FEh,000h,002h,000h,0FEh,000h,002h,000h,0FEh,000h,003h ; Щ
      db  01Bh,026h,00h,059h,059h,8Bh,000h,080h,000h,0FEh,000h,012h,000h,012h,000h,00Ch,000h ; Ъ
      db  01Bh,026h,00h,05ah,05ah,8Bh,000h,0FEh,000h,012h,000h,012h,00Ch,000h,000h,0FEh,000h ; Ы
      db  01Bh,026h,00h,05bh,05bh,8Bh,000h,0FEh,000h,012h,000h,012h,000h,012h,000h,00Ch,000h ; Ь
      db  01Bh,026h,00h,05ch,05ch,8Bh,000h,082h,000h,092h,000h,092h,000h,054h,000h,038h,000h ; Э
      db  01Bh,026h,00h,05dh,05dh,8Bh,000h,0FEh,000h,010h,000h,0FEh,000h,082h,000h,0FEh,000h ; Ю
      db  01Bh,026h,00h,05eh,05eh,8Bh,000h,060h,002h,090h,004h,090h,008h,090h,000h,0FEh,000h ; Я
      db  01Bh,026h,00h,05fh,05fh,8Bh,000h,004h,00Ah,020h,00Ah,020h,00Ah,020h,01Ch,002h,000h ; а

      db  01Bh,026h,00h,060h,060h,8Bh,000h,000h,00Ch,082h,050h,0A2h,010h,082h,010h,00Ch,000h ; б
      db  01Bh,026h,00h,061h,061h,8Bh,000h,022h,01Ch,022h,008h,022h,008h,022h,008h,014h,000h ; в
      db  01Bh,026h,00h,062h,062h,8Bh,000h,03Eh,000h,020h,000h,020h,000h,030h,000h,000h,000h ; г
      db  01Bh,026h,00h,063h,063h,0Bh,000h,038h,044h,001h,044h,001h,044h,001h,07Eh,000h,000h ; д
      db  01Bh,026h,00h,064h,064h,8Bh,000h,01Ch,022h,008h,022h,008h,022h,008h,022h,018h,000h ; е
      db  01Bh,026h,00h,065h,065h,8Bh,000h,022h,014h,008h,000h,03Eh,000h,008h,014h,022h,000h ; х
      db  01Bh,026h,00h,066h,066h,8Bh,000h,000h,000h,022h,000h,022h,008h,022h,008h,014h,000h ; з
      db  01Bh,026h,00h,067h,067h,8Bh,000h,03Eh,000h,004h,008h,010h,020h,000h,03Eh,000h,000h ; и
      db  01Bh,026h,00h,068h,068h,8Bh,000h,03Eh,000h,084h,048h,090h,020h,000h,03Eh,000h,000h ; й
      db  01Bh,026h,00h,069h,069h,8Bh,000h,000h,03Eh,000h,008h,000h,014h,000h,022h,000h,000h ; к
      db  01Bh,026h,00h,06ah,06ah,8Bh,000h,006h,008h,010h,020h,000h,020h,010h,008h,006h,000h ; л
      db  01Bh,026h,00h,06bh,06bh,8Bh,000h,03Eh,000h,010h,008h,004h,008h,010h,000h,03Eh,000h ; м
      db  01Bh,026h,00h,06ch,06ch,8Bh,000h,03Eh,000h,008h,000h,008h,000h,008h,000h,03Eh,000h ; н
      db  01Bh,026h,00h,06dh,06dh,8Bh,000h,01Ch,022h,000h,022h,000h,022h,000h,022h,01Ch,000h ; о
      db  01Bh,026h,00h,06eh,06eh,8Bh,000h,03Eh,000h,020h,000h,020h,000h,020h,000h,03Eh,000h ; п
      db  01Bh,026h,00h,06fh,06fh,0Bh,000h,07Fh,000h,044h,000h,044h,000h,044h,038h,000h,000h ; р

      db  01Bh,026h,00h,070h,070h,8Bh,000h,01Ch,022h,000h,022h,000h,022h,000h,022h,000h,000h ; с
      db  01Bh,026h,00h,071h,071h,8Bh,000h,020h,000h,020h,000h,03Eh,000h,020h,000h,020h,000h ; т
      db  01Bh,026h,00h,072h,072h,0Bh,000h,070h,008h,001h,008h,001h,008h,001h,07Eh,000h,000h ; у
      db  01Bh,026h,00h,073h,073h,0Bh,000h,01Ch,000h,022h,000h,07Fh,000h,022h,000h,01Ch,000h ; ф
      db  01Bh,026h,00h,074h,074h,8Bh,000h,022h,014h,000h,008h,000h,014h,022h,000h,000h,000h ; х
      db  01Bh,026h,00h,075h,075h,8Bh,000h,03Eh,000h,002h,000h,002h,000h,03Eh,000h,003h,000h ; ц
      db  01Bh,026h,00h,076h,076h,8Bh,000h,030h,008h,000h,008h,000h,008h,000h,03Eh,000h,000h ; ч
      db  01Bh,026h,00h,077h,077h,8Bh,000h,03Eh,000h,002h,000h,03Eh,000h,002h,000h,03Eh,000h ; ш
      db  01Bh,026h,00h,078h,078h,0Bh,07Ch,000h,004h,000h,07Ch,000h,004h,000h,07Ch,000h,006h ; щ
      db  01Bh,026h,00h,079h,079h,8Bh,000h,020h,000h,03Eh,000h,00Ah,000h,00Ah,004h,000h,000h ; ъ
      db  01Bh,026h,00h,07ah,07ah,8Bh,000h,03Eh,000h,00Ah,000h,00Ah,004h,000h,000h,03Eh,000h ; ы
      db  01Bh,026h,00h,07bh,07bh,8Bh,000h,03Eh,000h,00Ah,000h,00Ah,000h,00Ah,000h,004h,000h ; ь
      db  01Bh,026h,00h,07ch,07ch,8Bh,000h,022h,000h,02Ah,000h,02Ah,000h,02Ah,014h,008h,000h ; э
      db  01Bh,026h,00h,07dh,07dh,8Bh,000h,03Eh,000h,008h,000h,03Eh,000h,022h,000h,03Eh,000h ; ю
      db  01Bh,026h,00h,07eh,07eh,8Bh,000h,010h,02Ah,004h,028h,000h,028h,000h,03Eh,000h,000h ; я
;
init_vectors   proc  near
               push  cs
               pop   ds

               lea   dx,inst1_prn
               mov   ah,9
               int   21H

               MOV   CX,1096
               MOV   SI,offset mas

mgo:           MOV   AL,[SI]
               XOR   AH,AH
               XOR   DX,DX
               INT   17h
               INC   SI
               LOOP  mgo

               mov   ax,4c00h        ; завершить программу
               INT   21h
init_vectors   endp

code_seg       ends
               end   begin

