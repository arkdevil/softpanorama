Tue Jul  3 01:59:39 1990  David J. MacKenzie  (djm at apple-gunkies)

	* Version 1.2.

	* Move version number from Makefile to new file version.c.
	* parser.c: Recognize new -version predicate.

	* find.c (main): If no predicates that produce output are
	given, default to -print if the entire expression is true, not
	just the last part of an alternation.
	* Print the names of predicates with invalid arguments.

Mon Jul  2 23:48:17 1990  David J. MacKenzie  (djm at apple-gunkies)

	* pred.c: Don't check for invalid comparison types in numeric
	predicate functions.

Thu Jun 28 00:34:57 1990  David J. MacKenzie  (djm at apple-gunkies)

	* parser.c (parse_regex): Set fastmap and translate before
	compiling regex.

Mon Jun 25 18:08:59 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* fastfind.c (fastfind): Initialize count to 0.

	* lib/updatedb.sh: Only do regex comparison on directories,
	for speed.

	* listfile.c (list_file): Truncate user and group name to 8 chars.

Sun Jun 24 13:51:27 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.1.

	* Makefile [DISTFILES]: Add COPYING.

Fri Jun 22 03:54:27 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Version 1.0.

Tue Jun 19 03:55:28 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* lib/updatedb.sh: Prune entries that match PRUNEREGEX.
	Split up finding files from computing bigrams.
	Use redirection instead of nonportable grep -s to detect sort
	failure.  Optionally search network filesystems as well as
	local ones.

	* pred.c (pred_regex): Match against full pathname instead of
	just last element.
	* util.c (basename): Return "/", not "", if given "/".

	* find.c (process_path): Fix error in handling "/" directory.

Mon Jun 18 01:49:16 1990  David J. MacKenzie  (djm at apple-gunkies)

	* parser.c [STRSPN_MISSING] (strspn): New function.

Sun Jun 17 13:54:09 1990  David J. MacKenzie  (djm at apple-gunkies)

	* listfile.c: New file.
	* parser.c (parse_ls): New function.
	* pred.c (pred_ls): New function.

	* find.c (main): Remove interface to fastfind, to prevent
	conflict with POSIX syntax.
	* util.c (usage): Remove fastfind syntax from message.
	* fastfind.c (main): New function.
	* Makefile: Make fastfind a separate program.

	* find.c (main): Print correct message if a predicate arg is
	missing. 

	* parser.c (insert_exec_ok): Make args that start with a ';' but
	contain other characters not terminate the command.

Fri Jun 15 00:33:45 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* fstype.c: If MOUNTED isn't defined but MNT_MNTTAB is, use it
	instead.  True for HP/UX, at least.

Thu Jun 14 10:10:25 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* savedir.c: New file; now find won't run out of file
	descriptors in deep trees.
	* find.c (process_path): Use savedir.

Sat Jun  9 03:15:21 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* parser.c (parse_permmask): Allow symbolic mode masks.
	(parse_perm): Free 'struct change' when done with it.
	(get_oct): Function removed.

	* find.c (process_path): Allow arbitrarily-long filenames.
	More efficient string copying.  Initialize perm_mask to 07777
	instead of -1.

Thu Jun  7 04:22:42 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Makefile, find.c: Use DIRENT to control whether <dirent.h>
	is used.

Thu May 31 04:46:11 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* parser.c (parse_regex): New function.
	* pred.c (pred_regex): New function.

	* fstype.c (read_mtab): If mtab entry has a "dev=" option
	(like in SunOS 4.1), use it, so there is no need to stat the
	special file later on.
	(xatoi, strstr): New functions.

Mon May 21 01:04:42 1990  David J. MacKenzie  (djm at abyss)

	* lib/updatedb.sh: Put BINDIR in PATH.

	* fstype.c: Do nothing if MNTENT_MISSING is defined.

	* fstype.c: New file.
	* parser.c (parse_fstype): New function.
	* pred.c (pred_fstype): New function.

	* parser.c (parse_newer): Failure to stat -newer file is a
	fatal error.

	* pred.c (pred_ok): Flush output before reading.  Use getchar
	instead of scanf.

	* pred.c (pred_prune): Return false if -depth given.
	* find.c: Apply the predicates to the dir when -depth and
	-prune are given.

Sun May 20 19:55:30 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* pred.c (pred_prune): Set new global var `stop_at_current_level'.
	* find.c (process_path): Test and reset it.

Fri May 18 01:56:17 1990  David J. MacKenzie  (djm at abyss)

	* modechange.c, modechange.h: New files.
	* parser.c (parse_perm): Use mode_compile and mode_adjust to
	parse arg, to allow symbolic mode for POSIX.

Thu May 17 02:07:44 1990  David J. MacKenzie  (djm at abyss)

	* parser.c (get_oct): Don't consider an empty string a valid number.

	* parser.c (parse_perm): If arg starts with '-', set flag bit
	for special comparison (POSIX).
	* pred.c (pred_perm): If flag bit set, compare s[ug]id &
	sticky bits as well, and return true if the given perms are
	set, ignoring other bits.

	* find.c: New global var `exit_status'.  Use it.  (POSIX)
	* parser.c: Set `exit_status' if lstat on -newer file fails.

	* fastfind.c: New file.
	* find.c (main): Call fastfind if given only 1 arg.
	* util.c (usage): Update message. 
	* lib/{Makefile,updatedb.sh,bigram.c,code.c}: New files.
	* Makefile: Add 'all' and 'install' targets.

Wed May 16 23:23:35 1990  David J. MacKenzie  (djm at abyss)

	* parser.c (parse_nogroup, parse_nouser): Implement.
	* pred.c (pred_nogroup, pred_nouser): Implement.

Mon May 14 00:09:35 1990  David J. MacKenzie  (djm at abyss)

	* find.c: Add variable `stay_on_filesystem' for -xdev.
	(process_path): Take an arg determining whether this call is
	the root of a tree.  Use lstat instead of stat.  If
	stay_on_filesystem, don't process a dir on a different
	filesystem. 

	* parser.c (parse_newer): Use lstat instead of stat.  Is this right?
	(parse_xdev): Set stay_on_filesystem.

	* parser.c: Add dummy parse_nogroup, parse_nouser,
	parse_prune, and parse_xdev; to be written later.
	* pred.c: Add dummy pred_nogroup, pred_nouser, pred_prune.

	* find.c: Support System V directory library/headers.

	* find.c (process_path): Don't continue with a file that stat
	fails on.

	* defs.h, parser.c, pred.c: Change 'u_long' and 'u_short' to
	'unsigned long' and 'unsigned short'.
	* find.c, defs.h: Remove 'convert_glob' variable.
	* parser.c (parse_fullregex): Function removed.
	(parse_name): Remove regular expression code.
	(parse_type): Recognize sockets.
	Add code to check for missing arguments to many parse_* functions.
	* pred.c (pred_name): Use glob_match instead of regex.

Sun May 13 17:45:09 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* Replace fprintf, simple_error, and mem_error with error and
	usage. 

	* Fix string header includes for USG.

Tue Mar 27 12:40:29 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* defs.h: Change some #defines to enums.

Sun Mar 25 22:08:58 1990  David J. MacKenzie  (djm at albert.ai.mit.edu)

	* find.c (main): Don't take basename of argv[0].

	* util.c (xmalloc): New function.
	* find.c, parser.c, utils.c: Use xmalloc instead of malloc.

	* pred.c: Remove emulation of regex for BSD and use GNU
	library version in regcmp.c instead.
	* parser.c: Remove emulation of regcmp for BSD and use GNU
	library version in regcmp.c instead.
	* Makefile: Link with regex.o and regcmp.o.
	Add a DISTFILES macro and dist target.

	* Indent source code.  Move RCS logs to this file.

87/02/22  20:01:20  20:01:20  cire (Eric B. Decker)

	* pred.c: added guts to pred_size

87/02/22  00:59:42  00:59:42  cire (Eric B. Decker)

	* pred.c: added guts to perm and permmask.

87/02/21  23:02:21  23:02:21  cire (Eric B. Decker)

	* pred.c: made pred_name only look at the last component of
	the path.

87/02/21  22:26:47  22:26:47  cire (Eric B. Decker)

	* pred.c: added guts to name.  useds regex and regcmp to do
	regular expression handling.

87/02/21  00:17:21  00:17:21  cire (Eric B. Decker)

	* pred.c: added predicate newer

87/02/20  11:40:07  11:40:07  cire (Eric B. Decker)

	* pred.c: added guts to pred_ok

87/02/19  23:52:37  23:52:37  cire (Eric B. Decker)

	* pred.c: finished exec.

87/02/22  20:01:09  20:01:09  cire (Eric B. Decker)

	* parser.c: added guts to parse_size

87/02/22  00:59:16  00:59:16  cire (Eric B. Decker)

	* parser.c: added guts of perm and permmask.  added getoct
	routine for perm and permmask

87/02/21  23:32:50  23:32:50  cire (Eric B. Decker)

	* parser.c: added -fre, -fullregex predicate to turn off
	globbing conversion

87/02/21  23:01:01  23:01:01  cire (Eric B. Decker)

	* parser.c: reworked name so the regexpr pattern includes $ at
	the end to force globbing to work correctly.  End of the
	pattern refers to the end of the filename.

87/02/21  22:25:34  22:25:34  cire (Eric B. Decker)

	* parser.c: added guts to name.  uses a conversion from
	globbing to regexp format.  uses regex and regcmp to actually
	to the comparison.

87/02/21  00:17:11  00:17:11  cire (Eric B. Decker)

	* parser.c: added predicate newer

87/02/20  11:39:35  11:39:35  cire (Eric B. Decker)

	* parser.c: added ok guts.  consolidated exec and ok to using
	insert_exec_ok

87/02/19  00:20:54  00:20:54  cire (Eric B. Decker)

	* parser.c: minor bug in -fulldays predicate parser.  It
	should have set the flag full_days to true.

87/02/22  00:58:32  00:58:32  cire (Eric B. Decker)

	* find.c: changed where we are setting perm_mask to -1.  need
	to make sure that this happens before every apply_predicate.

87/02/21  23:32:11  23:32:11  cire (Eric B. Decker)

	* find.c: added error checking for no paths.  better error
	message if illegal ordering.

87/02/21  22:19:58  22:19:58  cire (Eric B. Decker)

	* find.c: added global convert_glob

87/02/22  20:00:12  20:00:12  cire (Eric B. Decker)

	* defs.h: added definition of BLKSIZE for size

87/02/21  22:19:25  22:19:25  cire (Eric B. Decker)

	* defs.h: added global convert_glob for name

Local Variables:
mode: indented-text
left-margin: 8
version-control: never
End:
