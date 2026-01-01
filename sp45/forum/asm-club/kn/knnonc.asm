kn_segment segment byte public
           assume cs:kn_segment, ds:kn_segment
           org  100h

kn_start:  mov  ah,05h
           mov  cx,4400h
           int  16h
           mov  ah,05h
           mov  cl,0dh
           int  16h
           retn
kn_segment ends
           end  kn_start
