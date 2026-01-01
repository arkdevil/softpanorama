
TWinLan Component
=================

This non-visual component wraps the Windows for Workgroups 3.11 net api.
To install:

1) Start Delphi
2) Choose Options --> Install Components in the menu.
3) Press Add and select: winlan.pas
4) Press Ok. After rebuilding, the WinLan component is in: Samples Tab.

Look at the demolan.dpr project in the demo subdir.
You also have the winlan.pas with all the source code if you want to change
or add more properties or methods.

Properties:
-----------
MachineName : String Read-Only     Returns the Machine name.
UserName    : String Read-Only     Returns the User name.

Methods:
--------
Function FindDisk:String;
Function FindPrinter:String;
Procedure ConnectDisk;
Procedure ConnectPrinter;
Procedure DisconnectDisk;
Procedure DisconnectPrinter;
Function FindMachine:String;
Procedure ChangePassword;
Function AutoLogon:Boolean;
Function Logoff:Boolean;
Function AddConnection(Const NetPath,Password,LocalName:String):Boolean;
Function CancelConnection(Const LocalName:String; ForceIfOpenFiles:Boolean):Boolean;

Some functions raise an EWinLan exception on error.

Send me questions and/or comments...
David Berneda.
MEFF
Compuserve: 100115,1155


