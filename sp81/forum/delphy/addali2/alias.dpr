program Alias; {Set BDE (Borland Database Engine) Alias.}
{(c) 1995.  Bradley R. Olson.  75512.2366@COMPUSERVE.COM
Written in Borland's Delphi 1.0 (r).

DISCLAIMER:
This code is distributed as freeware.  No warrantees, implicit
or explicit, are made concerning the usability or fitness of this code.  The user assumes
responsibilities for all consequences of using this code.  It is offered solely as a resource
for the benefit of the Delphi community.  Compiling this code implies that you have read
and understand this message.

USE:
I don't like to make my users go into the BDE config utility if I can help it.  This Windows
"command-line" utility lets me set the necessary BDE alias for them.  Usually my install
program calls ALIAS.EXE after it finishes installing my app.  It is called as with the
following params:

ALIAS <application-dir> <alias-name>

This works because I keep my data in the executable directory, since I use Crystal Reports
and it likes to be in the same dir as the data.  If your philosophy is diferent, you can
set the alias to a hard-coded subdir of the application directory as follows:

ALIAS <application-dir> <alias-name> <hard-coded-subdir>

If you're wondering, I use Kurt Herzog's installation program.  At $30, it's a deal, and
it lets me call ALIAS with the first param set to the application directory the user selected
during the install.  Other installs, I would hope, will also do this, but I've been so happy
with Kurt's that I haven't looked elsewhere.

I'm sure this program could be improved.  Maybe I'll clean it up someday.  A REAL windows
programmer could make this run smaller and prettier without WinCRT, but, alas, I'm too
busy making database programs to be one of those :-) .  Hope this sparks some improvements.

WISH LIST:  If someone can tell me how to delete or change a BDE alias, I'd love to know.
The BDIProcs unit only has a routine to set a new alias, so I imagine the answer is not in
the current BDE API.  Perhaps there is a DDE answer, but I don't know the topics to call,
and I'm not sure how fat the program would become.  Right now, with the size optimizations
set, this compiles to 35k and COMPRESS.EXE's to 24k, so I can slip it in on a one or two
disk install.

MODIFICATION LOG:
April 8, 1995 - Looked up how to do dialogs without Dialog.DCU (which is nice, but fat).  Now
the dialog version is smaller than the WinCRT version.  Also, to minimize space, I tried
pasting the consts and types from DBIErrs and DBITypes.  Okay, I know that the linker should
not include any code if I'm just using declarations, but I'm a skeptic, or, rather, USED to
be a skeptic.  There's no size gain from not including the two units as a whole, and there's
much to gain in transportability.

}

{$X+}

{ Remove the (**) comment below to instate compiler directives that enable prettier dialogs
to display when this program runs.  Leave as is to use WinCRT.  Using dialogs is prettier,
but fatter.}

{$DEFINE USE_DIALOGS}

{$IFDEF USE_DIALOGS}
uses SysUtils, DbiTypes, DbiProcs, DbiErrs, WinProcs, WinTypes;
{$ELSE}
uses SysUtils, DbiTypes,  DbiProcs, DbiErrs, WinCRT;
{$ENDIF}

type	zstring = array [0..255] of char;

procedure GiveMsg( snMsg: string);
{Just abstracts giving messages to user so you can WinCRT this or Dialog it.}
var s:string;  szMsg: zstring;
begin
{$IFDEF USE_DIALOGS}
	StrPCopy(szMsg, snMsg);
	MessageBox(0, szMsg, 'Setting Data Location', MB_ICONINFORMATION or MB_OK);
{$ELSE}
	writeln(msg);
	writeln('    (Press ENTER to continue.)');
	readln(s);
{$ENDIF}
end;

procedure SetAnAlias( snAlias, snPath: string);
{COMMENT CONVENTIONS:
	sn stands for "n-string", or pascal type, count-prefixed, strings;
	sz stands for "z-string", or c-type, null-terminated, strings. }
var 	szAlias, szPath: zstring;
		Env: DBIEnv;
		Result: DBIResult;
begin
{$IFnDEF USE_DIALOGS}
	Writeln('Attempting to set alias ' +snAlias+ ' to ' +snPath+ '.');
	Writeln;
{$ENDIF}
	StrPCopy( szAlias, snAlias);  StrPCopy( szPath, 'PATH:'+snPath);
	with Env do begin
		StrPCopy(szWorkDir,snPath);
		StrPCopy(szIniFile,'');
		bForceLocalInit := True;
		StrPCopy(szLang,'');
		StrPCopy(szClientName,'AliasMaker');
	end;
	if DbiInit(@Env) <> DBIERR_NONE then
		raise Exception.create('Error initializing Database Engine.  Alias not set.');
	Result :=  DbiAddAlias( nil, @szAlias, nil, @szPath, true);
	case Result of
		DBIERR_NONE:				GiveMsg('Alias, ' + snAlias + ' successfully set to '
											+ snPath + '.');
		DBIERR_NAMENOTUNIQUE:	GiveMsg('The alias, ' + snAlias + ' already exists.  ' +
											'You will need to run the Borland Database Engine ' +
											'configuration utility and change it yourself.  ' +
											'Sorry.  I tried my best.');
		else							GiveMsg('Error setting alias, ' + snAlias+ '.  Alias not set.');
	end;
	if DbiExit <> DBIERR_NONE then
		raise Exception.create('Error closing Database Engine.  Alias probably set, but exit and restart Windows for security.');
end;

var 	s: string;
		n: integer;
begin
	GiveMsg('Now we''ll attempt to create a database alias for your program.');
	n := paramcount;
	case ParamCount of
		2:		SetAnAlias(paramstr(2),paramstr(1));
		3:		SetAnAlias(paramstr(2),paramstr(1) + paramstr(3));
		else
			GiveMsg('This program must be called with two or three parameters:' +
			'  PATH ALIAS [ADDITIONAL_PATH_TO_APPEND_TO_PATH]');
	end;
{$IFNDEF USE_DIALOGS}
	DoneWinCRT;
{$ENDIF}
end.



{
INSTALL / EASY - The Easy-to-use Windows Application Installer
--------------------------------------------------------------
Kurt P. Herzog     Compuserve 72122,2023  kpherzog@hq.jcic.org

Install / Easy is a full-featured Windows Application Installer
package that is EASY & FAST to use.  Copies and decompresses,
creates directories, installs icons into Program Manager Groups,
modifies INI files, displays "Read-Me" files, etc.  No Scripts!
Version checking and support for several non-English languages.
Shell support for COMPRESS.EXE.  Customizable main Install Window.
Drag & Drop, supports MS Compression. Creation of installation
disks.  Multiple disk installations with ease and dependability.
Version Inspector and Date-Time Stamp utilities included.
Includes complete context-sensitive Windows Help system.
Requires Windows 3.1 or later.
Shareware registration fee $29.95 (US).

Install/Easy is available at the following locations (and others):
==================================================================

CompuServe - look for INSTEZ.ZIP in these forums:
  BCPPI   Section #01 General
  BPASCAL Section #10 Windows tools
  WINSDK Section #03 Public utilities

Internet - look for INSTEZ14.ZIP at CICA and various mirrors:
  ftp.cica.indiana.edu  //win3/util
  ftp.orst.edu //pub/mirrors/
  freebsd.cdrom.com  //.5/cica/util/
  micros.hensa.ac.uk  //mirrors/cica/win3/util

Other - look for INSTEZ14.ZIP at:
  The Secure Design BBS:  (503) 752-5990  "Other" files sub directory
  Secure Design E-Mail Server:  Send a message to "auto-help@sdesign.com"


You may register by sending me an International Money order, or a cheque from any bank that has a corresponding bank in the US that will honor it.  Be sure it is payable to me, Kurt P. Herzog,  in US funds.   Sorry, but I cannot process a Credit card or a Wire Transfer.  I Have had folks send me US cash through the mail, but you assume all risk if you use that method.

The cost of Install/Easy is $29.95 US per copy plus an additional $4.95 US to recieve the latest version on disk.  When I recieve your registration I will e-mail your registration number and send the disk by air mail.

Kurt P. Herzog 1440 N.E. Tenth Street Grants Pass, OR 97526 USA

Compuserve 72122,2023        Internet 72122.2023@compuserve.com

}
