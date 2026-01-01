From: schlegel@crocker.com (Mark Schlegel)
Newsgroups: comp.lang.rexx
Subject: Re: OS/2 - accessing the clipboard
Date: 26 Oct 1995 00:09:02 GMT

Gary Mort (gam@panix.com) wrote:
: How(or can) I do the following:
: I want to grab some text information in the clipboard
: and stick it into a variable inside my rexx script.


use the rexx function package APMT available in the EWS
directory of the many os/2 ftp sites or in os/2 CD ROM's
like the one in OS/2 Warp Unleashed (the book).  The
file is APMTST.ZIP, 3-07-95, 192232 bytes on my cd-rom.

: In theory, when this script is run there should be 1 text
: line in the clipboard.  At this point I just want to get
: this working for the ideal case, the script being called
: only when the clipboard has the proper data.  After
: that works I will try to add in some error checking.

APMT lets you select a window via the SELECT_WINDOW() function,
SELECT_WINDOW("*") will select the foreground window,
or you can put a title in there (like "OS/2 Window").
Then you can use SYSMENU_SELECT("Copy All") to copy the
clipboard (in your case the text is there by some other
method).  I'm just trying to get this home ANY menu selection
can be assessed by SYSMENU_SELECT...Copy all, copy, mark, Close..etc
The actual getting of lines from clipboard is done with this:

===========
     if QUERY_CLIPBOARD_TEXT("clip") = 0 then
      do
        do i = 1 to clip.0
          short = space(clip.i,0) /* remove all spaces from clip.i*/
          if length(short) <= 1
           then nop
           else call lineout outfile, clip.i
        end
        call lineout outfile," "  /* put in a final empty line, as..*/
      end                        /* a field separator */
=====
Oddly, I can't find a single word in the apmt docs about
query_clipboard_text, I just copied how the author used
it in os2prt.cmd.  The above code has do i = 1 to clip.0
do a loop so that I can load "short" with the compressed line
space(clip.i,0) I do this because I just want lines clip.i that
actually have text.  I've discovered that the clipboard has
a weird behavior, if you get a blank line from it, it will
actually always have a 0D hex (Carriage Return) in it.
Hence when clip.i is a empty line & a CR will be in it,
space(clip.i,0) will retain that CR, then length(space(clip.i,0))
will = 1  not 0 since although not a visible char it is a char
that affects length.  So

if length(short) <= 1 then nop
  else call lineout outfile, line.i

will fill that file with that hours text copied from the clipboard.

Mark









