;AH  Сервис                                                                      
;▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;01H уст. размер/форму курсора (текст). Курсор, если он видим, всегда мерцает.  
;    Вход:  CH = начальная строка (0-1fH; 20H=подавить курсор)                  
;           CL = конечная строка (0-1fH)                                        
;▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

CSEG           SEGMENT  'CODE'   
               ASSUME ds:CSEG               
                                            
cursor         proc far

               pushf
               push ss
               push ax
               push cx

               mov ah, 01h
	       mov ch, 20h      ; supress cursor
               int 10h

               pop cx
               pop ax
               pop ss
               popf
               ret 

cseg ends
end  cursor
