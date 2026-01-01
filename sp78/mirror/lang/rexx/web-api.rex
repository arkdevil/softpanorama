From: James Gaines <jgaines@mcs.net>
Newsgroups: comp.os.os2.programmer,comp.os.os2.programmer.misc,comp.os.os2.programmer.oop,comp.os.os2.programmer.porting,comp.os.os2.programmer.tools
Subject: Re: Web / REXX Socket API s
Date: 6 Oct 1995 14:33:19 GMT

Greetings REXX programmers.

Please help.

Situation:
I am writing a REXX script (script found below) to download a file from a
Web server using HTTP and the REXX Socket API (which mirrors the C API).
 All connections to the Web server are fine.  I can read and parse all
the header information just fine.  The code intends to read (via
SockRecv) data from the server in 4k chunks and reassemble the data into
a file found locally on the client's harddrive.  I am doing this via a DO
Loop.

Problem:
When looping through the data via repeated SockRecv() calls within the
GET_Data_Loop subroutine, I am retrieving the correct numbers of
characters into the 'rc' variable, however, I am NOT getting ANY change
in the returned information being stuffed into the variable 'data'.  In
other words, the content within the variable 'data' is not being updated
with each subsequent SockRecv() call.  I thought stream's pointer would
move with each call.

What am I doing wrong?  Do I need to move the content pointer explicitly?
Again, please help.  Forgive me if this is a newbie question.  Please
reply to jgaines@mcs.com or 312.702.5177.

Thanks in advance.

Peace,

James
jgaines@mcs.com


********************************* CODE ******************************
/* REXX HTTP Client
   (C) 1995 by James Gaines

   Revision history:
   V.1 - Initial Release

   Purpose: The purpose of this program is to maintain synchronicity of
the locally installed HORIZON code and
       any updates which might be available on the Code Server
machine.  This applet employs HTTP in
       order to access the server.  This approach has two primary
advantages:
    1) - Because it is a Web server, it provides connectivity
to all machines on the network.  This
          is important due to the fact that we are employing
OS/2 Peer-to-Peer which can not see
          across/through routers over to other subnets.
    2) - Very low and very fast hit on the Web server
machine.  This is the nature of HTTP and why it
          is currently (9-28-95) becoming the distributed
computing methodology of choice.

   Parameter(s): short n - where n is any small integer value.  If n
equals 0, then the applet resets the stored
      date value used and immediately downloads all the new
code.  Anyother value for n, invokes
      the date comparison logic which determines IF the code
needs to be downloaded from the server.

   NB: This program requires the rxSock dll function library, available
   anywhere IBM EWS is found.

*/

trace on

/* initialize variables and functions */
call GET_Init

/* establish socket connection */
call OPEN_WebSock

/* get header object header */
call GET_Header

/* excise file's modification date & time line from header */
call GET_Header_Info_Line 'Last-modified:'
datetime=result

/* excise file's modification date from header line */
call GET_Header_Info_Word datetime,2
curr_date=result

/* excise file's modification time from header line */
call GET_Header_Info_Word datetime,3
curr_time=result

/* excise file's content length from header */
call GET_Header_Info_Line 'Content-length:'
content_len=result

/* close socket */
call CLOSE_WebSock

/* prep Localizer file */
call SET_Localizer_Prep

/* compare date & time of Web and Localizer files: process only if date
or time are unequal */
call EVAL_Date_Time_Comparison
DT_Comp=result
if DT_Comp=0 then
   do
      /* establish socket connection again */
      call OPEN_WebSock

      /* retrieve file data */
      call GET_Data
      sentdatasize=result-length(header)

fdata=substr(loopdata,length(header)+1,length(loopdata)-length(header))

      /* export data to zip file */
      call PREP_ZipFile 'OPEN'
      rc=charout(tname,fdata,1)

      /* loop through data, place more data into file */
      call GET_Data_Loop content_len-sentdatasize

      /* export data to zip file */
      call PREP_ZipFile 'CLOSE'

      /* close socket */
      call CLOSE_WebSock

      /* close temp file */
      rc=stream(tname,'c','close')

      /* unzip file to correct subdirectory */

      /* uncompress in destructive form */
   end
exit




***********************************
/* subroutines */
***********************************

GET_Init:
/* initialization(s) */
key1='Last-modified:'
key2='GMT'
curr_date=''
curr_date_len=9
curr_date_mark='-'
curr_date_off=-2
curr_time=''
curr_time_len=8
curr_time_mark=':'
curr_time_off=-2
fpath='c:\horizon'
fpath_chk=directory(fpath)
fname=fpath'\localize.dat'
tpath='c:\hrzn'
tname=tpath'\horizon.uue'
begindatamark=d2c(10)d2c(10)
datasize=4000
website='www.lib.uchicago.edu'
webdir='/~louy'
webfile='test.uue'

/* load all functions */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* setup socket package */
if RxFuncQuery("SockLoadFuncs") then
do
  rc = RxFuncAdd("SockLoadFuncs", "RxSock", "SockLoadFuncs")
  rc = SockLoadFuncs()
end

/* make 'datasize' variable */
ds=''
ds=insert(' ',ds,0,datasize,' ')
return



OPEN_WebSock:
/* verify code/web server as addressable */
rc = SockGetHostByName(website, "host.!")
if (rc = 0) then
do
  say "Unable to resolve name of http server."
  exit
end
server = host.!addr

/* open a SOCKET to the code server */
sock = SockSocket("AF_INET", "SOCK_STREAM", "IPPROTO_TCP")
if (sock = -1) then
do
  say "Error opening socket: " errno
  exit
end

/* connect to SOCKETed code server */
server.!family = "AF_INET"
server.!port   = 80
server.!addr   = server

rc = SockConnect(sock, "server.!")
if (rc = -1) then
do
  say "Error connecting socket: " errno
  exit
end
return sock



CLOSE_WebSock:
/* close socket */
rc=SockClose(sock)
return



GET_Header:
/* transmit instructions to SOCKETed code server */
script='HEAD 'webdir'/'webfile' HTTP/1.0'd2c(10)d2c(10)

rc=SockSend(sock,script)
if (rc = -1) then
do
  say "Unable to resolve HTTP command: "script
  exit
end

/* stuff DATA object with retrieved information */
rc=SockRecv(sock,header,datasize)
return



/* excise info from Header */
GET_Header_Info_Line:
a=pos(ARG(1),header)
z=pos(d2c(10),header,a)
return (substr(header,a+length(ARG(1)),z-(a+length(ARG(1)))))



/* parse info from a single Line of header */
GET_Header_Info_Word:
i=1
c=1
do 1000
   a=pos(' ',ARG(1),c)
   z=pos(' ',ARG(1),a+1)

   if z=0 then
      z=length(ARG(1))+1

   if ARG(2)=i then
         leave

   c=z
   i=i+1

   /* error statement */
   if i=1000 then
  say 'ERROR: Can not find requested value in string: 'ARG(1)    '
.. GET_Header_Info_Word'
end
return (substr(ARG(1),a+1,z-(a+1)))



/* retrieve data from Web server: GET_Data */
GET_Data:
/* transmit instructions to SOCKETed code server */
script='GET 'webdir'/'webfile' HTTP/1.0'd2c(10)d2c(10)
rc=SockSend(sock,script)
if (rc = -1) then
do
  say "Unable to resolve HTTP command: "script
  exit
end

/* stuff DATA object with retrieved information */
rc=SockRecv(sock,loopdata,datasize)
return rc



GET_Data_Loop:
recvsum=0
i=1
do until recvsum>=ARG(1)

   rc=SockRecv(sock,loopdata,datasize)
   recvsum=recvsum+rc
   rc_c=charout(tname,loopdata)
   say 'recvsum='recvsum
   i=i+1

end
return



/* checking for current existence of fpath; if non-existent, path is
created, files are copied and program is stopped */
SET_Localizer_Prep:
if compare(translate(fpath_chk),translate(fpath))<>0 then
   do
      /* create subdirectory */
      rc_mkdir=SysMkDir(fpath)

      /* write data to Localizer file */
      rc=lineout(fname,curr_date,1)
      rc=lineout(fname,curr_time)
      local_date=curr_date
      local_time=curr_time
   end
else
   do
      /* collect information from localizer file */
      local_date=linein(fname)
      local_time=linein(fname)
   end
return



/* evaluate date status */
EVAL_Date_Time_Comparison:
if (compare(translate(curr_date),translate(local_date))<>0 or
compare(translate(curr_time),translate(local_time))<>0) then
  return 0
else
  return -1



/* affirm renaissance of temporary file */
PREP_ZipFile:
if ARG(1)='OPEN' then
   do
      DEL tname
      rc=stream(tname,'c','open')
   end
else
   rc=stream(tname,'c','close')
return




