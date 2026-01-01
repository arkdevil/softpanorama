From: rmarks@ksp.unisys.com (Richard Marks)
Newsgroups: comp.binaries.ibm.pc
Subject: v01i003: partitn, mainpulates partition info on hard disk v2.0
Summary: partitn.arc, mainpulates partition info on hard disk v2.0
Date: 8 Nov 88 17:19:49 GMT
Approved: dhesi@bsu-cs.UUCP

Posting-number: Volume 01 Issue 003
Originally-from: rmarks@ksp.unisys.com (Richard Marks)
Submitted-by: rmarks@ksp.unisys.com (Richard Marks)
Archive-name: partitn/part1

Below is a very valuable program for fixing up and moving around
disk boot records and partition boot records.  This program permits
updating these records and saving them off to files.  It also lets you
do some simple editting on them.  We have found it is an invaluable
utility to help get us out of various partition configuration jams.

Obviously this sort of program, if used improperly can blow the boot
record, if not the entire hard disk; so I have the usual disclaimers.
(However no-one has ever done this yet; the program has a lot of checks
and asks for validation before overwritting anything critical.)

It includes Turbo Pascal 4.0 source.

Richard Marks
rmarks@KSP.unisys.COM

[
This is version 2.0.  Not having done much backing up lately, I decided
not to test this program on any of my hard disks.  Use at your own
risk.

-- R.D.
]
