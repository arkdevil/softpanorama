Sun Sep  9 16:54:19 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.4.

	* cat.c, cp.h: Declare free returning void, not int, so it
	doesn't bomb on Xenix.

Fri Sep  7 04:35:35 1990  David J. MacKenzie  (djm at apple-gunkies)

	* system.h, backupfile.c, savedir.c [DIRENT]: if direct is
	defined (as on Ultrix 4.0), undefine it before redefining it.

Tue Sep  4 03:10:24 1990  David J. MacKenzie  (djm at apple-gunkies)

	* dd.c (apply_translations, translate_charset): Code moved
	from parse_conversion.
	(apply_translations): Convert from EBCDIC to ASCII before
	converting case.

	* mvdir.c (fullpath): Return a value.

	* dd.c (copy): Increment count of truncated records once
	per record, not once per character that overflows.

Mon Sep  3 22:23:57 1990  David J. MacKenzie  (djm at coke)

	* tac.c: Print error messages before calling cleanup, not after.

	* dd.c (swab_array): Function removed.
	(copy): Rewrite conv=swab to work when odd number of bytes
	are read.
	(scanargs): Die if invalid numeric value is given.
	(parse_integer): Return -1 if invalid arg.
	(bit_count): Faster version from Jim Meyering.

	* cp.c, mkfifo.c [MKFIFO_MISSING]: Define mkfifo.

Thu Aug 30 00:17:02 1990  David J. MacKenzie  (djm at apple-gunkies)

	* mvdir.c (main): Make sure `from' is not a parent of any part
	of `to', not just the explicitly given part.
	(fullpath): New function.

Wed Aug 29 19:50:05 1990  David J. MacKenzie  (djm at apple-gunkies)

	* mvdir.c: Renamed from mv_dir.c, for consistency with mkdir and rmdir.
	* dirlib.c: Caller changed.

Tue Aug 28 18:05:24 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* touch.c (main): Don't interpret first non-option arg as a
	time if `--' is given (POSIX-required kludge).

	* touch.c: Add long-named options.

	* Many files: Include <getopt.h> instead of "getopt.h" since
	getopt.h will be in the GNU /usr/include.

	* tac.c (cleanup): Return SIGTYPE, not int.

	* install.c: Declare some functions.

	* touch.c, getdate.y, posixtime.y, mktime.c: New files, from bin-src.

	* posixtime.y: Move year from before time to after it (but
	before the seconds), for 1003.2 draft 10.

Mon Aug 27 03:25:36 1990  David J. MacKenzie  (djm at apple-gunkies)

	* touch.c (main): If no time is given and first arg is a valid
	timespec, use it as one.

Sat Aug 25 01:36:16 1990  David J. MacKenzie  (djm at apple-gunkies)

	* posixtime.y: Enclose YYABORT in braces in case some yacc's
	need it.

	* touch.c: Remove -i option.  Change some error messages.
	(readname): Function removed.

Thu Aug 23 12:56:33 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cp.c (copy): Only restore dir mode if it was changed.

Wed Aug 22 01:45:54 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cp.c (copy): Don't only backup files when -f is given.

	* ls.c: Add -X +sort=extension option.  Rename
	+kilobyte-file-size to +kilobytes.

	* du.c: Rename -f option to -x, for POSIX.  Rename
	+kilobyte-file-size to +kilobytes.  Add -b, +bytes option for
	POSIX. 

	* cp-aux.c (usage): Change -o to -x.
	(stpcpy): Renamed from str_cpy.  Change callers in cp.c.

	* cp.c: New variable, `flag_copy_as_regular'.
	(main): For -R, unset `flag_copy_as_regular'.
	Rename -o to -x for consistency with du.
	(copy): Only unlink destination files when -f is given.
	Only prompt when -i given and copying as a regular file.
	Move check for previous link after other checks, reducing
	duplicate code.
	Create directories with mode 0700 initially, for POSIX.

Mon Aug 20 03:29:08 1990  David J. MacKenzie  (djm at apple-gunkies)

	* dd.c (copy): Swap input bytes instead of output bytes.
	(swab_array): New function.

	* dd.c (copy): If sync and noerror, zero the buffer before the
	read instead of after so that any data read before an error
	occurred are preserved.
	On read error, print stats and seek past the bad block if
	noerror.
	noerror doesn't affect write errors, for POSIX.
	(scanargs): Use two buffers if no buffer sizes given.
	Do not block or unblock if cbs not given.
	(print_stats): New function.
	(quit): Call it.

Mon Aug 13 23:30:03 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cp.c (copy): If dest. exists and is unwritable, skip the
	file.

	* rm.c, mv.c, cp.c, ln.c (main): Respect the last -f or -i given,
	for POSIX.

	* rm.c (remove_file): Only prompt if -i is given.
	(main, usage): Remove -o +override-mode option, obsolete if
	POSIX accepts our objection about prompting.

	* mv.c (do_move): Only prompt if -i is given.

	* ln.c (do_link): If dest. file exists and -i and -f not
	given, skip the file.

Tue Aug  7 12:51:18 1990  David J. MacKenzie  (djm at apple-gunkies)

	* dd.c (main): If seek= given, don't truncate output file.
	(copy): Use `read' to skip output blocks if not regular file.
	Sync with NUL instead of SPC.

	* cut.c (main, usage): Add -b and -n options for POSIX.
	(set_fields): Don't allow SPC or TAB as number separators.

	* paste.c (paste_parallel): If open of any file fails, quit
	(for POSIX).

Mon Aug  6 14:43:30 1990  David J. MacKenzie  (djm at pogo.ai.mit.edu)

	* head.c, tail.c: Change `chars' to `bytes' globally.
	(main, usage): Use POSIX.2 draft 10 option syntax.

	* rm.c: Rename `ignore_errors' to `ignore_missing_files', and
	have it only suppress messages about nonexisting files.
	(main): Get dev and ino of `.' and `..'.
	(rm): If file is the same as `.' or `..', return with error.
	(remove_file): Remove the file rather than skipping it if
	unwritable, no -i, and stdin not tty.
	(remove_dir): Return an error if directory is nonwritable,
	rather than nonreadable or nonsearchable, for POSIX.2 draft 10.

	* chmod.c (main): Use fixed error checking to make sure that
	options aren't mixed together in the same args as mode specifiers.

Sun Aug  5 11:51:12 1990  David J. MacKenzie  (djm at pogo.ai.mit.edu)

	* chmod.c (main): Use umask for '-' op.

	* cat.c (main): Don't delay error messages, so they appear
	where expected.
	(main, simple_cat, cat): Make errors in input files nonfatal.

Sat Aug  4 10:11:30 1990  David J. MacKenzie  (djm at pogo.ai.mit.edu)

	* mkfifo.c: Remove -p +path option, no longer specified by POSIX.

	* cat.c: Remove -c option added for POSIX draft 9, since POSIX
	draft 10 removed it. 

	* tac.c (tac_stdin): Use fstat instead of lseek to determine
	whether stdin is seekable, because lseek silently fails on
	some special files, like tty's.
	tail.c (tail_chars, tail_lines): Use fstat instead of lseek;
	don't turn off -f for non-regular files (assume the user knows
	what he's doing; it might work for fifo's and sockets).

	* paste.c (main): If no files given, use stdin.
	Don't let collapse_escapes write on string constant (delim default).
	(paste_parallel): Don't close stdin.

	* cut.c (main): Use standard input for filename of "-".

Fri Aug  3 13:38:28 1990  David J. MacKenzie  (djm at pogo.ai.mit.edu)

	* mkdir.c, mkfifo.c, create.c (main): Don't tell mode_compile
	to respect the umask for certain operations, since the umask
	is 0 anyway. 

	* cut.c (enlarge_line): Take an arg giving the required amount
	of space.  Change callers.
	(main): Don't allow -t'<TAB>' without -f.
	Make `delim' unsigned to fix sign extension problem in comparison.

	* install.c (get_ids): Use getuid and getgid to get defaults,
	instead of -1.

Fri Jul 27 14:32:40 1990  David J. MacKenzie  (djm at apple-gunkies)

	* backupfile.c (dirname): Always replace frontmost slash with
	a null.

Thu Jul 26 00:20:35 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cp.h: Declare umask as unsigned short.

	* eaccess.c: Make uid and gid unsigned short, and group array
	unsigned. 

Wed Jul 25 18:38:57 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* rm.c (remove_file, remove_dir): Print verbose message right
	before actually trying to remove the file, after the prompting.

	* ls.c (getuser, getgroup): Make uid and gid unsigned short,
	not int.

Tue Jul 24 03:39:42 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy), ln.c (do_link), mv.c (do_move): For +verbose,
	print the file names just before actually attempting the
	copy/link/move, to produce a list of the files that they
	actually try to copy/link/move, omitting skipped files.
	Remove leading spaces from +verbose output.

Mon Jul 23 16:57:44 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): Make +update operate silently, like
	+one-file-system. 

	* ln.c: Add -F as synonym for -d, for SunOS compatibility.

Tue Jul 17 17:58:26 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cut.c, paste.c: New files.

Sun Jul 15 23:23:28 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): Go back to using xstat on dest.

Wed Jul 11 12:10:33 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): Make directories with desired mode plus u+wx so
	if the copy is interrupted, the dir is closer to the desired mode.
	Don't backup directories.

Sun Jul  8 00:39:31 1990  David J. MacKenzie  (djm at apple-gunkies)

	* rm.c (main, usage): Add new option -d, +directory.
	(rm): If -d given, use remove_file instead of remove_dir for
	directories. 
	(remove_file): If directory, print "remove directory `foo'?"
	for interactive instead of "remove `foo'?".

	* cmp.c (main, usage): Rename -L option to -c and don't have
	it imply -l. 
	(printc): Take an arg to specify number of chars to pad to,
	for column alignment.
	(cmp): Respect flag_print_chars in default output format.
	Align columns for cmp -cl.

	* ln.c (main): If -s given, print warning message if symlinks
	are not available.
	* mkfifo.c (main): If fifo's are not available, print message
	and exit.

Sat Jul  7 17:23:30 1990  David J. MacKenzie  (djm at apple-gunkies)

	* create.c (main): Only use TMPDIR if directory is writable.
	For -p, validate pathname length and (if -P) portability,
	and don't complain if file already exists, and don't create it
	if -n is given. 
	(make_new_file): Created from code in main.
	(ensure_path_exists): Don't try to stat "" or "/".  Take arg
	indicating whether to set existing file's mode.
	Return value indicating whether file needs to be created.
	(validate_new_path): Take arg indicating whether to check if
	directories in path exist.  Don't check whether file exists.

	* cmp.c: For +show-chars, have getopt return 'L' so
	`flag_print_chars' gets set.

Fri Jul  6 02:02:49 1990  David J. MacKenzie  (djm at apple-gunkies)

	* install.c (main): Use the current user and group ID for the
	default owner and group.

	* cat.c, cp.c, head.c, install.c, ln.c, ls.c, mkdir.c,
	mkfifo.c, mv.c, rm.c, tac.c, tail.c (main): Don't change the
	option character if it's 0, as getopt now handles that internally.

	* mv.c (main): New option -u, +update.
	(do_move): Don't move nondirectories if -u and there is an existing 
	destination that has the same or newer mtime.
	(usage): Document -u, +update.

	* cp.c (main): New option -u, +update.
	(copy): Don't copy nondirectories if -u and there is an existing 
	destination that has the same or newer mtime.
	* cp-aux.c (usage): Document -u ,+update.

Thu Jul  5 10:04:12 1990  David J. MacKenzie  (djm at apple-gunkies)

	* ln.c (do_link): Don't check whether OLD exists before trying
	to make link.

Tue Jul  3 01:51:55 1990  David J. MacKenzie  (djm at apple-gunkies)

	* ls.c: Allow "+time=atime" and "+time=ctime" for C hackers.

	* chmod.c (main): Don't check whether multiple mode arguments
	are given, because optind has a different value depending on
	whether or not the option is the last character in the
	ARGV-element.

Sat Jun 30 12:32:51 1990  David J. MacKenzie  (djm at apple-gunkies)

	* cp.c (copy): Use lstat on dest. file, not *xstat.

Fri Jun 29 01:04:19 1990  David J. MacKenzie  (djm at apple-gunkies)

	* tac.c (main): Initialize fastmap and translate fields of
	regex before compiling it.

Mon Jun 25 18:07:20 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ls.c (print_long_format): Truncate user and group names to 8
	chars to preserve column alignment.
	(length_of_file_name_and_frills): Don't assume type indicator
	will be printed for unknown file types that some os's have.

	* install.c: Declare getgrnam for systems where grp.h doesn't.

Sat Jun 23 00:06:35 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.3.

	* du.c (count_entry) [HPUX_NFS_BUG]: If the size of the file
	according to the number of blocks reported is twice or more than
	the size of the file according to the number of bytes
	reported, halve the number of blocks.

Fri Jun 22 00:38:20 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* tac.c: Change +regexp to +regex for consistency with GNU find.

	* cp.c (copy_dir): Initialize 'ret' to 0.

	* cp.c (main), ln.c (main), mv.c (main), rm.c (main):
	Make -i override -f and -o, to be conservative about
	removing peoples' files.

	* mkdir.c (make_path), mkfifo.c (make_path): Don't try to stat
	"" or "/".

	* rm.c, rmdir.c, mkdir.c, mkfifo.c: Move code to remove
	slashes at the end of an arg from main to
	strip_trailing_slashes. 

	* install.c (strip): Print error message if the `strip'
	program can't be run.

	* system.h (convert_blocks): Macro moved from du.c and ls.c.
	Take a second parameter indicating whether to convert to
	kilobytes or 512 byte blocks.
	* ls.c, du.c: Pass second parameter to convert_blocks.

Thu Jun 21 01:19:28 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ls.c (print_long_format): Use mode_string instead of
	filemodestring. 

	* ls.c (print_long_format): Compare times as longs, not ints.
	(longdiff): Macro to compare two longs efficiently if sizeof
	int == sizeof long and less efficiently but correctly if they
	are different sizes.
	(compare_ctime, etc.): Use longdiff.

	* ls.c (decode_switches): Make -k not imply -s, to allow the
	summary directory size printed by -l to be in 1k blocks
	without having the size of each file printed as well.
	(convert_blocks): Provide for systems with a blocksize that is
	other than 512 or 1024 bytes.

	* du.c (main): Exit with status 0 normally.
	(convert_blocks): Provide for systems with a blocksize that is
	other than 512 or 1024 bytes.

Wed Jun 20 01:52:02 1990  Brian Fox  (bfox at albert.ai.mit.edu)

	* paste.c: Added test to check that there was an argument
	before dereferencing the argv vector.

Wed Jun 20 01:46:09 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cat.c (cat): If FIONREAD is available, only use it if it is
	supported by the filesystem that the file is on.

	* ln.c (do_link): Take out code to give an error if source and
	dest are the same file.  The dubious usefulness of the special
	case to prevent 'ln x x' from removing 'x' (ln -i can be used
	instead) is not worth preventing 'ln x y' from failing the
	second time in a row, and appears to contradict POSIX anyway.

Mon Jun 18 02:48:17 1990  David J. MacKenzie  (djm at apple-gunkies)

	* ls.c (print_file_name_and_frills,
	length_of_file_name_and_frills, print_long_format):
	Allow 6 digits for i-number, not 5.

Sun Jun 17 00:09:23 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* install.c (install_dir): Don't check whether "" or the root
	directory exists (the former fails on some systems).

	* system.h: Make inclusion of sys/file.h conditional on USG
	and _POSIX_SOURCE, not DIRENT.

	* chmod.c (change_dir_mode): Use xrealloc instead of free and
	xmalloc in case malloc already left extra room.
	(xrealloc): New function.

	* rm.c (clear_directory): Prevent buffer overruns.
	More efficient string handling.  Don't skip rest of directory
	if continuing after finding circular inode.
	(xrealloc): New function.

Sat Jun 16 01:45:42 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* argmatch.c (invalid_arg): Change order in which the items
	are printed. 

	* ls.c: Add +tabsize (-T) option.

Fri Jun 15 23:40:55 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* dd.c (scanargs): For ibs and obs, set C_HARDWAY.
	(copy): Use different buffers only if C_HARDWAY, not if
	blocksizes are the same, to ensure constant output block sizes.

Wed Jun 13 23:56:20 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* savedir.c: New file from code in chmod.c, modified to
	prevent buffer overruns.
	* chmod.c (change_dir_mode), cp.c (copy_dir), du.c
	(count_entry): Use savedir.

Thu Jun  7 03:52:02 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* system.h (ST_BLKSIZE) [!STBLOCKS_MISSING]: If st_blksize is
	0 (as on pipe reads on some systems), use BSIZE instead.
	Define BSIZE as DEV_BSIZE if necessary.

	* Makefile, system.h, fileblocks.c: Use STBLOCKS_MISSING to
	control whether st_blksize and st_blocks are used.
	* Makefile, system.h, backupfile.c: Use DIRENT to control
	whether <dirent.h> is used.

Sun Jun  3 20:26:19 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cat.c (main): Add a variable to control whether the check
	for input file == output file is made, because no values of
	st_dev and st_ino should be assumed to be available for this
	purpose.  Only do the check for regular files.

	* tac.c: Use bcopy instead of memcpy.

Wed May 30 15:34:47 EDT 1990 Jay Fenlason (hack@ai.mit.edu)

	* cut.c (main)  Don't dereference 0 while parsing args.

Thu May 31 00:55:36 1990  David J. MacKenzie  (djm at apple-gunkies)

	* fileblocks.c: New file.
	* du.c (blocks_to_kb): Replace with convert_blocks macro.
	(main): Recognize new -k option.
	(usage): Document it.
	* ls.c (nblocks): Replace with convert_blocks macro.
	* system.h (ST_BLKSIZE) [USG]: Use BSIZE from sys/param.h instead of
	having the user define BLKSIZE.
	(ST_NBLOCKS) [USG]: Use st_blocks from fileblocks.c.

	* head.c: Use longs instead of ints for file offsets, for 16
	bit machines.

	* cat.c, chmod.c, cmp.c, cp.c, cp.h, create.c, dd.c, dirlib.c,
	du.c, head.c, system.h, backupfile.c, ln.c, ls.c, install.c,
	mkdir.c, mkfifo.c, modechange.c, mv.c, mv_dir.c, rm.c,
	rmdir.c, tail.c, tac.c: Optionally use ANSI C and POSIX header files.

Wed May 23 00:40:39 1990  David J. MacKenzie  (djm at apple-gunkies)

	* argmatch.c: New file, taken from ls.c.
	* getversion.c (get_version): Use argmatch, to allow
	abbreviations.  Default backup type is existing_numbered.
	* mv.c (main), ln.c (main), cp.c (main): Only make backups if
	-b (+backup) is given.  If envar SIMPLE_BACKUP_SUFFIX is set,
	use it as a default instead of `~'.
	* mv.c (usage), ln.c (usage), cp-aux.c (usage): Update messages.

Tue May 22 00:56:51 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* install.c: New file (from ../bin-src).

	* cmp.c: Change some ints to longs for 16 bit machines.
	(bcmp_cnt): Make char-pointer counting slightly simpler.

	* dd.c (copy): Don't count completely failed writes as partial
	writes.  Make buffers unsigned.  If blocking or unblocking,
	pad final partial buffer if necessary.

	* getversion.c: New file.
	* mv.c (main), cp.c (main), ln.c (main): Control backup types
	with getenv ("VERSION_CONTROL") and +version-control or -V.

	* cp.c (yesno), mv.c (yesno), ln.c (yesno): Stop reading if
	EOF reached as well as at newline.

	* backupfile.[ch]: Rename var `version_control' to `backup_type'.

Sat May 19 23:38:46 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* touch.c: Change some error messages.  Include "getopt.h".

Sat May 19 00:16:50 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* mv.c (main), ln.c (main), cp.c (main): Revise
	backup-creation options.
	* mv.c (usage), ln.c (usage), cp-aux.c (usage): Revise messages.

	* chmod.c (describe_change): Use mode_string instead of
	filemodestring. 

	* cp.c (main): Recognize new options for making backups.
	* cp.c (copy): Make backups if requested.  Fix typo.
	* cp-aux.c (usage): Update message.

	* mv.c, cp.c: Remove code to conditionally use utimes instead
	of utime, since the extra resolution of utimes was not being
	used, the emulation overhead is probably insignificant,
	and utime is a standard function.

	* cp-hash.c: Fix up comments.

Fri May 18 23:06:23 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* mv.c (do_move): Only make backup if dest file exists.
	Don't continue moving file if dest can't be backed up.
	* ln.c (do_link): Don't try to unlink dest if it was backed up.
	Don't continue moving file if dest can't be backed up.

	* system.h: Make SIGTYPE default to void if not defined.

	* modechange.[ch]: Rename struct and external functions to start
	with 'mode_'.
	* modechange.c (oatoi): Make static.
	(mode_compile): Take an additional arg indicating which
	symbolic operators should be affected by the umask.
	* modechange.h: Add defines for mode_compile arg mask.
	If __STDC__, use prototypes.
	* chmod.c, mkdir.c, mkfifo.c, create.c: Account for above changes.

Tue May 15 16:17:34 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* dd.c (copy): Quit with nonzero status if final write fails.

Mon May 14 14:34:10 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* tac.c, regex.c, regex.h: New files.

	* dd.c: Make translation tables unsigned.
	(main): Give `input_file' and `output_file' nonzero values for
	stdin and stdout. 
	(parse_conversion): Set new global vars 'space_character' and
	'newline_character' to correct values when translating to EBCDIC
	(either flavor).
	(copy): Use 'space_character' and 'newline_character' instead
	of hardcoded ASCII values.  Ignore attempts to seek on output pipe,
	socket, or fifo.  If possible, seek instead of reading to skip
	initial input records.  Sync with `space_character' instead of
	nulls, for POSIX.

	* cp.c (copy_reg): Compare lseek values as longs, not ints.

Sat May 12 01:16:42 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp-hash (remember_created): Return error status instead of
	fatal error. 
	* cp.c (copy): Change caller.
	(do_copy, copy_reg): Return error status instead of fatal error.

	* cat.c (main): Allow input file to be output file for devices
	(ttys, etc.).  Check whether input file is output file when
	reading standard input.  Print any error messages for standard
	input. 

	* cmp.c (bcmp_cnt): Handle int comparisons correctly on 16 bit
	machines as well as 32 bit ones.
	* cmp.c, tail.c, ls.c, cp.c, du.c: Use longs instead of ints
	for file offsets. 

	* Move rename emulation from mv.c to dirlib.c so other
	programs can use it.
	* mv.c, ln.c (main): Recognize new options for making backups.
	* mv.c (do_move), ln.c (do_link): Make backups if requested.
	* mv.c, ln.c (usage): Update message.
	* backupfile.c, backupfile.h: New files.

	* cp.h: Ifdef out decl of umask because of SunOS 4.1 (POSIX) conflict.

	* Define all `main' functions as returning void.

Fri May 11 02:11:03 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c, mv.c, rm.c, rmdir.c, create.c, chmod.c: Change some
	error messages. 

	* cmp.c: Fix some exit statuses for POSIX.

	* du.c, cmp.c, cat.c, cp-aux.c (error): Function removed.
	Change callers to use error.c version.
	* cp.c (copy, do_copy, copy_dir): Return an error status.
	* ls.c (error, fatal, perror_with_name): Functions removed.
	Change callers to use error.c.

Tue May  8 03:41:42 1990  David J. MacKenzie  (djm at abyss)

	* tac.c: Use regular expressions as the record boundaries.
	Give better error messages.
	Reformat code and make it more readable.
	(main): Use getopt_long to parse options.
	(tac_stdin): Do not make a temporary file if standard input
	is a file.
	(tac_file): New function.
	(tac): Take an open file desc as an arg.
	(output): Rewrite to use its own efficient buffering.
	(xmalloc, xrealloc, xwrite): New functions.

Sat May  5 23:46:48 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c (do_link): Don't allow trying to link a file to itself,
	because the source file would be removed if they are the same
	directory entry, and also for consistency with mv and cp.

Fri May  4 13:42:53 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy_reg): Only write a null to the end of the file if
	the end of the file was sparse.

	* ls.c (print_name_with_quoting): Make the char to print
	unsigned to prevent sign extension problems with -b.

Fri Apr 20 13:52:15 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.2 released.

Wed Apr 18 14:36:15 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile: Use chsize for ftruncate on Xenix.

	* cp.c (copy): Remove broken code that attempted to
	substitute for ftruncate on systems missing it.

Mon Apr 16 13:58:01 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp-aux.c (usage): Fix mistake in message.

	* Version 1.1 released.

Sat Apr 14 17:23:11 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ls.c (main): Don't remove leading path from program_name.
	(basename): Function removed.
	(length_of_file_name_and_frills): Don't add 1 for type indicator
	for block and character special files. 

Thu Apr 12 19:50:15 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile: Suggest using -DBLKSIZE=512 instead of 1024 for USG.

	* dd.c (copy): Print copying statistics when exiting because
	of a read or seek error.
	(interrupt_handler): New function.
	(main): Trap SIGINT to run interrupt_handler, for POSIX.

Tue Apr 10 01:09:38 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* chmod.c (change_file_mode): Don't change the mode of
	symbolic links.

Mon Apr  9 13:30:00 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* modechange.c (compile_mode): Return an error if an octal
	number argument is too large.

Sun Apr  8 20:33:20 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* dd.c: Use `error' instead of `fatal' and `pfatal_with_name',
	for greater control of the message format.
	* head.c, tail.c: Use `error' instead of `fatal_perror' and
	`nonfatal_perror'.  Remove some unnecessary info from messages.
	* chmod.c, create.c, ln.c, mkdir.c, mkfifo.c, mv.c, mv_dir.c,
	rm.c, rmdir.c: Remove definition of `error'.
	* error.c: New file created from code in mv.c.
	* Makefile: Link the above programs with error.o.

	* ln.c (do_link): Use eaccess_stat to determine writability.
	* mv.c (do_move): Ditto.
	* rm.c (remove_file): Ditto.
	(remove_dir): Use eaccess_stat to determine readability and
	searchability.  Move initial interactive query here from
	clear_directory. 
	* Makefile: Link ln, mv, and rm with eaccess.o.

Sat Apr  7 11:47:52 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile: Link cp with eaccess.o.
	* eaccess.c: New file adapted from code in cp.c and cp-aux.c.
	* cp.c (copy): Use eaccess_stat to determine writability.
	Consider a file unwritable by root if it has no permissions.
	(main): Remove groups initialization code.
	* cp-aux.c (member): Function deleted.

	* cp.c (copy): Temporarily change the mode of directories if
	necessary to overwrite them when running recursively.
	Consider a directory to be non-overwritable if it lacks write
	permission as well as if it lacks execute permission.

	* cat.c (main), cp.c (copy_reg): Don't check error from close,
	because we know the arg is good and so it cannot fail.

	* rm.c, mv.c, mv_dir.c, chmod.c, create.c, ln.c: Remove some
	irrelevant or redundant information from error messages.

Fri Apr  6 15:20:45 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): Only change mode of regular files and directories;
	others are already correct.

Thu Apr  5 04:31:56 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* dd.c: Remove the vars that are set by command line options
	from a useless struct and give them more meaningful names.

Mon Apr  2 02:58:34 1990  David J. MacKenzie  (djm at spike.ai.mit.edu)

	* cp.c (main): Use NGROUPS from sys/param.h to determine
	whether BSD multiple groups are supported and how large to
	make the array.
	* Makefile: Remove references to GETGROUPS_MISSING.

Sun Apr  1 18:53:57 1990  David J. MacKenzie  (djm at spike.ai.mit.edu)

	* cp.c (main): Always initialize group info.

Sat Mar 31 22:29:57 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* mkfifo.c, create.c, mv_dir.c: New files.
	* Makefile: Add rules for them.
	* mv.c [RENAME_MISSING] (rename): To rename directories, run
	setuid root mv_dir program. 

Tue Mar 20 14:28:25 1990  David J. MacKenzie  (djm at pogo.ai.mit.edu)

	* touch.c: Remove POSIX_COMPAT ifdef since there is no reason
	to disable the GNU extensions.
	(main): Set new global var `program_name'.
	(error): Replace with more versatile version.
	Global: Change calls to fprintf and error to use the new error.
	(main): Initialize global variables.  Don't bother making
	temporary copy of arg to -d.  Don't ignore any files named on
	the command line if -i is given.
	(usage): Don't take an arg.  Use `program_name' instead of
	hardcoded name.
	(touch): In utime emulation for BSD, ftruncate the file to its
	original size so empty files stay empty after being touched.

Sun Mar 18 01:02:39 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c (strip_trailing_slashes): New function.
	(main, do_link): Call it.

	* cp-aux.c (strip_trailing_slashes): New function.
	* cp.c (do_copy): Call it.
	* cp.h: Declare it.

	* mv.c (strip_trailing_slashes): New function.
	(main, movefile): Call it.

Sat Mar 17 21:45:35 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp-aux.c, cp.h: Rename user_confirm_overwriting to yesno and
	don't have it print a prompt, so it can be used in several
	places. 

	* cp.c (do_copy): Change an error message to resemble mv's.
	Remove all trailing slashes from all non-option args.
	(main): Set new global var `stdin_not_tty'.
	(copy): Use POSIX method of handling file overwriting and
	prompting. 

	* dirlib.c (mkdir): Use chmod to set the directory mode after
	successful creation, so set[ug]id and sticky bits are set
	correctly. 

Thu Mar 15 12:33:23 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile: Add commented out definitions for SCO Xenix.

	* ls.c (print_type_indicator): Don't print a '*' next to
	executable block or character special files.

        * chmod.c (error): New function, replacing nonfatal_perror,
        memory_out, and invalid_mode.
        Global: Call error instead of the above functions.
	(change_dir_mode): Make the new size of the path twice the
	size of the name that was too long, rather than twice its old
	size. 

	* rm.c: Move interactive query about whether to remove a
	directory from remove_dir to clear_directory; only query for
	directories that are not empty.

Wed Mar 14 10:48:40 1990  David J. MacKenzie  (djm at rice-chex)

	* system.h [USG]: Define X_OK.

	* rm.c (main): Set new global var `stdin_not_tty'.
	(rm): Most of code moved to two new functions, remove_file and
	remove_dir.
	(remove_file): Use POSIX method of determining whether to remove
	non-directories.
	(remove_dir): Use POSIX method of determining whether to
	remove directories, almost.
	(perror_with_name): Function removed.
	(error): Simple version replaced with more powerful version.
	Global: Change calls to fprintf, perror_with_name, and old
	error to calls to new error.

	* ln.c (main): Set new global var `stdin_not_tty'.
	If force, turn off interactive.
	(do_link): By default, don't allow hard links to symbolic links to
	directories.  Use POSIX method of determining whether to
	overwrite destination.
	(yesno): Function renamed from confirm, and arg removed.
	(lisdir): Function removed.

	* mv.c (main): Set new global var `stdin_not_tty'.
	(yesno): Function renamed from yes.
	(do_move): Use POSIX method of determining whether to
	overwrite destination.

	* Makefile: Make executables depend on .o files, not .c files,
	to allow for parallel compilation.

	* cmp.c (main, cmp, usage): Replace -q +quick option with -L
	+show-chars option to add ASCII representation of bytes to -l format.

Tue Mar 13 00:50:14 1990  David J. MacKenzie  (djm at rice-chex)

	* rm.c (main): Disallow removal of paths that have '..' as the
	final element.
	(basename): New function.

	* ls.c (print_type_indicator): Mark FIFOs with '|' and sockets
	with '='.
	(print_long_format): Print numbers as unsigned and add extra
	space for POSIX flag.

	* dd.c: Make the record counts unsigned.
	(quit): Print them as unsigned.

	* cmp.c (cmp): Change EOF message for POSIX compatibility.
	For -l format, clear bits > FF.

	* modechange.c (compile_mode): Only get umask value when needed.
	If users are not given or are `a', affect set?id and sticky bits.
	If memory is exhausted while allocating a new list element,
	free the old elements before returning.

	* Makefile (CC): Add comment noting that either fixincludes or
	-traditional needs to be used for gcc to compile ioctl calls
	correctly. 

Mon Mar 12 16:25:23 1990  Jim Kingdon  (kingdon at pogo.ai.mit.edu)

	* touch.c [UTIME_OF_NULL_MISSING]: Call lseek() before write().

	* posixtime.y [__GNUC__]: Use __builtin_alloca.

Fri Mar  9 10:25:09 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* chmod.c (main): Recognize "a,+-=" as valid options.

	* mv.c: Move the code to copy files across filesystems from
	do_move to a new function, copy, which will eventually be
	replaced with modules from cp and rm (POSIX requires mv to
	move directories recursively across filesystems).
	(do_move): Don't query about overriding a mode that prohibits
	writing if interactive.  Remove unneeded variable.
	(copy): Unlink target if copy fails partway through.

Thu Mar  8 10:56:16 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): Don't remove a destination file of a different
	type unless +force is given.

	* ls.c (decode_switches, usage): Add -U (for "unsorted") as an
	equivalent to +sort=none.

Mon Mar  5 17:21:00 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* tail.c: Move global `errors' into main instead of having
	nonfatal_perror set it.
	(tail, tail_chars, tail_file, tail_lines, pipe_chars, pipe_lines):
	Return an error status.
	(file_lines, start_chars, start_lines): Reverse the meaning of
	the return value.
	(tail_lines, tail_chars): Account for that reversal.

Mon Mar  5 16:31:14 1990  Torbj|rn Granlund  (tege at echnaton)

	* cp.c (copy): Test for temporarily modified permission mode
	  after the other test, so that `-p' work for files whose mode
	  needed a temporary mode change.
	* cp.c (copy): Don't waste time calling unlink if we already
	  know that the destination doesn't exists.
	* cp.c (comment before do_copy): Correct.
	* cp.c (comment before copy): Describe all params.
	* cp.c (copy): Only change permission mode for regular files
	  and directories.
	* cp.c (copy): Unlink the destination file if its type is
	  different from the source.  If the destination is a
	  directory,  error.

Mon Mar  5 00:34:36 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* chmod.c (nonfatal_perror): Don't check for force_silent.
	(change_file_mode, change_dir_mode): If force_silent, don't
	print error messages.

	* mv.c (main): If force, turn off interactive.
	(do_move): Simplify check for query.  Rename `stb' to
	`to_stats' and `stbf' to `from_stats'.
	Return error condition if original file could not be renamed or
	unlinked. 

	* rm.c: Rename global `force_flag' to `ignore_errors' and change its
	meaning so that it does not overlap with `override_mode'.
	(main): Have -f +force set override_mode.  If override_mode is
	set, turn off interactive.
	(rm): Simplify checks for whether to query the user, based on
	the new relationship between override_mode and interactive.

	* head.c: Move global `errors' into main and have the various
	functions return an error status instead of setting it in
	nonfatal_perror. 

Sun Mar  4 23:39:03 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c (main): Reword an error message to be more like mv's.

	* rmdir.c: Move global `errors' into main instead of having 
	error set it.

	* mkdir.c: Move global `errors' into main and have make_path
	return an error status instead of having error set it.

	* chmod.c: Move global `errors' into main and have
	change_file_mode and change_dir_mode return an error status
	instead of setting it in nonfatal_perror.

Sat Mar  3 13:59:40 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c (main): Don't strip leading dirs from argv[0].

	* ln.c (confirm), mv.c (yes, do_move),
	cp-aux.c (user_confirm_overwriting), rm.c (rm, yesno, check_stack):
	Print query messages to stderr instead of stdout, for POSIX.
	Include program name in messages.

Sat Mar  3 11:27:27 1990  Torbj|rn Granlund  (tege at echnaton)

	* cmp.c (cmp): Call function bcmp_cnt for flag == 0 (i.e. no
	  options specified), to compare the two blocks and count
	  newlines simultaneously.
	* cmp.c New function: bcmp_cnt.

	* cmp.c (main): Test if output is redirected to /dev/null, and
	  assume `-s' if this is so.

	* cp.c (copy): Don't unlink directories with flag_force
	  (`-f').  Also avoid using force when not necessary.
	  Always copy fifo's and symbolic links as themselves.

	* cp.c (copy_reg): Make int scan first, char scan then, to
	  find frist non-zero byte.  This to avoid false hole
	  creation.

Sat Mar  3 10:22:28 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* mv.c: Rename `pgm' to `program_name'.  Move global `errors'
	into main.  Have do_move and movefile return an error status
	instead having error set it.  Remove global vars `args'
	and `args_left'.
	(main): Rename `ac' and `av' to `argc' and `argv' and use them
	and `optind' instead of `args' and `args_left'.

	* cp.c (copy): Don't ignore errors other than EPERM from chown.

Fri Mar  2 16:20:57 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* rm.c (main, usage): Allow -R as a synonym for -r, for POSIX.

	* cp.c (copy): If flag_preserve, preserve the owner and group
	if possible, as well as mode.
	(main): Allow -R as a synonym for -r option, for POSIX.
	* cp-aux.c (usage): Mention -R.

Tue Feb 27 11:49:04 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cp.c (copy): If not recursive, copy special files and
	symlinks like regular files and omit fifos.

Mon Feb 26 19:55:24 1990  Jim Kingdon  (kingdon at pogo.ai.mit.edu)

	* ls.c (print_long_format): If time is in the future, print
	the year.
	Make the cutoff for old files 6 months not 300 days.

Mon Feb 26 13:31:07 1990  Jim Kingdon  (kingdon at pogo.ai.mit.edu)

	* touch.c, Makefile: Use getdate.y instead of unctime.y.

	* touch.c: Remove posixtime.
	(main): Check for error from posixtime.
	posixtime.y: New file.

	* touch.c: Change a few cryptic error messages.

	* touch.c: Include <errno.h> not <sys/errno.h>.

	* touch.c: just_set_amtime: New variable.
	(touch): Add if (just_set_amtime) code.

Mon Feb 26 15:03:29 1990  Torbj|rn Granlund  (tege at echnaton)

	* cp.c (copy): Test for recursive copy in DIR alternative in
	  the switch statement, so all file types are copied correctly
	  even in a non-recursive copy.
	* cp.c (copy): Return after having created a symlink, since
	  chmod and utimes dereference, and would affect the symlink
	  target.  Remove test for symlinks after switch.

Sun Feb 25 18:31:09 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile: Compile ls after vdir so systems with a cc that
	can't do -c -o don't have to compile ls.c twice for ls.

	* dd.c (usage): Add braces around alternatives.

	* ls.c (print_long_format): Always print the group, for POSIX.
	(decode_switches): Make -g option a no-op for BSD users.
	(usage): Remove +group option.

	* cat.c (main, usage): Add -c option, identical to -s, for
	POSIX.  Alphabetize short options.

Wed Feb 21 11:13:26 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c (error): New function.
	(main, do_link): Call error instead of fprintf and exit.
	(main): Recognize new -d +directory option to allow superuser to
	make hard links to dirs, like the BSD ln -f option.
	(do_link): Don't allow hard links to dirs (they are hard to
	get rid of -- rmdir and unlink don't do it), unless -d was given.
	(usage): Mention -d +directory option.

	* rmdir.c (main): Remove trailing slashes from args (added by
	shell file completion but the rmdir syscall can't handle them).
	* mkdir.c (main): Remove trailing slashes from args, for
	uniformity with rmdir (you can't do file completion on dirs
	that haven't been made yet . . .).

	* mv.c: Rename global var `nargs' to `args_left' to avoid
	conflict with undocumented BSD libc function (the new name is
	clearer, anyway).

Tue Feb 20 17:09:19 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* dd.c: Use new global var `program_name' in error messages
	instead of hardcoded "dd".
	(main): Set program_name from argv[0].

	* chmod.c, head.c, tail.c (main): Don't strip leading dirs
	from argv[0].
	(basename): Function removed.

	* rm.c (main): Don't strip leading dirs from argv[0].

	* cat.c: Change `argbad' from a char to a short, so it will
	work on machines with unsigned chars.

Mon Feb 19 14:34:18 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* rm.c (main): Strip trailing slashes from each arg.

Thu Feb 15 13:23:52 1990  David J. MacKenzie  (djm at rice-chex)

	* Makefile [HPUX CFLAGS]: Add -DUTIMES_MISSING.

Wed Feb 14 15:01:18 1990  David J. MacKenzie  (djm at rice-chex)

	* Makefile (dist): Don't make a non-compressed tar file.

	* mv.c (do_move): Refuse to copy non-regular files across filesystems.

Tue Feb 13 15:06:18 1990  Jim Kingdon  (kingdon at pogo.ai.mit.edu)

	* touch.c (getname): New function.
	(main): Use it.

Mon Feb 12 11:30:45 1990  David J. MacKenzie  (djm at rice-chex)

	* ln.c (do_link): Check error return from unlink.
	Include errno.h.

	* du.c (main): Check error return from stat.
	(str_copyc, str_concatc): Don't return a value, since it is
	ignored. 

	* cp.c (copy): Check error return from unlink and chmod.  Fix
	typo in call to error.

	* mv.c (do_move): Check error return of fchmod/chmod and utime[s].
	(rename): Check error return of unlink.

	* Makefile Definitions of preprocessor macros moved from
	cp.c and mv.c.  HAVE_FTRUNCATE changed to FTRUNCATE_MISSING.
	* Makefile, dirlib.c: NEED_MKDIR changed to MKDIR_MISSING.
	* mv.c, cp.c: Change USG ifdefs to UTIMES_MISSING.

Sun Feb 11 17:50:29 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* chmod.c (usage): Add yet another ellipsis.

Sun Feb 11 16:41:30 1990  Jim Kingdon  (kingdon at pogo.ai.mit.edu)

	* cp.c (copy_reg): Use HAVE_FTRUNCATE to decide whether to
	use ftruncate().
	(main): Use GETGROUPS_MISSING to decide whether to use getgroups().
	[hpux || !USG]: Define HAVE_FTRUNCATE.
	[USG && !hpux]: Define GETGROUPS_MISSING.
	mv.c (rename): Put in #ifdef RENAME_MISSING not #ifdef USG.
	(do_move): Use FCHMOD_MISSING to decide whether to use fchmod().
	[USG && !hpux]: Define FCHMOD_MISSING and RENAME_MISSING.

Sat Feb 10 02:16:40 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* cmp.c (cmp): Rename `r' to `first_diff', and `x' to `smaller'.
	Remove unneccessary variable `c1'.  If -l was given, increase
	`char_number' by the number of bytes read, after producing output,
	rather than by the offset of the first differing bytes, before
	producing output.
	Replace if-else-if constructions with case statements for clarity.
	(bcmp2): Rename `n' to `nread'.

Fri Feb  9 10:25:03 1990  David J. MacKenzie  (djm at rice-chex)

	* mv.c (movefile): Remove trailing slashes from FROM (some
	filename completion systems add them for dirs, and they cause
	the rename syscall to fail).

Thu Feb  8 22:50:12 1990  Torbj|rn Granlund  (tege at sics.se)

	* cp.c (copy_reg): Change error handling after lseek, since
	  this is a fatal error.  Also change error message to
	  something more generally understood.
	* Handle files that end in a zero block on USG systems.

	* cp-aux.c (error): Use FATAL to recog fatal errs.

Thu Feb  8 21:25:40 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* ln.c: Remove incorrect comment.

	* cp.c, cp-aux.c (usage): Change +dereference option to
	+no-dereference, since dereferencing is done by default and
	the option turns it off.

Mon Feb  5 17:29:20 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.0 released.

Local Variables:
mode: indented-text
left-margin: 8
version-control: never
End:
