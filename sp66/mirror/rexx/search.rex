From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!gatech!howland.reston.ans.net!EU.net!sunic!erinews.ericsson.se!etxbosi Sun Aug 14 09:36:23 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!gatech!howland.reston.ans.net!EU.net!sunic!erinews.ericsson.se!etxbosi
From: etxbosi@solsta.ericsson.se (Bo Siltberg)
Newsgroups: comp.lang.rexx
Subject: Re: "in" operator?
Date: 11 Aug 1994 11:50:44 GMT
Organization: Ericsson Telecom
Lines: 42
Distribution: inet
Message-ID: <32d3ak$2k9@erinews.ericsson.se>
References: <2e45594a.415253@ars.muc.de> <325big$1hg9@sernews.raleigh.ibm.com>
NNTP-Posting-Host: solstae.ericsson.se
X-Newsreader: NN version 6.5.0 #4

pmuellr@vnet.ibm.com writes:

>In <2e45594a.415253@ars.muc.de>, rommel@ars.muc.de (Kai Uwe Rommel) writes:
>>
>>I would like to have a way to determine *which* values exist for a
>>given stem, something like awk's "in" operator. I can't find something
>>like this. Is there something to accomplish this and am I perhaps only
>>overlooking the obvious?

>Nothing built-in to help you.  You'll need to maintain a separate list
>of stem 'tails' if you need this functionality.  If the tails have no
>blanks in them, you can just keep the tails in one big 
>blank-delimited string.
 ^^^^^^^^^^^^^^^^^^^^^^^

I have noted, on IBM VM/CMS that adding strings to strings is very
slow compared to making an indexed list. Compare these two programs:
The first one looks very nice but it is about 100 times slower than the
second program. It's the "str=str l.i" statement that takes time.
This is very noticable for large number of elements.

Program 1:

   str = ''
   do i=1 to l.0
     if find(str,l.i) = 0       /* If no found earlier */
       then str=str l.i         /* add it to list */
   end

Program 2:

   check. = 0
   data.  = 0
   do i=1 to l.0
     t = l.i
     if check.t = 0 then do     /* If not found earlier */
       check.t = 1              /* Indicate l.i found */
       data.0=data.0 + 1        /* Update no of data */
       t=data.0
       data.t=l.i               /* add it to list */
     end
   end

