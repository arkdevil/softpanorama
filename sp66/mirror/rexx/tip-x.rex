From ankh.iia.org!uunet!newsfeed.ACO.net!osiris.wu-wien.ac.at!usenet Mon Aug 22 20:45:43 1994
Path: ankh.iia.org!uunet!newsfeed.ACO.net!osiris.wu-wien.ac.at!usenet
From: Rony.Flatscher@wu-wien.ac.at
Newsgroups: comp.lang.rexx
Subject: Re: Numeric to alphabets relation
Date: 22 Aug 1994 21:29:33 GMT
Organization: University of Economics and Business Administration
Lines: 28
Distribution: inet
Message-ID: <33b5bt$aup@osiris.wu-wien.ac.at>
References: <1994Aug22.202641.20733@tron.bwi.wec.com>
Reply-To: Rony.Flatscher@wu-wien.ac.at
NNTP-Posting-Host: wi-pc1.wu-wien.ac.at
X-Newsreader: IBM NewsReader/2 v1.02

In <1994Aug22.202641.20733@tron.bwi.wec.com>, srk@sun27 (Srinivas Kompella) writes:
>
>Hello,
>	I am using OS/2 2.1.1, Rexx 2.0. I have a small problem.
>
>if counter = 1 then output_file = 'A.dat'
>if counter = 2 ...................'B.dat'
>                                   :
>                                   :
>if counter = 26 then output_file= 'Z.dat'
>
>All I need is a correspondence between the numbers and the alphabets.
>
>Is there a simple way to do it?
>
>Thanks in advance for your response.
>

Srinivas:

You could try:

     alphabet = XRANGE("A", "Z")                /* produce alpha-string */
     output_file = SUBSTR(alphabet, counter, 1) || ".dat"

---rony



