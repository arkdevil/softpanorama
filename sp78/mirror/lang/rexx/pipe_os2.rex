Newsgroups: comp.lang.rexx
Date: Mon, 9 Oct 1995 10:19:00 EST
From: "Campbell, James A" <JCampbel@VITGSYSA.TELECOM.COM.AU>
Subject: Re: REXXPERTS: Multitasking/Piping with REXX into a program that
              uses stdin

>>I want to examine the standard input stream which is redirected from
>>some other program into the REXX script I am writing.  While I examine,
>>I put the lines I processed on a FIFO queue I create.
>>
>>Somewhere in the stream, I have the information I was looking for, and
>>want to execute a program, piping the FIFO into that.  I want to start
>>that program with 'detach' so that I can continue copying the stdin of
>>the script into the FIFO queue that the other program is going to read
>>as stdin.
>>
>>Here is what it will look like..
>>
>>some stream | rexx script ->FIFO
>>
>>detach program <FIFO:
>>

As a non-REXXPERT, have you considered using a named pipe instead of a
queue?


James Campbell
Telstra Corporation
JCampbel@VITGSYSA.TELECOM.com.au
+61 3 9295 4649

