From roe2@ellis.uchicago.edu  Sun Nov 08 02:11:29 1992
Newsgroups: comp.compression,alt.sources
Path: vipua!csoft!kiae!fuug!mcsun!uunet!haven.umd.edu!darwin.sura.net!zaphod.mps.ohio-state.edu!sol.ctr.columbia.edu!eff!news.oc.com!spssig.spss.com!uchinews!ellis!roe2
From: roe2@ellis.uchicago.edu (Cave Newt)
Subject: archiver magic entries (was: Re: Need a program that determines...)
Message-ID: <1992Oct21.012923.23008@midway.uchicago.edu>
Followup-To: comp.compression
Sender: news@uchinews.uchicago.edu (News System)
Reply-To: roe2@midway.uchicago.edu
Organization: University of Chicago
References: <1992Sep22.163744.107402@ns1.cc.lehigh.edu> <rol-230992181804@90.222.1.80> <Bvs4tF.1A4@usenet.ucs.indiana.edu>
Date: Wed, 21 Oct 1992 01:29:23 GMT
Lines: 148
Status: R

I'm afraid I missed the original article, but if you're on Unix
you can use the "file" program together with the "magic" entries
appended below.  Note that there are all sorts of inconsistencies
in various OS's "file" programs; some accept octal constants in
string values, some don't, some have bugs, some won't check the
system /etc/magic file after checking an auxiliary one, and @#($*!
Ultrix requires a bogus extra field between what are normally the 
third and fourth columns (rendering it *completely* incompatible
with every other machine I've used).  Sigh.

Anyway, this needs improvement, but it's good enough for a first
cut.  Be prepared to edit.

Cheerios,
  Greg

[Edit your newsgroups line if follow-up is not compression-related.]


# Newtware Specials:  compressed and PC-based files.
# Greg Roelofs, 15 May 92.  Most recent revisions:  23 Sep 92.
#
0	string		MZ			MS-DOS executable
#
# >>>>> ARC <<<<<
#
0	string		\032\010		Arc archive
0	short		0x1a08			Arc archive
0	short		0x081a			Arc archive
#
# >>>>> LHARC/LHA <<<<<
#
2	string		-lh0-			Lharc 1.x archive
2	string		-lh1-			Lharc 1.x archive
2	string		-lz4-			Lharc 1.x archive
2	string		-lz5-			Lharc 1.x archive
#	[never seen any but the last:]
2	string		-lzs-			LHa 2.x? archive [lzs]
2	string		-lh -			LHa 2.x? archive [lh ]
2	string		-lhd-			LHa 2.x? archive [lhd]
2	string		-lh2-			LHa 2.x? archive [lh2]
2	string		-lh3-			LHa 2.x? archive [lh3]
2	string		-lh4-			LHa 2.x? archive [lh4]
2	string		-lh5-			LHa (2.x) archive
#
# >>>>> ZIP <<<<<
#
# [newer, smarter "file" programs]
0	string		PK\003\004		Zip archive
>4	string		\011			(at least v0.9 to extract)
>4	string		\012			(at least v1.0 to extract)
>4	string		\013			(at least v1.1 to extract)
>4	string		\024			(at least v2.0 to extract)
# [stupid "file" programs, big-endian]
0       long    	0x504b0304		Zip archive
>1	long		0x4b030409		(at least v0.9 to extract)
>1	long		0x4b03040a		(at least v1.0 to extract)
>1	long		0x4b03040b		(at least v1.1 to extract)
>1	long		0x4b030414		(at least v2.0 to extract)
# [stupid "file" programs, little-endian]
0       long    	0x04034b50		Zip archive
>1	long		0x0904034b		(at least v0.9 to extract)
>1	long		0x0a04034b		(at least v1.0 to extract)
>1	long		0x0b04034b		(at least v1.1 to extract)
>1	long		0x1404034b		(at least v2.0 to extract)
#
# >>>>> ZOO <<<<<
#
# [GRR:  don't know if all of these versions exist, or if some missing...]
0	string		ZOO 			Zoo archive
>4	string		1.00			(v%4s)
>4	string		1.10			(v%4s)
>4	string		1.20			(v%4s)
>4	string		1.30			(v%4s)
>4	string		1.40			(v%4s)
>4	string		1.50			(v%4s)
>4	string		1.60			(v%4s)
>4	string		1.70			(v%4s)
>4	string		1.71			(v%4s)
>4	string		2.00			(v%4s)
>4	string		2.01			(v%4s)
>4	string		2.10			(v%4s)
# [newer, smarter "file" programs]
>32	string		\001\000		(modify: v1.0+)
>32	string		\001\004		(modify: v1.4+)
>32	string		\002\000		(modify: v2.0+)
>70	string		\001\000		(extract: v1.0+)
>70	string		\002\001		(extract: v2.1+)
# [stupid "file" programs, big-endian]
>32	short		0x0100			(modify: v1.0+)
>32	short		0x0104			(modify: v1.4+)
>32	short		0x0200			(modify: v2.0+)
>70	short		0x0100			(extract: v1.0+)
>70	short		0x0201			(extract: v2.1+)
# [stupid "file" programs, little-endian]
>32	short		0x0001			(modify: v1.0+)
>32	short		0x0401			(modify: v1.4+)
>32	short		0x0002			(modify: v2.0+)
>70	short		0x0001			(extract: v1.0+)
>70	short		0x0102			(extract: v2.1+)
# [GRR:  the following are alternate identifiers]
#20	long		0xdca7c4fd		Zoo archive
#20	long		0xc4fddca7		Zoo archive
#
# >>>>> COMPRESS <<<<<
#
# [newer, smarter "file" programs]
# [GRR:  are the upper three bits (block size) ever different from 100?]
0	string		\037\235		compress'd file
>2	string		\211			(9 bits)
>2	string		\212			(10 bits)
>2	string		\213			(11 bits)
>2	string		\214			(12 bits)
>2	string		\215			(13 bits)
>2	string		\216			(14 bits)
>2	string		\217			(15 bits)
>2	string		\220			(16 bits)
# [stupid "file" programs, big-endian]
0	short		0x1f9d			compress'd file
>1	short		0x9d89			(9 bits)
>1	short		0x9d8a			(10 bits)
>1	short		0x9d8b			(11 bits)
>1	short		0x9d8c			(12 bits)
>1	short		0x9d8d			(13 bits)
>1	short		0x9d8e			(14 bits)
>1	short		0x9d8f			(15 bits)
>1	short		0x9d90			(16 bits)
# [stupid "file" programs, little-endian]
0	short		0x9d1f			compress'd file
>1	short		0x899d			(9 bits)
>1	short		0x8a9d			(10 bits)
>1	short		0x8b9d			(11 bits)
>1	short		0x8c9d			(12 bits)
>1	short		0x8d9d			(13 bits)
>1	short		0x8e9d			(14 bits)
>1	short		0x8f9d			(15 bits)
>1	short		0x909d			(16 bits)
#
# From: cameron@spectrum.cs.unsw.oz.au (Cameron Simpson)
#
0	string		GIF			GIF image archive 
>3	string		87a			- version %3s
>3	string		87A			- version %3s
>3	string		89a			- version %3s
>3	string		89A			- version %3s
0	long		0xffd8ffe0		JPEG image, big endian
0	long		0xe0ffd8ff		JPEG image, little endian
0	string		hsi1			HSI1 image (wrapper for JPEG?)


