seg_a           segment para public
                assume  cs:seg_a, ds:seg_a, es:seg_a
                even
                org     0

;*--------------- таблица для CRC32 (386) -------------*
Table   dw  00000h, 00000h, 03096h, 07707h, 0612Ch, 0EE0Eh, 051BAh, 09909h, 0C419h, 0076Dh, 0F48Fh, 0706Ah, 0A535h, 0E963h, 095A3h, 09E64h
        dw  08832h, 00EDBh, 0B8A4h, 079DCh, 0E91Eh, 0E0D5h, 0D988h, 097D2h, 04C2Bh, 009B6h, 07CBDh, 07EB1h, 02D07h, 0E7B8h, 01D91h, 090BFh
        dw  01064h, 01DB7h, 020F2h, 06AB0h, 07148h, 0F3B9h, 041DEh, 084BEh, 0D47Dh, 01ADAh, 0E4EBh, 06DDDh, 0B551h, 0F4D4h, 085C7h, 083D3h
        dw  09856h, 0136Ch, 0A8C0h, 0646Bh, 0F97Ah, 0FD62h, 0C9ECh, 08A65h, 05C4Fh, 01401h, 06CD9h, 06306h, 03D63h, 0FA0Fh, 00DF5h, 08D08h
        dw  020C8h, 03B6Eh, 0105Eh, 04C69h, 041E4h, 0D560h, 07172h, 0A267h, 0E4D1h, 03C03h, 0D447h, 04B04h, 085FDh, 0D20Dh, 0B56Bh, 0A50Ah
        dw  0A8FAh, 035B5h, 0986Ch, 042B2h, 0C9D6h, 0DBBBh, 0F940h, 0ACBCh, 06CE3h, 032D8h, 05C75h, 045DFh, 00DCFh, 0DCD6h, 03D59h, 0ABD1h
        dw  030ACh, 026D9h, 0003Ah, 051DEh, 05180h, 0C8D7h, 06116h, 0BFD0h, 0F4B5h, 021B4h, 0C423h, 056B3h, 09599h, 0CFBAh, 0A50Fh, 0B8BDh
        dw  0B89Eh, 02802h, 08808h, 05F05h, 0D9B2h, 0C60Ch, 0E924h, 0B10Bh, 07C87h, 02F6Fh, 04C11h, 05868h, 01DABh, 0C161h, 02D3Dh, 0B666h
        dw  04190h, 076DCh, 07106h, 001DBh, 020BCh, 098D2h, 0102Ah, 0EFD5h, 08589h, 071B1h, 0B51Fh, 006B6h, 0E4A5h, 09FBFh, 0D433h, 0E8B8h
        dw  0C9A2h, 07807h, 0F934h, 00F00h, 0A88Eh, 09609h, 09818h, 0E10Eh, 00DBBh, 07F6Ah, 03D2Dh, 0086Dh, 06C97h, 09164h, 05C01h, 0E663h
        dw  051F4h, 06B6Bh, 06162h, 01C6Ch, 030D8h, 08565h, 0004Eh, 0F262h, 095EDh, 06C06h, 0A57Bh, 01B01h, 0F4C1h, 08208h, 0C457h, 0F50Fh
        dw  0D9C6h, 065B0h, 0E950h, 012B7h, 0B8EAh, 08BBEh, 0887Ch, 0FCB9h, 01DDFh, 062DDh, 02D49h, 015DAh, 07CF3h, 08CD3h, 04C65h, 0FBD4h
        dw  06158h, 04DB2h, 051CEh, 03AB5h, 00074h, 0A3BCh, 030E2h, 0D4BBh, 0A541h, 04ADFh, 095D7h, 03DD8h, 0C46Dh, 0A4D1h, 0F4FBh, 0D3D6h
        dw  0E96Ah, 04369h, 0D9FCh, 0346Eh, 08846h, 0AD67h, 0B8D0h, 0DA60h, 02D73h, 04404h, 01DE5h, 03303h, 04C5Fh, 0AA0Ah, 07CC9h, 0DD0Dh
        dw  0713Ch, 05005h, 041AAh, 02702h, 01010h, 0BE0Bh, 02086h, 0C90Ch, 0B525h, 05768h, 085B3h, 0206Fh, 0D409h, 0B966h, 0E49Fh, 0CE61h
        dw  0F90Eh, 05EDEh, 0C998h, 029D9h, 09822h, 0B0D0h, 0A8B4h, 0C7D7h, 03D17h, 059B3h, 00D81h, 02EB4h, 05C3Bh, 0B7BDh, 06CADh, 0C0BAh
        dw  08320h, 0EDB8h, 0B3B6h, 09ABFh, 0E20Ch, 003B6h, 0D29Ah, 074B1h, 04739h, 0EAD5h, 077AFh, 09DD2h, 02615h, 004DBh, 01683h, 073DCh
        dw  00B12h, 0E363h, 03B84h, 09464h, 06A3Eh, 00D6Dh, 05AA8h, 07A6Ah, 0CF0Bh, 0E40Eh, 0FF9Dh, 09309h, 0AE27h, 00A00h, 09EB1h, 07D07h
        dw  09344h, 0F00Fh, 0A3D2h, 08708h, 0F268h, 01E01h, 0C2FEh, 06906h, 0575Dh, 0F762h, 067CBh, 08065h, 03671h, 0196Ch, 006E7h, 06E6Bh
        dw  01B76h, 0FED4h, 02BE0h, 089D3h, 07A5Ah, 010DAh, 04ACCh, 067DDh, 0DF6Fh, 0F9B9h, 0EFF9h, 08EBEh, 0BE43h, 017B7h, 08ED5h, 060B0h
        dw  0A3E8h, 0D6D6h, 0937Eh, 0A1D1h, 0C2C4h, 038D8h, 0F252h, 04FDFh, 067F1h, 0D1BBh, 05767h, 0A6BCh, 006DDh, 03FB5h, 0364Bh, 048B2h
        dw  02BDAh, 0D80Dh, 01B4Ch, 0AF0Ah, 04AF6h, 03603h, 07A60h, 04104h, 0EFC3h, 0DF60h, 0DF55h, 0A867h, 08EEFh, 0316Eh, 0BE79h, 04669h
        dw  0B38Ch, 0CB61h, 0831Ah, 0BC66h, 0D2A0h, 0256Fh, 0E236h, 05268h, 07795h, 0CC0Ch, 04703h, 0BB0Bh, 016B9h, 02202h, 0262Fh, 05505h
        dw  03BBEh, 0C5BAh, 00B28h, 0B2BDh, 05A92h, 02BB4h, 06A04h, 05CB3h, 0FFA7h, 0C2D7h, 0CF31h, 0B5D0h, 09E8Bh, 02CD9h, 0AE1Dh, 05BDEh
        dw  0C2B0h, 09B64h, 0F226h, 0EC63h, 0A39Ch, 0756Ah, 0930Ah, 0026Dh, 006A9h, 09C09h, 0363Fh, 0EB0Eh, 06785h, 07207h, 05713h, 00500h
        dw  04A82h, 095BFh, 07A14h, 0E2B8h, 02BAEh, 07BB1h, 01B38h, 00CB6h, 08E9Bh, 092D2h, 0BE0Dh, 0E5D5h, 0EFB7h, 07CDCh, 0DF21h, 00BDBh
        dw  0D2D4h, 086D3h, 0E242h, 0F1D4h, 0B3F8h, 068DDh, 0836Eh, 01FDAh, 016CDh, 081BEh, 0265Bh, 0F6B9h, 077E1h, 06FB0h, 04777h, 018B7h
        dw  05AE6h, 08808h, 06A70h, 0FF0Fh, 03BCAh, 06606h, 00B5Ch, 01101h, 09EFFh, 08F65h, 0AE69h, 0F862h, 0FFD3h, 0616Bh, 0CF45h, 0166Ch
        dw  0E278h, 0A00Ah, 0D2EEh, 0D70Dh, 08354h, 04E04h, 0B3C2h, 03903h, 02661h, 0A767h, 016F7h, 0D060h, 0474Dh, 04969h, 077DBh, 03E6Eh
        dw  06A4Ah, 0AED1h, 05ADCh, 0D9D6h, 00B66h, 040DFh, 03BF0h, 037D8h, 0AE53h, 0A9BCh, 09EC5h, 0DEBBh, 0CF7Fh, 047B2h, 0FFE9h, 030B5h
        dw  0F21Ch, 0BDBDh, 0C28Ah, 0CABAh, 09330h, 053B3h, 0A3A6h, 024B4h, 03605h, 0BAD0h, 00693h, 0CDD7h, 05729h, 054DEh, 067BFh, 023D9h
        dw  07A2Eh, 0B366h, 04AB8h, 0C461h, 01B02h, 05D68h, 02B94h, 02A6Fh, 0BE37h, 0B40Bh, 08EA1h, 0C30Ch, 0DF1Bh, 05A05h, 0EF8Dh, 02D02h
;*------------ первая таблица для CRC32 -------------*
Table1  dw  00000h, 03096h, 0612Ch, 051BAh, 0C419h, 0F48Fh, 0A535h, 095A3h 
        dw  08832h, 0B8A4h, 0E91Eh, 0D988h, 04C2Bh, 07CBDh, 02D07h, 01D91h 
        dw  01064h, 020F2h, 07148h, 041DEh, 0D47Dh, 0E4EBh, 0B551h, 085C7h 
        dw  09856h, 0A8C0h, 0F97Ah, 0C9ECh, 05C4Fh, 06CD9h, 03D63h, 00DF5h 
        dw  020C8h, 0105Eh, 041E4h, 07172h, 0E4D1h, 0D447h, 085FDh, 0B56Bh 
        dw  0A8FAh, 0986Ch, 0C9D6h, 0F940h, 06CE3h, 05C75h, 00DCFh, 03D59h 
        dw  030ACh, 0003Ah, 05180h, 06116h, 0F4B5h, 0C423h, 09599h, 0A50Fh 
        dw  0B89Eh, 08808h, 0D9B2h, 0E924h, 07C87h, 04C11h, 01DABh, 02D3Dh 
        dw  04190h, 07106h, 020BCh, 0102Ah, 08589h, 0B51Fh, 0E4A5h, 0D433h 
        dw  0C9A2h, 0F934h, 0A88Eh, 09818h, 00DBBh, 03D2Dh, 06C97h, 05C01h 
        dw  051F4h, 06162h, 030D8h, 0004Eh, 095EDh, 0A57Bh, 0F4C1h, 0C457h 
        dw  0D9C6h, 0E950h, 0B8EAh, 0887Ch, 01DDFh, 02D49h, 07CF3h, 04C65h 
        dw  06158h, 051CEh, 00074h, 030E2h, 0A541h, 095D7h, 0C46Dh, 0F4FBh 
        dw  0E96Ah, 0D9FCh, 08846h, 0B8D0h, 02D73h, 01DE5h, 04C5Fh, 07CC9h 
        dw  0713Ch, 041AAh, 01010h, 02086h, 0B525h, 085B3h, 0D409h, 0E49Fh 
        dw  0F90Eh, 0C998h, 09822h, 0A8B4h, 03D17h, 00D81h, 05C3Bh, 06CADh 
        dw  08320h, 0B3B6h, 0E20Ch, 0D29Ah, 04739h, 077AFh, 02615h, 01683h 
        dw  00B12h, 03B84h, 06A3Eh, 05AA8h, 0CF0Bh, 0FF9Dh, 0AE27h, 09EB1h 
        dw  09344h, 0A3D2h, 0F268h, 0C2FEh, 0575Dh, 067CBh, 03671h, 006E7h 
        dw  01B76h, 02BE0h, 07A5Ah, 04ACCh, 0DF6Fh, 0EFF9h, 0BE43h, 08ED5h 
        dw  0A3E8h, 0937Eh, 0C2C4h, 0F252h, 067F1h, 05767h, 006DDh, 0364Bh 
        dw  02BDAh, 01B4Ch, 04AF6h, 07A60h, 0EFC3h, 0DF55h, 08EEFh, 0BE79h 
        dw  0B38Ch, 0831Ah, 0D2A0h, 0E236h, 07795h, 04703h, 016B9h, 0262Fh 
        dw  03BBEh, 00B28h, 05A92h, 06A04h, 0FFA7h, 0CF31h, 09E8Bh, 0AE1Dh 
        dw  0C2B0h, 0F226h, 0A39Ch, 0930Ah, 006A9h, 0363Fh, 06785h, 05713h 
        dw  04A82h, 07A14h, 02BAEh, 01B38h, 08E9Bh, 0BE0Dh, 0EFB7h, 0DF21h 
        dw  0D2D4h, 0E242h, 0B3F8h, 0836Eh, 016CDh, 0265Bh, 077E1h, 04777h 
        dw  05AE6h, 06A70h, 03BCAh, 00B5Ch, 09EFFh, 0AE69h, 0FFD3h, 0CF45h 
        dw  0E278h, 0D2EEh, 08354h, 0B3C2h, 02661h, 016F7h, 0474Dh, 077DBh 
        dw  06A4Ah, 05ADCh, 00B66h, 03BF0h, 0AE53h, 09EC5h, 0CF7Fh, 0FFE9h 
        dw  0F21Ch, 0C28Ah, 09330h, 0A3A6h, 03605h, 00693h, 05729h, 067BFh 
        dw  07A2Eh, 04AB8h, 01B02h, 02B94h, 0BE37h, 08EA1h, 0DF1Bh, 0EF8Dh
;*------------ вторая таблица для CRC32 -------------*
Table2  dw  00000h, 07707h, 0EE0Eh, 09909h, 0076Dh, 0706Ah, 0E963h, 09E64h 
        dw  00EDBh, 079DCh, 0E0D5h, 097D2h, 009B6h, 07EB1h, 0E7B8h, 090BFh 
        dw  01DB7h, 06AB0h, 0F3B9h, 084BEh, 01ADAh, 06DDDh, 0F4D4h, 083D3h 
        dw  0136Ch, 0646Bh, 0FD62h, 08A65h, 01401h, 06306h, 0FA0Fh, 08D08h 
        dw  03B6Eh, 04C69h, 0D560h, 0A267h, 03C03h, 04B04h, 0D20Dh, 0A50Ah 
        dw  035B5h, 042B2h, 0DBBBh, 0ACBCh, 032D8h, 045DFh, 0DCD6h, 0ABD1h 
        dw  026D9h, 051DEh, 0C8D7h, 0BFD0h, 021B4h, 056B3h, 0CFBAh, 0B8BDh 
        dw  02802h, 05F05h, 0C60Ch, 0B10Bh, 02F6Fh, 05868h, 0C161h, 0B666h 
        dw  076DCh, 001DBh, 098D2h, 0EFD5h, 071B1h, 006B6h, 09FBFh, 0E8B8h 
        dw  07807h, 00F00h, 09609h, 0E10Eh, 07F6Ah, 0086Dh, 09164h, 0E663h 
        dw  06B6Bh, 01C6Ch, 08565h, 0F262h, 06C06h, 01B01h, 08208h, 0F50Fh 
        dw  065B0h, 012B7h, 08BBEh, 0FCB9h, 062DDh, 015DAh, 08CD3h, 0FBD4h 
        dw  04DB2h, 03AB5h, 0A3BCh, 0D4BBh, 04ADFh, 03DD8h, 0A4D1h, 0D3D6h 
        dw  04369h, 0346Eh, 0AD67h, 0DA60h, 04404h, 03303h, 0AA0Ah, 0DD0Dh 
        dw  05005h, 02702h, 0BE0Bh, 0C90Ch, 05768h, 0206Fh, 0B966h, 0CE61h 
        dw  05EDEh, 029D9h, 0B0D0h, 0C7D7h, 059B3h, 02EB4h, 0B7BDh, 0C0BAh 
        dw  0EDB8h, 09ABFh, 003B6h, 074B1h, 0EAD5h, 09DD2h, 004DBh, 073DCh
        dw  0E363h, 09464h, 00D6Dh, 07A6Ah, 0E40Eh, 09309h, 00A00h, 07D07h 
        dw  0F00Fh, 08708h, 01E01h, 06906h, 0F762h, 08065h, 0196Ch, 06E6Bh 
        dw  0FED4h, 089D3h, 010DAh, 067DDh, 0F9B9h, 08EBEh, 017B7h, 060B0h 
        dw  0D6D6h, 0A1D1h, 038D8h, 04FDFh, 0D1BBh, 0A6BCh, 03FB5h, 048B2h 
        dw  0D80Dh, 0AF0Ah, 03603h, 04104h, 0DF60h, 0A867h, 0316Eh, 04669h 
        dw  0CB61h, 0BC66h, 0256Fh, 05268h, 0CC0Ch, 0BB0Bh, 02202h, 05505h 
        dw  0C5BAh, 0B2BDh, 02BB4h, 05CB3h, 0C2D7h, 0B5D0h, 02CD9h, 05BDEh 
        dw  09B64h, 0EC63h, 0756Ah, 0026Dh, 09C09h, 0EB0Eh, 07207h, 00500h 
        dw  095BFh, 0E2B8h, 07BB1h, 00CB6h, 092D2h, 0E5D5h, 07CDCh, 00BDBh 
        dw  086D3h, 0F1D4h, 068DDh, 01FDAh, 081BEh, 0F6B9h, 06FB0h, 018B7h 
        dw  08808h, 0FF0Fh, 06606h, 01101h, 08F65h, 0F862h, 0616Bh, 0166Ch 
        dw  0A00Ah, 0D70Dh, 04E04h, 03903h, 0A767h, 0D060h, 04969h, 03E6Eh 
        dw  0AED1h, 0D9D6h, 040DFh, 037D8h, 0A9BCh, 0DEBBh, 047B2h, 030B5h 
        dw  0BDBDh, 0CABAh, 053B3h, 024B4h, 0BAD0h, 0CDD7h, 054DEh, 023D9h 
        dw  0B366h, 0C461h, 05D68h, 02A6Fh, 0B40Bh, 0C30Ch, 05A05h, 02D02h
key0       dd  12345678h            ; 0EBE
key1       dd  23456789h            ; 0EC2
key2       dd  34567890h            ; 0EC6
Stream     db  1024 dup (0)         ; подается параметром
Point      dw  0                    ; текущее положение в Stream []
curnum     dw   10 dup (0)
BufUse     db   12 dup (0)
i          dw   0
carry      dw   0
l          dw   0
cur        db   0
digit      db   512 dup (0)
        ;----123456789-123456789-1234567----
;digit:
;        db  '~@#$%^&*()_+-=[]{},.\"/?:;`'     ; +27
;        db  27h  ;\'                          ; +01
;        db  'abcdefghijklmnopqrstuvwxyz'      ; +26
;        db  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'      ; +26
;        db  '0123456789'                      ; +10
                                        ; ----------
                                        ; Итого: 90
param   struc
pBufUse dd   0         ; +0
pStream dd   0         ; +4
passbeg dw   0         ; +8
passend dw   0         ; +10
pcurnum dd   0         ; +12
psize   dw   3 dup (0) ; +16
pBits   dw   0         ; +22
pCPU    dw   0         ; +24
pSizeD  dw   0         ; +26
pDigit  dd   0         ; +28
pVideo  dw   0         ; +32
param   ends           ; --- 34

Input:
param   <>

;-----------------------------------------
; функция       Update_keys
;-----------------------------------------
;void update_keys (unsigned char Sym)
;{
;Key [0] = crc32 (Key [0],Sym);
;Key [1] = Key [1] + (Key [0] & 0xFF);
;Key [1] = Key [1] * 134775813L + 1L;
;Key [2] = crc32 (Key [2], (unsigned char)(Key [1] >> 24));
;}
;-----------------------------------------
; параметр в BX: символ пароля
;-----------------------------------------
update_keys         proc      near
                    PUSH      SI
                    MOV       SI,offset key0  ; 0EBE
                    CALL      crc32           ; функция CRC32
                    MOV       SI,offset key1  ; 0EC2
                    MOV       CX,Word Ptr [SI]
                    MOV       BX,Word Ptr [SI+2]
                    XOR       AH,AH
                    ADD       CX,AX
                    ADC       BX,0
                    MOV       DX,8405h
                    MOV       AX,CX
                    MUL       DX
                    SHL       CX,1
                    SHL       CX,1
                    SHL       CX,1
                    ADD       CH,CL
                    ADD       DX,CX
                    ADD       DX,BX
                    SHL       BX,1
                    SHL       BX,1
                    ADD       DX,BX
                    ADD       DH,BL
                    MOV       CL,5
                    SHL       BX,CL
                    ADD       DH,BL
                    ADD       AX,1
                    ADC       DX,0
                    MOV       Word Ptr [SI],AX
                    MOV       Word Ptr [SI+2],DX
                    MOV       BL,DH
                    XOR       BH,BH
                    MOV       SI,offset key2  ; 0EC6
                    CALL      crc32           ; функция CRC32
                    POP       SI
                    RET
update_keys         endp
;-----------------------------------------
;   функция CRC32 (key,char)
;-----------------------------------------
crc32               proc      near
                    LODSW     
                    MOV       DX,Word Ptr [SI]
                    XOR       BL,AL
                    MOV       AL,AH
                    MOV       AH,DL
                    MOV       DL,DH
                    XOR       DH,DH
                    SHL       BX,1
                    XOR       AX,Word Ptr Table1[BX]
                    XOR       DX,Word Ptr Table2[BX]
                    MOV       Word Ptr [SI-2],AX
                    MOV       Word Ptr [SI],DX
                    RET
crc32               endp
;-----------------------------------------
; параметр в BX: символ пароля
;-----------------------------------------
update_keys_386     proc      near
                    .386
                    XOR       ECX,ECX
                    MOVZX     EDX,bx
                    mov       bx,di
                    lea       DI,key0               ;0EBE
                    CLI       
                    MOV       EAX,DWord Ptr [DI]           ;\
                    XOR       DL,AL                        ; |
                    SHR       EAX,8                        ; | crc32
                    XOR       EAX,DWord Ptr [ECX+4*EDX]    ; |
                    STOSD                                  ;/  ds:si=EAX
                    MOV       DL,AL
                    MOV       EAX,DWord Ptr [DI]           ; EAX = key1
                    ADD       EAX,EDX
                    IMUL      EAX,EAX,08088405h
                    INC       EAX
                    STOSD
                    SHR       EAX,18h
                    MOV       EDX,DWord Ptr [DI]           ;\ EDX = key1
                    XOR       AL,DL                        ; |
                    SHR       EDX,8                        ; | crc32
                    XOR       EDX,DWord Ptr [ECX+4*EAX]    ; |
                    STI                                    ; |
                    MOV       DWord Ptr [DI],EDX           ;/
                    mov       di,bx
                    .8086
                    RET
update_keys_386     endp
;-----------------------------------------
;unsigned char decrypt_byte (void)
;-----------------------------------------
;register unsigned short temp;
;temp = (unsigned int)(Key [2] | 2);
;return (unsigned char)((temp * (temp ^ 1)) >> 8);
;-----------------------------------------
descrypt_byte       proc      near
                    MOV       cx,Word Ptr key2   ; [0EC6]
                    OR        cx,2
                    MOV       ax,cx
                    XOR       al,1
                    MUL       cx
                    mov       al,ah
                    sub       ah,ah
                    RET
descrypt_byte       endp

result              dw     0
entry               dw     0

ConstructTree       proc   near
                    mov    di,ax
                    MOV       cx,Word Ptr key2   ; [0EC6]
                    OR        cx,2
                    MOV       ax,cx
                    XOR       al,1
                    MUL       cx
                    mov       al,ah
                    sub       ah,ah
                    mov    si,word ptr Point
                    xor    al,byte ptr Stream [si]
                    or     bx,bx
                    jz     do_continue
                    cmp    ax,bx
                    jz     do_continue
                    ret
do_continue:
                    mov    word ptr entry,di
                    mov    si,ax
                    mov    bx,ax
                    call   update_keys
                    inc    si
                    mov    word ptr result,si
                    inc    word ptr Point
                    xor    di,di
while_loop_t:
                    MOV       cx,Word Ptr key2   ; [0EC6]
                    OR        cx,2
                    MOV       ax,cx
                    XOR       al,1
                    MUL       cx
                    mov       al,ah
                    sub       ah,ah
                    mov    bx,word ptr Point
                    xor    al,byte ptr Stream [bx]
                    mov    bp,ax
                    mov    bx,ax
                    call   update_keys
                    mov    cl,4
                    shr    bp,cl
                    and    bp,0Fh
                    inc    bp
                    add    di,bp
                    cmp    di,word ptr entry
                    ja     err_1
                    inc    word ptr Point
                    dec    si
                    jnz    while_loop_t
                    
                    cmp    di,word ptr entry
                    jnz    err_1
                    
                    mov    ax,word ptr result
                    inc    ax
                    cmp    ax,ax
                    ret
err_1:
                    ret
ConstructTree       endp
ConstructTree_386   proc   near
                    mov    di,ax
                    MOV       cx,Word Ptr key2   ; [0EC6]
                    OR        cx,2
                    MOV       ax,cx
                    XOR       al,1
                    MUL       cx
                    mov       al,ah
                    sub       ah,ah
                    mov    si,word ptr Point
                    xor    al,byte ptr Stream [si]
                    or     bx,bx
                    jz     do_continue_386
                    cmp    ax,bx
                    jz     do_continue_386
                    ret
do_continue_386:
                    mov    word ptr entry,di
                    mov    si,ax
                    mov    bx,ax
                    call   update_keys_386
                    inc    si
                    mov    word ptr result,si
                    inc    word ptr Point
                    xor    di,di
while_loop_t_386:
                    MOV       cx,Word Ptr key2   ; [0EC6]
                    OR        cx,2
                    MOV       ax,cx
                    XOR       al,1
                    MUL       cx
                    mov       al,ah
                    sub       ah,ah
                    mov    bx,word ptr Point
                    xor    al,byte ptr Stream [bx]
                    mov    bp,ax
                    mov    bx,ax
                    call   update_keys
                    mov    cl,4
                    shr    bp,cl
                    and    bp,0Fh
                    inc    bp
                    add    di,bp
                    cmp    di,word ptr entry
                    ja     err_1_386
                    inc    word ptr Point
                    dec    si
                    jnz    while_loop_t_386
                    
                    cmp    di,word ptr entry
                    jnz    err_1_386
                    
                    mov    ax,word ptr result
                    inc    ax
                    cmp    ax,ax
                    ret
err_1_386:
                    ret
ConstructTree_386   endp

mess                db     0Dh,'Password: '

PrnPassword         proc   near
                    mov    si,offset mess
                    mov    cx,11
dispm:
                    lodsb
                    mov    dl,al
                    mov    ah,2
                    int    21h
                    loop   dispm
                    
                    mov    cx,word ptr Input.passbeg
                    xor    bp,bp
dispp:
                    mov    si,word ptr curnum [bp]
                    mov    dl,byte ptr digit [si]
                    mov    ah,2
                    int    21h
                    inc    bp
                    inc    bp
                    loop   dispp
                    
                    ret
PrnPassword         endp

public          _test_
_test_          proc    far
                push    bp
                mov     bp,sp
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    es
                push    ds
                push    bp
                cld
                push    cs
                pop     es
                mov     di,offset Input
                lds     si,dword ptr ss:[bp+6]
                mov     cx,34
                rep     movsb
                
                mov     di,offset BufUse
                lds     si,dword ptr cs:Input.pBufUse
                mov     cx,12
                rep     movsb
                
                mov     di,offset Stream
                lds     si,dword ptr cs:Input.pStream
                mov     cx,1024
                rep     movsb
                
                mov     di,offset curnum
                lds     si,dword ptr cs:Input.pcurnum
                mov     cx,10
                rep     movsw
                
                mov     di,offset digit
                lds     si,dword ptr cs:Input.pDigit
                mov     cx,word ptr cs:Input.pSizeD
                rep     movsb
                
                push    cs
                pop     ds
                test    byte ptr Input.pBits,4
                jz      skip_Literal
                mov     byte ptr do_jmp+1,0
                mov     byte ptr do_jmp_386+1,0
skip_Literal:
                mov     byte ptr Input.pBits+1,0
for_loop:
                mov     word ptr carry,0
while_loop:
                mov     ax,word ptr carry
                cmp     ax,word ptr Input.passbeg
                jb      tmp_1
                jmp     exit_while_loop
tmp_1:
                mov     word ptr l,0
for_loop_1:
                mov     ax,word ptr l
                mov     word ptr curnum,ax
                mov     word ptr Point,0
                
                mov     word ptr key0+2, 1234h
                mov     word ptr key0  , 5678h
                mov     word ptr key1+2, 2345h
                mov     word ptr key1  , 6789h
                mov     word ptr key2+2, 3456h
                mov     word ptr key2  , 7890h
                
                mov     si,offset curnum
                mov     di,word ptr Input.passbeg
                cmp       byte ptr Input.pCPU,0
                jnz       loc_386
for_loop_2:
                mov     bx,word ptr ds:[si]
                mov     bl,byte ptr digit [bx]
                xor     bh,bh
                call    update_keys
                inc     si
                inc     si
                dec     di
                jnz     for_loop_2
                
                mov     bp,offset BufUse
for_loop_3:
                MOV     cx,Word Ptr key2   ; [0EC6]
                OR      cl,2
                MOV     ax,cx
                XOR     al,1
                MUL     cx
                mov     bl,ah
                sub     bh,bh
                xor     bl,byte ptr ds:[bp+di]
                call    update_keys
                inc     di
                cmp     di,12
                jb      for_loop_3
do_jmp:
                jmp     short two_tree
                mov     ax,256
                mov     bx,97
                call    ConstructTree
                jnz     end_for_loop_1_t
                mov     word ptr Input.psize,ax
two_tree:
                mov     ax,64
                xor     bx,bx
                call    ConstructTree
end_for_loop_1_t:
                jnz     end_for_loop_1
                mov     word ptr Input.psize+2,ax
                mov     ax,64
                xor     bx,bx
                call    ConstructTree
                jnz     end_for_loop_1
                mov     word ptr Input.psize+4,ax
                mov     byte ptr Input.pBits+1,1 ; Нашли-и-И-И !!!!!!! Гип-Гип-Ура!
                jmp     exit_for_loop
loc_386:
for_loop_2_386:
                mov     bx,word ptr ds:[si]
                mov     bl,byte ptr digit [bx]
                xor     bh,bh
                call    update_keys_386
                inc     si
                inc     si
                dec     di
                jnz     for_loop_2_386
                
                mov     bp,offset BufUse
for_loop_3_386:
                MOV     cx,Word Ptr key2   ; [0EC6]
                OR      cl,2
                MOV     ax,cx
                XOR     al,1
                MUL     cx
                mov     bl,ah
                sub     bh,bh
                xor     bl,byte ptr ds:[bp+di]
                call    update_keys_386
                inc     di
                cmp     di,12
                jb      for_loop_3_386
do_jmp_386:
                jmp     short two_tree_386
                mov     ax,256
                mov     bx,97
                call    ConstructTree_386
                jnz     end_for_loop_1
                mov     word ptr Input.psize,ax
two_tree_386:
                mov     ax,64
                xor     bx,bx
                call    ConstructTree_386
                jnz     end_for_loop_1
                mov     word ptr Input.psize+2,ax
                mov     ax,64
                xor     bx,bx
                call    ConstructTree_386
                jnz     end_for_loop_1
                mov     word ptr Input.psize+4,ax
                mov     byte ptr Input.pBits+1,1 ; Нашли-и-И-И !!!!!!! Гип-Гип-Ура!
                jmp     exit_for_loop
end_for_loop_1:
                inc     word ptr l
                mov     ax,word ptr l
                cmp     ax,word ptr Input.pSizeD
                jae     tmp_2
                jmp     for_loop_1
tmp_2:
                mov     cx,word ptr Input.pSizeD
                dec     cx
                mov     ax,1
while_loop_1:
                mov     bx,ax
                shl     bx,1
                cmp     word ptr curnum [bx],cx
                jb      exit_while_loop_1
                mov     word ptr curnum [bx],0
                inc     ax
                cmp     ax,word ptr Input.passbeg
                jb      while_loop_1
exit_while_loop_1:
                inc     word ptr curnum [bx]
                mov     word ptr carry,ax
                cmp     byte ptr Input.pVideo,0
                jz      no_cur_cmp
                inc     byte ptr cur
                cmp     byte ptr cur,100
                jb      end_while_loop
                mov     byte ptr cur,0
no_cur_cmp:
                call    PrnPassword
end_while_loop:
                jmp     while_loop
exit_while_loop:
                mov     ax,word ptr Input.passbeg
                cmp     ax,word ptr Input.passend
                jae     exit_for_loop
                xor     ax,ax
                mov     di,offset curnum
                mov     cx,10
                rep     stosw
                inc     word ptr Input.passbeg
                jmp     for_loop
exit_for_loop:
                pop     bp
                cld
                mov     si,offset Input
                les     di,dword ptr ss:[bp+6]
                mov     cx,34
                rep     movsb
                
                mov     si,offset curnum
                les     di,dword ptr cs:Input.pcurnum
                mov     cx,10
                rep     movsw
                
                pop     ds
                pop     es
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     bp
                retf
_test_          endp

seg_a           ends
                end

