

                                     WinFC  Ver. 1.0b          
                     Copyright (C) 1993-1994 by Kevin Routley and  
                               Rick Trowel.  All Rights Reserved.

  

       WinFC is a Microsoft Windows 3.1(tm) text file comparison
       utility which graphically represents the differences between
       two text files. You can conveniently navigate through the
       differences between two files using toolbar navigation or 
       by the next/previous menu item found in the difference menu.

       The currently active difference is indicated by the red 
       graphics area between the two files, and all other differences 
       are indicated by the black graphics. 

   New Features in V1.0B:
   ----------------------
	V1.0A fixed the GPF that occurred when closing using the system
        menu or Alt-F4.

	V1.0B adds the ability to ignore blank lines and white spaces 
        when comparing files.  Currently, these options can only be
        selected by editing WINFC.INI (provided in the evaluation package).
        To ignore blank lines when comparing files, edit WINFC.INI and 
        change the line:
	    IgnoreBlankLines=0
        to:
            IgnoreBlankLines=1

        To ignore white space (blanks and tabs) when comparing files, edit
        WINFC.INI and change the line:
	    IgnoreSpaces=0
        to:
            IgnoreSpaces=1

        Also in V1.0B is the ability to turn off the graphics highlighting
        in the center region.  To turn off the graphics, edit WINFC.INI and
        change the line:
            NoGraphics=0
        to:
            NoGraphics=1

        Note that these options will not take effect until the next time
        that WinFC is activated.  A future release of WinFC will provide
        a dialog box to dynamically change these and future options.

   Installation:   
   -------------   
       1) Create a directory to hold all the WinFC related files.  
          The recommended directory name (used in the following 
          instructions) is "C:\WINFC".

       2) Copy all WinFC-related files to this directory. You need
          WinFC1B.exe at a minimum.

       3) Add WinFC to a program group by selecting the program
          group you want to add WinFC to, select the program
          manager's File->New menu item entry. Select "Program item"
          and the press "OK". Fill in the following fields and then
          press "OK":
                      Description: WinFC
	    Command Line: winfc1b.exe
                      Working Dir: c:\winfc     

  Uninstall   
  ---------
    To uninstall WinFC goto the WinFC directory, or the
    directory where you located the WinFC files. Delete all the
    files found in the following packing list section. If you
    created a separate directory for the WinFC files, that
    directory can now be deleted.  

  Packing List   
  ------------
    The complete WinFC V1.0b evaluation package should contain
    the files listed in PACKING.LST.  Please be sure that each file is
    present. If any of the files or PACKING.LST are missing then 
    the package is not complete and is not suitable for distribution to
    others.
 
  Software requirements:  
  ----------------------   
    WinFC was designed and implemented to run under Microsoft Windows 3.1 or  
    Windows for Workgroups. It has not tested by the authors in any other    
    environment.  A 80386 or better processor is also required. 

 
  Shareware:   
  ----------    
    Feel free to distribute WinFC in it's entirety to others. All that is asked
    is that this file remain with the distributed copies. This product is    
    shareware. If you like it, please register.  If you want to license a number 
    of copies, please refer to the information found in the ORDER.TXT file.


  Registration Benefits: 
  ----------------------    
    The essence of user-supported software is to provide computer users with    
    quality software without high prices, and at the same time to provide     
    incentive for programmers to continue to develop new products. In addition, 
    the register version of WinFC contains the following added features:        

	- You will be sent a floppy containing the most recent registered 
          version of WinFC.  Only registered copies of WinFC contain the 
          following features:    
             o Multiple MDI children.  One for each set of file comparisons.

	- Notification of new versions of WinFC and low-cost upgrades. 
          Upgrades are currently $10 for registered users.

        - Preferred technical support and new features.

	- Satisfaction from supporting the shareware concept

  Disclaimer and Agreement:   
  -------------------------   
    Users of WinFC must accept this disclaimer of warranty. If you
    do not accept this disclaimer, do not use WinFC. "WINFC IS
    SUPPLIED AS IS. THE AUTHORS DISCLAIMS ALL WARRANTIES, EXPRESSED OR  
    IMPLIED, INCLUDING, WITHOUT LIMITATION, THE WARRANTIES OF 
    MERCHANTABILITY AND OF FITNESS FOR ANY PURPOSE. THE AUTHORS ASSUMES NO 
    LIABILITY FOR DAMAGES, DIRECT OR CONSEQUENTIAL, WHICH MAY RESULT FROM THE 
    USE OF WINFC, EVEN IF THE AUTHORS HAS BEEN ADVISED OF THE POSSIBILITY   
    OF SUCH DAMAGES." "THE LICENSE AGREEMENT AND WARRANTY SHALL BE CONSTRUED, 
    INTERPRETED AND GOVERNED BY THE LAWS OF ENGLAND AND WALES. YOU MAY HAVE
    OTHER RIGHTS WHICH VARY FROM ONE COUNTRY TO ANOTHER."

    WinFC is a Shareware program, this is not free software, and is provided at
    no charge to users for evaluation. Feel free to share it with your friends   
    and colleagues, but please do not give it away altered or as part of another 
    system. 

    This license allows you to use this software for evaluation purposes without 
    charge for a period of 30 days. If you use this software after the 30 day     
    evaluation period a registration fee of $15 plus $2.50 shipping and handling
    is required. Payments must be in US dollars drawn on a US bank, and should
    be sent to (see ORDER.TXT): 

                           Tekra Software        
			   2800A Lafayette Rd #174
			   Portsmouth, NH  03801
 
    When payment is received you will be sent a registered copy of the latest  
    version of WinFC. The registration fee  will license one copy for use on   
    any one computer at any one time. Site License agreements are available.

    Any person or organization wanting to distribute WinFC for profit must  
    first contact Tekra Software at the address above for authorization.

