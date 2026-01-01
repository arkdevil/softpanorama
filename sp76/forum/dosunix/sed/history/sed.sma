
Date: Fri, 21 Jun 91 14:07:05 CDT
From: robin@utafll.uta.edu (Robin Cover)
Message-Id: <9106212107.AA17356@utafll.uta.edu>
To: kirsch@usasoc.soc.mil
Subject: sed11
Cc: robin@utafll.uta.edu

Thanks to Eric Raymond and others who contributed to the 18K sed exec.

I have a couple questions - which might be as easily answered as having
a BSD UNIX manual (but I don't).

Scripts which worked with the GNUish sed don't work with the current
sed, namely, in the treatment of <CR> and <LF>.  With the GNUish
version, one may enter OD OA (<CR><LF>) directly into a script and
get results; your current 18K version seems to accept the notation
 \d13\d10  as equivalent to <CR><LF>, but I do not see this in the
man page.  In fact, it has never been clear to me why the GNUish
utils for DOS do not (always?) predictably improve on the handling
of the 8th bit.  Much of my text processing requires that I am
able to address control chars (0-31), hi-bit chars -- in a word,
all chars that wordprocessors reserve for their private purposes.
Standard UNIX is very unreliable in (usually NOT) allowing one to
address the full 8-bit ascii char set except for minor instances
of generosity, so I look to the DOS UNIX-lookalikes to solve the
problem.

Questions:

1) are decimal 10 and 13 the ONLY chars that can be addressed with "sed11"
   using the convention \d13  ?
2) otherwise, will "sed11" faithfully handle all 256 chars, if they are
   in scripts and text files?
3) is it not reasonable to think of pushing the buffer size beyond
   4K (e.g., for the purpose of using tags in the pattern space)?  The
   major drawback of these utils is that they choke on long lines --
   I am thinking of SGML files, for instance.  Do you know of any
   attempts (for 386 machines) to build grep/sed/awk to handle
   LONG lines - approaching 32K, or more?

Thanks,

Robin Cover

-----------------------------------------------------------------------------
Robin Cover                BITNET:   zrcc1001@smuvm1     ("one-zero-zero-one")
6634 Sarah Drive           Internet: robin@utafll.uta.edu     ("uta-ef-el-el")
Dallas, TX  75236  USA     Internet: zrcc1001@vm.cis.smu.edu
Tel: (1 214) 296-1783      Internet: robin@ling.uta.edu
FAX: (1 214) 841-3642      Internet: robin@txsil.sil.org
=============================================================================



Date:     Sat, 22 Jun 91 16:14:58 EDT
From:     David Kirschbaum
To:       robin@utafll.uta.edu (Robin Cover)
Subject:  Re:  sed11

>Scripts which worked with the GNUish sed don't work with the current
>sed, namely, in the treatment of <CR> and <LF>.  With the GNUish
>version, one may enter OD OA (<CR><LF>) directly into a script and
>get results; your current 18K version seems to accept the notation
> \d13\d10  as equivalent to <CR><LF>, but I do not see this in the
>man page.

I believe these instructions (from the sed11.man) apply to all commands:

l               (2)
   List. Sends the pattern space to standard output.  A "w" option may follow as in the s command below. Non-printable characters expand to:
   \b  --  backspace (ASCII 08)
   \t  --  tab       (ASCII 09)
   \n  --  newline   (ASCII 10)
   \r  --  return    (ASCII 13)
   \e  --  escape    (ASCII 27)
   \xx --  the ASCII character corresponding to 2 hex digits xx.

Your CR or 0DH would be \0D  and your LF would be \0A.  Similar to, but
simpler than, C's \0x0d and \0x0a.

>      In fact, it has never been clear to me why the GNUish
>utils for DOS do not (always?) predictably improve on the handling
>of the 8th bit.  Much of my text processing requires that I am
>able to address control chars (0-31), hi-bit chars -- in a word,
>all chars that wordprocessors reserve for their private purposes.
>Standard UNIX is very unreliable in (usually NOT) allowing one to
>address the full 8-bit ascii char set except for minor instances
>of generosity, so I look to the DOS UNIX-lookalikes to solve the
>problem.

Well, we have ordinary text file reads here.  In DOS there's very little
processing that occurs during text file reads .. just EOL and EOF mainly.
I scanned sed11's source and found nothing to indicate text characters are
being tampered for their 8th bit.

Unfortunately, this is *not* "raw" mode in its crudest form, so you will
NOT be able to get *all* the control characters.  But sed was, after all,
from the beginning intended to deal with TEXT.  And you wish to step
outside those boundaries.

>Questions:
>
>1) are decimal 10 and 13 the ONLY chars that can be addressed with "sed11"
>   using the convention \d13  ?

Donno .. I'm not familiar enough with sed and its command files to
experiment.  It *looks* like any character could be used.  But where'd you
get that "\dxx" business?  I didn't see anything like that in the source,
and the man says just to use "\xx".

>2) otherwise, will "sed11" faithfully handle all 256 chars, if they are
>   in scripts and text files?

It looks like it, except for ^Z (ASCII 26) and CR/LFs.

>3) is it not reasonable to think of pushing the buffer size beyond
>   4K (e.g., for the purpose of using tags in the pattern space)?  The
>   major drawback of these utils is that they choke on long lines --
>   I am thinking of SGML files, for instance.  Do you know of any
>   attempts (for 386 machines) to build grep/sed/awk to handle
>   LONG lines - approaching 32K, or more?

I tried, bumping the buffers up to 24K (needed malloc() to do that too).
It seemed to run just fine, but then choked&died on loooooong lines (about
14Kb).  Don't know why, and don't plan to spend the time finding out!
Again, you're wandering beyond text files .. and there's no warrant for
sed to do things like that.

Sorry I can't be more help, but I am *not* a bonafide sed writer or
developer.  I only did a hack to port it to Turbo C v2.0, and have no
plans to enhance or modify sed in any other way.

David Kirschbaum
Toad Hall
kirsch@usasoc.soc.mil


Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Sun, 23 Jun 91 16:08:09 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106232108.AA01077@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: sed

Here are the messages from Borland C++ 2.0 on the sed that you just put on
simtel.  Do I need to worry about any of them and if so and you make diffs
will you please send them to me?  Also can sed be a com file or do you know?
Borland C++  Version 2.0 Copyright (c) 1991 Borland International
sedcomp.c:
Warning sedcomp.c 221: Function should return a value in function main
Warning sedcomp.c 761: Function should return a value in function gettext
Warning sedcomp.c 831: Constant out of range in comparison in function ycomp
sedexec.c:
Warning sedexec.c 256: Function should return a value in function selected
Warning sedexec.c 472: Possibly incorrect assignment in function dosub
Turbo Link  Version 4.0 Copyright (c) 1991 Borland International
        Available memory 155200



Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Sun, 23 Jun 91 19:21:30 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106240021.AA03140@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: another sed question

Assuming that I have both cat and uudecode how do I get this script to work
with the sed that you just uploaded to simtel?
#! /bin/sh
cat $* | sed '/^END/,/^BEGIN/d'| uudecode



Date:     Mon, 24 Jun 91 13:42:09 EDT
From:     David Kirschbaum
To:       mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Subject:  Re:  sed

>Here are the messages from Borland C++ 2.0 on the sed that you just put on
>simtel.  Do I need to worry about any of them and if so and you make diffs
>will you please send them to me?  Also can sed be a com file or do you know?

Well, the C++ complaints look *almost* like my TC 2.0 ones ...

>sedcomp.c:
>Warning sedcomp.c 221: Function should return a value in function main

Yeah, yeah, it wants a "return(0)" to keep from bitching.  The function
exits with other values BEFORE the very end, so that last return() isn't
needed and would just be wasted code.  But the compiler doesn't know that.

>Warning sedcomp.c 761: Function should return a value in function gettext

Ditto here.  Or stick in a return(0) to quiet the compiler if you don't
mind wasted code.

>Warning sedcomp.c 831: Constant out of range in comparison in function ycomp

This is line 831 in my source:
        for (c = 0; c < 128; c++)       /* fill in self-map entries in table */

Be damned if I can see a constant range problem here!  "c" is just a plain
old char!  I got no such warning myself.  I wonder if this is the same
line C++ talking about?  You'll have to chase it down via the Integrated
Environment's editor.

>sedexec.c:
>Warning sedexec.c 256: Function should return a value in function selected

Again, a bogus warning, doesn't matter.

>Warning sedexec.c 472: Possibly incorrect assignment in function dosub
Here's my line 472:
        for (rp = rhsbuf; c = *rp++;) {

I guess it looks a little flakey, but it worked okay on my system.

I don't plan to make any diffs unless a serious error appears on someone's
system, or they can show it's bogus code.  (You should've seen the
warnings *before* my tweaks!  Hah!  Yet the compiled code ran perfectly!)

Re it compiling as a .COM file .. I *guess* so .. didn't try myself, but
it should compile and link up as a tiny model.  The memory requirements
for sed's arrays and buffers aren't that great, after all.

You can but try!

David


Date:     Mon, 24 Jun 91 13:56:27 EDT
From:     David Kirschbaum
To:       mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Subject:  Re:  another sed question

>Assuming that I have both cat and uudecode how do I get this script to work
>with the sed that you just uploaded to simtel?
>#! /bin/sh
>cat $* | sed '/^END/,/^BEGIN/d'| uudecode

Hey, disclaimer here!  I'm no sed wizard, and never even tried to use it
before just recently (when the stupid AT&T Fortran-to-C translator
required it).  I'm just doing the port!

I *suppose* sed11 can be used as a pipe (although neither the sed11 man
file nor my BSD host's sed man file say anything about that). The problem
might be in the "quoted" parameter.

I tried a quoted string like yours above when trying to build the f2c
source, and sed11 coughed.  The line looked like this in the Makefile:
(those are the `backward` ASCII 96 quotes in case they don't make it
through your mailer)

         sed -e `s/#define/%token/` tokdefs.h >gram.in

I removed the quotes, and used:

        sed -e s/#define/%token/ tokdefs.h >gram.in

and it worked perfectly.

So you might try the same line, but without the quotes.

David


Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Mon, 24 Jun 91 16:39:20 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106242139.AA18030@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: sed and makefile

I don't use the integrated environment of TC or BC++ very much and am having
trouble converting your configuration file.  Could you tell me the options in
TC that you used to compile sed so that I can create a makefile for it?



Date:     Tue, 25 Jun 91 11:34:26 EDT
From:     David Kirschbaum
To:       mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Subject:  Re:  sed and makefile

>I don't use the integrated environment of TC or BC++ very much and am having
>trouble converting your configuration file.  Could you tell me the options in
>TC that you used to compile sed so that I can create a makefile for it?

Well, let's see:
  -A    Source/ANSI keywords only...On   (I think)
  -a    Code generation/Alignment...Word
  -C-   Source/Nested comments...Off (default)
  -d    Code generation/Merge duplicate strings...On
  -f    Code generation/Floating point...Emulation (default)
  -K    Code generaton/Default char type...Unsigned
  -k-   Code generation/Standard stack frame...Off
  -ms   Model...Small
  -N-   Code generation/Test stack overflow...Off (default)
  -r    Optimization/Use register variables...On (default)
  -v-   Debug/Source debugging...Off (default)

Optimization can be set any way you want, really.
Ditto with Errors (I usually turn *everything* on).
I leave all the Names (segments) alone (default).
Re floating point:  I don't think sed uses any, but I leave it set to
Emulation (default) just in case.  (Nothing'll be brought in from the
libraries if not required.)

I think this oughtta do you.  I put some redundant (default) switches
above just so you'd know they'd been considered.  And you can't depend on
"defaults" with TC, since no telling what was reset during installation.

Hope this helps.

David


Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Mon, 24 Jun 91 16:55:44 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106242155.AA18556@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: more on sed

I'd really like to get sed working with BC++ 2.0.  The command
sed 1,5d filename
should print the file denoted by filename except for the first 5 lines and
the one that you distributed does, but the one compiled with BC++ 2.0 prints
the entire file as if the "1,5d" command didn't exist.  I can't see and
therefore don't know how to use the integrated debuger or Turbo Debuger, but
could send you a binary created by BC++ 2.0 with debugging information if that
would help you.  Also maybe you know someone with either TC++ 1.0 1.01 or
BC++ 2.0 that can try to compile sed and figure out the problem.  I don't know
if it works with TC++ 1.0 or TC++ 1.01, but I am having a problem with BC++
2.0.  Hey maybe we will have the luck of infozip and one of can either
figure it out or knows someone who can figure it out because I'm stumped.



Date:     Tue, 25 Jun 91 11:41:39 EDT
From:     David Kirschbaum
To:       mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Subject:  Re:  more on sed

>I'd really like to get sed working with BC++ 2.0.  The command
>sed 1,5d filename
>should print the file denoted by filename except for the first 5 lines and
>the one that you distributed does, but the one compiled with BC++ 2.0 prints

Yep, the command works just fine on my system with sed11 (as compiled with
TC v2.0).

>the entire file as if the "1,5d" command didn't exist.  I can't see and

I have *no* idea why the BC++ 2.0 version doesn't work.

>therefore don't know how to use the integrated debuger or Turbo Debuger, but
>could send you a binary created by BC++ 2.0 with debugging information if that
>would help you.  Also maybe you know someone with either TC++ 1.0 1.01 or
>BC++ 2.0 that can try to compile sed and figure out the problem.  I don't know
>if it works with TC++ 1.0 or TC++ 1.01, but I am having a problem with BC++
>2.0.

I don't know that a binary created by BC++ 2.0 with debugging information
would help at all.  (I have no assurances that my Turbo Debugger would
work with later versions.)  Plus (although I can see) I have little use
for, and seldom use, Turbo Debugger.

I don't have a single soul around here that does any significant TC
programming!  (Amazing, but then this *is* the "Howling Wilderness of
Computerdom.")  So, no versions of TC++ or BC++ about that I could go and
compile on.

Maybe it's time to field the problem to one of the newsletters, eh?  I
don't subscribe to "Info-C" (if there is such a thing).

Tell you what:  hold off for a few days until a couple of the Info-ZIP
guys get back from Minnesota, vacation, etc., and I'll throw it at them.
I believe Cave Newt has a TC++ or some such.  I'll send the source off to
them, with the problem description, and we can see what they come up with.

It certainly is curious that we've found such an obvious TC-BC
incompatibility!

David


Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Tue, 25 Jun 91 14:43:29 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106251943.AA10493@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: Re:  more on sed

I usually send stuff to Mark so maybe you can also send it to him when he 
gets back.



Return-Path: <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Date: Tue, 25 Jun 91 14:45:25 -0500
From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
Message-Id: <9106251945.AA10551@bsu-cs.bsu.edu>
To: kirsch@usasoc.soc.mil
Subject: Re:  sed and makefile

I use those exact switches with BC++ 2.0 and this is very strange.  I'll be
glad when one of the infozipers solves it.



Date: Mon, 16 Sep 91 11:42:39 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109161842.AA26552@elm.sdd.trw.com.sdd.trw.com>
To: mdlawler@bsu-cs.edu
Subject: SED for the PC
Cc: kirsch@usasoc.soc.mil

 Somehow or where I received a version of SED12. I wanted a version for
my pc and it seems appropriate.  I discovered however that the code would not 
compile under BC++ 2.0 as advertised.  Mostly warning messages, but I hate warnings
anyway. I also discovered four serious errors. The errors are:
 *  the initialization for the variable 'delete' should be FALSE. Otherwise the
    first line will be marked deleted.

 *  The compiler got into an endless loop reporting an RE error.

 *  'genbuf' was only 71 bytes long, but was treated as if it was 4000 bytes long
 
After much screwing around I made the following modifications to sed.
If you are interested in my version of the source code please contact me.
at helman@elm.sdd.trw.com.


Changes made to SED:
  1. l command cleanup (indexing and quoting)
  2. first line problem (should have been delete FALSE) ****
  3. y command compile funny BC++ problem with chars and ints
  4. fixed `\' escapes in patterns
  5. fixed `\' escapes in rhs
  6. fixed `\' escapes in y strings 
  7. fixed `\' escapes in inserted text
  8. fixed `\' in sets  (all fixed by fixquote routine)
  9. RE bad looping on error message   *****
 10. reworked entire selected routine
 11. spaces after -e -f and nothing after -g -n
 12. errors to stderr and general error message fixups
 13. usage message when no args
 14. Make it compile under Sun Unix with minimum lint complaints
 15. Make it compile under BC++ 2.0   *****
 16. Fix recognition of last line to edit
 17. ; # and initial space clean ups
 18. No `\` escapes in file names or labels
 19. Last line may not have \n in commands
 20. 256 bit characters in all contexts
 21. Add + option to second address
 22. allow \{m,n\} RE's including after \1 as for *; + now \{1,\}
 23. allow \<  and \> RE's
 24. Genbuf now extremly long to hold everything(was 71!!) *****
 25. Misc cleanups for n, N, & D commands range checks cleaned up.
 26. Reset inrange flag on exit from {} nesting
 27. Blanks after : (actually all of label processing fixed up
 28. - in character character sets now works for ranges
 29. g flag in s command cleanup used ++ instead of = 1
 30. made separate -e and -f input routines and fixed up gettext
 31. RELIMIT replaced by poolend  allows REs to be of any size
 32. \0 character is now an error in an RE body
 33. address of 000 now illegal
 34. trailing arguments of s command handled properly
 35. & substitutions fixed(previously could not escape)
 36. handling of lastre

I am not really much of a Unix or SED hacker, but am an old
SNOBOL, TRAC and other obscure text language hacker.  The code
for the pattern matching was excellent and I learned a lot from it.

Any way I hope to hear from you.

/s/ Howard Helman
    SEIDCON Inc.
I am on contract with TRW



Date:     Tue, 17 Sep 91 18:07:40 EDT
From:     David Kirschbaum
To:       James McNealy <sasjcm@unx.sas.com>
Subject:  Re:  sed12.zip from simtel20 (fwd)

>> I received sed12.zip from simtiel20 and unpacked it. I found that
>> compile.h missing. Was this intentionally left out of the zip file?
>  ^^^^^^^^^
>  Please excuse my typo. This should read compiler.h
>
>> If not can it be sent to me?
>> I do appreciate you responding at your earliest possible convenience.

compiler.h was not left out of the package:  it never came *with* the
package!

I was only working in Turbo C and had no need for compiler.h.

Checking up on my Vax BSD 4.3 host, I don't find a compiler.h in my
/usr/include directory either.

So I donno *what* that compiler.h is all about.  I suggest you comment it
out, compile, and see what coughs!

Incidentally, yet another user has done some tweaks on sed12.  He reports
a number of bugs fixed, but I haven't had a chance to get his code yet and
examine the changes.  So be informed there may be yet another update in
the near future.

David Kirschbaum
Toad Hall
kirsch@usasoc.soc.mil


Date:     Tue, 17 Sep 91 18:13:42 EDT
From:     David Kirschbaum
To:       helman@elm.sdd.trw.com (Howard L. Helman)
cc:       mdlawler@bsu-cs.edu
Subject:  Re:  SED for the PC

> Somehow or where I received a version of SED12. I wanted a version for
>my pc and it seems appropriate.  I discovered however that the code would not
>compile under BC++ 2.0 as advertised.  Mostly warning messages, but I hate warnings
>anyway.

I didn't have Borland C++, so couldn't test it.

>After much screwing around I made the following modifications to sed.
>If you are interested in my version of the source code please contact me.
>at helman@elm.sdd.trw.com.

I'd like much to get your new source to check it out in my TC 2.0
environment.  Can you give me an anonymous ftp pointer, or EMail it to me
in uuencoded or ship'ed archive (.zip, .arc, or .tar.Z format) please?

David Kirschbaum
Toad Hall
kirsch@usasoc.soc.mil


Date:     Fri, 20 Sep 91 15:15:30 EDT
From:     David Kirschbaum
To:       Howard L. Helman (sed prj) <helman@elm.sdd.trw.com>,
          Michael D. Lawler <bsu-cs!mdlawler@iuvax.cs.indiana.edu>
Subject:  sed14

Howard,

Notice the different address for mdlawler.  I *think* this one is the
latest for him.)

I had problems with your source and my raggedy old TC 2.0: mostly a bunch
of warnings, plus different output from a wee little test I had lying
about.  (Yours did it right, mine did it wrong.)

I expanded some of your code and made some little changes to keep TC 2.0
from complaining so much.  (So if you'd check on your BC++ or whatever to
be sure I didn't break it, ok?)

Also, turns out char type is critical when compiling:  this sucker wants
*signed* chars!  Before I'd always been using my default unsigned char
config, so the last line in the little ctrans test was going away.

If all looks and runs ok, we're about ready to field this sucker, eh?
Give me the OK if it still looks good with "modern" compilers and I'll
distribute it here and there (SIMTEL20 if it's still accepting uploads,
comp.sources.misc, and wherever).

Oh, are you confined to .zoo archives for a reason?  Or only a principle?
If you don't have or don't wish to use the PKWare family, we *do* have our
handy_dandy generic unzip and zip utilities from the Info-ZIP project
available for use.

zoo isn't a problem (since I do have it on my PC) .. just wondered.
I'll put it all in a .zip before uploading to SIMTEL20, and to a
compressed shar format to meet comp.sources.misc's requirements.

I haven't tried compiling and testing it up on my Vax BSD 4.3 host.  Do
you think that's necessary/appropriate?  After all, it's the PC
environment that needs this sucker the most.

Regards,
David Kirschbaum
Toad Hall
kirsch@usasoc.soc.mil


Date: Fri, 20 Sep 91 15:37:05 EDT
From: David Kirschbaum <kirsch>
Message-Id: <9109201937.AA03978@sarofs>
To: kirsch
Subject:  MAIL SEND STATUS MESSAGES

To: helman@elm.sdd.trw.com
To: mdlawler@bsu-cs.bsu.edu
Subject: DATA FILE INCLUDED - \temp\sed14.zoo
MESSAGE SUCCESSFULLY SENT



Date: Fri, 20 Sep 91 13:19:19 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109202019.AA01028@elm.sdd.trw.com.sdd.trw.com>
To: kirsch@usasoc.soc.mil
Subject: Reply on sed14

 David,
 

Thanks for your prompt response.  I am still trying to send the
program to Lawler. All my mail has come back recently.

Sorry to hear that there were warnings.  I compiled using
bcc with all warnings turned on and only got the
pia warning prob incorrect assignment.  I always turn
this off with a -w-pia or equivalent.

I always use signed characters an old habit from my pdp 11 days.
My personnal computer was a pdp/11 until two years ago.

It seems to compile both modern (ANSI) and old style (sun unix) for
me.  

I used zoo because it is the most compatible for me.  The sun station
I connect to the network has zoo not zip.  Using zoo I can test the
source both compressed and regular on both systems.   Feel free
to repack with zip.

By the way, I found a small bug.  It is related to the one I found and
fixed having to do with no addresses on a { command.  It seems that
the ! operator does not work for command with no addresses.  Why one
would want to do this is a mystery to me, but unix sed allows it.  Also
the } command allows for addresses a nono.

The following should fix the problem.  It is not the best solution
but I with you lets get this sucker moving before the end of
the fiscal year.


to fix ! to work on all commands and no addresses on }:

in SEDCOMP.C : delete lines 292 and 293 and add the || stuff on 301
  292:                  if(!cmdp->addr1)   /* no address is special*/
  293:                     cmdp->command=(cmdp->flags.allbut?BCMD:NOCMD);

  301:                  if(cmdp->addr1||cmdp->flags.allbut) ABORT(AD1NG);/*not allowed*/
                                      --------------------
in SEDEXEC.C  remove first test on line 133 and add test on  line 159
  133:                    if (ipc->addr1 && !selected(ipc)) {ipc++;continue;}
                              xxxxxxxxxxxxxx 
  159:     if(ans=(!*p1||ipc->flags.inrange)) ;
                  -------                  -

h**2 
Howard Helman
helman@elm.sdd.trw.com



Date:     Mon, 23 Sep 91 10:36:08 EDT
From:     David Kirschbaum <kirsch@maxemail>
To:       helman@elm.sdd.trw.com (Howard L. Helman)
Subject:  Re:  Reply on sed14

>Thanks for your prompt response.  I am still trying to send the
>program to Lawler. All my mail has come back recently.

Maybe the new address will work better. It's the one he uses for his
Info-ZIP correspondence, and that's pretty current.

>Sorry to hear that there were warnings.  I compiled using
>bcc with all warnings turned on and only got the
>pia warning prob incorrect assignment.  I always turn
>this off with a -w-pia or equivalent.

I usually find that "probably incorrect assignment" is usually trying to
tell me something!  I then break down the questionable statement until it
quits complaining.  Never hurt me yet, although it might not be the most
terse or efficient programming style.

>I always use signed characters an old habit from my pdp 11 days.
>My personnal computer was a pdp/11 until two years ago.

Funny .. and I default to unsigned.  Forget why.

>By the way, I found a small bug.  It is related to the one I found and
>fixed having to do with no addresses on a { command.  It seems that
>the ! operator does not work for command with no addresses.  Why one
>would want to do this is a mystery to me, but unix sed allows it.  Also
>the } command allows for addresses a nono.

Roger, will patch it in to my version.  Think we should field this sucker?

David


Date: Fri, 20 Sep 91 13:59:36 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109202059.AA01072@elm.sdd.trw.com.sdd.trw.com>
To: kirsch@usasoc.soc.mil
Subject: Quick look at your changes

David:

I just looked at the sed14 you sent me.  
Sorry about the terse code an old habit
I pay for my toner and paper and other
supplies so I tend to conserve space on
my listings.  Also I cannot understand
code longer than 25 lines these days since
that is my screen size. 

Anyway, Please just change as you feel is necessary
the lines to increase your readability.  Also just
change the if(a=y) and if(!(a=y)) contructs as you
wish.  The setting of -w-pia will correct these.
I prefer not to have so many #ifdef s et al so
I guess I do not understand your OLDSTUFF, I know C 
coders always used to do it without the explicit zero
test in the old days. 

 Just recode the lines if you have a problem.  Please
explain what broken means in your comment.  If
sounds serious but the changes seem minor.  Particularly
if only a warning.  All newer borland compilers
allow the #pragma  directive to turn the warning
off and force signed characters.  I do not have
the exact syntax here at work so I won't try
to quote the exact line.  I will get it for you
on Monday.

Anyway it looks ok.
h**2
helman@elm.sdd.trw.com




Date:     Mon, 23 Sep 91 10:43:25 EDT
From:     David Kirschbaum <kirsch@maxemail>
To:       helman@elm.sdd.trw.com (Howard L. Helman)
Subject:  Re:  Quick look at your changes

>Anyway, Please just change as you feel is necessary
>the lines to increase your readability.  Also just
>change the if(a=y) and if(!(a=y)) contructs as you
>wish.  The setting of -w-pia will correct these.

Funny TC 2.0 doesn't like that if(!(a=y)) construct,
since it's so common.  But it sure doesn't!  Get a
warning every time!

>I prefer not to have so many #ifdef s et al so
>I guess I do not understand your OLDSTUFF,

I do that #ifdef OLDSTUF so I can see what the code
*used* to look like before I tweaked it.  That way,
if my tweak was wrong, we can go back to the original.
In a final version (e.g., once the tweaks are proven
to be better, correct, whatever), the OLDSTUF gets
ripped out.

>explain what broken means in your comment.  If
>sounds serious but the changes seem minor.  Particularly
>if only a warning.

Broken means, in the little test file I included, there
was a significant difference in the output.  Your (correct)
executable correctly reformats the last entry in the test
Pascal file (a function).  My version (with unsigned chars)
would NOT convert it (producing a weird "x 1 x 2" output line
with x being an IBM PC graphics character).  Changing to signed
chars fixed that .. but how was I to know that until I'd chased
down all the other warnings first?

>  All newer borland compilers
>allow the #pragma  directive to turn the warning
>off and force signed characters.  I do not have
>the exact syntax here at work so I won't try
>to quote the exact line.  I will get it for you
>on Monday.

Not to bother:  I knew that, and once I figured that
might be the difference, I just switched to signed chars.
In a TC 2.0 TCC command line, there's also a switch .. and
I'll be constructing a TCC command line for your README file
Real Soon Now (before the official fielded version).

David


Message-Id: <9109202135.AA17459@usasoc.soc.mil>
Date: Fri, 20 Sep 91 13:41:47 -0400
From: bsu-cs!mdlawler@iuvax.cs.indiana.edu (Michael D. Lawler)
To: usasoc.soc.mil!kirsch@iuvax
Subject: Re:  Keith Petersen

No you don't have to.  Thats enough info.  Did you get a modified copy of
your sed program?  You were supposed to be getting one, but I can't
remember the guys name that sent it to you.  If you have it can you forward
it to me?  Thanks!



Message-Id: <9109202335.AA18770@usasoc.soc.mil>
Date: Fri, 20 Sep 91 17:53:42 -0400
From: bsu-cs!mdlawler@iuvax.cs.indiana.edu (Michael D. Lawler)
To: usasoc.soc.mil!kirsch@iuvax
Subject: Re:  sed14

I got it thanks!



Date:     Mon, 23 Sep 91 10:46:31 EDT
From:     David Kirschbaum <kirsch@maxemail>
To:       Howard L. Helman (sed prj) <helman@elm.sdd.trw.com>
Subject:  Re:  sed14

Ok, the new lawler address is working.  He's now in the loop with the new
code.  I'll forward your latest changes/msgs to him as well.

David
----- Forwarded Message Start

Message-Id: <9109202335.AA18770@usasoc.soc.mil>
Date: Fri, 20 Sep 91 17:53:42 -0400
From: bsu-cs!mdlawler@iuvax.cs.indiana.edu (Michael D. Lawler)
To: usasoc.soc.mil!kirsch@iuvax
Subject: Re:  sed14

I got it thanks!


----- End of Forwarded Message


Date: Mon, 23 Sep 91 09:24:22 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109231624.AA02072@elm.sdd.trw.com.sdd.trw.com>
To: kirsch@usasoc.soc.mil
Subject: Updates to SED14
Cc: bsu-cs!mdlawler@iuvax.cs.indiana.edu

David, Mike and any others:

I finally got around to testing the sed14 version.  I was sorry
that my updates I sent you on Friday were incorrect.  I thought
I tested them but I do this at night at home and I must have  been
asleep.  I don't feel as bad after finding the mistranslation in the
N command.  I still find it easier to read and understand without the
explicit test but any consistent style is fine.  So I am sending you
these fixes and an updated version of the documentation in zoo format.


As promised the inline pragmas to allow compilation are:
#pragma warn -pia    /* silence prob incorrect assignment */
#pragma option -K-   /* signed characters*/

These work with TC++ and BC++.  I am surprised that you are
still using TC2.  I got off of it over a year ago.  It was
a good system but the newer compilers are great especially 
for the upgrade prices.  I found the C++ set to be a complete
ANSI compiler and although there are a few bugs in it, most
of the problems with TC2 have been fixed. 

h**2

These changes have been extensively tested, and fix the following:

   ! processing with no addresses
   } command with !
   N command error
   * and + normal if not at repeatable spot big error  by me
   \{ processing  m processing error and 0 allowed
   A clean up in sedcomp 
   A recommendation for D command

Fixes in SEDCOMP.C:
 clean up ! processing  delete lines 313 and 314
  312:            case '{':                     /* start command group */
  313: xx               if(!cmdp->addr1)   /* no address is special*/
  314: xx                  cmdp->command=(cmdp->flags.allbut?BCMD:NOCMD);
  315:                  cmdp->flags.allbut = !cmdp->flags.allbut;

 do not allow ! option } commands  add test to line 322
  321:            case '}':                            /* end command group */
  322:                  if (cmdp->addr1||cmdp->flags.allbut)
                                       --------------------                          

 Bug in processing * + in REs  move assmgt from 465 to after 467, 473, 482,
    and 485.  Fix typo on 478 and 502.  This was a biggie
  464:            switch (c) {
  465:                 case '\\':lastep=0;
                                 xxxxxxxxx                                      
  466:                  if ((c = *cp++) == '(') {  /* start tagged section */
  467:                    if (bcount >= MAXTAGS) return 0;
                          lasetep=0;
                          ++++++++++

  473:                    if (brnestp <= brnest) return 0;/* extra \) */
                          lastep=0;                        
                          +++++++++
  474:                    *fp++ = CKET;                 /* enter end-of-tag */

  477:                    break;}
  478:                  else if(c=='{'){if(!lastep) return 0; /* rep error*/
                                                **
  479:                    *lastep|=MTYPE; lastep=0;

  482:                  else if(c=='<'){   /*begining of word test*/
                          lastep=0;
                          +++++++++
  483:                    *fp++=CBOW;
  484:                    break;}

  485:                  else if(c=='>'){/*end of word test*/
                          lastep=0;
                          +++++++++     
  486:                    *fp++=CEOW;
  487:                    break;}

  501:                 case '+':        /* 1 to n repeats of previous pattern */
  502:                  if(!lastep)   goto defchar;
                                **
  503:                  *lastep|=MTYPE; lastep=0; *fp++=1;*fp++=0xFF;
 

 Bug in processing \{ expressions delete line 547; This was removed once
 also add test on 549 to disallow 0 times.
  546:  static int processm(Void) {int i1=0,i2=0;
  547:    cp++; /*move past bracket*/
          xxxxxxxxxxxxxxxxxxxxxxxxxxx
  548:    while(isdigit(*cp))i1=i1*10+*cp++-'0';
  549:    if(i1<=0||i1>255)return 0;
             -------
  550:    *fp++ = (char)i1;Bug fixes for SEDEXEC.C

 I think the correct way to handle D commands (after rereading the Unix stuff)
 is to change line 130 to the following.  I.e. after a D start over without
 a line read.  Any Unixers got any ideas???  I did not make this change.
      /*while(cdswitch||spend=getline(linebuf)!=NULL){ */ /* v1.5 if approved*/
  130:       while( (spend=getline(cdswitch?spend:linebuf))!= NULL){ /* v1.4 */

 Exec fix for ! commands with no address delete test from line 137
  137:                    if (ipc->addr1 && !selected(ipc)) {ipc++;continue;}
                              xxxxxxxxxxxxx              

There appears to be no reason for the test on line 145 just do the assmnt
  145:                       if ((ipc = ipc->u.link) == 0) {ipc = cmds;break;}}
                             xxxxx                 xxxxxxxxxxxxxxxxxxxxxxxxxx x

The final exec fix for ! with no address add the following before line 169
           if(!p1)return !ipc->flags.allbut;
           +++++++++++++++++++++++++++++++++ 
  169:     if( (ans=ipc->flags.inrange) != 0) ; /* v1.4 */

 Fix the `oldstuf' stuff for a correct test  in an N command.
 I highly recommend only one form.   I prefer mine because of the
 error here but after the fix the explicit test version is ok by me
  467:  #ifdef OLDSTUF  /* v1.4 */
  468:                     if(!(execp=getline(spend)))pending=ipc,delete=TRUE;
  469:  #else
  470:                    if( (execp=getline(spend)) == 0)        /* v1.4 */
                                    == not != !!!!!!!!!!!!!!!!!!!!
  471:                              pending=ipc,delete=TRUE;
  472:  #endif
  473:                          else pending=NULL,spend=execp;





Date:     Mon, 23 Sep 91 17:15:30 EDT
From:     David Kirschbaum <kirsch@maxemail>
To:       helman@elm.sdd.trw.com (Howard L. Helman)
cc:       bsu-cs!mdlawler@iuvax.cs.indiana.edu
Subject:  Updated sed15.zip release

I've posted all the new changes you sent (manually .. ugh ugh ugh:  if
this continues, we simply *must* get together on a diff and patch
routine!)  I *think* I have it all correct.

I've integrated the README's, added some historical stuff, etc.  Assembled
the various files (docs, TC v2.0-specific stuff), etc. into sub-ZIPs.
Cleaned out the old #ifdef OLDSTUF from the source (since you've debugged
my hacks, right?) .. and we should be about ready to go to press.

I'm sending along sed15.zip separately (uuencoded).  Michael, I'm not
sending it to you just yet (since there may still be some minor
corrections).  If all is approved (or after the next batch of changes),
I'll update you, ok?

If this version meets with your approval, Howard, I can upload it to
SIMTEL20 to replace the older SED12.ZIP.  We can also send it on to
comp.sources.misc on the Usenet side of the world, since this is pretty
nice portable code.  Might even give gnused some competition .. or at
least prompt someone to maybe attempt to reconcile this stuff!  But not
me, boy:  I'm getting *out* of this sed business!   Been *way* over my
head for weeks now! :-)

Regards,
David


Date: Mon, 23 Sep 91 14:24:34 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109232124.AA02729@elm.sdd.trw.com.sdd.trw.com>
To: bsu-cs!mdlawler@iuvax.cs.indiana.edu
Subject: Updated Source for sed
Cc: kirsch@usasoc.soc.mil



Ok guys if you want it is my updated source as per
my previous communication.  There are two additional changes
made in sedexec.c to correctly fix the D command.  I did some
tests on Sun4 Unix and these changes appear to make the 
DOS sed act exactly like Unix sed.
h**2

---------------CUT HERE-------------------------------------
begin 644 hhsednew.zoo
[extracted]



Date: Mon, 23 Sep 91 14:45:24 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109232145.AA02876@elm.sdd.trw.com.sdd.trw.com>
To: kirsch@usasoc.soc.mil
Subject: Re:  Updated sed15.zip release

Well as you may have gotten by now is my updated source as per Michael.
In any case I recommend the fix for the D command my original fix needs
some () in it.  And I am done with this sucker. I was fun and it took
more effort than I thought but hopefully the world will have a better
sed for it.  

See you around the net
h**2



Message-Id: <9109240450.AA21922@usasoc.soc.mil>
Date: Mon, 23 Sep 91 23:04:54 -0400
From: bsu-cs!mdlawler@iuvax.cs.indiana.edu (Michael D. Lawler)
To: usasoc.soc.mil!kirsch@iuvax
Subject: Re:  Updated sed15.zip release

You guys can decide who is to send it to me when sed 1.5 is finished.  Thanks!



Date:     Mon, 23 Sep 91 18:12:00 EDT
From:     David Kirschbaum <kirsch@maxemail>
To:       helman@elm.sdd.trw.com (Howard L. Helman)
cc:       bsu-cs!mdlawler@iuvax.cs.indiana.edu
Subject:  Re:  Updated Source for sed

>Ok guys if you want it is my updated source as per
>my previous communication.  There are two additional changes
>made in sedexec.c to correctly fix the D command.  I did some
>tests on Sun4 Unix and these changes appear to make the
>DOS sed act exactly like Unix sed.
>h**2

Sigh .. I didn't expect more changes so soon!  Please throw away the
sed15.zip I just sent you (should've made it a .zoo, come to think of it,
for your examination anyway) .. I'll post these changes and send the new
zip15.zoo to you for your approval, ok?

The .zoo'll probably not have the documentation (since that's exactly as
you sent it to me).  Just the source, README, etc.

David

