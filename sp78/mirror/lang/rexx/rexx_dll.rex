From: rmahoney@netusa.net
Newsgroups: comp.os.os2.programmer.misc
Subject: Re: DLL for both REXX and PM ??
Date: 12 Oct 1995 03:46:32 GMT

In <DG95nJ.9rt@undergrad.math.uwaterloo.ca>, bcrwhims@undergrad.math.uwaterloo.ca (Carsten Whimster) writes:
>
>If I do this, perhaps I should have two DLLs, one of which is a real C
>DLL, and the other one of which is just a REXX front-end for the C
>DLL. Is this possible? It should be, I think, but I am a DLL novice :)

  Have one DLL with 2 entry points ( a "C" entry point and a REXX entry point)
and 1 common function that gets called from those functions (after you
parse the input) and does all the work.

Robert Mahoney                    Have trouble spelling?
2Rud Software and                Check out SpellGuard
Consulting                      An as-you-type spell checker
         http://www.netusa.net/~rmahoney/


