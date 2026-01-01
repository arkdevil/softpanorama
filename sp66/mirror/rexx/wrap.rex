From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!gatech!howland.reston.ans.net!EU.net!Austria.EU.net!newsfeed.ACO.net!osiris.wu-wien.ac.at!usenet Sun Aug 14 09:32:15 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!MathWorks.Com!news.duke.edu!news-feed-1.peachnet.edu!gatech!howland.reston.ans.net!EU.net!Austria.EU.net!newsfeed.ACO.net!osiris.wu-wien.ac.at!usenet
From: Rony.Flatscher@wu-wien.ac.at
Newsgroups: comp.lang.rexx
Subject: Re: Word wrap routine
Date: 11 Aug 1994 15:03:30 GMT
Organization: University of Economics and Business Administration
Lines: 119
Distribution: world
Message-ID: <32dek2$51a@osiris.wu-wien.ac.at>
References: <5f.379.293.0ND96878@runningb.com>
Reply-To: Rony.Flatscher@wu-wien.ac.at
NNTP-Posting-Host: wi-pc1.wu-wien.ac.at
X-Newsreader: IBM NewsReader/2 v1.00

In <5f.379.293.0ND96878@runningb.com>, joe.negron@runningb.com (Joe Negron) writes:
>Er> I need help with a word wrap routine. You know, if you're writing a
>  > sentence and reach the right margin, the whole word you were typing
>  > on is moved to the next line.
>Er> Some of you ARexx experts can probably help me.
>
>I don't know much about Rexx (which is why I'm here! :), but here is the
>algorithm expressed in BASIC:
>
>================================ Begin =================================
>DECLARE SUB WordWrap (Text$, Wide%, LeftMargin%)
>
>'***********************************************************************
>'* SUB WordWrap
>'*
>'* PURPOSE
>'*    Wraps a string of text on the screen.
>'***********************************************************************
>SUB WordWrap (Text$, Wide%, LeftMargin%) STATIC
>   Length% = LEN(Text$)
>   Pointer% = 1
>   LeftMargin% = 12
>
>   'scan a block of eighty characters backwards, looking for a blank
>   '  stop at the first blank, or if we reached the end of the string
>   DO
>      FOR X% = Pointer% + Wide% TO Pointer% STEP -1
>         IF MID$(Text$, X%, 1) = " " OR X% = Length% + 1 THEN
>            IF LeftMargin% THEN
>               LOCATE , LeftMargin%
>            END IF
>
>            PRINT MID$(Text$, Pointer%, X% - Pointer%);
>            Pointer% = X% + 1
>
>            WHILE MID$(Text$, Pointer%, 1) = " "
>               Pointer% = Pointer% + 1       'swallow extra blanks to
>            WEND                             '  the next word
>
>            IF POS(0) > 1 THEN               'if the cursor didn't wrap
>               PRINT                         '  next line
>            END IF
>
>            EXIT FOR                         'done with this block
>         END IF
>      NEXT X%
>   LOOP WHILE Pointer% < Length%
>END SUB 
>================================= End ==================================
>
>I think this is pretty clear - the only thing that may require some
>explanation if you don't know anything about BASIC is the POS() function
>(it reports the current cursor column).
>

A REXX-version could look like the following:

================================ Begin =================================
/*
   procedure to wrap words within given width, each line being ended 
   with the ASCII-CRLF-characters (x0D0A), if wrap occurs;

   consecutive blanks are replaced by one blank only;

   option "split" splits words which are longer than given width at
   exactly width; by default words longer than width are left unchanged
*/
WORDWRAP: PROCEDURE
   PARSE ARG string, width, option

   string = SPACE(string, 1)            /* change multiple blanks to one only */
   option = TRANSLATE(LEFT(option, 1))  /* get first letter of option, if any */

   newline = "0d0a"x                    /* ASCII-CRLF to split lines */
   wrapped = ""                         /* result of wrapped words */
   first = 1                            /* initial position to start looking */

   DO FOREVER
     IF LENGTH(string) - first < width THEN     /* rest fits into width */
        chunk = STRIP(SUBSTR(string, first))
     ELSE                                       /* find blank */
     DO
        /* find last blank within given width */
        pos = LASTPOS(" ", string, first + width)

        IF pos = 0 | pos < first THEN   /* no blank found, very long word */
        DO
           IF option = "S" THEN         /* split word to fit into width */
             pos = first + width - 1
           ELSE                         /* use any blank after width */
             pos = POS(" ", string, first)
        END

        IF pos = 0 THEN       /* still no blank found, rest has no blanks */
           chunk = STRIP(SUBSTR(string, first))
        ELSE                  /* use positions found while looking for blanks */
           chunk = STRIP(SUBSTR(string, first, pos - first + 1))
     END

     IF wrapped = "" THEN               /* no wrapped words as of yet ? */
        wrapped = chunk
     ELSE                               /* append CR-LF */
        wrapped = wrapped || newline || chunk

     IF LENGTH(string) - first < width | pos = 0 THEN
        LEAVE

     first = pos + 1                    /* next starting position for string */
   END

   RETURN wrapped                       /* return string of wrapped words */
================================= End ==================================

23 LOCs in BASIC
33 LOCs in REXX (doing a little more)

---rony



