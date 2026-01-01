Return-Path: <helman@elm.sdd.trw.com>
Received: from elm.sdd.trw.com.sdd.trw.com by deneva.sdd.trw.com (4.1/SMI-4.0 TRW 1.8)
	id AA05375; Mon, 23 Sep 91 14:24:25 PDT
Received: by elm.sdd.trw.com.sdd.trw.com (4.1/SMI-4.1)
	id AA02729; Mon, 23 Sep 91 14:24:34 PDT
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
