/* rexxmode.e - this is the E part of the Rexx mode package  940522 */

/* The enter and space bar keys have been defined to do             */
/* specific REXX editing features.                                  */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : REXX_mode.  It sets current editing mode to   */
/*   be REXX mode.                                                  */
/*                                                                  */
/* 940510: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adapting rexxkeys.e to hooks.                                  */
/*                                                                  */

/* This file is an adaptation of the EPM 'rexxkeys.e' E Macro file  */

compile if not defined(BLACK)
const
   my_rexx_keys_is_external = 1
   INCLUDING_FILE = 'REXXMODE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const my_rexx_keys_is_external = 0
compile endif

compile if my_rexx_keys_is_external = 1
   REXX_TABS = 3
   REXX_MARGINS = 1 MAXMARGIN 1
   WANT_CUA_MARKING = 'SWITCH'
   ASSIST_TRIGGER = 'ENTER'
   ENHANCED_ENTER_KEYS = 1
   ENTER_ACTION   = 'ADDATEND'
   c_ENTER_ACTION = 'ADDLINE'
   SYNTAX_INDENT = 3
compile endif

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
compile if my_rexx_keys_is_external = 0
   'maddhook load_hook rexx_load_hook'
compile endif

defc REXX_mode
   keys my_rexx_keys
   'msetfilemode REXX mode'
 
defc rexx_load_hook
   universal load_ext
   universal load_var
   if load_ext='BAT' | load_ext='CMD' | load_ext='EXC' | load_ext='EXEC' | load_ext='XEDIT' | load_ext='ERX' then
      getline line,1
      if substr(line,1,2)='/*' or (line='' & .last = 1) then
 compile if REXX_TABS <> 0
         if not (load_var // 2) then  -- 1 would be on if tabs set from EA EPM.TABS
            'tabs' REXX_TABS
         endif
 compile endif
 compile if REXX_MARGINS <> 0
         if not (load_var%2 - 2*(load_var%4)) then  -- 2 would be on if tabs set from EA EPM.MARGINS
            'ma'   REXX_MARGINS
         endif
 compile endif
         'REXX_mode'
      endif
   endif
compile endif

compile if WANT_CUA_MARKING & EPM
 defkeys my_rexx_keys clear
compile else
 defkeys my_rexx_keys
compile endif

def space=
   universal expand_on
   if expand_on then
      if not rex_first_expansion() then
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
   universal ML_autoindent

   if expand_on then
      if not rex_second_expansion() then
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
         if Ml_autoindent then
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

def c_x=       -- Force expansion if we don't have it turned on automatic
   if not rex_first_expansion() then
      call rex_second_expansion()
   endif

defc indent_rexx_line
   call indent_pos()
compile endif  -- EXTRA

compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used
defproc rex_first_expansion            -- Called by space bar
   retc = 0                            -- Default, enter a space
   if .line then
      w=strip(textline(.line),'T')
      wrd=upcase(w)
      If wrd='IF' Then
         replaceline w' then'
         insertline substr(wrd,1,length(wrd)-2)'else',.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
      elseif wrd='WHEN' Then
         replaceline w' then'
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
      elseif wrd='DO' Then
         insertline substr(wrd,1,length(wrd)-2)'end /* do */',.line+1                                    
;        if not insert_state() then insert_toggle endif
      endif
   endif
   return retc

defproc rex_second_expansion
   retc=1                               -- Default, don't insert a line
   if .line then
      getline line
      line = upcase(line)
      parse value line with firstword .
      c=max(1,verify(line,' '))-1  -- Number of blanks before first word.

      If firstword='SELECT' then
         insertline substr('',1,c+SYNTAX_INDENT)'when',.line+1
         insertline substr('',1,c /*+SYNTAX_INDENT*/)'otherwise',.line+2
         insertline substr('',1,c)'end  /* select */',.line+3
         '+1'                             -- Move to When clause
         .col = c+SYNTAX_INDENT+5         -- Position the cursor
      Elseif firstword = 'DO' then
         call einsert_line()
         .col=.col+SYNTAX_INDENT
      Elseif Pos('THEN DO',line) > 0 or Pos('ELSE DO',line) > 0 Then
         call einsert_line()
         .col=.col+SYNTAX_INDENT
         insertline substr('',1,c)'end  /* Do */',.line+1
;     Elseif pos('/*',line) then          -- Annoying to me, as I don't always
;        if not pos('*/',line) then       -- want a comment closed on that line                                                                                            
;           end_line;keyin' */'           -- Enable if you wish by uncommenting
;        endif
;        call einsert_line()
      Else
         retc = 0                         -- Insert a blank line
      Endif
   Else
      retc=0
   Endif
   Return(retc)

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
         i=verify(wrd,'({:;','M',1)-1
         if i<=0 then i=length(wrd) endif
         firstword=upcase(substr(wrd,1,i))
         if firstword = 'DO' | firstword='OTHERWISE' then
            .col=.col+SYNTAX_INDENT
         elseif pos('THEN DO',line) | pos('ELSE DO',line) then
            .col=.col+SYNTAX_INDENT
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