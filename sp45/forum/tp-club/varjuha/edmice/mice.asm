MouseShape STRUC
           HotSpotX    dw   0
           HotSpotY    dw   0
           AndMask     dw   16 dup (0)
           XorMask     dw   16 dup (0)
           ENDS

ShowMouse MACRO
       mov   ax, 1
       int   33h
       ENDM

HideMouse MACRO
       mov   ax, 2
       int   33h
       ENDM

SetGraphMode MACRO
       mov   ax, 13h
       int   10h
       ENDM

SetTextMode MACRO
       mov   ax, 03h
       int   10h
       ENDM

MouseInstalled MACRO
LOCAL MIExit
       mov    ax, 3533h
       int    21h
       mov    ax, es
       or     ax, bx
       je     MIExit
       xor    ax, ax
       int    33h
       cmp    ax, 0FFFFh
       je     MIExit
       xor    ax, ax
   MIExit:
       ENDM

SetMouseShape MACRO  ShapeSeg, ShapeOfs
       mov    ax, ShapeSeg
       mov    es, ax
       mov    bx, offset ShapeOfs
       mov    ax, es:[bx]
       mov    cx, es:[bx+2]
       add    bx, 4
       mov    dx, bx
       mov    bx, ax
       mov    ax, 0009h
       int    33h
       ENDM

Getch  MACRO
       xor    ah, ah
       int    16h
       ENDM
