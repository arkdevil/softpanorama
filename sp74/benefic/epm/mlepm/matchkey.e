/*****************************************************************************/
/*  Assist interface for E3      Ralph Yozzo                                 */
/*                                                                           */
/*  This macro is intended for use with programming language                 */
/*  which have tokens which must be balanced to compile correctly.           */
/*  We shall call these tokens "balanceable tokens" or BalTok for            */
/*  short.                                                                   */
/*                                                                           */
/*  The functions provided include moving from an opening token              */
/*  (e.g., (, {, [ ) to a closing token (e.g., ), }, ] ) and vice versa.     */
/*                                                                           */
/*  KEYS:                                                                    */
/*  Ctrl-[, Ctrl-]  -- move to corresponding BalTok                          */                                                           
/*                                                                           */
/*  CONSTANTS:                                                               */
/*  gold -BalTok tokens  are defined in the const gold and additional        */
/*        tokens may be added.                                               */
/*                                                                           */
/*  Example:                                                                 */
/*     if ((c=getch())=='c'                                                  */
/*      &&(d=complicatedisntit(e))){                                         */
/*      lookforbracket();                                                    */
/*     }                                                                     */
/* In the above program segment if one places the cursor on an opening       */
/* parenthesis and presses Ctrl-[ the cursor will move to the corresponding  */
/* closing parenthesis if one exists.  Pressing Ctrl-[ again will reverse    */
/* the process.                                                              */
/*                                                                           */
/* Modified by Larry Margolis to use the GREP option of Locate to search     */
/* for either the opening or closing token, rather than checking a line at   */
/* a time.  I also changed the key from Ctrl-A to Ctrl-[ or -], which are    */
/* newly allowed as definable keys, and deleted the matching of /* and */.   */
/* (The GREP search is much faster than the way Ralph did it, but doesn't    */
/* let you match either of 2 strings.)  Finally, the user's previous search  */
/* arguments are saved and restored, so Ctrl-F (repeatfind) will not be      */
/* affected by this routine.                                                 */
/* Modified by Martin Lafaix to mimic Emacs parent matching.  Opening tokens */
/* insert the matching one, too.  Don't use it if you don't like it! :-)     */
/*****************************************************************************/

const GOLD = '(){}[]<>'  -- Parens, braces, brackets & angle brackets.

def '('=
   keyin '()'; left

def '['=
   keyin '[]'; left

def '{'=
   keyin '{}'; left

def ')'=
   keyin ')'
   call massist()

def '}'=
   keyin '}'
   call massist()

def ']'=
   keyin ']'
   call massist()

defproc massist
compile if EVERSION >= '5.50'
   call psave_pos(savepos)
compile endif
   n=1
   c=substr(textline(.line),.col-1,1)
   GETSEARCH search_command -- Save user's search command.
   k=pos(c,GOLD)            --  '(){}[]'
   search = substr(GOLD,(k+1)%2*2-1,2)
   if search='[]' then search='\[\]'; endif
compile if EVERSION >= '5.60'
   if search='()' then search='\(\)'; endif
   'L /['search']/ex-R'
compile else
   'L /['search']/eg-R'
compile endif
   loop
      repeatfind
      if rc then leave; endif
      if substr(textline(.line), .col, 1) = c then n=n+1; else n=n-1; endif
      if n=0 then leave; endif
   endloop
   if rc=sayerror('String not found') then
      sayerror 'Unbalanced token.'
   else
compile if EVERSION >= '5.60'
   'L /['search']/ex+F'
compile else
   'L /['search']/eg+F'
compile endif
      sayerror 1
   endif
   SETSEARCH search_command -- Restores user's command so Ctrl-F works.
compile if EVERSION >= '5.50'
   call prestore_pos(savepos)
compile endif
