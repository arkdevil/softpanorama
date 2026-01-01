$ !
$ !             "Makefile" for VAX/VMS versions of DOSDIR/DIRENT
$ !
$ on error then exit
$ ! if argument specified then skip compile and goto link step.
$ if P1 .NES. "" then goto link
$ write sys$output "Compiling : dosdir"
$ cc example2,filelist,dosdir,match,fnsplit
$ cc example3,dirent
$link:
$ write sys$output "Linking   : dosdir"
$ link filelist,dosdir,match,fnsplit
$ link example2,dosdir,match
$ link example3,dirent
$ dir_name = f$environment("default")
$ filelist :== $'dir_name'FILELIST.EXE
$ example2 :== $'dir_name'EXAMPLE2.EXE
$ example3 :== $'dir_name'EXAMPLE3.EXE
$ exit
