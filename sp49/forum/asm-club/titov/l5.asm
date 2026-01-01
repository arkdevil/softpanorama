; 5-start modules prefix loader.
; COPY this/B+Zmodule/B DOSmodule.com/B
                        push cs
                        pop  ax
                        add  ax,17
                        push ax     ; New CS=old+PSPsize(16)+size of this(1)
                        mov ax,5
                        push ax     ; New IP=0
                        retf        ; Load IP,CS
                        db "Titov"  ; (10 bytes needed)
                        db "Load5"
; There 5module begins
