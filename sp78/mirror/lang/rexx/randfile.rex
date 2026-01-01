Newsgroups: comp.lang.rexx
From: peter@engcorp.com (Peter Hansen)
Subject: Re: Beginner question:get filenames
Date: Thu, 28 Sep 1995 18:39:56 GMT

In <44cdc7$46v@ralph.vnet.net>, robtmil@success.net (Robt. Miller) writes:
> I'm trying to write a REXX program that will get the names of all the
>wav files in a directory and then play them at random at random times. My
>first question is how do I get a list of all the .wav files? In a batch file
>I can say "for %%b in (*.wav) do .." - how do I do this in REXX?

Something like:

call SysFileTree '*.wav','files','FO'
do i = 1 to files.0
    'PLAYFILE' files.i   /* substitute appropriate command for PLAYFILE */
    end

As this is a REXX Utility function, you should make sure you know how
to use those functions.  Type HELP REXX REXXUTIL for more information.

-----------------------------------------------------------------------
 Peter Hansen                   Engenuity Corporation          Guelph
 peter@engcorp.com                                             Ontario
 http://www.sentex.net/~engcorp/peter/                         Canada
-----------------------------------------------------------------------


From news.ios.com!news.ece.uc.edu!babbage.ece.uc.edu!news.kei.com!simtel!news.sprintlink.net!in1.uu.net!pipeline!psinntp!psinntp!psinntp!news.netvision.net.il!usenet Mon Oct  2 22:33:43 1995
Path: news.ios.com!news.ece.uc.edu!babbage.ece.uc.edu!news.kei.com!simtel!news.sprintlink.net!in1.uu.net!pipeline!psinntp!psinntp!psinntp!news.netvision.net.il!usenet
From: ariel@amis-jlm.co.il
Newsgroups: comp.lang.rexx
Subject: Re: Beginner question:get filenames
Date: 30 Sep 1995 13:14:31 GMT
Organization: NetVision LTD.
Lines: 35
Distribution: inet
Message-ID: <44jfrn$9qi@news.netvision.net.il>
References: <44cdc7$46v@ralph.vnet.net>
Reply-To: ariel@amis-jlm.co.il
NNTP-Posting-Host: dns.amis-jlm.co.il
X-Newsreader: IBM NewsReader/2 v1.02

In <44cdc7$46v@ralph.vnet.net>, robtmil@success.net (Robt. Miller) writes:
> I'm trying to write a REXX program that will get the names of all the
>wav files in a directory and then play them at random at random times. My
>first question is how do I get a list of all the .wav files? In a batch file
>I can say "for %%b in (*.wav) do .." - how do I do this in REXX?

In OS/2:

  call SysFileTree 'c:\mydir\*.wav','aWavFiles.','fo'

After the call you'll have the file names in aWavFiles.1 to aWavFiles.n,
and the number of files, n, in aWavFiles.0. You need to load the
RexxUtil DLL before using SysFileTree(). The info on that is in the
"Rexx Utility Functions (RexxUtil)" section in the Rexx Command
Reference INF file.

>via Warp/IAK

I suspect you are using OS/2 :), but since you didn't specify which Rexx
you are using, a more generic answer on finding "how do I do this":

Rexx provides a set of built-in functions as part of the language, but
these are general and apply to all platforms (string handling, stream
I/O, etc). When you need something that is specific to the environment
you are using, like interacting with the file system, you look for a
Rexx add-on libraries which provides the tools to manipulate that
specific environment. Every Rexx interpreter will usually have a basic
set of such environment-specific functions available along with the
built-in Rexx commands and functions. RexxUtil is that basic add-on
library in OS/2.

Without spoiling the fun, Random(), OTH, is a basic Rexx function :)

Ariel.


