
CSEG           SEGMENT  'CODE'   
               ASSUME cs:CSEG               
                                            
cursor         proc far

               pushf
               push ss
               push ax
               push cx

               MOV    AL,10110110B                                     
               OUT    43H,AL                                           
               MOV    AX,1000                ;select frequency         
               OUT    42H,AL                 ; and send value one      
               MOV    AL,AH                  ;byte at a time           
               OUT    42H,AL                                           
               IN     AL,61H                 ;turn speaker on          
               MOV    AH,AL                                            
               OR     AL,3                                             
               OUT    61H,AL                                           
                                                                       
               MOV    CX,5000                ;CX controls duration     
KILLTIME:      LOOP   KILLTIME                                         
                                                                       
               MOV    AL,AH                  ;turn speaker off         
               OUT    61H,AL                                           

               pop cx
               pop ax
               pop ss
               popf
               ret 

cseg ends
end  cursor
