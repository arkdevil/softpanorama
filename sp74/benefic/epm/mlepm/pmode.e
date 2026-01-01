/* pmode.e - this is the E part of the Pascal mode package   940522 */

/* The enter and space bar keys have been defined to do             */
/* specific Pascal editing features.                                */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : Pascal_mode.  It sets current editing mode to */
/*   be Pascal mode.                                                */
/*                                                                  */
/* 940510: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adapting pkeys.e to hooks.                                     */
/*                                                                  */

/* This file is an adaptation of the EPM 'pkeys.e' E Macro file     */

compile if not defined(BLACK)
const
   my_p_keys_is_external = 1
   INCLUDING_FILE = 'PMODE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const my_p_keys_is_external = 0
compile endif

compile if my_p_keys_is_external = 1
   P_TABS = 3
   P_MARGINS = 1 MAXMARGIN 1
   WANT_CUA_MARKING = 'SWITCH'
   ASSIST_TRIGGER = 'ENTER'
   ENHANCED_ENTER_KEYS = 1
   ENTER_ACTION   = 'ADDATEND'
   c_ENTER_ACTION = 'ADDLINE'
   SYNTAX_INDENT = 3
compile endif

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
compile if my_p_keys_is_external=0
   'maddhook load_hook p_load_hook'
compile endif

defc Pascal_mode
   keys my_pas_keys
   'msetfilemode Pascal Mode'
 
defc p_load_hook
   universal load_ext
   universal load_var
   if load_ext='PAS' or load_ext='PASCAL' then
 compile if P_TABS <> 0
      if not (load_var // 2) then  -- 1 would be on if tabs set from EA EPM.TABS
         'tabs' P_TABS
      endif
 compile endif
 compile if P_MARGINS <> 0
      if not (load_var%2 - 2*(load_var%4)) then  -- 2 would be on if tabs set from EA EPM.MARGINS
         'ma'   P_MARGINS
      endif
 compile endif
      'Pascal_mode'
   endif
compile endif

compile if WANT_CUA_MARKING & EPM
 defkeys my_pas_keys clear
compile else
 defkeys my_pas_keys
compile endif

compile if EVERSION >= 5
def space=
compile else
def ' '=
compile endif
   universal expand_on
   if expand_on then
      if  not pas_first_expansion() then
         keyin ' '
      endif
   else
      keyin ' '
   endif
   undoaction 1, junk                -- Create a new state

compile if ASSIST_TRIGGER = 'ENTER'
def enter=
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
   universal enterkey
 compile endif
compile else
def c_enter=
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
   universal c_enterkey
 compile endif
compile endif
   universal expand_on

   if expand_on then
      if not pas_second_expansion() then
compile if ASSIST_TRIGGER = 'ENTER'
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
         call enter_common(enterkey)
 compile else
         call my_enter()
 compile endif
compile else  -- ASSIST_TRIGGER
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
         call enter_common(c_enterkey)
 compile else
         call my_c_enter()
 compile endif
compile endif -- ASSIST_TRIGGER
      endif
   else
compile if ASSIST_TRIGGER = 'ENTER'
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
      call enter_common(enterkey)
 compile else
      call my_enter()
 compile endif
compile else  -- ASSIST_TRIGGER
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
      call enter_common(c_enterkey)
 compile else
      call my_c_enter()
 compile endif
compile endif -- ASSIST_TRIGGER
   endif

/* Taken out, interferes with some people's c_enter. */
;def c_enter=   /* I like Ctrl-Enter to finish the comment field also. */
;   getline line
;   if pos('{',line) then
;      if not pos('}',line) then
;         end_line;keyin' }'
;      endif
;   endif
;   down;begin_line

def c_x=       /* Force expansion if we don't have it turned on automatic */
   if not pas_first_expansion() then
      call pas_second_expansion()
   endif
compile endif  -- EXTRA

compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used
defproc pas_first_expansion
   retc=1
   if .line then
      getline line
      line=strip(line,'T')
      w=line
      wrd=upcase(w)
      if wrd='FOR' then
         replaceline w' :=  to  do begin'
         insertline substr(wrd,1,length(wrd)-3)'end; {endfor}',.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      elseif wrd='IF' then
         replaceline w' then begin'
         insertline substr(wrd,1,length(wrd)-2)'end else begin',.line+1
         insertline substr(wrd,1,length(wrd)-2)'end; {endif}',.line+2
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
     elseif wrd='WHILE' then
         replaceline w' do begin'
         insertline substr(wrd,1,length(wrd)-5)'end; {endwhile}',.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      elseif wrd='REPEAT' then
         replaceline w
         insertline substr(wrd,1,length(wrd)-6)'until  ; {endrepeat}',.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT
      elseif wrd='CASE' then
         replaceline w' of'
         insertline substr(wrd,1,length(wrd)-4)'end; {endcase}',.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc pas_second_expansion
   retc=1
   if .line then
      getline line
      parse value upcase(line) with 'BEGIN' +0 a /* get stuff after begin */
      parse value line with wrd rest
      firstword=upcase(wrd)
      if firstword='FOR' then
         /* do tabs to fields of pascal for statement */
         parse value upcase(line) with a ':='
         if length(a)>=.col then
            .col=length(a)+4
         else
            parse value upcase(line) with a 'TO'
            if length(a)>=.col then
               .col=length(a)+4
            else
               call einsert_line()
               .col=.col+SYNTAX_INDENT
            endif
         endif
      elseif a='BEGIN' or firstword='BEGIN' or firstword='CASE' or firstword='REPEAT' then  /* firstword or last word begin?*/
;        if firstword='BEGIN' then
;           replaceline  wrd rest
;           insert;.col=SYNTAX_INDENT+1
;        else
            call einsert_line()
            .col=.col+SYNTAX_INDENT
;        endif
      elseif firstword='VAR' or firstword='CONST' or firstword='TYPE' or firstword='LABEL' then
         if substr(line,1,2)<>'  ' or substr(line,1,3)='   ' then
            getline line2
            replaceline substr('',1,SYNTAX_INDENT)||wrd rest  -- <indent> spaces
            call einsert_line();.col=.col+SYNTAX_INDENT
         else
            call einsert_line()
         endif
      elseif firstword='PROGRAM' then
         /* make up a nice program block */
         parse value rest with name ';'
         getline bottomline,.last
         parse value bottomline with lastname .
         if  lastname = 'end.' then
            retc= 0     /* no expansion */
         else
;           replaceline  wrd rest
            call einsert_line()
            insertline 'begin {' name '}',.last+1
            insertline 'end. {' name '}',.last+1
         endif
      elseif firstword='UNIT' then       -- Added by M. Such
         /* make up a nice unit block */
         parse value rest with name ';'
         getline bottomline,.last
         parse value bottomline with lastname .
         if  lastname = 'end.' then
            retc= 0     /* no expansion */
         else
;           replaceline  wrd rest
            call einsert_line()
            insertline 'interface',.last+1
            insertline 'implementation',.last+1
            insertline 'end. {' name '}',.last+1
         endif
      elseif firstword='PROCEDURE' then
         /* make up a nice program block */
         name= getheading_name(rest)
;        replaceline  wrd rest
         call einsert_line()
         insertline 'begin {' name '}',.line+1
         insertline 'end; {' name '}',.line+2
      elseif firstword='FUNCTION' then
         /* make up a nice program block */
         name=getheading_name(rest)
;        replaceline  wrd rest
         call einsert_line()
         insertline 'begin {' name '}',.line+1
         insertline 'end; {' name '}',.line+2
      elseif pos('{',line) then
         if not pos('}',line) then
            end_line;keyin' }'
         endif
         call einsert_line()
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc getheading_name          /*  (heading ) name of heading */
   return substr(arg(1),1,max(0,verify(upcase(arg(1)),
                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')-1))
compile endif  -- EXTRA
