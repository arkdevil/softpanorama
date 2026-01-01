Return-Path: <robin@utafll.uta.edu>
Received:  by utafll.uta.edu (4.1/25-eef)
        id AA17356; Fri, 21 Jun 91 14:07:05 CDT
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
