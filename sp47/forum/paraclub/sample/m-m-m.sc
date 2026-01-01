CoEdit "customer"

WHILE true
   CtrlHome Right   ; go to 1st field in tableview
   IMAGERIGHTS READONLY
   WAIT TABLE
      PROMPT "Choose customer, then press F10",
             "Press Esc to leave"
      UNTIL "F10","Esc"
   IMAGERIGHTS
   SWITCH
      CASE RETVAL = "F10" :
         PICKFORM "1"
         WHILE true
            DownImage          ; go to 2nd level table
            IMAGERIGHTS READONLY
            WAIT TABLE
               PROMPT "Choose invoice, then press F10 to show items",
                      "Press Esc to return to CUSTOMER select"
               UNTIL "F10","Esc"
            IMAGERIGHTS
            SWITCH
               CASE RETVAL = "F10" :
                  UpImage      ; go to 1st level table
                  [INVOICE ID LINK] = [INVOICE->INVOICE ID]   ; assign LINK
                  displaydate  = [INVOICE->INVOICE DATE] ; display variable
                  PgDn                                   ; Page 2 of form
                  DownImage
                  IMAGERIGHTS UPDATE
                  WAIT TABLE                       ; go to 3rd level table
                     PROMPT "Browse thru items, press Esc to leave"
                     UNTIL "Esc"
                  IMAGERIGHTS
                  UNLOCKRECORD ; must unlock record before leaving linked form
                  UpImage      ; go to 1st level table
                  PgUp         ; go to page 1, where 2nd level table is
               CASE RETVAL = "Esc" :
                  QUITLOOP
            ENDSWITCH
         ENDWHILE
         FormKey ; back to tableview
      CASE RETVAL = "Esc" :
         QUITLOOP
   ENDSWITCH
ENDWHILE
do_it!
clearall
