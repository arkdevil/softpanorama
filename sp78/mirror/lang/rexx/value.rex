From: murray@lamar.colostate.edu
Newsgroups: comp.lang.rexx
Subject: Re: compound variable storage
Date: 9 Oct 1995 15:51:59 GMT

In <30798A2C@msmailv0.telecom.com.au>, "Campbell, James A" <JCampbel@VITGSYSA.TELECOM.COM.AU> writes:
>>>problem:  I'm trying to add numbers into a compound variable like:
>>>
>>>                alphabet.k.value = alphabet.k.value + 1
>>>
>>>k is a variable from 1 - 26 and a letter from the alphabet is stored
>>>(alphabet.1 = A, alphabet.2 = B, etc).  But everytime my program hits this
>>>section,
>>>I get a REXX0041, BAD ARITHMETIC CONVERSION.  How can this be?  Please
>e-mail
>>>me if you know why.  TIA

This is wacky.  Are you saying that you're trying to create a loop where
saying

DO K = 1 to 3
 alphabet.k.value = alphabet.k.value + 1
END

would translate to:
A.value = A.value + 1
B.value = B.value + 1
C.value = C.value + 1
?????????????????

If that is the case, then instead of saying alphabet.k.value I
think you'd have to say
ret_code = VALUE(alphabet.k'.value',alphabet.k'.value'+1)

But then again, I only started programming in REXX a week ago,
so remember free advice is worth what you paid for it.

Murray Todd Williams
TEAM OS/2

