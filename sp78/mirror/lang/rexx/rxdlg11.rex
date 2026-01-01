Newsgroups: comp.lang.rexx
Subject: Re: REXX as script lang from my appl. (o
From: jeff.glatt@horizonsbbs.com
Date: Wed, 27 Sep 95 17:12:00 EST

>How do applications use REXX for scripting?  I know how to write
>a dll of rx funcs for use in REXX, but what I really want to do
>is call the REXX interpretter from my (non-rexx) application and
>recieve the text back that REXX doesn't understand.

You're in luck. I made a freeware REXX DLL that can be used by any app
to easily add a "REXX environment" to that program. It's a bit
easier than rolling your own code, has documentation and simple
examples of a C app using the DLL, plus the scripts that you
launch inherit all of REXX Dialog commands, meaning that they can
create PM windows with PM controls and manage their own user
interface for such. (The only caveat there is that your app also
has to be a PM app). D/L RXDLG11.ZIP at:

ftp.servtech.com/pub/users/wraymond/os2midi

(I recommend that you also get FILERX11.ZIP if you want to fool with
device drivers from REXX)




