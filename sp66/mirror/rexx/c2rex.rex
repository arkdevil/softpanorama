From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!solaris.cc.vt.edu!uunet!psinntp!newsserver.pixel.kodak.com!newsserver.rdcs.Kodak.COM!icts01!wiegers Fri Aug 26 08:36:29 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!solaris.cc.vt.edu!uunet!psinntp!newsserver.pixel.kodak.com!newsserver.rdcs.Kodak.COM!icts01!wiegers
From: wiegers@icts01.kodak.com (Karl Wiegers)
Newsgroups: comp.lang.rexx
Subject: Re: C interface to REXX (CMS?)
Date: 25 Aug 1994 17:15:35 GMT
Organization: Eastman Kodak Company
Lines: 24
Distribution: inet
Message-ID: <33ijjn$7ih@kodak.rdcs.Kodak.COM>
References: <777469220snz@doofer.demon.co.uk> <1994Aug23.051109.16324@newsgate.sps.mot.com>
NNTP-Posting-Host: icts01.kodak.com

In article <1994Aug23.051109.16324@newsgate.sps.mot.com> ttg242@newton.sps.mot.com writes:
>I s'pose it's possible to write functions for REXX using 'C' in the
>CMS environment.  If it is, has anyone done it and could they let me
>have an example to hack or point me to any relevant documentation.
>
>Regards,
>David TvE

The Waterloo C compiler for VM from Watcom supports the creation of C
functions callable from REXX.  We have used this capability to write
mathematical functions like SQRT and LOG10 that are absent from REXX.
The Waterloo function library provides functions to set REXX variables,
fetch the values of REXX variables into a C character array, delete 
(drop) REXX variables, and return a value from the function that can
be referenced in the C program.  This is quite simple, and is described
in the Waterloo C Development System Version 3.0 for VM/CMS User's
Guide, p. 208.  It works fine.

-- 
Karl Wiegers                         (716) 477 4525 (voice)
Eastman Kodak Company                (716) 588 7075 (fax)
1st Floor Bldg 59                    kwiegers@kodak.com
Rochester NY 14650-1723
Opinions expressed here are almost certainly unique to me.

