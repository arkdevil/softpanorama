From: jennann@ibm.net (Jennifer Anne Gardner)
Newsgroups: comp.os.os2.networking.tcp-ip,comp.os.os2.apps,comp.os.os2.misc,comp.os.os2.utilities,comp.os.os2.programmer.tools,comp.os.os2.mail-news,comp.lang.rexx
Subject: I DISAGREE, MIKE
Date: Wed, 18 Oct 95 19:41:00 GMT

Mike, I disagree.  Here are some of the utilities that I found in the
Surfboard beta package.  Everything is written in REXX (except the magic
DLL) and you get the source code, free.  You can modify them all you want.
Set up icons in a folder and then simply double-click on whatever utility
you want to run.  If you don't know REXX, so what.

From what I hear, Surfboard will be available to the public sometime
next week, well ahead of schedule. Once you can get your hands on it you
can try it out and eat your words.

Here are some samples with parameters:


FTPCOPY ftp://hobbes.nmsu.edu/os2/demos/post103a.zip d:\temp\post103a.zip

FTPCOPY d:\temp\file.zip ftp://host.edu/file.zip user password

  FTPCOPY lets you copy to or from a site.  It works for anonymous or
  password FTP.  You can send a half dozen small files faster that you can
  fire up FTPPM.

NEWSNEW comp.os.os2.announce since 10/05/95 00:00:00 output.txt

NEWSPOST news-s01.ny.us.ibm.net file.txt

  NEWS* is power to the people.  You could write a killer offline news
  reader using VXREXX with the SurfBoard/2 DLL.

MAILNEW pop03.ny.us.ibm.net user password

  There is also a MAILGET utility.  Nice for somebody else but not for me.

WEBCOPY http://www.players.com/picture1.gif d:\temp\picture1.gif

WEBCOPY http://www.players.com/index.htm d:\temp\index.htm -i

  The second example gets an html file with all images.

WEBCRAWL http://www.players.com/ 4 100

  Crawls four deep from the home page looking for and testing up to 100
  links.  You can change the depth and cutout.

WEBNEW sitelist.txt newstuff.htm

  Crawls through a site list of pages to find out what has changed from
  the other day (when you ran it last) and prepares a on-disk html page on
  what is new complete with hot links.  This will save me 2 hours a week
  easy.

SENDNOTE smpt.tiac.com joe@ibm.net note.pop

SENDNOTE smtp.tiac.com distlist.txt note.pop

  This is simple and runs about 10 times as fast a SENDMAIL.  It includes
  some neat built in features that Post Road includes for faster, better
  controlled SMTP sending such as cyclical reconnection intervals.

Mike, this is not DOS-like stuff at all.  REXX is not DOS-like, nor are
multithread DLL's.  If you mean not full of rich GUI, that is because this
is a utility package for *anyone* who uses the Internet for more than
checking sport scores from a web page.  I pulled a news group from inside
EPM and was reading it offline in less time than it takes for NR/2 to find
itself and think about loading.

Max says hello.  I posted this with Surfboard.

Jennifer Anne Gardner

