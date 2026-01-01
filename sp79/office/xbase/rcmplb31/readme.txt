RCmpLib v3.1 - 24/01/95    (c) 1993-95 Rolf van Gelder, All rights reserved
---------------------------------------------------------------------------

RCmpLib - Clipper Library with File and String Compression Functions

---------------------------------------------------------------------------

Packing list :

Dutch.REG               - Registration form (for DUTCH users)
RCmpDemo.PRG            - Demo program for CA-Clipper v5.xx
RCmpDemo.EXE            - Demo program (executable)
RCmpDemS.PRG            - Demo program for Nantucket Clipper Summer '87
RCmpLib.CH              - Header File for CA-Clipper v5.xx
RCmpLib.DOC             - Documentation file
RCmp_S87.LIB            - RCmpLib Library for Nantucket Clipper Summer '87
RCmp_C50.LIB            - RCmpLib Library for CA-Clipper v5.0x
RCmp_C52.LIB            - RCmpLib Library for CA-Clipper v5.2x
RCmpLib.NG              - Norton Guide with function descriptions
RCmpLib.REG             - International registration form
ReadMe.TXT              - This file

---------------------------------------------------------------------------

To compile and link the demo programs :

CA-CLIPPER v5.XX :

   Clipper  RCmpDemo /N
   RtLink   File RCmpDemo Lib RCmp_C50        - or -
   Blinker  File RCmpDemo Lib RCmp_C50        - or -
   ExoSpace File RCmpDemo Lib RCmp_C50 EXO PAC INT10
   (For Clipper 5.2x : RCmp_C52)

NANTUCKET CLIPPER SUMMER '87 :

   Clipper  RCmpDemS
   PLink86  File RCmpDemS Lib RCmp_S87        - or -
   Blinker  File RCmpDemS Lib RCmp_S87

---------------------------------------------------------------------------

History :

v3.1  (24-01-95) - Bug fixed in RCmpList() : file date is correct now
                 - File date from the RCmpList() function is represented
                   using the current SET DATE format (Clipper 5.xx only)
                 - Files will be opened in SHARED mode
                 - Protected mode: GPF fixed (module I_CmpFile())

v3.0f (05-12-94) - Bug fixed : lower case bar color strings didn't function

v3.0e (20-08-94) - Improved memory management
                   (No more 5302/5305 errors ...)

v3.0d (27-06-94) - Some minor (internal) changes

v3.0c (20-03-94) - Error corrected: nil parameter for <cDrvPath>
                   (R_DCmpFile()) caused system hang-up ...

v3.0b (14-03-94) - Corrupted file detection (R_CmpList() & R_DCmpFile())

v3.0a (13-03-94) - Disk full detection corrected
                 - Progress bars for large files ( > 2,8 MB ) corrected

v3.0  (20-02-94) - Brand new version of the library, completely rewritten
                 - Many new features added

v2.0  (20-09-93) - ExoSpace compatible library added (RCmpExo.lib)
                 - <nCmpFact> parameter added to R_Compress()
                 - New function: R_LastErr()
                 - Updated error codes (in RCmpLib.CH)
                 - CAUTION ! Files that are compressed using RCmpLib v1.xx
                   can't be decompressed using RCmpLib v2.0 !

v1.2  (15-09-93) - Initialization error corrected
                 - Bug in the Clipper Summer '87 version corrected
                   (First byte of a decompressed file was always 00h ...)

v1.1  (04-09-93) - Error corrected while linking with RTLINK
                 - Separate library for Clipper Summer '87 added

---------------------------------------------------------------------------

ALSO AVAILABLE FROM THE SAME AUTHOR :

---------------------------------------------------------------------------
RBarLib

CA-Clipper Library with PROGRESSION BAR functions, a.o. :

- INDEX function with progression bar display
- PACK  function with progression bar display
  This PACK function also reorganizes memo-files !

---------------------------------------------------------------------------
RBckLib

Functions to create multiple disk compressed backups

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

 UN-Registered demo versions of these libraries can, world-wide, be found
 on BBS-es, FTP-Servers, Simtel mirrors, CD-ROMS, UserGroups etc.
 You have to look for them in the CLIPPER and/or DATABASE directories.

 If you can't locate the library you are interested in, just send a letter
 to the address as listed below.
 You have to include US $ 5 (IN CASH !!!) for handling, floppy, etc.
 I will ship the demo version as soon as possible.
 Don't forget to mention which library you are interested in ....

---------------------------------------------------------------------------
FOR FURTHER INFORMATION :

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
