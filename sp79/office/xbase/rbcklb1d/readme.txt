RBckLib v1.0d - 18/01/95   (c) 1993-95 Rolf van Gelder, All rights reserved
---------------------------------------------------------------------------

RBckLib - Clipper Library with Compressed Backup Functions (multiple disk)

---------------------------------------------------------------------------

Packing list :

Dutch.REG               - Registration form (for DUTCH users)
RBckDemo.PRG            - Demo program for CA-Clipper v5.xx
RBckDemS.PRG            - Demo program for Nantucket Clipper Summer '87
RBckLib.CH              - Header File for CA-Clipper v5.xx
RBckLib.DOC             - Documentation file
RBck_S87.LIB            - RBckLib Library for Nantucket Clipper Summer '87
RBck_C50.LIB            - RBckLib Library for CA-Clipper v5.0x
RBck_C52.LIB            - RBckLib Library for CA-Clipper v5.2x
RBckLib.NG              - Norton Guide with function descriptions
RBckLib.REG             - International registration form
ReadMe.TXT              - This file

---------------------------------------------------------------------------

To compile and link the demo programs :

CA-CLIPPER v5.XX :

   Clipper  RBckDemo /N
   RtLink   File RBckDemo Lib RBck_C50        - or -
   Blinker  File RBckDemo Lib RBck_C50        - or -
   ExoSpace File RBckDemo Lib RBck_C50 EXO PAC INT10
   (For Clipper 5.2x : replace RBck_C50 with RBck_C52)

NANTUCKET CLIPPER SUMMER '87 :

   Clipper  RBckDemS
   PLink86  File RBckDemS Lib RBck_S87  - or -
   Blinker  File RBckDemS Lib RBck_S87

---------------------------------------------------------------------------

History :

v1.0d (18-01-95) - Small bug corrected in the Summer '87 version of
                   R_Restore (the 'line 416 aMask' error)
                 - Bug fixed in RBckList() : file date is correct now
                 - File date from the RBckList() function is represented
                   using the current SET DATE format (Clipper 5.xx only)
v1.0c (02-12-94) - Names of internal functions altered
                 - Check if the restore directory is writeable
                 - Bug fix : NIL values in the aDirSpec array
                   (R_BackUp() function) are skipped
                 - All files (including READ-ONLY, HIDDEN etc.)
                   will be deleted from the root directory of the
                   target diskette
v1.0b (08-08-94) - Improved memory management (no more 5302/5305 errors)
                 - Automatic creation of non-existing restore directories
                 - If the lEscape parameter is .T., the escape key is
                   disabled even during disk changes.
                 - The default "Insert disk message" depends from the
                   lEscape setting.  
                 - lEscape parameter added to R_BckList()
                 - lSilent parameter added to R_BackUp(), R_Restore() &
                   R_BckList()
                 - Source and destination drive doesn't have to be
                   removable anymore
v1.0a (17-07-94) - Empty files (filesize=0) are no longer backed up
v1.0  (16-07-94) - First world-wide release

---------------------------------------------------------------------------

ALSO AVAILABLE FROM THE SAME AUTHOR :

---------------------------------------------------------------------------
RBarLib

CA-Clipper Library with PROGRESSION BAR functions, a.o. :

- INDEX function with progression bar display
- PACK  function with progression bar display
  This PACK function also reorganizes memo-files !

---------------------------------------------------------------------------
RCmpLib

CA-Clipper Library with FILE & STRING COMPRESSION functions, a.o. :

- Compress multiple files into one archive
- Extract one or more file from an archive
- Compress/Decompress strings & memo-fields

---------------------------------------------------------------------------
RFntLib

CA-Clipper Library with SCREEN FONT functions, featuring :

- Functions to install screen fonts under Clipper
- Sophisticated Screen Font Editor
- Many ready-to-use EGA/VGA screen fonts
- Utility to change the screen font for use under DOS

---------------------------------------------------------------------------
RPCXLib

CA-Clipper Library with many GRAPHIC functions, a.o. :

- Display PCX-files on EGA, VGA and even SuperVGA
- Manipulate EGA and VGA color palettes
- Mix your own Clipper colors

---------------------------------------------------------------------------

 UN-Registered demo copies of these libraries can, world-wide, be found
 on BBS-es, FTP-Servers, Simtel mirrors, CD-ROMS, via UserGroups etc.
 You have to look for them in the CLIPPER and/or DATABASE directories.

 If you can't locate the library you are interested in, just send a letter
 to the address as listed below.
 You have to include US $ 5 (IN CASH !!!) for handling, floppy, etc.
 I will ship the demo copy as soon as possible.
 Don't forget to mention which library you are interested in ....

---------------------------------------------------------------------------
FOR FURTHER INFORMATION :

___________  ______________________________________________________________
 \_____    \  * * * *  R v G   C l i p p e r   C o l l e c t i o n  * * * *
  |       _/_  _ ________                  ______
  \    |   \\ \//  _____/                  \____ \          Rolf van Gelder
  /____|_  / \//   \  ___                  )  |_> >   Binnenwiertzstraat 27
_________\/__  \    \_\  \    _THE_        |   __/ost    5615 HG  EINDHOVEN
\            \__\______  /  ShareWare   ___|__|             The Netherlands
 \_  ______   \_   ___ \/   Libraries   \____ \ 
 /   \     \  /    \  \/   For CLIPPER  )  | > >              +31-40-438852
/     \     \/\     \____               |   __/hone         (Eve & Weekend)
\      \_______\______  /             __|__|     
 \             /      \/             / __ \     Internet: rcrolf@urc.tue.nl
  \_______    /                     \  ___/mail      Bitnet: rcrolf@heitue5
_________ \  / _____________________ \___  > ______________________________
           \/ (c) 1995 RvG  Eindhoven    \/