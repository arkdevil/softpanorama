/* rcmode.e - this is the E part of the RC mode package      940522 */

/* The enter and space bar keys have been defined to do             */
/* specific RC editing features.                                    */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : RC_mode.  It sets current editing mode to     */
/*   be RC mode.                                                    */
/*                                                                  */
/* 940516: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adapting ekeys.e to RC and hooks.                              */
/*                                                                  */

/* This file is an adaptation of the EPM 'ekeys.e' E Macro file     */

compile if not defined(BLACK)
const
   my_rc_keys_is_external = 1
   INCLUDING_FILE = 'RCMODE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const my_rc_keys_is_external = 0
compile endif
compile if not defined(I_like_uppercase_keyword)
   const I_like_uppercase_keyword = 1
compile endif

compile if my_rc_keys_is_external = 1
   C_TABS = 2
   C_MARGINS = 1 MAXMARGIN 1
   WANT_CUA_MARKING = 'SWITCH'
   ASSIST_TRIGGER = 'ENTER'
   ENHANCED_ENTER_KEYS = 1
   ENTER_ACTION   = 'ADDATEND'
   c_ENTER_ACTION = 'ADDLINE'
   SYNTAX_INDENT = 2
compile endif

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
compile if my_rc_keys_is_external = 0
   'maddhook load_hook rc_load_hook'
compile endif

defc RC_mode
   keys my_rc_keys
   'msetfilemode RC mode'
 
defc rc_load_hook
   universal load_ext
   universal load_var
   if load_ext='RC' | load_ext='DLG' then
 compile if C_TABS <> 0
      if not (load_var // 2) then  -- 1 would be on if tabs set from EA EPM.TABS
         'tabs' C_TABS
      endif
 compile endif
 compile if C_MARGINS <> 0
      if not (load_var%2 - 2*(load_var%4)) then  -- 2 would be on if tabs set from EA EPM.MARGINS
         'ma'   C_MARGINS
      endif
 compile endif
      'RC_mode'
   endif

compile if WANT_CUA_MARKING & EPM
 defkeys my_rc_keys clear
compile else
 defkeys my_rc_keys
compile endif

def space=
   universal expand_on
   if expand_on then
      if  not my_rc_first_expansion() then
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
      if not my_rc_second_expansion() then
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
   if not my_rc_first_expansion() then
      call my_rc_second_expansion()
   endif

defc indent_rc_line
   call indent_pos()
compile endif  -- EXTRA

compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used
defproc my_rc_first_expansion
   /*  up;down */
   retc=1
   if .line then
      getline line
      line=strip(line,'T')
      w=line
      wrd=upcase(w)
      firstwrd=strip(wrd,'L')
      if wrd='SUBMENU' then
compile if I_like_uppercase_keyword
         replaceline wrd' "", '
compile else
         replaceline w' "", '
compile endif
         if not insert_state() then insert_toggle
         endif
         .col=.col+2
      elseif wrd='STRINGTABLE' then
compile if I_like_uppercase_keyword
         replaceline wrd
compile endif
         insertline substr(wrd,1,length(wrd)-11)'BEGIN',.line+1
         insertline substr(wrd,1,length(wrd)-11)'END',.line+2
         .line=.line+1
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         call einsert_line()
         .col=.col+SYNTAX_INDENT
      elseif wrd='BEGIN' then
compile if I_like_uppercase_keyword
         replaceline wrd
compile endif
         insertline substr(wrd,1,length(wrd)-5)'END',.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT
compile if I_like_uppercase_keyword
      elseif pos(firstwrd,'MENU DLGTEMPLATE ACCELTABLE MENUITEM') |
             pos(firstwrd,'ASSOCTABLE AUTOCHECKBOX AUTORADIOBUTTON BITMAP') |
             pos(firstwrd,'CHECKBOX CODEPAGE COMBOBOX CONTAINER CONTROL CTEXT') |
             pos(firstwrd,'CTLDATA DEFPUSHBUTTON DIALOG DLGINCLUDE EDITTEXT') |
             pos(firstwrd,'ENTRYFIELD FONT FRAME GROUPBOX HELPITEM HELPSUBITEM') |
             pos(firstwrd,'HELPSUBTABLE HELPTABLE ICON LISTBOX LTEXT') |
             pos(firstwrd,'MESSAGETABLE MLE NOTEBOOK POINTER PRESPARAMS PUSHBUTTON') |
             pos(firstwrd,'RADIOBUTTON RCDATA RCINCLUDE RESOURCE RTEXT SLIDER') |
             pos(firstwrd,'SPINBUTTON SUBITEMSIZE VALUESET WINDOW') |
             pos(firstwrd,'WINDOWTEMPLATE') then
          replaceline wrd
         keyin ' '
compile endif
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc my_rc_second_expansion
   retc=1
   if .line then
      getline line
      parse value line with wrd rest
      firstword=upcase(wrd)
      if firstword='SUBMENU' then
         /* do tabs to fields of pascal for statement */
         parse value upcase(line) with a ','
         if length(a)>=.col then
            .col=length(a)+3
         else
            insertline substr(line,1,pos(wrd,line)-1)'  BEGIN',.line+1
            insertline substr(line,1,pos(wrd,line)-1)'  END',.line+2
            .line=.line+1
            call einsert_line()
            .col=.col+SYNTAX_INDENT
         endif
      elseif firstword='MENU' then
         insertline substr(line,1,pos(wrd,line)-1)'BEGIN',.line+1
         insertline substr(line,1,pos(wrd,line)-1)'END',.line+2
         .line=.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT
      elseif firstword='ACCELTABLE' then
         insertline substr(line,1,pos(wrd,line)-1)'BEGIN',.line+1
         insertline substr(line,1,pos(wrd,line)-1)'END',.line+2
         .line=.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT
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
         i=verify(wrd,'({:;','M',1)-1
         if i<=0 then i=length(wrd) endif
         firstword=upcase(substr(wrd,1,i))
         if firstword='BEGIN' then
            .col=.col+SYNTAX_INDENT
         elseif firstword='END' then
            .col=max(1,.col-SYNTAX_INDENT)
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