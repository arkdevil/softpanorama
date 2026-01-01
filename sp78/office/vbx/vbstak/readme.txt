	    VBStak 1.2.1 Installation Procedures
		       07/27/95

1 Installation
  1.1 Copy vbstak.exe self extracting zip to the a directory of
   your choice. 

  1.2 Type (or use Windows run command):
   
	pkunzip -d vbstak.zip 
   
   It is important to use the -d command to create the 
   appropriate sub-directories.

  1.3 Copy vbstak\vbstak.vbx to your windows\system directory

  1.4 Refer to VBStak.hlp for setup details and hints. 

2. Files in VBSTAK.EXE

    VBSTAK.VBX 
      VBStak Custom Control - copy to windows/system directory.

    VBSTAK.HLP
      Windows help file for VBSTAK components.

    VBSTAK.TXT 
      Visual basic constants and declarations for VBStak

    Contant.txt
      VB constants and declarations

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
	

3. VBMAIL Operation
    
    3.1 Introduction
    
    The VBMail sample program uses smtp and pop3 to create a simple
    INTERNET mail interface. To run the sample executable, add 
    VBail.exe to a Windows group and start it up. VBMail assumes that 
    you have access to a Mail server providing smtp and pop3 services.
    
    3.2 Setup 
    
    Edit VBMail.ini file. Change HostName setting to the name of your
    mail server.

    3.3 Sending Mail
    
    Click on the Mail/Send menu item to open the Send mail dialog.
    Enter your user name and the destination user and host name in 
    the user@host format.Enter the text of the message then press 
    'Send Mail'

    The status window should show the steps in the mail operation 
    with "Mail Accepted" as the last item.

    3.4 Receiving Mail
    
    Click on Mail/Receive menu item. Enter your user name (on the 
    mail host) and your password. Press the 'Get Mail' button. 
    The package will connect to the host 
    
    If mail is waiting the Lst: list box will receive the 
    available messages. Clicking on a list item will display the 
    message in the text box. Press 'Delete' to remove the message.
    
4.0 STAKMAN

    4.1 Description
    
    StakMan is a prototyping tool to interactively check TCP/IP 
    connection and services. The basic steps in opening, connecting,
    communicating and closing TCP/IP sockets are made available 
    through push button and text box interfaces.

    4.2 Setup 
    
    Create a program item from STAKMAN.EXE in the Windows group
    of your choice. Launch the program. 
    
    4.3 Operation 
    
    As an illustration of StakMan operation we will open a connection 
    with a echo service on a host. Fill in the following fields:
    
    Host Name: yourMailHost
    Service: echo
    Protocol: tcp
    Line Mode: on
    
    Click <Get Service> button 
      Serviec# should show: 7
    Click <Get Protocol>
      Protocol# should show: 6 
    Click <Get Host> 
      Host Address: hostIPAddress.
    Click <Connect> 
      Status: 4, Socket: socketNumber     

    Click on the Send text box and enter:
    Testing(cr)
       Receive should show: 'Testing'

    4.4 If you encounter errors consult VBSTAK.hlp for tips.
    
5.0 Version 1.2 updates.
    
    5.1 Support for server/secondary channel operation - Added \
       action STAK_ACTION_LISTEN.

    5.2 Check for null HostAddress.

    5.3 Added LocalAddress property access to support multi-homed
	hosts. 

    5.4 Revised help and sample programs. 

   Version 1.2.2 Updates

    5.5 Corrected FD_CONNECT message missing. 

    5.6 Updated VBMAIL to support most pop3/smtp servers. 

    5.7 Corrected VBFTP send errors. (TIPS1.1 sample)

