From ankh.iia.org!uunet!MathWorks.Com!news.duke.edu!eff!wariat.org!malgudi.oar.net!infinet!jridge Fri Aug 26 08:33:40 1994
Path: ankh.iia.org!uunet!MathWorks.Com!news.duke.edu!eff!wariat.org!malgudi.oar.net!infinet!jridge
From: jridge@infinet.com (Joel C. Ridge)
Newsgroups: comp.lang.rexx
Subject: RXFTP vs RXSOCK
Date: 23 Aug 1994 02:12:10 GMT
Organization: InfiNet - Internet Access (614/224-3410)
Lines: 38
Distribution: inet
Message-ID: <33bltq$9tg@rigel.infinet.com>
NNTP-Posting-Host: rigel.infinet.com
Summary: problem calling FtpLoadFuncs
Keywords: ftp tcpip
X-Newsreader: TIN [version 1.2 PL2]

Got the "June CSD" for IBM's TCP/IP 2.0 specifically to take advantage of 
the Rexx FTP functions.  Doesn't seem to work...

When I execute the following:

/* rexx */
if RxFuncQuery('FtpLoadFuncs') <> 0 then do
	call RxFuncAdd 'FtpLoadFuncs','rxftp','FtpLoadFuncs'
	say 'Rexx FTP Functions now loaded'
	rc = FtpLoadFuncs()
end
else do 
	say 'FTP Functions already loaded'
	rc = FtpLoadFuncs()
end

-------------
This routine loads the Functions OK, but when it executes the 
FtpLoadFuncs(), it fails.

The following executes with no problem:
/* rexx */
if RxFuncQuery('SockLoadFuncs') <> 0 then do
	call RxFuncAdd 'SockLoadFuncs','rxsock','SockLoadFuncs'
	say 'Loaded Rexx Socket Functions'
	rc = SockLoadFuncs()
end
else do
	say 'Socket Functions already loaded'
	rc = SockLoadFuncs()
end
---------------
I can't find much of a difference between the two.  Any ideas.  I checked 
the DLL with a hex browser and see the function name, (which appears 
in IBMs Docs) but it won't execute.  Any ideas?

-- SLIPin inta da net.  
jcr

