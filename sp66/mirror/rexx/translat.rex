From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!emory!swrinde!howland.reston.ans.net!spool.mu.edu!torn!nntp.cs.ubc.ca!bcsystems!bcsystems!nntp Sun Aug 14 09:38:13 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!emory!swrinde!howland.reston.ans.net!spool.mu.edu!torn!nntp.cs.ubc.ca!bcsystems!bcsystems!nntp
Newsgroups: comp.lang.rexx
Subject: Re: REXX Script to change case of filenames
Message-ID: <1994Aug11.160811.4917@vmsmail.gov.bc.ca>
From: glittle@bcsc02.gov.bc.ca (Glen Little)
Date: 11 Aug 94 16:08:11 PDT
Reply-To: glittle@bcsc02.gov.bc.ca (Glen Little)
References: <dwormuth-1108941641370001@134.174.81.89>
Distribution: inet
Organization: B.C. Ministry of Finance, FICOM
Nntp-Posting-Host: glittle.bcsc.gov.bc.ca
X-Newsreader: IBM NewsReader/2 v1.02
Lines: 20

In <dwormuth-1108941641370001@134.174.81.89>, dwormuth@dsg.harvard.edu (David Wormuth) writes:
>I just added a drive formatted with HPFS. Suddenly my unix utilities don't
>like the man pages files in UPPER case. Has anyone written a script to
>change the case of filenames in REXX?
>
>I looked through some REXX manuals, but don't see a rename function.
>
>Thanks

If you want to force the letters in a string to be lowercase, you can use:

  newString = translate(oldString, xrange('61'x,'7A'x), xrange('41'x,'5A'x))

This converts uppercase to lowercase for the standard 26 letters.

+---------------------------------------+
+             Glen Little               +
+       glittle@bcsc02.gov.bc.ca        +
 **** I speak for no one but myself ****


