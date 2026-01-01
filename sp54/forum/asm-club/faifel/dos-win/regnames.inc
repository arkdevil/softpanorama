'┌───────────────────────────────────────────────────────────────────────────┐
'│			      REGNAMES.INC				     │
'│									     │
'│			       Turbo Basic				     │
'│		(C) Copyright 1987 by Borland International		     │
'│									     │
'│   This file is to be used as a $INCLUDE file whenever you use the CALL    │
'│ INTERRUPT statement in your Turbo Basic program. The file contains        │
'│ named constants that represent the registers the CALL INTERRUPT statement │
'│ can manipulate.							     │
'│									     │
'│ In order to use this file include it in your programs using the $INCLUDE  │
'│ metastatement:                                          		     │
'│	                                                            	     │
'│   $INCLUDE "REGNAMES.INC"						     │
'│	                                  				     │
'└───────────────────────────────────────────────────────────────────────────┘

%FLAGS = 0
%AX    = 1
%BX    = 2
%CX    = 3
%DX    = 4
%SI    = 5
%DI    = 6
%BP    = 7
%DS    = 8
%ES    = 9
