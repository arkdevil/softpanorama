/* Replace string1 with string2 in file, save old file in .bak */
/* Note: Search is case insensitive */
/* Written by Scott Maxwell May 16, 1994 */

parse arg file string1 string2

if string1 == '' then do
  say "Usage: SEARCH file string1 [string2]"
  say ""
  say "  Searches for string1 in file case-insensitively."
  say "  If string2 exists, string1 is replaced with string2"
  say "  and the original file is stored in <filestem>.bak"
  exit(1)
end

string1 = translate(string1)

if Stream(file,'C','QUERY EXISTS') = '' then do
   say file "not found."
   exit(1)
end

if string2 = '' then do
   call RxFuncAdd 'SysFileSearch','RexxUtil','SysFileSearch'
   call SysFileSearch string1,file,'line.','N'
   do i = 1 to line.0
      parse var line.i num contents
      say num":"'09'x contents
   end
   exit(0)
end

lp = LastPos('.',file)
if lp = 0 then lp = Length(file)+1
bakfile = Left(file,lp-1)'.bak'

if Stream(bakfile,'C','QUERY EXISTS') \= '' then do
   call RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
   call SysFileDelete bakfile
end

'@ren' file bakfile '> nul'

do while lines(bakfile)
   l = linein(bakfile)
   ltran = translate(l)
   p = pos(string1,ltran)
   do while p \= 0
      l = Left(l,p-1)||string2||substr(l,p+length(string1))
      ltran = translate(l)
      p = pos(string1,ltran,p+length(string2))
   end
   call lineout file,l
end
call lineout file
call lineout bakfile
