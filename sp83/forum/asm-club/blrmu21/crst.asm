page ,132
title crst ( cursor reset ) - as of 05/14/96 - 06:05 pm
;
         .model small
         .code
;
         org   256
;
crst:
;
         mov   ah,1                  ; set cursor type
         mov   ch,6                  ; start line ( from top )
         mov   cl,7                  ; end line ( from top )
         int   16                    ; interrupt 10h
         ret
;
         end   crst