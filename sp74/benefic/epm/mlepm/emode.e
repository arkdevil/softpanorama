/* emode.e - this is the E part of the E mode package        940522 */

/* The enter and space bar keys have been defined to do             */
/* specific E3 editing features.                                    */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : E_mode.  It sets current editing mode to      */
/*   be E mode.                                                     */
/*                                                                  */
/* 940510: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adapting ekeys.e to hooks.                                     */
/*                                                                  */

/* This file is an adaptation of the EPM 'ekeys.e' E Macro file     */

compile if not defined(BLACK)
const
   my_e_keys_is_external = 1
   INCLUDING_FILE = 'EMODE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const my_e_keys_is_external = 0
compile endif

compile if my_e_keys_is_external = 1
   E_TABS = 3
   E_MARGINS = 1 MAXMARGIN 1
   WANT_CUA_MARKING = 'SWITCH'
   ASSIST_TRIGGER = 'ENTER'
   ENHANCED_ENTER_KEYS = 1
   ENTER_ACTION   = 'ADDATEND'
   c_ENTER_ACTION = 'ADDLINE'
   SYNTAX_INDENT = 3
compile endif

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
compile if my_e_keys_is_external = 0
   'maddhook load_hook e_load_hook'
compile endif

defc E_mode
   keys my_e_keys
   'msetfilemode E mode'
 
defc e_load_hook
   universal load_ext
   universal load_var
   if load_ext='E' then
 compile if E_TABS <> 0
      if not (load_var // 2) then  -- 1 would be on if tabs set from EA EPM.TABS
         'tabs' E_TABS
      endif
 compile endif
 compile if E_MARGINS <> 0
      if not (load_var%2 - 2*(load_var%4)) then  -- 2 would be on if tabs set from EA EPM.MARGINS
         'ma'   E_MARGINS
      endif
 compile endif
      'E_mode'
   endif

compile if WANT_CUA_MARKING & EPM
 defkeys my_e_keys clear
compile else
 defkeys my_e_keys
compile endif

def space=
   universal expand_on
   if expand_on then
      if  not my_e_first_expansion() then
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
   universal ML_autoindent
   universal expand_on

   if expand_on then
      if not my_e_second_expansion() then
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
         if ML_autoindent then
            call indent_pos()
         endif
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
;   if pos('/*',line) then
;      if not pos('*/',line) then                     
;         end_line;keyin' */'
;      endif
;   endif
;   down;begin_line

def c_x=       /* Force expansion if we don't have it turned on automatic */
   if not my_e_first_expansion() then
      call my_e_second_expansion()
   endif

defc indent_e_line
   call indent_pos()
compile endif  -- EXTRA

compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used
defproc my_e_first_expansion
   /*  up;down */
   retc=1
   if .line then
      getline line
      line=strip(line,'T')
      w=line
      wrd=upcase(w)
      if wrd='FOR' then
         replaceline w' =  to'
         insertline substr(wrd,1,length(wrd)-3)'endfor',.line+1
         if not insert_state() then insert_toggle
         endif
         keyin ' '
      elseif wrd='IF' then
         replaceline w' then'
         insertline substr(wrd,1,length(wrd)-2)'else',.line+1
         insertline substr(wrd,1,length(wrd)-2)'endif',.line+2
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      elseif wrd='ELSEIF' then
         replaceline w' then'
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      elseif wrd='WHILE' then
         replaceline w' do'
         insertline substr(wrd,1,length(wrd)-5)'endwhile',.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         keyin ' '
      elseif wrd='LOOP' then
         replaceline w
         insertline substr(wrd,1,length(wrd)-4)'endloop',.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT
;      elseif wrd='DO' then
;         replaceline w
;         insertline substr(wrd,1,length(wrd)-2)'enddo',.line+1
;         keyin ' '
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc my_e_second_expansion
   retc=1
   if .line then
      getline line
      parse value line with wrd rest
      firstword=upcase(wrd)
      if firstword='FOR' then
         /* do tabs to fields of pascal for statement */
         parse value upcase(line) with a '='
         if length(a)>=.col then
            .col=length(a)+3
         else
            parse value upcase(line) with a 'TO'
            if length(a)>=.col then
               .col=length(a)+4
            else
               call einsert_line()
               .col=.col+SYNTAX_INDENT
            endif
         endif
      elseif firstword='IF' or firstword='ELSEIF' or firstword='WHILE' or firstword='LOOP' or firstword='DO' or firstword='ELSE' then
         if pos('END'firstword, upcase(line)) then
            retc = 0
         else
            call einsert_line()
            .col=.col+SYNTAX_INDENT
            if firstword='LOOP' | firstword='DO' then
               insertline substr(line,1,.col-SYNTAX_INDENT-1)'end'lowcase(wrd), .line+1
            endif
         endif
      elseif pos('/*',line) then
;     elseif substr(firstword,1,2)='/*' then  /*see speed requirements */                                                                         
         if not pos('*/',line) then
            end_line;keyin' */'
         endif
         call einsert_line()
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc indent_pos  /* Indent current line */
   if .line then
      oldline=.line
      .line=.line-1
      while .line & textline(.line)='' do
         .line=.line-1
      endwhile
      if .line then
         call pfirst_nonblank()
         getline line
         line=strip(line,'T')
         parse value line with wrd rest
         i=verify(wrd,'({:','M',1)-1
         if i<=0 then i=length(wrd) endif
         firstword=upcase(substr(wrd,1,i))
         if firstword='FOR' then
            .col=.col+SYNTAX_INDENT
         elseif firstword='IF' or firstword='ELSEIF' or firstword='WHILE' or firstword='LOOP' or firstword='DO' or firstword='ELSE' then
            if pos('END'firstword, upcase(line)) = 0 then
               .col=.col+SYNTAX_INDENT
            endif
         endif
      else
         .col=1
      endif
      newpos=.col
      .line=oldline
      call pfirst_nonblank()
      if .col<newpos then
         for i=1 to newpos-.col 
            keyin ' '
         endfor
      elseif .col>newpos then
         delta=.col-newpos; .col=.col-delta
         for i=1 to delta
            deletechar
         endfor
      endif
   endif

compile endif  -- EXTRA
