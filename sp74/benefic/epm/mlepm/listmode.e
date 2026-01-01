/* listmode.e - this is the E part of the List mode package  940522 */

/* The space bar key has been defined to do specific List editing   */
/* features.                                                        */
/*                                                                  */
/* [List means files like 00index.txt, or dir, or ...]              */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : List_mode.  It sets current editing mode to   */
/*   be List mode.                                                  */
/*                                                                  */
/* 940521: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adapting rexxmode.e to listmode.e.                             */
/*                                                                  */

/* This file is an adaptation of the EPM 'rexxkeys.e' E Macro file  */

compile if not defined(BLACK)
const
   my_list_keys_is_external = 1
   INCLUDING_FILE = 'LISTMODE.E'
   EXTRA_EX = 0
   WANT_CUA_MARKING = 'SWITCH'
   include 'stdconst.e'
compile else
   const my_list_keys_is_external = 0
compile endif

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
compile if my_list_keys_is_external = 0
   'maddhook load_hook list_load_hook'
compile endif

defc List_mode
   keys my_list_keys
   'msetfilemode List mode'
   'msetselectedsize 0'
 
defc list_load_hook
   universal load_ext
   universal load_var
   if load_ext='LIST' | rightstr(upcase(.filename),11)='00INDEX.TXT' then
      'List_mode'
   endif
compile endif

compile if WANT_CUA_MARKING & EPM
 defkeys my_list_keys clear
compile else
 defkeys my_list_keys
compile endif

def 'u', 'U'=
   oldmod=.modify
   'munhilitefile'
   'msetselectedsize 0 *'
   .modify=oldmod

def 'l', 'L'=
   'mfindselected'
 
def space=
   oldmod=.modify
   call psave_mark(savemark)
   unmark; mark_line
   class=0; line=.line; col=1; off=-255
   attribute_action 1, class, off, col, line
   if class<>0 & line=.line then
      'munhilitemark'
      sign='-'
   else
      'process_style Selected'
      sign='+'
   endif
   getline line
   parse value line with wrd rest
   do while wrd<>'' & verify(wrd,'0123456789')
      parse value rest with wrd rest
   enddo
   if wrd='' then
      size=0
   else
      size=wrd
   endif
   'msetselectedsize' size sign
   call prestore_mark(savemark)
   .modify=oldmod

defc mfindselected=
   getfileid start_fid
   'xcom e /c .selected'
   .autosave=0
   getfileid tools_fid
   'mfind' start_fid tools_fid 'Selected'
   .modify=0
 
defc mmoveselected
   sayerror 'Not yet implemented... Sorry'
compile endif  -- EXTRA

compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used

defc msetselectedsize
   universal ML_array_ID
   parse arg size sign
   getfileid fileid
   call get_array_value(ML_array_ID, fileid'.selected.size',  oldsize)
   call get_array_value(ML_array_ID, fileid'.selected.count', oldcount)
   if sign='+' then
      oldsize = oldsize+size; oldcount=oldcount+1
   elseif sign='-' then
      oldsize = oldsize-size; oldcount=oldcount-1
   else
      oldsize=size; oldcount=0
   endif
   do_array 2, ML_array_ID, fileid'.selected.size', oldsize
   do_array 2, Ml_array_ID, fileid'.selected.count', oldcount
   if sign='+' | sign='-' | sign='*' then
      if oldcount>1 then
         'setstatusline Line %l of %s   'oldcount' Items selected ['oldsize' bytes] List mode     %m'
      else
         'setstatusline Line %l of %s   'oldcount' Item selected  ['oldsize' bytes] List mode     %m'
      endif
   endif
 
compile endif  -- EXTRA
