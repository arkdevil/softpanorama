RBarLib v1.2 - 19/09/94    (c) 1993-95 Rolf van Gelder, All rights reserved
---------------------------------------------------------------------------

RBarLib : Clipper Library with Progress Bar functions

Packing list :

DEMODBF.DBF             - Demo Database file (used by RBarDemo)
DEMODBF.FRM             - Demo Report file   (used by RBarDemo)
DUTCH.REG               - Registration form for DUTCH users
RBARLIB.REG             - Registration form for INTERNATIONAL users
RBARDEMO.PRG            - Clipper 5.xx Demo program for RBarLib (Source)
RBARLIB.DOC             - Documentation
RBAR_C50.LIB            - Library for Clipper version 5.0x
RBAR_C52.LIB            - Library for Clipper version 5.2x
RBARLIB.NG              - Norton Guide with the functions of RBarLib
README.TXT              - This file

Note :
The names and salaries in the DemoDbf file are made up by the author ...

To compile and link the Demo program :

   CLIPPER  RBarDemo /N
   RTLINK   FILE RBarDemo LIB RBar_C50  -or-
   BLINKER  FILE RBarDemo LIB RBar_C50  -or-
   EXOSPACE FILE RBarDemo LIB RBar_C50

Type RBARDEMO to start the demonstration.


HISTORY :

v1.0  (06-11-93) World-wide release
v1.1  (25-07-94) Protected Mode compatible version
v1.2  (19-09-94) Position & Color parameters added to R_Ntx & R_Pack


ALSO AVAILABLE FROM THE SAME AUTHOR :

RBckLib - Clipper library with compressed backup functions
RCmpLib - Clipper library with file compression functions
RFntLib - Clipper library with Screen Font functions & Editor
RPCXLib - Clipper library with many graphic functions
          (including displaying PCX-files on EGA/VGA and even on SuperVGA)

FOR MORE INFO :

___________  ________________________________________________________________
 \_____    \  * * * *   R v G   C l i p p e r   C o l l e c t i o n   * * * *
  |       _/_  _ ________                    ______
  \    |   \\ \//  _____/                    \____ \          Rolf van Gelder
  /____|_  / \//   \  ___                    )  |_> >   Binnenwiertzstraat 27
_________\/__  \    \_\  \     _THE_         |   __/ost    5615 HG  EINDHOVEN
\            \__\______  /   ShareWare    ___|__|             The Netherlands
 \_  ______   \_   ___ \/    Libraries    \____ \ 
 /   \     \  /    \  \/    For CLIPPER   )  | > >              +31-40-438852
/     \     \/\     \____                 |   __/hone         (Eve & Weekend)
\      \_______\______  /               __|__|     
 \             /      \/               / __ \     Internet: rcrolf@urc.tue.nl
  \_______    /                       \  ___/mail      Bitnet: rcrolf@heitue5
_________ \  / _______________________ \___  > ______________________________
           \/  (c) 1995 RvG  Eindhoven     \/
