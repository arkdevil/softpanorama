         .title Instruction code TEST

DATA_8   = 0233
DATA_16  = 2048
INDEX_8  = 0x16
BIT_3    = 3
RESTART  = 4     / Restart from address 0x20  (4 * 8)
PORT     = 15

/ Exchenge, Block move, Find

         ex      de, hl
         ex      af, af'
         exx
         ex      (sp), hl
         ex      (sp), ix
         ex      (sp), iy
         movi
         movir
         movd
         movdr
         cmpi
         cmpir
         cmpd
         cmpdr

/ 8 - bit arithmetic & logic
         add     b, a
         add     c, a
         add     d, a
         add     e, a
         add     h, a
         add     l, a
         add     a, a

         add     $DATA_8, a
         add     (hl), a
         add     INDEX_8(ix), a
         add     INDEX_8(iy), a

         adc     b, a
         adc     c, a
         adc     d, a
         adc     e, a
         adc     h, a
         adc     l, a
         adc     a, a

         adc     $DATA_8, a
         adc     (hl), a
         adc     INDEX_8(ix), a
         adc     INDEX_8(iy), a

         sub     b, a
         sub     c, a
         sub     d, a
         sub     e, a
         sub     h, a
         sub     l, a
         sub     a, a

         sub     $DATA_8, a
         sub     (hl), a
         sub     INDEX_8(ix), a
         sub     INDEX_8(iy), a

         sbc     b, a
         sbc     c, a
         sbc     d, a
         sbc     e, a
         sbc     h, a
         sbc     l, a
         sbc     a, a

         sbc     $DATA_8, a
         sbc     (hl), a
         sbc     INDEX_8(ix), a
         sbc     INDEX_8(iy), a

         and     b, a
         and     c, a
         and     d, a
         and     e, a
         and     h, a
         and     l, a
         and     a, a

         and     $DATA_8, a
         and     (hl), a
         and     INDEX_8(ix), a
         and     INDEX_8(iy), a

         or      b, a
         or      c, a
         or      d, a
         or      e, a
         or      h, a
         or      l, a
         or      a, a

         or      $DATA_8, a
         or      (hl), a
         or      INDEX_8(ix), a
         or      INDEX_8(iy), a

         xor     b, a
         xor     c, a
         xor     d, a
         xor     e, a
         xor     h, a
         xor     l, a
         xor     a, a

         xor     $DATA_8, a
         xor     (hl), a
         xor     INDEX_8(ix), a
         xor     INDEX_8(iy), a

         cmp     a, b
         cmp     a, c
         cmp     a, d
         cmp     a, e
         cmp     a, h
         cmp     a, l
         cmp     a, a

         cmp     a, $DATA_8
         cmp     a, (hl)
         cmp     a, INDEX_8(ix)
         cmp     a, INDEX_8(iy)

         inc     b
         inc     c
         inc     d
         inc     e
         inc     h
         inc     l
         inc     a
         inc     (hl)
         inc     INDEX_8(ix)
         inc     INDEX_8(iy)

         dec     b
         dec     c
         dec     d
         dec     e
         dec     h
         dec     l
         dec     a
         dec     (hl)
         dec     INDEX_8(ix)
         dec     INDEX_8(iy)

/ 8-bit load
         mov     b, c
         mov     c, d
         mov     d, e
         mov     e, h
         mov     h, l
         mov     l, a
         mov     a, b

         mov     $DATA_8, b
         mov     $DATA_8, c
         mov     $DATA_8, d
         mov     $DATA_8, e
         mov     $DATA_8, h
         mov     $DATA_8, l
         mov     $DATA_8, a

         mov     (hl), b
         mov     (hl), c
         mov     (hl), d
         mov     (hl), e
         mov     (hl), h
         mov     (hl), l
         mov     (hl), a

         mov     INDEX_8(ix), b
         mov     INDEX_8(ix), c
         mov     INDEX_8(ix), d
         mov     INDEX_8(ix), e
         mov     INDEX_8(ix), h
         mov     INDEX_8(ix), l
         mov     INDEX_8(ix), a

         mov     INDEX_8(iy), b
         mov     INDEX_8(iy), c
         mov     INDEX_8(iy), d
         mov     INDEX_8(iy), e
         mov     INDEX_8(iy), h
         mov     INDEX_8(iy), l
         mov     INDEX_8(iy), a

         mov     b, (hl)
         mov     c, (hl)
         mov     d, (hl)
         mov     e, (hl)
         mov     h, (hl)
         mov     l, (hl)
         mov     a, (hl)

         mov     b, INDEX_8(ix)
         mov     c, INDEX_8(ix)
         mov     d, INDEX_8(ix)
         mov     e, INDEX_8(ix)
         mov     h, INDEX_8(ix)
         mov     l, INDEX_8(ix)
         mov     a, INDEX_8(ix)

         mov     b, INDEX_8(iy)
         mov     c, INDEX_8(iy)
         mov     d, INDEX_8(iy)
         mov     e, INDEX_8(iy)
         mov     h, INDEX_8(iy)
         mov     l, INDEX_8(iy)
         mov     a, INDEX_8(iy)

         mov     $DATA_8, (hl)
         mov     $DATA_8, INDEX_8(ix)
         mov     $DATA_8, INDEX_8(iy)
         mov     (bc), a
         mov     (de), a
         mov     (bc), a
         mov     DATA+1, a
         mov     a, (bc)
         mov     a, (de)
         mov     a, DATA
         mov     v, a
         mov     r, a
         mov     a, v
         mov     a, r

/ 16-bit load
         mov     $DATA_16, bc
         mov     $DATA_16, de
         mov     $DATA_16, hl
         mov     $DATA_16, sp
         mov     $DATA_16, ix
         mov     $DATA_16, iy


         mov     hl, DATA

         mov     bc, DATA
         mov     de, DATA
         mov     hl, DATA
         mov     sp, DATA
         mov     ix, DATA
         mov     iy, DATA

         mov     DATA, hl

         mov     DATA, bc
         mov     DATA, de
         mov     DATA, hl
         mov     DATA, sp
         mov     DATA, ix
         mov     DATA, iy

         mov     hl, sp
         mov     ix, sp
         mov     iy, sp

         push    bc
         push    de
         push    hl
         push    af
         push    ix
         push    iy
         pop     bc
         pop     de
         pop     hl
         pop     af
         pop     ix
         pop     iy

/ Arithmetic & control
         daa
         com
         neg
         cmc
         sec
         nop
         halt
         di
         ei
         im      0
         im      1
         im      2

/ 16-bit arithmetic
         add     bc, hl
         add     de, hl
         add     hl, hl
         add     sp, hl

         adc     bc, hl
         adc     de, hl
         adc     hl, hl
         adc     sp, hl

         sbc     bc, hl
         sbc     de, hl
         sbc     hl, hl
         sbc     sp, hl

         add     bc, ix
         add     de, ix
         add     ix, ix
         add     sp, ix

         add     bc, iy
         add     de, iy
         add     iy, iy
         add     sp, iy

         inc     bc
         inc     de
         inc     hl
         inc     sp

         inc     ix
         inc     iy

         dec     bc
         dec     de
         dec     hl
         dec     sp

         dec     ix
         dec     iy

/ Rollers
         rlc     a
         rol     a
         rrc     a
         ror     a

         rlc     r
         rlc     (hl)
         rlc     INDEX_8(ix)
         rlc     INDEX_8(iy)

         rol     r
         rol     (hl)
         rol     INDEX_8(ix)
         rol     INDEX_8(iy)
         
         rrc     r
         rrc     (hl)
         rrc     INDEX_8(ix)
         rrc     INDEX_8(iy)

         ror     r
         ror     (hl)
         ror     INDEX_8(ix)
         ror     INDEX_8(iy)

         asl     r
         asl     (hl)
         asl     INDEX_8(ix)
         asl     INDEX_8(iy)

         asr     r
         asr     (hl)
         asr     INDEX_8(ix)
         asr     INDEX_8(iy)

         lsr     r
         lsr     (hl)
         lsr     INDEX_8(ix)
         lsr     INDEX_8(iy)

         rld
         rrd

/ Bits instrutions
         bit     BIT_3, b
         bit     BIT_3, c
         bit     BIT_3, d
         bit     BIT_3, e
         bit     BIT_3, h
         bit     BIT_3, l
         bit     BIT_3, a

         bit     BIT_3, (hl)
         bit     BIT_3, INDEX_8(ix)
         bit     BIT_3, INDEX_8(iy)

         bis     BIT_3, b
         bis     BIT_3, c
         bis     BIT_3, d
         bis     BIT_3, e
         bis     BIT_3, h
         bis     BIT_3, l
         bis     BIT_3, a

         bis     BIT_3, (hl)
         bis     BIT_3, INDEX_8(ix)
         bis     BIT_3, INDEX_8(iy)

         bic     BIT_3, b
         bic     BIT_3, c
         bic     BIT_3, d
         bic     BIT_3, e
         bic     BIT_3, h
         bic     BIT_3, l
         bic     BIT_3, a
ALFA:
         bic     BIT_3, (hl)
         bic     BIT_3, INDEX_8(ix)
         bic     BIT_3, INDEX_8(iy)

/ Calls
         call    ALFA
         ccs     ALFA
         cmi     ALFA
         ccc     ALFA
         cne     ALFA
         cpl     ALFA
         cpe     ALFA
         cpo     ALFA
         ceq     ALFA
         
         ret
         rcs
         rmi
         rcc
         rne
         rpl
         rpe
         rpo
         req

         reti
         retn

         rst     RESTART
         
/ Jumps
         jmp     ALFA

         jcs     ALFA
         jmi     ALFA
         jcc     ALFA
         jne     ALFA
         jpl     ALFA
         jpe     ALFA
         jpo     ALFA
         jeq     ALFA
1:         
         br      1b
         bcs     1b
         blo     1b
         bcc     1b
         bhis    1b
         beq     1b
         bne     1b
         jmp     (hl)
         jmp     (ix)
         jmp     (iy)
         sob     b, 1b

/ Input / Output
         in      PORT, a
         in      (c), b
         in      (c), c
         in      (c), d
         in      (c), e
         in      (c), h
         in      (c), l
         in      (c), a

         ini
         inir
         ind
         indr

         out     a, PORT
         out     b, (c)
         out     c, (c)
         out     d, (c)
         out     e, (c)
         out     h, (c)
         out     l, (c)
         out     a, (c)
         
         outi
         outir
         outd
         outdr

DATA:    .byte   035, 034, 033
         .end

 
