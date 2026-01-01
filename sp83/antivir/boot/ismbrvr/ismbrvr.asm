.model tiny
.radix 16
.code
        org 100
start:
        mov     dx,offset message
        mov     ah,09
        int     21
        xor     ax,ax
        int     16
        or      al,20
        cmp     al,'y'
        je      Goforit
        mov     dx,offset notdone
        mov     ah,09
        int     21
        mov     ax,4c01
        int     21

GoForIt:
        xor     ax,ax
        mov     ds,ax
        mov     ax,word ptr ds:[413]
        mov     cs:ConvMEM,ax        
        mov     di,offset Int13
        mov     si,13*4
        movsw
        movsw
        push    cs
        pop     ds
        
        cmp     ConvMem,280
        je      RegConvMem
        mov     ah,09
        mov     dx,offset StrangeConv
        int     21

RegCOnvMem:

        mov     ax,0201
        mov     bx,offset OrgSector
        mov     cx,1
        mov     dx,80
        int     13

        call    TunnelInterrupts
        mov     ax,0201
        mov     bx,offset NewSec
        mov     cx,1
        mov     dx,80
        int     13

        push    cs cs
        pop     es ds
        mov     di,offset NewSec
        mov     si,offset OrgSector
        mov     cx,200
        repz    cmpsb
        jcxz    NoDifference

        mov     ax,0301
        mov     bx,offset OrgSector
        mov     cx,1
        mov     dx,80
        int     13

        mov     ah,3c
        mov     dx,offset sample
        xor     cx,cx
        int     21
        xchg    bx,ax
        mov     ah,40
        mov     dx,offset NewSec
        mov     cx,200
        int     21
        mov     ah,3e
        int     21


LOCKEMIN:
        cli
        mov     ah,09
        mov     dx,offset fixed
        int     21

        xor     ax,ax
        int     16
        jmp     LOCKEMIN


Nodifference:
        mov     ah,09
        mov     dx,offset noprob
        int     21
        mov     ax,4c00
        int     21

TunnelInterrupts:
        push    ax bx cx dx es ds si di
        xor     ax,ax
        mov     ds,ax
        push    word ptr ds:[04]
        push    word ptr ds:[06]
        cli
        mov     word ptr ds:[04],offset Int1
        mov     word ptr ds:[06],cs
        
        pushf
        
        pushf
        pop     ax
        or      ax,100
        push    ax
        popf
        
        xor     ax,ax
        call    dword ptr cs:[int13]   ;tunnel interrupt 13

        pushf
        pop     ax
        and     ax,0feff
        push    ax
        popf

   ExitTunnel:
        les     bx,dword ptr cs:[Root13]
        cli
        xor     ax,ax
        mov     ds,ax
        pop     word ptr ds:[06]
        pop     word ptr ds:[04]
        mov     word ptr ds:[13*4],bx
        mov     word ptr ds:[13*4+2],es
        sti
        pop     di si ds es dx cx bx ax
        ret

Int1:
        cmp     cs:found,1
        je      exitint1
        push    bp
        mov     bp,sp
        push    ax bx cx dx es ds si di
        mov     ax,ss:[bp+2]
        mov     cx,4
        shr     ax,cl
        add     ax,ss:[bp+4]
        cmp     ax,0c000
        jb      DoneInt1
        mov     cs:found,1
        les     bx,SS:[bp+2]
        mov     word ptr cs:[Root13],bx
        mov     word ptr cs:[Root13+2],es
  DoneInt1:
        pop     di si ds es dx cx bx ax bp
exitint1:
        iret

StrangeConv db   0a,0dh,'Conventional Memory Suspicious.',0a,0dh,24
Fixed   db      0a,0dh,'Virus Cleaned - sample saved in VIRUS.MBR .',0a,0dh  
        db             'Now COLD REBOOT IMMEDIATELY!!!!!!!!!!!!!!!!',0a,0dh,24
NoProb  db      0a,0dh,'No Stealthing Detected.  No Action Taken.',0a,0dh,24
notdone db      0a,0dh,'No Action Taken.',0a,0dh,24
Message:
db      0a,0dh
db      '--==[Stormbringer''s Instant Stealth MBR Virus Remover.]==--',0a,0dh
db      '          USE AT YOUR OWN RISK!  RTFM Before Using!         ',0a,0dh
db      0a,0dh,'Continue (y/N)',24
sample          db      'Virus.MBR',0
found           db      0

NewSec          db      200 dup(?)
OrgSector       db      200 dup(?)
Int13           dd      ?
Root13          dd      ?
ConvMem         dw      ?

end start
