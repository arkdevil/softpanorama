README file for CCPanel Delphi Freeware Component

from C.I.U.P,K.C. Software, Inc.

--------------------------------------------------------
Table of Contents
0.0 Introduction
1.0 Installation of CCPanel on your Hard Disk
1.1 Installation of CCPanel to the Delphi VCL
1.2 Running the CCPanel Demo program
2.0 Using CCPanel in Delphi
3.0 Legal Stuff
4.0 Final Notes
--------------------------------------------------------
0.0 Introduction

CCPanel is a freeware demonstration component from
C.I.U.P.K.C. Software. It provides source code that
illustrates how to add a property editor to a new
component, and how to create a new component using
OOP methods.

CCPanel comes with all files necessary to install
it to the Delphi VCL and use it at design time. It
also includes source code so that other versions
of CCPanel can be created by other users.
--------------------------------------------------------
1.0 Installation of CCPanel on your Hard Disk

The following steps assume you have acquired 
CCPANEL.ZIP from the CIUPKC Software HQ WWW site at
www.webcom.com. If you didn't, then change the
references to "where you downloaded it" to where
it was otherwise acquired (floppy disk, etc.)

1.01 Create a new directory CIUPKC on your hard drive.
1.02 Copy the CCPANEL.ZIP from where you downloaded it
     to the new directory.
1.03 Unzip the file using PKZIP 2.04G or a compatible
     utility.
1.04 You should then see the following files (aside from
     the .ZIP file):
     CCCLEDIT.DCU		Compiled RGB Editor Unit
     CCCLEDIT.DFM		RGB Editor Form
     CCCLEDIT.PAS		RGB Editor Unit Source
     CCPANCP.DCU		Compiled CCPanel Unit
     CCPANCP.PAS		CCPanel Unit Source
     CCPANCP.DCR		CCPanel Component Palette Bitmap
     CCPANEL.DPR		CCPanel Demo Program 
     CCPANEL.DSK		CCPanel Demo Program 
     CCPANEL.OPT		CCPanel Demo Program
     CCPANEL.RES		CCPanel Demo Program
     CCPANTST.DCU		CCPanel Demo Program
     CCPANTST.DFM		CCPanel	Demo Program
     CCPANTST.DSK		CCPanel Demo Program
     CCPANTST.PAS		CCPanel Demo Program
     README.TXT			This file

1.05 Copy the CCCLEDIT.* and CCPANCP.* files to the 
     LIB directory under DELPHI whereever it lives
     on your hard disk. Leave the others in the
     CIUPKC directory.
--------------------------------------------------------
1.1 Installation of CCPanel to the Delphi VCL

1.11 Activate Delphi. Under the Options menu, choose
     "Install Components".
1.12 Select Add, then Browse. Move to the BIN directory
     and select the CCPANCP.PAS file. 
1.13 Select OK and OK again, and the CCPanel component
     will be added to your VCL under a "CIUPKC Freeware"
     tab with a custom bitmap.

NOTE: Due to the simple nature of this
      component, no help files are provided. For more
      complex components, they will be!
--------------------------------------------------------
1.2 Running the CCPANEL Demo program

1.21 Start Delphi, then choose Open Project. Move to the
     CIUPKC directory and select CCPANEL.DPR.
1.22 You will get an error message saying "Error loading
     Symbol File" and nothing seems to happen. This is
     because no .DSM file was included to save space.
1.23 Select Compile/Build All and Delphi will recreate the
     program, including the symbol file.
1.24 Choose View|Units and open the CPANLTST.PAS file. This
     allows a look at the simple source code for the demo.
     Choose View|Forms and bring up Form1. This shows the
     custom colors for the form, depending on the color
     resolution of your monitor and graphics card.
1.25 Choose Run|Run and you can view the final product.
     Select Close from the system menu to end the program.
--------------------------------------------------------
2.0 Use of CCPanel in Delphi

2.1 CCPanel works like any other component; you select
    it off its palette entry and place it on your form.
2.2 There are three differences from the normal TPanel
    component: Color now has an ellipsis button, and
    there are two new fields, HighLightColor and 
    ShadowColor. These are described as a triplet of
    numbers. This represents the RGB value of the
    current color for each property. Selecting the
    ellipsis brings up the RGB property editor form.
2.3 Use the slider bars to set an RGB color for any of
    the three color properties, and click OK when done.
    These colors will appear in the final version of
    your form.
2.4 Sometimes a bevel selection does not immediately
    take effect; if this happens, minimize the form
    being designed and restore it, and the correct
    color will appear for the bevels.
--------------------------------------------------------
3.0 Legal Stuff

CCPanel is provided, as is, no warranties are expressed
or implied. CIUPKC Software, Inc., assume no liabilities
for any losses incurred due to the use or misuse of the
CCPanel Delphi Component.

So There!

Seriously, this is freeware, so use it, abuse it, but
most of all, learn from it and enjoy it.
--------------------------------------------------------
4.0 Final Notes

A similar version of this component is found in the
book "Delphi How To" by Gary Frerking, Nathan Wallace,
and Wayne Niddery. The book is, IMHO, an excellent
one and should be out by August. Give it a look!

Also, if you didn't get CCPANEL from the CIUPKC Software
web site, check out 

http://www.webcom.com/~kilgalen/welcome.html

Lots of neat stuff there!

--------------------------------------------------------
Nathan Wallace, CEO of CIUPKC Software
