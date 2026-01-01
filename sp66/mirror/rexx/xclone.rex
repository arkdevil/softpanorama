From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!sol.ctr.columbia.edu!howland.reston.ans.net!vixen.cso.uiuc.edu!newsfeed.ksu.ksu.edu!moe.ksu.ksu.edu!wizard.uark.edu!comp!acrosby Mon Aug 22 20:36:01 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!sol.ctr.columbia.edu!howland.reston.ans.net!vixen.cso.uiuc.edu!newsfeed.ksu.ksu.edu!moe.ksu.ksu.edu!wizard.uark.edu!comp!acrosby
From: acrosby@comp..uark.edu (Albert Crosby)
Newsgroups: comp.lang.rexx
Subject: Re: Source "Beautifier"
Date: 22 Aug 1994 08:14:32 GMT
Organization: UA AGHE Microcomputer & Network Support
Lines: 40
Distribution: inet
Message-ID: <339mp8$776@wizard.uark.edu>
References: <REXXLIST%94081811331267@NIC.SURFNET.NL> <330u16$5oj@yoda.syntex.com> <adamtCuuosE.25r@netcom.com>
Reply-To: acrosby@comp.uark.edu
NNTP-Posting-Host: comp.uark.edu

adamt@netcom.com (Adam Thornton) writes:

>In article <330u16$5oj@yoda.syntex.com>,  <MIKE.GORGOLINSKI@SYNTEX.COM> wrote:
>>could you please send me a copy of xedit?
>>I would really appreciate it.

>I bet IBM wouldn't.

>That does raise an interesting question, though: which shareware/freeware
>package provides the best approximation to XEDIT, both in terms of
>look-and-feel and in terms of macro language capabilities?  I'm mostly
>thinking of OS/2 or DOS environments, but what about for Unix boxes too?

Freeware:

THE. The Hesslinger Editor.  Available for DOS, OS/2, Unix, AmigaDOS.  Other
ports may be underway.  Supports REXX interpreters in all of the above
environments.

Shareware:

I'm not aware of anything.

Commercial:

DOS/OS/2: Kedit from Mansfield Software.  Includes the KEXX language, a
version of REXX  for just the editor.  Also available, Personal REXX for DOS
and OS/2, works with Kedit.

Unix: Uni-Xedit coupled with Uni-REXX.  I've not tried writing REXX macros
in Uni-Xedit, but my understanding is it works.

Someone else may be able to give a more complete answer.

Albert
--
Albert Crosby          | Microcomputer & Network Support | IBM Certified
acrosby@comp.uark.edu  |   University of Arkansas        |  OS/2 Engineer &
1 501 575 4452         |     College of Agriculture And  |   Lan Server 
=======Team OS/2=======|       Home Economics            |    Administrator*

From ankh.iia.org!uunet!gatekeeper.us.oracle.com!decwrl!nntp.crl.com!crl.crl.com!not-for-mail Mon Aug 22 20:37:07 1994
Path: ankh.iia.org!uunet!gatekeeper.us.oracle.com!decwrl!nntp.crl.com!crl.crl.com!not-for-mail
From: daugava@crl.com (Andrei Zaitsev)
Newsgroups: comp.lang.rexx
Subject: Re: any DOS rexx interpreter
Date: 22 Aug 1994 13:49:44 -0700
Organization: CRL Dialup Internet Access	(415) 705-6060  [login: guest]
Lines: 3
Distribution: inet
Message-ID: <33b318$gts@crl.crl.com>
References: <bdc_9408020453@blkcat.fidonet.org>
NNTP-Posting-Host: crl.com
X-Newsreader: TIN [version 1.2 PL2]

Large REXX subset is builtin into KEDIT - XEDIT clone for DOS.
It gives you even more power than the original duet of
XEDIT/REXX in CMS.

From ankh.iia.org!uunet!spool.mu.edu!howland.reston.ans.net!paladin.american.edu!auvm!UTOPIA.FNET.FR!David.Salthouse Mon Aug 22 20:38:50 1994
Path: ankh.iia.org!uunet!spool.mu.edu!howland.reston.ans.net!paladin.american.edu!auvm!UTOPIA.FNET.FR!David.Salthouse
Comments: Gated by NETNEWS@AUVM.AMERICAN.EDU
Newsgroups: comp.lang.rexx
X-Mailer: ELM [version 2.4 PL21]
Content-Type: text
Content-Length: 1661
Message-ID: <199408210852.AA28859@ns.fnet.fr>
Date: Sun, 21 Aug 1994 10:52:34 +0200
Sender: REXX Programming discussion list <REXXLIST@UGA.BITNET>
From: David Salthouse <David.Salthouse@UTOPIA.FNET.FR>
Subject: XEDIT lookalikes
Comments: To: REXXLIST@vm.gmd.de
Lines: 34

/*  Warning this message contains references to commercial
    products which the author sells */

In reply to Adam Thorton's question of 20 Aug 1994

>That does raise an interesting question, though: which shareware/freeware
>package provides the best approximation to XEDIT, both in terms of
>look-and-feel and in terms of macro language capabilities?  I'm mostly
>thinking of OS/2 or DOS environments, but what about for Unix boxes too?

Robert Benaroya has recently shipped SEDIT 3.61.  This version is close
to 100% compatible with XEDIT.  Notable additions include support for
CTLCHAR, RESERVED and READ to enable people who used XEDIT as a screen
manager to run their code happily under UNIX.  It also handles prefix
macros.  Supported platforms are Risc/6000, SUN, HP, DEC, and Silicon
Graphics. It is commercial software.

KEDIT from Mansfield handles most of XEDIT but not prefix macros or READ
or CTLCHAR or RESERVED but like SEDIT is much more interactive than the
old mainframe XEDIT.  KEDIT runs on DOS, OS/2 and soon Windows where it
should change a few mindsets. It is also commercial software.

Personally I work exclusively with Quercus Personal REXX/KEDIT under
OS/2 and With SREXX/SEDIT on the Sun.  My macros will be 100% compatible
across SUN / OS/2 / CMS with the next release of SREXX.

I have seen correspondance on this list about the THE (The Hessling
Editor) which is for UNIX, DOS, and OS/2 and described as a freeware
KEDIT lookalike but I haven't yet tried it.

These are all the Xavier Editors I know.

I shall now wrestle with EMACS to send this message to the list.

David Salthouse       david.salthouse@utopia.fnet.fr

From ankh.iia.org!uunet!salliemae!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!!" Mon Aug 22 20:39:38 1994
Path: ankh.iia.org!uunet!salliemae!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!!"
Comments: Gated by NETNEWS@AUVM.AMERICAN.EDU
Newsgroups: comp.lang.rexx
X-Mail: IBM - Thomas J. Watson Research Center 38-049 -- Workstation Services
        Yorktown Heights, NY  10598
X-External-Networks: yes
Message-ID: <9408221353.AA0115@vesuvius.watson.ibm.com>
Date: Mon, 22 Aug 1994 09:52:07 EST
Sender: REXX Programming discussion list <REXXLIST@UGA.BITNET>
From: "Thomas E. Bridgman 914-945-3510 (T/L 862-3510)"
              <mrtom@WATSON.IBM.COM>
Subject: XEDIT lookalikes
Comments: To: REXXLIST@uga.cc.uga.edu
In-Reply-To: <.AA0106@vesuvius.watson.ibm.com>
Lines: 8

Rudi Pittman writes:
> So where can a fellow locate a copy of this freeware editor your referring
> to?

The THE editor can be obtained from ftp.gu.edu.au in /src/THE.

Tom Bridgman - Systems Engineering Services (OS/2)
VNET:   MRTOM at WATSON    Internet: MRTOM@WATSON.IBM.COM
Bitnet: MRTOM at YKTVMV    IBMMAIL:  USIB53B6

From ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!newsxfer.itd.umich.edu!nntp.cs.ubc.ca!bcsystems!bcsc02.gov.bc.ca!CFORDE Mon Aug 22 20:39:58 1994
Path: ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!newsxfer.itd.umich.edu!nntp.cs.ubc.ca!bcsystems!bcsc02.gov.bc.ca!CFORDE
Newsgroups: comp.lang.rexx
Subject: Re: XEDIT lookalikes
Message-ID: <1701A8816S86.CFORDE@bcsc02.gov.bc.ca>
From: Carl Forde <CFORDE@bcsc02.gov.bc.ca>
Date: Mon, 22 Aug 94 09:40:34 PDT
Organization: BC Systems Corporation
Nntp-Posting-Host: bcsc02.gov.bc.ca
Lines: 16



In article <940821135420157@greatesc.com>
rudi.pittman@greatesc.com (Rudi Pittman) wrote:
>
>  Da> I have seen correspondance on this list about the THE (The Hessling
>  Da> Editor) which is for UNIX, DOS, and OS/2 and described as a freeware

The OS/2 version is available at ftp-os2.cdrom.com in pub/os2/2_x/editors
as theos215.zip.

Have fun,
Carl Forde                            phonenet: 604-389-3234
VM Systems Software Group             bitnet  : CFORDE at BCSC02
British Columbia Systems Corporation  internet: cforde@bcsc02.gov.bc.ca
VM embodied formal client/server structures years before PCs. -- Gartner Group

From ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!newsxfer.itd.umich.edu!isclient.merit.edu!msuinfo!harbinger.cc.monash.edu.au!bunyip.cc.uq.oz.au!griffin.itc.gu.edu.au!snark.itc.gu.edu.au!not-for-mail Mon Aug 22 20:40:30 1994
Path: ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!newsxfer.itd.umich.edu!isclient.merit.edu!msuinfo!harbinger.cc.monash.edu.au!bunyip.cc.uq.oz.au!griffin.itc.gu.edu.au!snark.itc.gu.edu.au!not-for-mail
From: mark@snark.itc.gu.edu.au (Mark Hessling)
Newsgroups: comp.lang.rexx
Subject: Re: XEDIT lookalikes
Date: 23 Aug 1994 07:39:34 +1000
Organization: Griffith University, Brisbane, Australia
Lines: 25
Distribution: inet
Message-ID: <33b5um$dia@snark.itc.gu.edu.au>
References: <940821135420157@greatesc.com>
NNTP-Posting-Host: snark.itc.gu.edu.au

rudi.pittman@greatesc.com (Rudi Pittman) writes:

> -=> Quoting David.salthouse@utopia.fn to All <=-


> Da> I have seen correspondance on this list about the THE (The Hessling
> Da> Editor) which is for UNIX, DOS, and OS/2 and described as a freeware
> Da> KEDIT lookalike but I haven't yet tried it.

>So where can a fellow locate a copy of this freeware editor your referring
>to?


THE's home is at ftp.gu.edu.au:/src/THE The current release is 1.5, but
there is also a beta of release 2.0 in the same directory.

Cheers, Mark
------------------------------------------------------------------------
Mark Hessling                         Email: M.Hessling@gu.edu.au
DBA,ITS                               Phone: +617 875 7691
Griffith University                   Fax:   +617 875 5314
Nathan, Brisbane                      ***** PDCurses Maintainer *****
QLD 4111                              *** Author of THE and GUROO ***
Australia                             ======= Member of RexxLA ======
------------------------------------------------------------------------

From ankh.iia.org!uunet!usc!howland.reston.ans.net!swrinde!ihnp4.ucsd.edu!news.cerf.net!nntp-server.caltech.edu!news.claremont.edu!kaiwan.com!greatesc!rudi.pittman Mon Aug 22 20:42:21 1994
Path: ankh.iia.org!uunet!usc!howland.reston.ans.net!swrinde!ihnp4.ucsd.edu!news.cerf.net!nntp-server.caltech.edu!news.claremont.edu!kaiwan.com!greatesc!rudi.pittman
From: rudi.pittman@greatesc.com (Rudi Pittman)
Newsgroups: comp.lang.rexx
Subject: Re: any DOS rexx interpre
Date: Sun, 21 Aug 1994 18:30:00 GMT
Message-ID: <940821135420155@greatesc.com>
Organization: The Great Escape - Gardena, CA - (310) 676-3534
Distribution: world
Lines: 41   

 -=> Quoting Bob Luce to All <=-

 BL> Simon Chenery (simonc@genasys.com.au) wrote:
 BL> : Does anyone know of any version of REXX that will run on MS-DOS?
 BL> : I have seen versions for OS/2 but have been unable to find one for
 BL> DOS. : --
 BL> : Simon    (simonc@g2syd.genasys.com.au)

I am using one of two Shareware/Freeware Rexx compilers for the IBM PC.
Mine was downloaded from BIX.(one of the big boards like AOL.) I will
include some snippets from my compiler for info. Not sure how I would get a
copy to you however......

                 Author.........Bill N. Vlachoudis
                 Address........Eirinis 4
                                TK555 35 Pilea
                                Thessaloniki Greece
                 Computer addr..cdaz0201@Grtheun1.EARN
                                vlachoudis@olymp.ccf.grtheun.gr [155.207.1.1]
                                bill@donoussa.physics.auth.gr   [155.207.2.6]
                 Telephone......(31) 322-805
                 Date...........Mar-1993



     About this REXX interpreter
     ~~~~~~~~~~~~~~~~~~~~~~~~~~
        I wrote this version of REXX because I though that it would be
     nice to have my own REXX interpreter do use it with DOS, UNIX and
     also as a macro language for my programs. This REXX interpreter is
     all written in ANSI C, and I didn't try to make it fast but to as
     much more flexible, with very little restrictions and also to be
     compatible with IBM REXX from CMS.






... Trespassers will be shot.  Survivors will be SHOT AGAIN!
___ Blue Wave/QWK v2.12

From ankh.iia.org!uunet!salliemae!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!!" Mon Aug 22 20:42:56 1994
Path: ankh.iia.org!uunet!salliemae!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!!"
Comments: Gated by NETNEWS@AUVM.AMERICAN.EDU
Newsgroups: comp.lang.rexx
X-Mail: IBM - Thomas J. Watson Research Center 38-049 -- Workstation Services
        Yorktown Heights, NY  10598
X-External-Networks: yes
Message-ID: <9408221351.AA0114@vesuvius.watson.ibm.com>
Date: Mon, 22 Aug 1994 09:48:58 EST
Sender: REXX Programming discussion list <REXXLIST@UGA.BITNET>
From: "Thomas E. Bridgman 914-945-3510 (T/L 862-3510)"
              <mrtom@WATSON.IBM.COM>
Subject: Re: any DOS rexx interpre
Comments: To: REXXLIST@uga.cc.uga.edu
In-Reply-To: <9408221343.AA0106@vesuvius.watson.ibm.com>
Lines: 12

Rudi Pittman writes:
> I am using one of two Shareware/Freeware Rexx compilers for the IBM PC.
> Not sure how I would get a copy to you however......

Just a nit, but you are using a REXX *interpreter*, not a compiler.  I am
not aware of any REXX compilers, product or shareware, for DOS or OS/2.

Bill Vlachoudis' REXX interpreter for DOS can be obtained via anonymous FTP
from rexx.uwaterloo.ca in the /pub/freerexx directory.

Tom Bridgman - Systems Engineering Services (OS/2)
VNET:   MRTOM at WATSON    Internet: MRTOM@WATSON.IBM.COM
Bitnet: MRTOM at YKTVMV    IBMMAIL:  USIB53B6

