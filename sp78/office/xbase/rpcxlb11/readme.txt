RPCXLib v1.1 - 19/04/95    (c) 1993-95 Rolf van Gelder, All rights reserved
---------------------------------------------------------------------------

RPCXLib - Graphic CA-Clipper Library

---------------------------------------------------------------------------

Packing list :

DUTCH.REG		- Registration form (for DUTCH users)
FILE_ID.DIZ             - Description file
GIRL.PCX                - Sample 640x480x256 PCX file
MEMYSELF.PCX            - Sample 640x480x16  PCX file (that's me ...)
README.TXT              - This file
RPCXDEMO.PRG            - Demonstration program for RPCXLib (Clipper 5.xx)
RPCXLIB.CH              - Header file with pre-defined constants
RPCXLIB.DOC             - Documentation of RPCXLib
RPCXLIB.GDR             - Driver file for SuperVGA adapters
RPCXLIB.NG              - Norton Guide for RPCXLib
RPCXLIB.REG             - International registration form
RPCX_C5X.LIB            - RPCXLib library for Clipper 5.xx
RPCX_S87.LIB            - RPCXLib library for Clipper Summer '87
SUNFLOWR.PCX            - Sample 320x200x256 PCX file

---------------------------------------------------------------------------

To compile and link the demo program :

CA-CLIPPER v5.XX :

   Clipper  RPCXDemo /N
   RtLink   File RPCXDemo Lib RPCX_C5X        - or -
   Blinker  File RPCXDemo Lib RPCX_C5X

---------------------------------------------------------------------------

Note :
The functions R_GetRGB () and R_PCXInfo () are NOT SUPPORTED in the
SUMMER '87 version of the library !!

---------------------------------------------------------------------------

History :

v1.1  (19-04-95) - Improved SuperVGA drivers (Vesa VBE 1.2 compatible)
                 - Bug in Vesa driver fixed (the '800x600 video mode' bug)
                 - Some minor changes & bug fixes

v1.0  (10-11-93) - First world-wide release

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

CA-Clipper Library with COMPRESSED BACKUP functions :

- Multiple Disk backup
- Data Compression during backup
- Fast with a good compression ratio

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
           \/ (c) 1993-95 RvG Eindhoven  \/