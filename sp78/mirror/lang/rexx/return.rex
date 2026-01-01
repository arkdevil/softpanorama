Newsgroups: comp.lang.rexx
From: @  (Peter Hansen)
Subject: Re: Setting ERRORLEVEL from REXX
Date: Wed, 4 Oct 1995 15:47:31 GMT

In <44psk3$t2n@redstone.interpath.net>, loren@usair.com writes:
>.... The problem he is running into is that the batch
>file checks ERRORLEVEL to see how the REXX program terminated, but REXX
>does not appear to set ERRORLEVEL.  We have tried "exit n" (with n being the
>desired ERRORLEVEL), ....

Try 'return n' in place of your 'exit n'...

If that doesn't work, try again.  :-)  I just wrote a test file and
it does the job.  Email if you need help.

-----------------------------------------------------------------------
 Peter Hansen                   Engenuity Corporation          Guelph
 peter@engcorp.com                                             Ontario
 http://www.sentex.net/~engcorp/peter/                         Canada
-----------------------------------------------------------------------


