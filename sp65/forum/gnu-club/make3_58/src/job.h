/*
 * MS-DOS port (c) 1990 by Thorsten Ohl <ohl@gnu.ai.mit.edu>
 *
 * To this port, the same copying conditions apply as to the
 * original release.
 *
 * IMPORTANT:
 * This file is not identical to the original GNU release!
 * You should have received this code as patch to the official
 * GNU release.
 *
 * MORE IMPORTANT:
 * This port comes with ABSOLUTELY NO WARRANTY.
 *
 * $Header: e:/gnu/make/RCS/job.h'v 3.58.0.2 90/07/17 03:32:50 tho Exp $
 */

/* Structure describing a running or dead child process.  */

struct child
  {
    struct child *next;		/* Link in the chain.  */

    struct file *file;		/* File being remade.  */

    char **environment;		/* Environment for commands.  */

    char *commands;		/* Commands being executed.  */
    char *command_ptr;		/* Pointer into above.  */
    unsigned int command_line;	/* Index into file->cmds->command_lines.  */

    int pid;			/* Child process's ID number.  */
    unsigned int remote:1;	/* Nonzero if executing remotely.  */

    unsigned int noerror:1;	/* Nonzero if commands contained a `-'.  */

    unsigned int good_stdin:1;	/* Nonzero if this child has a good stdin.  */
    unsigned int deleted:1;	/* Nonzero if targets have been deleted.  */
  };

extern struct child *children;

#ifdef MSDOS
extern  int _cdecl wait (int *status);
extern  void new_job (struct file *file);
extern  void block_children (void);
extern  void unblock_children (void);
#else /* not MSDOS */
extern void new_job ();
extern void wait_for_children ();
extern void block_children (), unblock_children ();
#endif /* not MSDOS */

#ifdef MSDOS
extern  void exec_command (char **argv, char **envp, char *path, char *shell);
#endif /* MSDOS */

extern char **construct_command_argv ();
extern void child_execute_job ();
extern void exec_command ();

extern unsigned int job_slots_used;
