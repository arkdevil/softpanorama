			VBStak Installation Procedures
				03/10/95


1. Create a vbstak Directory of your choice eg.

c:\vbstak\

2. Copy vbstak.exe self extracting zip to the vbstak directory

3. Type (or run from windows) vbstak.exe -d

4. Copy vbstak\vbstak.vbx to your windows\system directory


5. Files in VBSTAK.ZIP

	VBSTAK.VBX 
	  VBStak Custom Control - copy to windows/system directory.

	VBMAIL\ (directory)
	  Mail sample program.
	    VBMAIL.MAK - Make file for mail application
	    SENDMAIL.FRM - Send mail daughter form
	    RECEIVEM.FRM - Receive mail daughter form
	    MAILFORM.FRM - MDI Master form
	    VBMAIL.EXE - Compiled VBMail program
	    VBMAIL.INI - VBMAIL initialization file copy to your 
		windows directory

	STAKMAN\ (directory)
	  TCP/IP manual control/test program.
	    STAKMAN.FRM - Stak Manager form
	    STAKMAN.MAK - Stak Manager VB make file
	    STAKMAN.EXE - Compiled Stakman progrm
	    
	VBSTAK.HLP
	  Windows help file for VBSTAK components.

	VBSTAK.TXT 
	  Visual basic constants and declarations for VBStak

	Contant.txt
	  VB constants and declarations

2. VBMAIL Operation
	
	2.1 Introduction
	The VBMail sample program uses smtp and pop3 to create a simple
	INTERNET mail interface. To run the sample executable, add 
	VBail.exe to a Windows group and start it up. VBMail assumes that 
	you have access to a Mail server providing smtp and pop3 services.

	2.2 Sending Mail
	Click on the Mail/Send menu item.  Enter your user name. 
	Enter the destination user and host name in the user@host 
	format. Enter the text of the message then press send.

	The status window should show the steps in the mail operation 
	with "Mail Accepted" as the last item.

	2.3 Receiving Mail
	Click on Mail/Receive menu item. Enter your user name (on the 
	mail host) and your password. 

	
