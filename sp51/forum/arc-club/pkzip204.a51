From:  Dmitry S. Kohmanyuk <dk@farm.cs.kiev.ua>
Subject: comp.compression people about PKZIP 2.04c
Reply-To: dk%farm.cs.kiev.ua@ussr.eu.net
Organization: Animals Paradise Farm
Distribution: su
Date: Sun, 10 Jan 93 22:59:31 +0200 
Message-ID: <ABpu8KhGc5@farm.cs.kiev.ua>
Lines: 719
Keywords: pkzip bugs serious
Sender: news-server@river.cs.kiev.ua


        Некоторые статьи из comp.compression - FYI only ...

>From nevries@accucx.cc.ruu.nl  Thu Jan 07 22:47:15 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!sun4nl!ruuinf!accucx!nevries
From: nevries@accucx.cc.ruu.nl (Nico E de Vries)
Newsgroups: comp.compression
Subject: *** WARNING *** dangerous bugs in PKZIP 2.04c
Message-ID: <3558@accucx.cc.ruu.nl>
Date: 7 Jan 93 07:44:34 GMT
Organization: Academic Computer Centre Utrecht
Lines: 23
Status: RO

There are many bugs in PKZIP 2.04c of which two seem to be significant.
First of all their DPMI support is very buggy, this causes crashes,
loss of data etc. ALWAYS USE THE -) OPTION TO DISABLE DPMI. When
you are using Windows, OS/2 2.0 or QEMM this is vital (386^MAX has
not been investigated yet).
Running PKUNZIP from a batch file or with REARJ also generaties problems
for which no reason has been found yet.
PKWARE has already promised a bug fix release (and specifically
advises to use the -) option many times on CompuServe) but till
now only acknowledged bugs with voluma names and the CFG file (manual
bugs).

When using -) PKZIP seems to work flawlessly and is a very impressive
program. Especially the speed of -es remains amazing to me.

Nico E. de Vries  (nevries@cc.ruu.nl) |------------------*   AA   III  PPP
_ This text is supplied AS IS, no warranties of any kind |  A  A   I   P  P
| apply. No rights can be derived from this text. This   |  AAAA   I   PPP
| text is likely to contain spelling and grammar errors. |  A  A   I   P
*---------------------------( Donate to GreenPeace! )----*  A  A  III  P

To get (many) ==> LOSSLESS DATA COMPRESSION SOURCES <== get lds_10.zip at
garbo.uwasa.fi /pc/programming. Make files for Borland C are included.


>From pss1@kepler.unh.edu  Thu Jan 07 22:46:58 1993
Xref: relay1 comp.compression:674 comp.os.msdos.4dos:317
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!news.funet.fi!sunic!uunet!virgin!unhtel!mozz.unh.edu!kepler.unh.edu!pss1
From: pss1@kepler.unh.edu (Paul S Secinaro)
Newsgroups: comp.compression,comp.os.msdos.4dos
Subject: A note on using PKUNZIP 2.04c with 4DOS and Windows 3.1
Date: 6 Jan 1993 13:47:15 GMT
Organization: University of New Hampshire  -  Durham, NH
Lines: 20
Distribution: inet
Message-ID: <1ient3INNqop@mozz.unh.edu>
NNTP-Posting-Host: kepler.unh.edu
Status: RO


In case anyone else is having problems along these lines, I'd just
like to mention that I've experienced fatal crashes (memory allocation
errors) when trying to use pkunzip 2.04c in a Windows 4DOS session.
In order to prevent this, I'm using the '-)' switch, which disables
DPMI support (this is mentioned in ADDENDUM.DOC).  This seems to
eliminate the problem.

Just thought I'd pass that along.  If anyone *doesn't* have problems
with 4DOS and pkunzip, I'd like to hear about what they did to get
around it (other than the above-mentioned solution).

Paul


--
Paul Secinaro
pss1@kepler.unh.edu
Synthetic Vision and Pattern Analysis Laboratory
UNH Dept. of Electrical and Computer Engineering


>From berg@physik.tu-muenchen.de  Thu Jan 07 21:24:02 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!news.funet.fi!sunic!mcsun!Germany.EU.net!urmel.informatik.rwth-aachen.de!physik.tu-muenchen.de!berg
From: berg@physik.tu-muenchen.de (Stephen R. van den Berg)
Newsgroups: comp.compression
Subject: COMPRESS=maximum (Re: PKZip 2.04c quick impressions)
Date: 6 Jan 1993 18:21:04 GMT
Organization: Rechnerbetrieb Informatik - RWTH Aachen
Lines: 19
Message-ID: <1if7ugINN1hl@urmel.informatik.rwth-aachen.de>
References: <81505@ncratl.AtlantaGA.NCR.COM> <1993Jan6.043149.10166@wam.umd.edu> <1993Jan6.092256.11613@uwasa.fi>
NNTP-Posting-Host: tabaqui.informatik.rwth-aachen.de
Originator: berg@tabaqui
Status: RO

In article <1993Jan6.092256.11613@uwasa.fi> ts@uwasa.fi (Timo Salmi) writes:
>Well, I did some light testing with PKZIP 2.04C and soon run into
>the following problem.  My PKZIP.CFG file (in the current directory
>as the manua says) has the following line

>COMPRESS=maximal

>It had no effect.  Compression is normal despite this.  What gives?

The manual is wrong.
Use:
        COMPRESS=maximum

It should give the expected results.
--
Sincerely,                                  berg@pool.informatik.rwth-aachen.de           Stephen R. van den Berg (AKA BuGless).    berg@physik.tu-muenchen.deYou are currently aboard a fully automated plane.  There is no pilot on board.
Rest assured, you have nothing to worry about... worry about... worry about...


>From nevries@accucx.cc.ruu.nl  Sat Jan 09 00:34:19 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!sun4nl!ruuinf!accucx!nevries
From: nevries@accucx.cc.ruu.nl (Nico E de Vries)
Newsgroups: comp.compression
Subject: More severe bugs in PKZIP 2.04c.
Message-ID: <3561@accucx.cc.ruu.nl>
Date: 7 Jan 93 22:45:20 GMT
Organization: Academic Computer Centre Utrecht
Lines: 25
Status: RO

I have to admit at first I expected most problems with PKZIP 2.04C
to be DPMI related. Unfortunately that is not the case. Even in
super safe mode (everything disabled, slowcopy etc) the program
seems to make mistakes. An interesting example:

I made a zip file of all cpp files included in Borland C++ 3.1 +AF
examples directory (-r -p). I tried to extract bitma*.cpp. Strangely
enough this fails with an CRC error but ONLY if there is already some
bitmap.cpp in the current directory! If the current directory is not
empty no error is produced. The test integrity option generates
no problems.

I am beginning to wonder how well tested this program is. And I
wonder even more about what PKWARE did during all those delays. I
am still impressed by the Super Fast compression. It is even
super fast with 386 disabled.

Nico E. de Vries  (nevries@cc.ruu.nl  100115,2303) |-----*   AA   III  PPP
_ This text is supplied AS IS, no warranties of any kind |  A  A   I   P  P
| apply. No rights can be derived from this text. This   |  AAAA   I   PPP
| text is likely to contain spelling and grammar errors. |  A  A   I   P
*---------------------------( Donate to GreenPeace! )----*  A  A  III  P

To get (many) ==> LOSSLESS DATA COMPRESSION SOURCES <== get lds_10.zip at
garbo.uwasa.fi /pc/programming. Make files for Borland C are included.


>From robjung@world.std.com  Sat Jan 09 00:34:42 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!spool.mu.edu!hri.com!enterpoop.mit.edu!world!robjung
From: robjung@world.std.com (Robert K Jung)
Newsgroups: comp.compression
Subject: Re: More severe bugs in PKZIP 2.04c.
Message-ID: <C0JEvz.KM6@world.std.com>
Date: 8 Jan 93 13:31:11 GMT
References: <3561@accucx.cc.ruu.nl>
Organization: The World Public Access UNIX, Brookline, MA
Lines: 41
Status: RO

nevries@accucx.cc.ruu.nl (Nico E de Vries) writes:

>I have to admit at first I expected most problems with PKZIP 2.04C
>to be DPMI related. Unfortunately that is not the case. Even in
>super safe mode (everything disabled, slowcopy etc) the program
>seems to make mistakes.

I have also come across a case that I think is EXTREMELY serious.

Using -3 -) on a vanilla DOS 5.0 (no config.sys, no autoexec.bat) on
a 486DX machine, I used PKZIP 2.04c to backup several Wing Commander
EXE files to diskettes. (PKZIP -& -3 -) b:test *.EXE).  On compressing
the last file onto the first diskette, PKZIP displayed "done" indicating
that it had finished the compression phase and then prompted for
the insertion of a new diskette.  Then PKZIP wrote about 60K of data on
that diskette.

I immediately typed "PKUNZIP b:test".  PKUNZIP extracted all BUT the last
file reporting a file CRC error with a "file has bad table" error message.

I have reproduced this error several times using proven diskettes under
different configurations using the SAME FILE SET and ALWAYS getting the
file corruption.

However, if I add another file to the set being backed up, so that the
"done" message is split across the "insert a new diskette" message, the
backup works out fine.

I would suggest that a lot of experimentation be done with the -& option
of PKZIP 2.04c to see how prevalent this situation is.  This error occurred
on my THIRD different backup attempt.

For obvious reasons, I have been looking at this release very closely for
the last two days and have found it to be very buggy especially in the
multiple volume mode.

Regards,
Robert K Jung

P.S.  Most backup programs recommend setting the program VERIFICATION mode ON.
      I guess with PKZIP that means always using PKUNZIP -t on the backup set.


>From robjung@world.std.com  Sat Jan 09 00:34:42 1993
Newsgroups: comp.compression
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!world!robjung
From: robjung@world.std.com (Robert K Jung)
Subject: Re: More severe bugs in PKZIP 2.04c.
Message-ID: <C0JG3H.M2o@world.std.com>
Organization: The World Public Access UNIX, Brookline, MA
References: <3561@accucx.cc.ruu.nl> <C0JEvz.KM6@world.std.com>
Date: Fri, 8 Jan 1993 13:57:17 GMT
Lines: 24
Status: RO

robjung@world.std.com (Robert K Jung) writes:

>Using -3 -) on a vanilla DOS 5.0 (no config.sys, no autoexec.bat) on
>a 486DX machine, I used PKZIP 2.04c to backup several Wing Commander
>EXE files to diskettes. (PKZIP -& -3 -) b:test *.EXE).  On compressing
>the last file onto the first diskette, PKZIP displayed "done" indicating
>that it had finished the compression phase and then prompted for
>the insertion of a new diskette.  Then PKZIP wrote about 60K of data on
>that diskette.

>I immediately typed "PKUNZIP b:test".  PKUNZIP extracted all BUT the last
>file reporting a file CRC error with a "file has bad table" error message.

Apparently, a user reported a similar error to the PKWARE CompuServe forum.
They were backing up a 1.7 MB ZIP file (zipped with 1.1) and got the
"file has bad table" error.  So I tried the same thing, creating a ZIP file
slightly larger than one diskette.  PKZIP 2.04 compressed it saving 1 percent
onto two diskettes.  This backup set produced the same "bad table" error
message.

*** PROCEED WITH CAUTION backing up ZIP files ***

Regards,
Robert K Jung


>From rob@sound.demon.co.uk  Sun Jan 10 15:29:08 1993
Newsgroups: comp.compression
From: rob@sound.demon.co.uk (Robert J Barth)
Path: softp!relay1!csoft!kiae!demos!fuug!mcsun!uunet!pipex!demon!sound.demon.co.uk!rob
Subject: PKZ204C (W04) error !
Reply-To: rob@sound.demon.co.uk
Distribution: world
X-Mailer: cppnews $Revision: 1.30 $
Organization: Sound & Vision BBS (UK) 0932 252323
Lines: 20
Date: Fri, 8 Jan 1993 16:38:52 +0000
Message-ID: <726536332snx@sound.demon.co.uk>
Sender: usenet@demon.co.uk
Status: RO

More ZIP crapness :

PKZIP: (W04) Warning! can't delete \\SERVER\CDRIVE\ABCDEFGH
Every bloody time, it leaves chunks divisble by ~64 litered all over my HD.
I run Netware Lite 1.10, on a mixture of 386s/486s, and it'sa annoying !
W04 is listed as something completely different...

In SHEZ, it's not overwriting it's %age running totals, so I get e.g. :
 Inflating: FRED.EXE (224488100%

When's the bug fix version due out :-)

-rob-

=----------------------------------.----------------------------------------=
| Nominal  : Rob Barth             | RJB Communications (+44) (0)932 253131 |
| InterNet : rob@sound.demon.co.uk | Sound & Vision BBS (+44) (0)932 252323 |
| FidoNet  : sysop, 2:254/14       |  The best UK BBS with a full UseNet &  |
| Nyx      : rbarth@nyx.cs.du.edu  | Internet Email feed. All hours/speeds. |
=----------------------------------.----------------------------------------=


>From kocherp@leland.Stanford.EDU  Wed Jan 06 20:50:41 1993
Newsgroups: comp.compression,sci.crypt,comp.sys.ibm.pc.misc
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!stanford.edu!nntp.Stanford.EDU!kocherp
From: kocherp@leland.Stanford.EDU (Paul Carl Kocher)
Subject: PKZIP 2.04C AV IS EASILY BROKEN
Message-ID: <1993Jan6.045837.23161@leland.Stanford.EDU>
Sender: news@leland.Stanford.EDU (Mr News)
Organization: DSG, Stanford University, CA 94305, USA
Date: Wed, 6 Jan 93 04:58:37 GMT
Lines: 10
Status: RO

The authenticity verification system in the new PKZIP is easily
forged (it took me about an hour to break it), and thus cannot be
trusted.

I have sent a message to PKWARE, and will post more information
after talking with them tomorrow.

-- Paul

kocherp@leland.stanford.edu, 415-497-6589


>From schepers@watserv1.uwaterloo.ca  Thu Jan 07 21:24:03 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!noc.near.net!hri.com!spool.mu.edu!torn!watserv2.uwaterloo.ca!watserv1!schepers
From: schepers@watserv1.uwaterloo.ca (Peter Schepers)
Newsgroups: comp.compression
Subject: PKZIP 2.04c
Message-ID: <C0G7o7.EwB@watserv1.uwaterloo.ca>
Date: 6 Jan 93 20:02:30 GMT
Organization: University of Waterloo
Lines: 56
Status: RO

Newsgroups: comp.compression
Subject: PKZIP 2.04c
Summary:
Expires:
Sender:
Followup-To:
Distribution:
Organization: University of Waterloo
Keywords:

This is actually a response to a posting by Mr. Nico De Vries...


I have been toying with PKZIP running under OS/2 2.0 GA/SP, and have
experienced some interesting problems as well. Up until a few minutes ago,
I could not get it to work reliably. So I went ahead and screwed around
with the DOS settings, to see what could possibly happen.

One of the interesting things is PKZIP detects XMS, EMS, DPMI, micro type
all automatically. So these are the settings I decided to change.

First off, don't try to run PKZIP under OS/2 with no XMS set. I found this
was a sure way to generate a program fault (i.e This Program Encountered
an Error message). At this point the session is dead. When set for
64k, the whole system trapped with a TRAP 6.  It  still seemed to cause
problems. So I left it at 1 Mb. So far so good.

As soon as I had done this, I switched the Dos FS session to the
background, and promptly PKZIP generated an error again. Close down the
session again.

OK. Set XMS to 1Mb. Set EMS to 1Mb. Leave DPMI alone. Try it again in the
background. Crash again.

OK. Set XMS to 1Mb. Set EMS to 1 Mb. Turn DPMI off. Now it works? Go
figure.

Toying with the EMS settings by the way seems to make no difference.

So the settings seem to be.... DPMI off, EMS doesn't matter, XMS to 1 Mb.
This seems to work.

Can someone else verify my findings?


P.S. Right now in the background, I am compressing the whole WATCOM C
directory (all 6 Megs of it.) So far so good... I just checked and it
worked nicely.




>From the workbench/universe of:         :       "Help! Help! I'm being
schepers@watserv1.uwaterloo.ca          :   repressed!"   - Monty Python
------------------------------------------------------------------------------
Peter Schepers     University of Waterloo     Waterloo     Ontario     Canada.


>From nevries@accucx.cc.ruu.nl  Thu Jan 07 21:24:13 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!sun4nl!ruuinf!accucx!nevries
From: nevries@accucx.cc.ruu.nl (Nico E de Vries)
Newsgroups: comp.compression
Subject: PKZIP 2.04c, reported bugs, problems etc.
Message-ID: <3555@accucx.cc.ruu.nl>
Date: 6 Jan 93 16:50:35 GMT
Organization: Academic Computer Centre Utrecht
Lines: 20
Status: RO

So far I have seen the following problems with PKZIP 2.04c:

- volume labels are not correctly stored (not at all it seems)
- runing PKUNZIP from a batch files generates CRC errors, crashes etc
- there seems not to be a way to verify a multivolume archive
- under OS/2 2.0 the program crashes at random moments
- there seem to be problems with PKZIP.CFG
- authenticy verification has been cracked by Paul Kochner in 1 hour

If anyone has more experience, please share them (also correct me if I
am wrong).

Nico E. de Vries  (nevries@cc.ruu.nl) |------------------*   AA   III  PPP
_ This text is supplied AS IS, no warranties of any kind |  A  A   I   P  P
| apply. No rights can be derived from this text. This   |  AAAA   I   PPP
| text is likely to contain spelling and grammar errors. |  A  A   I   P
*---------------------------( Donate to GreenPeace! )----*  A  A  III  P

To get (many) ==> LOSSLESS DATA COMPRESSION SOURCES <== get lds_10.zip at
garbo.uwasa.fi /pc/programming. Make files for Borland C are included.


>From rdippold@cancun.qualcomm.com  Fri Jan 08 20:07:10 1993
Xref: relay1 comp.compression:697 comp.os.msdos.4dos:321
Newsgroups: comp.compression,comp.os.msdos.4dos
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!walter!qualcom.qualcomm.com!cancun!rdippold
From: rdippold@cancun.qualcomm.com (Ron Dippold)
Subject: PKZip 2.04c and 4DOS
Message-ID: <rdippold.726430057@cancun>
Sender: news@qualcomm.com
Nntp-Posting-Host: cancun.qualcomm.com
Organization: Qualcomm, Inc., San Diego, CA
Date: Thu, 7 Jan 1993 18:07:37 GMT
Lines: 11
Status: RO

All those who are getting strange CRC problems and "Insert disk #1"
type wierdnesses while running PKZip 2.04c from a batch file:  are you
using 4DOS?  I found that the visible problems stopped when I ran
under just COMMAND.COM.  I'm not sure whether this is interaction with
4DOS or just a different memory configuration.  PKZ204C has known DPMI
and other memory problems and 4DOS has been extremely solid, so for
the moment I'm assuming it's a PKZ problem, but it's something to consider.

--
Thank you for flying USAF.  We hope you will consider us again when your travelplans next include bombing Baghdad.


>From rdippold@cancun.qualcomm.com  Wed Jan 06 20:50:19 1993
Newsgroups: comp.compression
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!wupost!uwm.edu!linac!att!cbnewsm!cbnewsl!att-out!walter!qualcom.qualcomm.com!cancun!rdippold
From: rdippold@cancun.qualcomm.com (Ron Dippold)
Subject: Re: PKZip 2.04c quick impressions
Message-ID: <rdippold.726281589@cancun>
Sender: news@qualcomm.com
Nntp-Posting-Host: cancun.qualcomm.com
Organization: Qualcomm, Inc., San Diego, CA
References: <rdippold.726235592@cancun> <bontchev.726251313@fbihh> <1993Jan5.172729.23504@midway.uchicago.edu> <rdippold.726275693@cancun>
Date: Wed, 6 Jan 1993 00:53:09 GMT
Lines: 25
Status: RO

rdippold@cancun.qualcomm.com (Ron Dippold) writes:
>Also, info-zip folks:  several files which I downloaded from
>archive.toronto.edu which had been packed with Info-Zip failed with
>CRC errors when I unpacked them with PKUnzip 2.04c.  Unzip handled the
>same files with no problem.  I don't have any files I know were packed

I take it all back!  It does happen, yes, but only when I run it from
a batch file.  It does happen with Info-Zip made files, but also with
PKZIP made files.  Interesting, eh?

  pkunzip -o -d 669bliss.zip

works fine, but if I put that exact same line in a batch file called
a.bat and run "a" I get all sorts of strange errors, and even
sometimes it asks me to "Insert disk #1"!  I can get that last one
pretty reliably as well by forcing a disk and path, as in:

  pkunzip -o -d c:\zip\669bliss.zip

Even without running it in a batch file.

Looks like no more mucking around with the validation checks!  Whew...
--
Cat, n: A soft, indestructible automaton provided by nature to be kicked when
things go wrong in the domestic circle. -- Ambrose Bierce


>From nevries@accucx.cc.ruu.nl  Sat Jan 09 00:33:32 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!sun4nl!ruuinf!accucx!nevries
From: nevries@accucx.cc.ruu.nl (Nico E de Vries)
Newsgroups: comp.compression
Subject: Re: PKZip 2.04c quick impressions
Message-ID: <3559@accucx.cc.ruu.nl>
Date: 7 Jan 93 22:32:57 GMT
References: <rdippold.726235592@cancun> <bontchev.726251313@fbihh> <1993Jan5.172729.23504@midway.uchicago.edu> <814@ulogic.UUCP>
Organization: Academic Computer Centre Utrecht
Lines: 27
Status: RO

In <814@ulogic.UUCP> hartman@ulogic.UUCP (Richard M. Hartman) writes:

[About PKZIP 2.04c multivolume support]

>It seems it could mark the sector (which should have been done during
>formatting of the disk anyway) and try and find the next good sector,
>OR get rid of the (potentially flawed) disk and redo those 19 sectors
>on the next disk.

Actually PKZIP does the opposite. If a sector is marked BAD in the
FAT its quick format removes the mark making it good again. A very
bad thing for file integrity.

>=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
>If only you knew what's inside of me now       |
>you wouldn't want to know me, somehow.         |       -Richard Hartman
>But, you will love me tonight,                 |       hartman@uLogic.COM
>we alone will be all right.  Heaven!           |

Nico E. de Vries  (nevries@cc.ruu.nl  100115,2303) |-----*   AA   III  PPP
_ This text is supplied AS IS, no warranties of any kind |  A  A   I   P  P
| apply. No rights can be derived from this text. This   |  AAAA   I   PPP
| text is likely to contain spelling and grammar errors. |  A  A   I   P
*---------------------------( Donate to GreenPeace! )----*  A  A  III  P

To get (many) ==> LOSSLESS DATA COMPRESSION SOURCES <== get lds_10.zip at
garbo.uwasa.fi /pc/programming. Make files for Borland C are included.


>From madler@cco.caltech.edu  Thu Jan 07 22:46:37 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!news.claremont.edu!nntp-server.caltech.edu!madler
From: madler@cco.caltech.edu (Mark Adler)
Newsgroups: comp.compression
Subject: Re: pkzip 2.04c / unzip v5.0 compatibility
Date: 6 Jan 1993 17:20:38 GMT
Organization: California Institute of Technology, Pasadena
Lines: 64
Distribution: world
Message-ID: <1if4d6INNpgs@gap.caltech.edu>
References: <1ied29INN37p@butler.cc.tut.fi>
NNTP-Posting-Host: sandman.caltech.edu
Status: RO


>> Unzip gives an error message 'BAD CRC 00000000 should be 629643f6'.
...
>> pkunzip 2.04c gets the CRCs ok.

Just to let you know that we're on top of things, here are some
quickie diffs for inflate.c in Unzip 5.0 to allow it to unzip
anything pkzip 2.04c can make (so far).  Basically, inflate.c
is calling deflated entries bad when they are not, in one case
because of an apparent change between pkzip 1.93a and 2.04c,
and in the other case because of a mistake on my part.  For those
of you testing Unzip 5.0 with files made by pkzip 2.04c, please
apply these patches to inflate.c and recompile Unzip 5.0.  If
you encounter more problems, please let us know at:

     zip-bugs@wkuvx1.bitnet

Thanks.

Mark Adler
madler@cco.caltech.edu

*** inflate.c.50        Thu Aug 13 19:46:16 1992
--- inflate.c   Wed Jan  6 09:15:01 1993
***************
*** 324,331 ****
    do {
      c[*p++]++;                  /* assume all entries <= BMAX */
    } while (--i);
!   if (c[0] == n)
!     return 2;                   /* bad input--all zero length codes */


    /* Find minimum and maximum length, bound *m by those */
--- 324,335 ----
    do {
      c[*p++]++;                  /* assume all entries <= BMAX */
    } while (--i);
!   if (c[0] == n)                /* null input--all zero length codes */
!   {
!     *t = (struct huft *)NULL;
!     *m = 0;
!     return 0;
!   }


    /* Find minimum and maximum length, bound *m by those */
***************
*** 469,475 ****


    /* Return true (1) if we were given an incomplete table */
!   return y != 0 && n != 1;
  }


--- 473,479 ----


    /* Return true (1) if we were given an incomplete table */
!   return y != 0 && g != 1;
  }




>From brianb@julian.uwo.ca  Sat Jan 09 00:34:33 1993
Newsgroups: comp.compression
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!zaphod.mps.ohio-state.edu!cs.utexas.edu!torn!newshost.uwo.ca!julian.uwo.ca!brianb
From: brianb@julian.uwo.ca (Brian Borowski)
Subject: Re: pkzip 2.04c / unzip v5.0 compatibility
Organization: University of Western Ontario, London
Date: Fri, 8 Jan 1993 13:07:24 GMT
Message-ID: <1993Jan8.130724.21237@julian.uwo.ca>
Keywords: passwords problem.
References: <19342@mindlink.bc.ca> <1iierpINNk9f@gap.caltech.edu>
Sender: news@julian.uwo.ca (USENET News System)
Nntp-Posting-Host: julian.uwo.ca
Lines: 12
Status: RO


I don't know if anyone else has noticed this, and maybe I'm not
doing something right, but the following situation has been observed.

If I zip up a file with pkzip 204c with password encryption,
I find that unzip 5.0 cannot unzip such a file.  It asks for
the password, but will not undo the file.

Has anyone else observed this behaviour?  If I am not doing something
right, let me know please.

brianb@julian.uwo.ca


>From madler@cco.caltech.edu  Sun Jan 10 15:29:09 1993
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!zaphod.mps.ohio-state.edu!saimiri.primate.wisc.edu!ames!data.nas.nasa.gov!mustang.mst6.lanl.gov!nntp-server.caltech.edu!madler
From: madler@cco.caltech.edu (Mark Adler)
Newsgroups: comp.compression
Subject: Re: pkzip 2.04c / unzip v5.0 compatibility
Date: 9 Jan 1993 00:10:56 GMT
Organization: California Institute of Technology, Pasadena
Lines: 21
Message-ID: <1il56hINN9lq@gap.caltech.edu>
References: <1iierpINNk9f@gap.caltech.edu> <1993Jan8.130724.21237@julian.uwo.ca> <1993Jan8.224724.23801@leland.Stanford.EDU>
NNTP-Posting-Host: sandman.caltech.edu
Keywords: passwords problem.
Status: RO


Paul Kocher thinks:

>> instead of having two bytes of the crc32 at the end of the encryption
>> header, the final byte of this header is a zero.  (The others are

Actually, there was a bug in Unzip 5.0's decryption that is fixed in
our current beta version.  That beta version appears to have no problem
decrypting stuff from PKZIP 2.04c.  However, we check for the high
byte of the crc as the 12th byte of the encryption header--not a zero.

Can you recheck your assertion that the 12th byte is a zero?  I don't
see how this can agree with our test results.

In any case, a new patched unzip will be released next week which
includes the patches I posted to decompress stuff from pkzip 2.04c,
as well as the decryption fix that's been there a while, and some
other fixes.

Mark Adler
madler@cco.caltech.edu


>From ts@chyde.uwasa.fi  Fri Jan 08 20:07:10 1993
Xref: relay1 comp.archives.msdos.announce:232 comp.compression:698
Newsgroups: comp.archives.msdos.announce,comp.compression
Path: softp!farmua!relay1!csoft!kiae!demos!fuug!news.funet.fi!uwasa.fi!chyde.uwasa.fi!ts
From: ts@chyde.uwasa.fi (Timo Salmi)
Subject: unz50u1.exe uploaded to garbo
Message-ID: <ts9301071830.4938@chyde.uwasa.fi>
Followup-To: comp.compression
Sender: ts@uwasa.fi (Timo Salmi)
Organization: University of Vaasa
Date: Thu, 7 Jan 1993 18:30:54 GMT
Approved: ts@chyde.uwasa.fi
Lines: 38
Status: RO

-Subject: Re: unz50u1.exe uploaded to garbo
-To: jloup@chorus.fr (Jean-loup Gailly)
-Date: Thu, 7 Jan 1993 20:30:33 +0200 (EET)
-From: ts

>
> Timo,
>
> I have uploaded to garbo an MSDOS executable of unzip 5.0 with a patch
> allowing it to extract files created by pkzip 2.04c.  The patch has
> already been posted in source form in comp.compression by Mark Adler.
> The file is unz50u1.exe. ('u1' stands for 'unofficial patch 1'.) It is
> a self-extracting lha file. I will shortly upload unz50u1.tar.Z to
> garbo as well.
>
> We will release as soon as possible an official patch for unzip 5.0,
> which will be posted to comp.sources.misc. No patch is necessary in
> zip 1.9p1, since pkunzip 2.04c appears to accept all zip-generated
> files (except for bugs in pkunzip which are also present for
> pkzip-generated files, such as when pkunzip is invoked in a batch
> file).
>
> We also work on the multi-disk support in zip and unzip, but this will
> take a little more time.
>
> Jean-loup
>

Thank you for your contribution.  This upload is now available as
  33926 Jan  6 23:06 garbo.uwasa.fi:/pc/arcers/unz50u1.exe

   All the best, Timo

..................................................................
Prof. Timo Salmi      Co-moderator of comp.archives.msdos.announce
Moderating at garbo.uwasa.fi anonymous FTP archives 128.214.87.1
Faculty of Accounting & Industrial Management; University of Vaasa
Internet: ts@uwasa.fi Bitnet: salmi@finfun   ; SF-65101, Finland


--
((setter reply-address) *my-mail* "dk%farm.cs.kiev.ua@ussr.eu.net") #| cs:dk |#



