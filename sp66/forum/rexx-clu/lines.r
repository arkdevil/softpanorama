/** count lines, by redirecting DIR command **/
/** redirection can be avoided by using stacks
 ** so, instead of "dir ...> file" we will use
 ** "dir" arg(1) "(stack"
 ** do queued    (instead of do until eof(file))
 **    parse pull fn ft sz .
 **    ....
 ** and not "del" file  command at the end
 **/
call load "files.r"
lines = 0
size = 0
file = "$$$fff$$$"
"dir" arg(1) ">" file
do until eof(file)
   parse value read(file) with fn ft sz .
   if pos('.',fn) then do     /* some shells display files as: */
      sz = ft                 /* RX.EXE  57357  bla bla bla    */
      parse var fn fn '.' ft
   end
   if datatype(size) ^= 'NUM' then iterate
   f = fn'.'ft
   call write ,"file" f
   l = lines(f)
 /*   sz = filesize(f) */
   say format(l,5) format(s,6)
   lines = lines + l
   size = size + sz
end
say "total lines =" lines
say "total size  =" size
"del" file
exit 0
