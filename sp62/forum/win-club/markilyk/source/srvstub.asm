;------------------------------------------------
;    SRVSTUB.ASM
;    (C)1992-93 Алксандр Маркилюк
;    Stub для ASSOCSRV.EXE
;------------------------------------------------
     .MODEL small
     .STACK 100h
     .DATA
Copyright db   'File assotiation utility server V2.0 (C) 1992-93 by'
          db   ' A.Markilyuk',0ah,0dh
          db   'This program must be run under Microsoft Windows 3.1'
          db   0dh,0ah,0dh,0ah,'$'

     .CODE

     mov  ax,@data
     mov  ds,ax
     mov  ah,9
     mov  dx, offset Copyright
     int  21h
     mov  ax,4c00h
     int  21h

     END
