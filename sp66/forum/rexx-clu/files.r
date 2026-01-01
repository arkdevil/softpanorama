/*
        A small library of files routines.
        Bill N. Vlachoudis   bill@donoussa.physics.auth.gr
*/

say "This is a library file, and cannot run alone..."
exit 1

/* ----------- return file size, or -1 if file not found --------------- */
filesize: procedure
file = open(arg(1),"rb")
if file = -1 then return -1
size = seek(file,0,"eof")
call close file
return size

/* ----------------- return 0 or 1 if file exists -------------- */
state: procedure
file = open(arg(1),"rb")
if file = -1 then return 0
call close file
return 1

/*-------------------  count the lines of a file ----------------*/
lines: procedure
file = open(arg(1),"r")
if file = -1 then return -1
do lines=1 until eof(file)
   a = read(file)
end
call close file
return lines

/* -------------------- execio read ------------------------- */
/* -- push file to stack -- */
execioread: procedure
file = open(arg(1),"r")
if file = -1 then return -1
do lines=1
   line = read(file)
   if eof(file) then leave
   queue line
end
call close file
return lines
