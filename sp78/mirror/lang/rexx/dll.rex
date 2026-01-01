Newsgroups: comp.lang.rexx
From: giguere@csg.uwaterloo.ca (Eric Giguere)
Subject: Re: VX-REXX and external DLL's
Date: Tue, 3 Oct 1995 16:29:41 GMT

In article <DFvKpy.EFA@undergrad.math.uwaterloo.ca>,
Carsten Whimster <bcrwhims@undergrad.math.uwaterloo.ca> wrote:
>In article <44q8mm$8d7@bingnet1.cc.binghamton.edu>,  <phlatline@mhv.net> wrote:
>|  How do you go about loading DLL's in VX-REXX?
>|
>|  please e-mail
>
>I would like to know the answer to this too, and also, how do you
>write DLLs for REXX? Do I need 2.1, or can I keep going with 2.0c?

The OS/2 REXX interpreter supports an API for writing DLLs that REXX
can use.  Any version of VX-REXX can use these DLLs.  You use the
RXFUNCADD built-in function to load the DLL.  Usually you load
the DLL by registering a single entry point and then call that entry point
and it then registeres any other functions.  Like this:

  call RXFuncAdd 'SystLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    call SysLoadFuncs

As for building the DLLs, you just need a C compiler and the OS/2 Toolkit.
Samples come with the toolkit, also you can get VX-REXX Tech Notes #1 and
#7 to help you out.

Eric

