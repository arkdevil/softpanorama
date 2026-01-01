/*  swap.c - swap parent to disk, EMS, or XMS while executing child (MS-DOS)
    Copyright (C) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 1, or (at your option)
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    IMPORTANT:

    This code is not an official part of the GNU project and the
    author is not affiliated to the Free Software Foundation.
    He just likes their code and spirit.  */

static char RCS_id[] =
"$Header: e:/gnu/make/RCS/swap.c'v 0.11 90/07/23 18:34:29 tho Exp $";


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>
#include <sys/types.h>

#include <dos.h>

/* Add OFF to PTR, taking care of segment overflow  */
#define FP_ADD(ptr,off) \
  (FP_SEG (ptr) += (off) >> 4, FP_OFF (ptr) += (off) & 0xff, ptr)

/* Paragraph-align PTR.  */
#define FP_PARA_ALIGN(ptr)			\
  {						\
    FP_SEG (ptr)				\
      += ((FP_OFF (ptr) + 15) >> 4) + 1;	\
    FP_OFF (ptr) = 0x0000;			\
  }


/* generate inline code (usable in swapper!) */
#pragma intrinsic (memcpy)

/* don't call MS' stack checker (it will fail with the local stack!)  */
#pragma check_stack (off)


#define FILE_IO_BLKSIZE		0x8000
#define MAX_MSDOS_CMDLINE	126
#define MAX_MSDOS_PATH		144
#define MAX_MSDOS_MCBS		25


/* Atributte to force storage in the code segment! */
#define CODE _based (_segname ("_CODE"))

static off_t		CODE _swap_swapped_bytes;
static unsigned int	CODE _swap_handle;
static unsigned int	CODE _swap_psp;
static unsigned int	CODE _swap_resident_paras;
static unsigned int	CODE _swap_first_block_paras;


/* Parameters for DOS for creating a child process */
#pragma pack (1)
static struct
{
  _segment	environment_segment;
  char _far	*cmd_line_ptr;
  char _far	*fcb_ptr_1;
  char _far	*fcb_ptr_2;

}			CODE _swap_parameter_block;
#pragma pack ()

static char		CODE _swap_path[MAX_MSDOS_PATH];
static char		CODE _swap_cmdline[MAX_MSDOS_CMDLINE + 2];
static char		CODE _swap_fcb_1[16];	/* FCBs for DOS.  */
static char		CODE _swap_fcb_2[16];
static unsigned int	CODE _swap_environ_seg;
static unsigned int	CODE _swap_environment_size;
static int		CODE _swap_return_code;

static struct
{
  _segment	loc;
  unsigned int	len;
}			CODE _swap_orig_mcbs[MAX_MSDOS_MCBS];

/* This is a kludge to store _far pointers in the code segment.  */

static struct
{
  char _far *env;
  char _far *env_ptr;
  char _far *xms_fct;
  int (*swap_in_fct) (int handle, void _far * buffer, long bytes);
  int (*swap_out_fct) (int handle, void _far * buffer, long bytes);

}			 CODE __swap_far_ptrs;

#define _swap_environment	(__swap_far_ptrs.env)
#define _swap_environment_ptr	(__swap_far_ptrs.env_ptr)
#define _swap_xms_control	(__swap_far_ptrs.xms_fct)
#define _swap_in_function	(__swap_far_ptrs.swap_in_fct)
#define _swap_out_function	(__swap_far_ptrs.swap_out_fct)

#pragma pack (1)
static struct
{
  long	length;
  int	src_handle;
  long	src_offset;
  int	dest_handle;
  long	dest_offset;
}			CODE  _swap_xms_move_table;
#pragma pack ()


/* The local stack */
#define STACK_SIZE	0x200
static char		CODE _swap_local_stack[STACK_SIZE];
static unsigned int	CODE _swap_stack_pointer;
static _segment		CODE _swap_stack_segment;

/* This uses the first transient function to determine the end of the
   resident code.  */
#define FIRST_TO_SWAP	(&install_parameters)

/* MS-DOS interface */

#pragma pack (1)		/* won't fit, if we don't pack! */
struct mcb_info
{
  char		 id_byte;	/* 'M': not, 'Z': last MCB	*/
  unsigned short owner;		/* PSP of owner			*/
  unsigned short length;	/* length (in paragraphs = 16b)	*/
};
#pragma pack ()

static void _swap_fatal_error (char code, char CODE *msg, size_t len);
static int  _swap_free_block (_segment block);
static int  _swap_set_block (_segment block, unsigned int paras);
static unsigned int  _swap_allocate_block (unsigned int paras);
static void _swap_free_upper_blocks (void);
static void _swap_reclaim_upper_blocks (void);
static int  _swap_load_and_execute_program (void);

/* Disk I/O */

static unsigned int _swap_read (int handle, void _far * buffer, size_t bytes);
static unsigned int _swap_write (int handle, void _far * buffer, size_t bytes);
static int  _swap_rewind (int handle);
static int  _swap_write_to_handle (int handle, void _far * buffer, long size);
static int  _swap_read_from_handle (int handle, void _far * buffer, long size);


/* XMS */

static int _swap_xms_move_out (int handle, void _far * buffer, long bytes);
static int _swap_xms_move_in (int handle, void _far * buffer, long bytes);
static int _swap_xms_move (void);
static int xms_installed (void);
static void xms_get_control_function (void);
static unsigned int xms_allocate_memory (unsigned int kilobytes);
static unsigned int xms_free_memory (unsigned int handle);


/* EMS */

static int _swap_ems_save_page_map (int handle);
static int _swap_ems_restore_page_map (int handle);
static int _swap_ems_map_logical_page (int handle, int logical_page);
static int _swap_move_to_ems (int handle, void _far *buffer, long bytes);
static int _swap_move_from_ems (int handle, void _far *buffer, long bytes);
static int _swap_ems_present (void);
static int _swap_ems_alloc_pages (int n);
static int _swap_ems_free_pages (int handle);
static void _far *_swap_ems_get_page_frame (void);

/* Signal handling */

static void (_interrupt _far *_swap_caller_int23) (void);
static void _interrupt _far _swap_int23_handler (void);

static int	CODE _swap_user_interrupt = 0;	/* record interrupts  */
static char	CODE _swap_int23_handler_message[] =
  "\r\n\a\a\a*** User interrupt: waiting for child...\r\n\r\n";

/* "Higher" level code.  */

static void _swap_setup_environment (void);
static int  _swap_spawn_child (void);

static void install_parameters (char *path, char *cmdline, char *env,
				size_t size);
static struct mcb_info far *last_mcb (void);
static int  alloc_swap_file (char *name, long size);
static unsigned int cleanup_swap_file (unsigned handle, char *name);


/* The ONE and ONLY entry point */

enum swapping_mode { none, disk, ems, xms };

int spawn_child (enum swapping_mode mode, char *path, char *cmdline,
		 char *env, int len, char *swap_file);

/* Very Fatal Error messages.  */

static char CODE _swap_err_msg_head[] = \
  "\r\nFatal error in memory management. Aborting.\r\nReason: ";
static char CODE _swap_err_msg_0[] = "Can't reallocate core.";
static char CODE _swap_err_msg_1[] = "Can't swap code back.";
static char CODE _swap_err_msg_2[] = "Can't release core.";
static char CODE _swap_err_msg_3[] = "Too many MCBs.";

#define SWAP_FATAL_ERROR(num) \
  _swap_fatal_error (-1, _swap_err_msg_##num, sizeof (_swap_err_msg_##num))


void
_swap_setup_environment (void)
{
  _swap_resident_paras = FP_SEG (_swap_environment) - _swap_psp;

  if (_swap_environment_size && *_swap_environment_ptr)
    {
      memcpy (_swap_environment, _swap_environment_ptr,
	      _swap_environment_size);
      _swap_resident_paras += (_swap_environment_size + 15) >> 4;
      _swap_environ_seg = FP_SEG (_swap_environment);
    }
  else
    _swap_environ_seg = 0;	/* pass our own environment */
}


/* Memory management.

   WARNING:  this used undocumented MS-DOS features.

   This features seem to be very stable anyway (Microsoft obviously uses
   them in their own programs and since they won't want to break them,
   these feaatures shouldn't go away.  */

/* Does this MCB belong to us?  */
#define OUR_MCB(mcb) ((mcb)->owner == _swap_psp)

/* Return a pointer to OUR first MCB */
#define FIRST_MCB(mcb) \
  (FP_SEG (mcb) = _swap_psp - 1, FP_OFF (mcb) = 0, mcb)

/* Return a pointer to the next MCB */
#define NEXT_MCB(mcb) \
  (FP_SEG (mcb) = FP_SEG (mcb) + mcb->length + 1, mcb)

int
_swap_free_block (_segment block)
{
  _asm
    {
      mov	ax, block;
      mov	es, ax;
      mov	ah, 0x49		/* MS-DOS Free Allocated Memory */
      int	0x21
      jc	failed
      xor	ax, ax;			/* success */
    failed:
    }
}

int
_swap_set_block (_segment block, unsigned int paras)
{
  _asm
    {
      mov	ax, block
      mov	es, ax
      mov	bx, paras
      mov	ah, 4ah			/* MS-DOS Set Block */
      int	0x21
      jc	failed
      xor	ax, ax			/* success */
    failed:
    }
}


static unsigned int
 _swap_allocate_block (unsigned int paras)
{
  _asm
    {
      mov	bx, paras
      mov	ah, 0x48	/* MS-DOS Allocate Memory */
      int	0x21
      jnc	done
      mov	ax, 0x0000	/* failed */
    done:
    }
}


/* Free, one by one, the memoy blocks owned by us.  This excluded the
   first block, which will be shrunk later.  _swap_orig_mcbs will be
   zero-terminated. */

void
_swap_free_upper_blocks (void)
{
  int i = 0;
  struct mcb_info far *mcb;

  FIRST_MCB (mcb);

  while (mcb->id_byte == 'M')
    {
      NEXT_MCB (mcb);	/* leave the first block intact (for the moment)  */

      if (OUR_MCB (mcb))
	{
	  if (i >= MAX_MSDOS_MCBS)
	    SWAP_FATAL_ERROR (3);
	  if (_swap_free_block (FP_SEG (mcb) + 1))
	    SWAP_FATAL_ERROR (2);
	  _swap_orig_mcbs[i].loc = FP_SEG (mcb) + 1;
	  _swap_orig_mcbs[i].len = mcb->length;
	  i++;
	}
    }
  _swap_orig_mcbs[i].loc = 0x000;
}


/* Reclaim, one by one, the original memory blocks, as stored in
   _swap_orig_mcbs.  From the MS-DOS point of view, this should be not
   necessary, since MS-DOS keeps (to my knowledge) no internal record of
   the memory allocation and the original MCBs are restored together with
   the image.  But in this way we can catch the fatal condition when the
   child has (illegally) left a resident grandchild.  Also we will be
   warned if our methos fails with future MS-DOS versions.  */

void
_swap_reclaim_upper_blocks (void)
{
  int i = 0;

  while (_swap_orig_mcbs[i].loc != 0x000)
    if (_swap_allocate_block (_swap_orig_mcbs[i].len)
	!= _swap_orig_mcbs[i].loc)
      SWAP_FATAL_ERROR (0);
    else
      i++;
}


int
_swap_load_and_execute_program (void)
{
  _swap_parameter_block.environment_segment = _swap_environ_seg;
  _swap_parameter_block.cmd_line_ptr = (char _far *) &_swap_cmdline;
  _swap_parameter_block.fcb_ptr_1 = (char _far *) &_swap_fcb_1;
  _swap_parameter_block.fcb_ptr_2 = (char _far *) &_swap_fcb_2;

  /* The compiler saves si and di by himself.  */

  _asm
    {
      push	ds		/* save ds */

      mov	ax, cs		/* let es and ds point into code segment */
      mov	es, ax
      mov	ds, ax

      mov	si, offset _swap_cmdline	/* parse commandline */
      mov	di, offset _swap_fcb_1		/* create first FCB */
      mov	ax, 0x2901		 /* MS-DOS Parse File Name */
      int	0x21
      mov	di, offset _swap_fcb_2		/* create second FCB */
      mov	ax, 0x2901		  /* MS-DOS Parse File Name */
      int	0x21
      mov	bx, offset _swap_parameter_block /* es:bx */
      mov	dx, offset _swap_path		 /* ds:dx */

      mov	ax, 0x4b00		/* MS-DOS Load and Execute Program */
      int	21h
      mov	ax, 0ffffh		/* assume failure */
      jc	failed

      mov	ah, 0x4d		/* MS-DOS Get Return Code of Child */
      int	21h
      mov	_swap_return_code, ax	/* store return code */

    failed:
      pop	ds		/* restore ds */
    }
}

int
_swap_spawn_child (void)	/* CAN'T TAKE PARAMETERS! */
{
  /* void */			/* CAN'T HAVE LOCAL VARIABLES!  */

	/* FROM HERE ON: DON'T REFER TO THE GLOBAL STACK! */
  _asm
    {
      mov	cs:_swap_stack_pointer, sp	/* save stack position */
      mov	cs:_swap_stack_segment, ss
      cli					/* Interrupts off */
      mov	ax, seg _swap_local_stack	/* Change stack */
      mov	ss, ax				/* Point to top of new stack */
      mov	sp, offset _swap_local_stack + STACK_SIZE
      sti					/* Interrupts on */
    }

  if ((*_swap_out_function) (_swap_handle, _swap_environment,
			     _swap_swapped_bytes))
    return -1;

  _swap_setup_environment ();
  _swap_free_upper_blocks ();
  _swap_set_block (_swap_psp, _swap_resident_paras);

  _swap_load_and_execute_program ();		/* !!! BIG DEAL !!! */

  if (_swap_set_block (_swap_psp, _swap_first_block_paras))
    SWAP_FATAL_ERROR (0);
  _swap_reclaim_upper_blocks ();

  if ((*_swap_in_function) (_swap_handle, _swap_environment,
			     _swap_swapped_bytes))
    SWAP_FATAL_ERROR (1);

  _asm
    {
      mov	ax, cs:_swap_stack_pointer	/* get saved stack position */
      mov	bx, cs:_swap_stack_segment
      cli					/* Interrupts off */
      mov	ss, bx				/* Change stack */
      mov	sp, ax
      sti					/* Interrupts on */
    }
	/* THE GLOBAL STACK IS SAVE AGAIN! */

  return _swap_return_code;

}



/* Display LEN bytes from string MSG and *immediately* return to DOS,
   with CODE as return code.  This is a panic exit, only to be used
   as a last resort.			~~~~~~~~~~			*/

void
_swap_fatal_error (char code, char CODE *msg, size_t len)
{
  _asm
    {
      mov	ax, cs		/* ds = cs */
      mov	ds, ax
      mov	bx, 0x02	/* /dev/stderr */
      mov	dx, offset _swap_err_msg_head
      mov	cx, length _swap_err_msg_head
      mov	ah, 0x40	/* MS-DOS Write Handle */
      int	0x21
      mov	dx, msg		/* message */
      mov	cx, len		/* length */
      mov	ah, 0x40
      int	0x21
      mov	al, code	/* bail out */
      mov	ah, 0x4c	/* MS-DOS End Process */
      int	0x21
    }
}


/* Lowest level disk I/0:  */

/* Write SIZE bytes from BUFFER to HANDLE.  Returns 0 on success, -1 on
   failure.  */

int
_swap_write_to_handle (int handle, void _far *buffer, off_t size)
{
  while (size > 0L)
    {
      size_t bytes = (size_t) min (size, FILE_IO_BLKSIZE);
      size_t bytes_written = _swap_write (handle, buffer, bytes);
      if (bytes_written != bytes)
	return -1;
      FP_ADD (buffer, bytes);
      size -= bytes;
    }

  return 0;
}

size_t
_swap_write (int handle, void _far *buffer, size_t bytes)
{
  _asm
    {
      push	ds
      mov	dx, word ptr buffer	/* offset */
      mov	ax, word ptr buffer + 2	/* segment */
      mov	ds, ax
      mov	bx, handle
      mov	cx, bytes
      mov	ah, 0x40		/* MS-DOS Write Handle */
      int	0x21
      jnc	done
      mov	ax, 0xffff
    done:
      pop	ds
    }
}


/* Read SIZE bytes from HANDLE to BUFFER.  Returns 0 on success, -1 on
   failure.  */

int
_swap_read_from_handle (int handle, void _far *buffer, off_t size)
{
  _swap_rewind (handle);

  while (size > 0L)
    {
      size_t bytes = (size_t) min (size, FILE_IO_BLKSIZE);
      size_t bytes_read = _swap_read (handle, buffer, bytes);
      if (bytes_read != bytes)
	return -1;
      FP_ADD (buffer, bytes);
      size -= bytes;
    }

  return 0;
}

size_t
_swap_read (int handle, void _far *buffer, size_t bytes)
{
  _asm
    {
      push	ds
      mov	dx, word ptr buffer	/* offset */
      mov	ax, word ptr buffer + 2 /* segment */
      mov	ds, ax
      mov	bx, handle
      mov	cx, bytes
      mov	ah, 0x3f		/* MS-DOS Read Handle */
      int	0x21
      jnc	done
      mov	ax, 0xffff
    done:
      pop	ds
    }
}


/* Rewind the file pointer for HANDLE to the beginning of the file.  */

int
_swap_rewind (int handle)
{
  _asm
    {
      mov	bx, handle
      mov	cx, 0x0000	/* offset = 0 */
      mov	dx, 0x0000
      mov	ax, 0x4200	/* MS-DOS Move File Pointer, (beginning) */
      int	0x21
      jc	failed
      mov	ax, 0x0000
    failed:
    }
}

/* XMS interface */

int
_swap_xms_move_out (int handle, void _far *buffer, long bytes)
{
  _swap_xms_move_table.length = bytes;
  _swap_xms_move_table.src_handle = 0x0000;
  _swap_xms_move_table.src_offset = (long) buffer;
  _swap_xms_move_table.dest_handle = handle;
  _swap_xms_move_table.dest_offset = 0L;

  _swap_xms_move ();
}

int
_swap_xms_move_in (int handle, void _far *buffer, long bytes)
{
  _swap_xms_move_table.length = bytes;
  _swap_xms_move_table.dest_handle = 0x0000;
  _swap_xms_move_table.dest_offset = (long) buffer;
  _swap_xms_move_table.src_handle = handle;
  _swap_xms_move_table.src_offset = 0L;

  _swap_xms_move ();
}

int
_swap_xms_move (void)
{
  _asm
    {
      push	ds
      mov	si, offset _swap_xms_move_table
      mov	ax, seg _swap_xms_move_table
      mov	ds, ax
      mov	ah, 0x0b
      call	far ptr cs:[_swap_xms_control]
      cmp	ax, 0x0001
      jne	failed
      mov	ax, 0x0000
      jmp	done
    failed:
      mov	ax, 0xffff
    done:
      pop	ds
    }
}


#if 0

/* EMS interface */

#define PHYSICAL_PAGE	0x00

int
_swap_move_to_ems (int handle, void _far *buffer, long bytes)
{
  int logical_page = 0;

  while (paras > 0)
    {
      unsigned int bytes = min (paras, 0x0400) << 4;
      paras -= bytes >> 4;
      if (ems_map_logical_page (handle, logical_page++))
	return -1;
      memcpy (swappee.ems_page_frame, &msdos_child_environment, bytes);
    }

  return 0;
}


int
_swap_move_from_ems (int handle, void _far *buffer, long bytes)
{
  int logical_page = 0;

  while (paras > 0)
    {
      unsigned int bytes = min (paras, 0x0400) << 4;
      paras -= bytes >> 4;
      if (ems_map_logical_page (handle, logical_page++))
	return -1;
      memcpy (&msdos_child_environment, swappee.ems_page_frame, bytes);
    }

  return 0;
}


int
_swap_ems_map_logical_page (int handle, int logical_page)
{
  _asm
    {
      mov	dx, handle
      mov	bx, logical_page
      mov	ax, 0x4400 + PHYSICAL_PAGE	/* EMS Map Page */
      int	0x67
      mov	cl,  8				/* "mov ax, ah" */
      shr	ax, cl
    }
}

void
_swap_ems_save_page_map (int handle)
{
  _asm
    {
      mov	dx, handle
      mov	ah, 0x47			/* EMS Save Page Map */
      int	0x67
      mov	cl,  8				/* "mov ax, ah" */
      shr	ax, cl
    }
}

void
_swap_ems_restore_page_map (int handle)
{
  _asm
    {
      mov	dx, handle
      mov	ah, 0x48			/* EMS Restore Page Map */
      int	0x67
      mov	cl,  8				/* "mov ax, ah" */
      shr	ax, cl
    }
}

#endif /* NEVER */

/* Signal handling */

/* Simple ^C handler that displays a short message and waits for the child
   to return.  Set a flag _swap_user_interrupt which can be used to
   determine, whether such an event occured.
   Note:  resetting the C library signals is NOT enough, since even the
   default handlers use at least some library code.  */

void _interrupt _far
_swap_int23_handler (void)
{
  _swap_user_interrupt = 1;

  _asm
    {
      sti			/* want to access DOS */
      mov	ax, cs		/* ds = cs */
      mov	ds, ax
      mov	bx, 0x02	/* /dev/stderr */
      mov	dx, offset _swap_int23_handler_message
      mov	cx, length _swap_int23_handler_message
      mov	ah, 0x40	/* MS-DOS Write Handle */
      int	0x21
    }
}

/* The transient part starts here. */
#pragma check_stack ()

/* Install the global parameters.  Execute this as the first function, since
   some macros need _swap_psp with the correct value.  */

void
install_parameters (char *path, char *cmdline, char *env, size_t size)
{
  size_t len = strlen (cmdline);
  struct mcb_info far *mcb;

  _fstrcpy ((char _far *) _swap_path, (char _far *) path);

  *_swap_cmdline = (char) len;
  _fstrcpy ((char _far *) _swap_cmdline + 1, (char _far *) cmdline);
  _swap_cmdline[len+1] = '\r';

  _swap_environment_ptr = env;	/* this will be copied later */
  _swap_environment_size = size;

  _swap_psp = _psp;	/* put them into a save place. */
  _swap_first_block_paras = FIRST_MCB (mcb)->length;
}


/* Allocate a swap file named NAME, making sure that at least SIZE bytes
   are available on the disk.  Returns a MS-DOS handle (not to be
   confused with a C file-descriptor!).  */

int
alloc_swap_file (char *name, off_t size)
{
  struct diskfree_t disk_free;
  unsigned drive;
  off_t free;
  int handle;

  if (name == NULL || *name == '\0')	/* could create filename ourselves. */
    return -1;

  if (name[1] == ':')
    drive = tolower (*name) - 'a' + 1;
  else
    /* Get current drive. */
    _dos_getdrive (&drive);

  _dos_getdiskfree (drive, &disk_free);

  free = (off_t) disk_free.avail_clusters *
    (off_t) disk_free.sectors_per_cluster * (off_t) disk_free.bytes_per_sector;

  if (free < size)
    return (-1);

  if (_dos_creat (name, _A_NORMAL, &handle))
    return (-1);
  else
    return handle;
}

/* Close and delete the temporary file.  */

unsigned int
cleanup_swap_file (unsigned int handle, char *name)
{
  return !_dos_close (handle) && !unlink (name);
}


/* More XMS */
/* Microsoft's recommendation:  */

int
xms_installed (void)
{
  _asm
    {
      mov	ax, 0x4300
      int	0x2f
      cmp	al, 0x80
      jne	failed
      mov	ax, 0x0001
      jmp	done
    failed:
      mov	ax, 0x0000
    done:
    }
}

void
xms_get_control_function (void)
{
  _asm
    {
      mov	ax, 0x4310
      int	0x2f
      mov	word ptr cs:_swap_xms_control, bx
      mov	bx, es
      mov	word ptr cs:_swap_xms_control + 2, bx
    }
}

unsigned int
xms_allocate_memory (unsigned int kilobytes)
{
  _asm
    {
      mov	dx, kilobytes
      mov	ah, 0x09
      call	far ptr cs:[_swap_xms_control]
      cmp	ax, 0x0001
      jne	failed
      mov	ax, dx
      jmp	done
    failed:
      mov	ax, 0xffff
    done:
    }
}

unsigned int
xms_free_memory (unsigned int handle)
{
  _asm
    {
      mov	dx, handle
      mov	ah, 0x0a
      call	far ptr cs:[_swap_xms_control]
      cmp	ax, 0x0001
      je	done
      mov	ax, 0x0000
    done:
    }
}


#if 0

/* More EMS */

/* Test for presence of LIM EMS 4.0.
   (this procedure is taken from the LIM specification).  */

int
_swap_ems_present (void)
{
  static char _far ems_id[] = "EMMXXXX0"; /* LIM EMS 4.0 identification. */
  char _far *ems_device = (char _far *) _dos_getvect (0x67);

  FP_OFF (ems_device) = 0x000a;

  return !_fstrcmp (ems_id, ems_device);
}

/* Allocate pages from the EMS Manager.  Returns handle or -1 no error.  */

int
_swap_ems_alloc_pages (int n)
{
  _asm
    {
      mov	bx, n
      mov	ah, 0x43	/* EMS Allocate Pages */
      int	0x67
      cmp	ah, 0x00
      jz	success
      mov	ax, 0xffff	/* failure */
      ret
    success:
      mov	ax, dx		/* return handle */
    }
}

/* Free pages allocated for HANDLE.  Returns 0 if successful.  */

int
_swap_ems_free_pages (int handle)
{
  _asm
    {
      mov	dx, handle
      mov	ah, 0x45	/* EMS Free Pages */
      int	0x67
      mov	cl, 8		/* "mov ax, ah" */
      shr	ax, cl
    }
}

/* Return far pointer to EMS page frame.  */

void _far *
_swap_ems_get_page_frame (void)
{
  void _far *frame = (void _far *) 0;

  _asm
    {
      mov	ah, 0x41		/* EMS Page Frame */
      int	0x67
      cmp	ah, 0x00
      jz	success
      ret				/* failure */
    success:
      mov	word ptr frame + 2, bx	/* segment of page frame */
    }

  return frame;
}

#endif /* NEVER */

/* Return the last MCB owned by us.
   WARNING:  This assumes that _swap_psp has already been set to _PSP
	     (e.g. by install_parameters())   */

struct mcb_info far *
last_mcb (void)
{
  struct mcb_info far *mcb;
  struct mcb_info far *ret;

  FIRST_MCB (mcb);

  while (mcb->id_byte == 'M')
    {
      if (OUR_MCB (mcb))
	ret = NEXT_MCB (mcb);
      else
	NEXT_MCB (mcb);
    }

  if (mcb->id_byte == 'Z')	/* found the end */
    return ret;
  else				/* error */
    return NULL;
}


/* MODE is the preferred swapping mode, if XMS or EMS are requested but not
   available, it is mapped to DISK.  PATH is the complete path of the program
   to be executed, it must not be longer than MAX_MSDOS_PATH (=144).  CMDLINE
   is the commandline to be passed to the program, it must not be longer than
   MAX_MSDOS_CMDLINE (=126).  ENV is a well formed MS-DOS environment of
   length LEN, including the terminating '\0's.  FILE is a valid filename,
   which will be used for a possible disk swap file.  */

int
spawn_child (enum swapping_mode mode, char *path, char *cmdline, char *env,
	     int len, char *file)
{
  int rc;
  unsigned int (*cleanup_function) (unsigned int handle,...);

  install_parameters (path, cmdline, env, len);

  _swap_environment = (char _far *) FIRST_TO_SWAP;
  FP_PARA_ALIGN (_swap_environment);

  _swap_swapped_bytes = (long) ((char _huge *) last_mcb ()
			- (char _huge *) _swap_environment);

  switch (mode)
    {
    case ems:			/* not implemented yet */
      /* fall through */

    case xms:
      if (xms_installed ())
	{
	  xms_get_control_function ();
	  _swap_out_function = _swap_xms_move_out;
	  _swap_in_function = _swap_xms_move_in;
	  cleanup_function = xms_free_memory;
	  _swap_handle = xms_allocate_memory (
	    (unsigned int) ((_swap_swapped_bytes + 0x03ff) >> 10) + 1);
	  if (_swap_handle != -1)
	    break;
	}
      /* fall through */

    case disk:
      _swap_out_function = _swap_write_to_handle;
      _swap_in_function = _swap_read_from_handle;
      cleanup_function = cleanup_swap_file;
      _swap_handle = alloc_swap_file (file, _swap_swapped_bytes);
      if (_swap_handle == -1)
	{
	  fprintf (stderr, "Out of swap space!\n");
	  exit (0);
	}
    }

  _swap_user_interrupt = 0;
  _swap_caller_int23 = _dos_getvect (0x23);	/* temporarily disable ^C  */
  _dos_setvect (0x23, _swap_int23_handler);

  rc = _swap_spawn_child ();

  if (_swap_user_interrupt)			/* did the user hit ^C ? */
    rc = 0xffff;
  _dos_setvect (0x23, _swap_caller_int23);

  cleanup_function (_swap_handle, file);

  return rc;
}


/* 
 * Local Variables:
 * mode:C
 * minor-mode:auto-fill
 * ChangeLog:ChangeLog
 * compile-command:make
 * End:
 */
