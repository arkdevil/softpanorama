From ankh.iia.org!uunet!newsfeed.ACO.net!osiris.wu-wien.ac.at!usenet Fri Aug 26 08:31:16 1994
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



From ankh.iia.org!uunet!cs.utexas.edu!chpc.utexas.edu!news.utdallas.edu!feenix.metronet.com!usenet Fri Aug 26 08:31:37 1994
Newsgroups: comp.lang.rexx
Path: ankh.iia.org!uunet!cs.utexas.edu!chpc.utexas.edu!news.utdallas.edu!feenix.metronet.com!usenet
From: kf5mg@metronet.com
Subject: Re: Numeric to alphabets relation
Sender: usenet@metronet.com (UseNet news admin)
Message-ID: <CuyK4r.A1L@metronet.com>
Date: Mon, 22 Aug 1994 22:36:26 GMT
Lines: 29
Reply-To: kf5mg@metronet.com
References: <1994Aug22.202641.20733@tron.bwi.wec.com>
Nntp-Posting-Host: net234.metronet.com
Organization: ampr.org
X-Newsreader: IBM NewsReader/2 v1.02

In <1994Aug22.202641.20733@tron.bwi.wec.com>, srk@sun27 (Srinivas Kompella) writes:
>
>Hello,
>       I am using OS/2 2.1.1, Rexx 2.0. I have a small problem.
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


output_file = d2c(i+64) || '.dat'

will do what you want assuming that your on an ASCII system. d2c() converts
a number to a letter. Adding 64 to the base number will give you a capital
letter. You might want to add a datatype() check prior to the code to make
sure your data is numeric.

73's  de  Jack  -  kf5mg
Internet        -  kf5mg@kf5mg.ampr.org            -  44.28.0.14
                -  kf5mg@metronet.com              -  work (looking  for)
AX25net         -  kf5mg@kf5mg.#dfw.tx.usa.noam    -  home (817) 488-4386


