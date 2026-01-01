Return-Path: <helman@elm.sdd.trw.com>
Received: from elm.sdd.trw.com.sdd.trw.com by deneva.sdd.trw.com (4.1/SMI-4.0 TRW 1.8)
        id AA16853; Mon, 30 Sep 91 13:09:46 PDT
Received: by elm.sdd.trw.com.sdd.trw.com (4.1/SMI-4.1)
        id AA10242; Mon, 30 Sep 91 13:09:55 PDT
Date: Mon, 30 Sep 91 13:09:55 PDT
From: helman@elm.sdd.trw.com (Howard L. Helman)
Message-Id: <9109302009.AA10242@elm.sdd.trw.com.sdd.trw.com>
To: kirsch@usasoc.soc.mil
Subject: My latest sed

David,

I am sending herein a zoo form of my latest sed.  This should fix
the following: 
        1. Clean up of execute() for no gotos
        2. Problem with n N D commands at EOF
        3. adds #n first comment == -n option
        4. typo in SKIPWS    (actually not a problem its always called with cp)

I do use diff on Unix and fc on DOS to check and document differences.  
I gave you an edited commented version for your analysis.  I find I have
to struggle with the outputs of either program to determine exactly what
has changed, and of course it can not tell me why.

I am sending Lawler a copy of the source in straight ascii as he requested.  It
is the same as this zoo format.

I would like a copy of the final distribution.  My version is probably different
from yours and I would like to get line numbers in sync again.

h**2


--------------CUT HERE---------------------------------------
begin 644 HHSED15A.ZOO
