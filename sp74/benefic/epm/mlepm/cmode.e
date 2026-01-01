/* cmode.e - this is the E part of the C mode package        940522 */

/* The enter and space bar keys have been defined to do             */
/* specific C editing features.                                     */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new function : C_mode.  It sets current editing mode to      */
/*   be C mode.                                                     */
/*                                                                  */
/* 940507: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Hook support -- defload kludge removed!                        */                                                                                                        
/*                                                                  */
/* 940505: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Highlighting is now optional.                                  */
/*          I_like_highlighting                                     */
/*  .Indentation style can be changed at runtime: cindentstyle.     */
/*  .WANT_BRACE_BELOW_STATEMENTS and I_like_systematic_braces       */
/*   removed.                                                       */
/*                                                                  */
/* 940501: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .New naming convention.  Exported functions are mhilite[file],  */
/*   mrehilite[file], munhilite[file], mindentline (and all         */
/*   'highlight' synonyms).                                         */
/*  .It's now compatible with the MLHILITE package (be sure to link */
/*   MyCKeys before MLHILITE if MyCKeys is used as an externally    */
/*   linked module.)                                                */
/*  .mhilite_C_mark function added (required by MLHILITE).          */
/*  .Removed the 'endembed comments' bug.                           */
/*                                                                  */
/* 940403: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .unhighlight_file and rehighlight_file functions added          */
/*   (unhilite_file and rehilite_file works, too).                  */
/*                                                                  */
/* 940402: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Better Q support. :)                                           */
/*  .Misc. comments handling changes.                               */
/*  .hilite_file is now a highlight_file synonym.                   */
/*                                                                  */
/* 940401: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .New file extension handling.                                   */
/*          C_EXTENSIONS                                            */
/*  .C++ comments (//) recognized.                                  */
/*  .highlight_file function added.                                 */
/*                                                                  */
/* 940304: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .indent_pos really indents                                      */
/*  .indentline function added (you can assign it to your favorite  */
/*   key)                                                           */
/*  .use ebooke hook (as an option)                                 */
/*          I_m_using_ebooke                                        */
/*                                                                  */
/* 930930: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Highlight support for comments, case statements &              */
/*   functions headers.                                             */
/*  .Autoindentation in STREAM mode.                                */
/*          I_like_automatic_indent                                 */
/*  .Misc expansion changes.                                        */
/*          I_like_systematic_braces                                */
/*                                                                  */

/* this file is an adaptation of the EPM 'ckeys.e' E Macro file     */


;  Usage:                                                           
;
;  Preliminary notes
;
;  mcindentstyle n
;
;     This command modifies the C-code indentation style.  Three
;     styles are actually recognized (-1 is the default):
;
;        1        int dummy(int a)        3        int dummy(int a)
;                 {                                {
;                   int b;                           int b;
;                                         
;                   if(a)                            if(a)
;                     {                              {
;                     b=a;                             b=a;
;                     }                              }
;                   else                             else
;                     b=a+1;                           b=a+1;
;                 }                                }
;
;        2        int dummy(int a)
;                 {
;                   int b;
;
;                   if(a) {
;                     b=a;
;                   }
;                   else
;                     b=a+1;
;                 }
;
;     If n is negative, braces will not be automatically added.
;
;     Example:
;
;        cindentstyle 2
;
;     The second indent style will be used (it does not 'reflow' the
;     previously entered code.)
;


 
compile if not defined(BLACK)
const
   my_c_keys_is_external = 1
   INCLUDING_FILE = 'CMODE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const my_c_keys_is_external = 0
compile endif

/*
** Expansion control constants
**
** You can modify those constants to adjust autoexpansion behavior
*/

CONST
compile if not defined(I_like_my_cases_under_my_switch)
   I_like_my_cases_under_my_switch = 1
compile endif
compile if not defined(I_like_a_semicolon_supplied_after_default)
   I_like_a_semicolon_supplied_after_default = 0
compile endif
compile if not defined(ADD_BREAK_AFTER_DEFAULT)
   ADD_BREAK_AFTER_DEFAULT = 1
compile endif
compile if not defined(C_EXTENSIONS)
   C_EXTENSIONS = 'C H PH IH SQC CPP HPP CXX XH XPH XIH'
compile endif
compile if not defined(USE_ANSI_C_NOTATION)
   USE_ANSI_C_NOTATION = 1  -- 1 means use shorter ANSI C notation on MAIN.
compile endif
compile if not defined(I_like_highlighting)
   I_like_highlighting = 1
compile endif

compile if my_c_keys_is_external = 1
   C_TABS = 2
   C_MARGINS = 1 MAXMARGIN 1
   WANT_CUA_MARKING = 'SWITCH'
   ASSIST_TRIGGER = 'ENTER'
   ENHANCED_ENTER_KEYS = 1
   ENTER_ACTION   = 'ADDATEND'
   C_ENTER_ACTION = 'ADDLINE'
   SYNTAX_INDENT = 2
compile endif

/*
** End of expansion control constants
*/

compile if INCLUDING_FILE <> 'EXTRA.E'  -- Following only gets defined in the base

definit
   universal ML_C_indentstyle
   ML_C_indentstyle = -1
compile if my_c_keys_is_external = 0
   'maddhook load_hook c_load_hook'
compile endif

defc C_mode
   keys my_c_keys
   'msetfilemode C mode'
 
defc c_load_hook
   universal load_ext
   universal load_var
   if wordpos(load_ext,C_EXTENSIONS) then
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
      'C_mode'
   endif

compile if I_like_highlighting = 1
defc mhilite_C_mark=
   sayerror 'Highlighting...'
   call psave_pos(savepos)
   call psave_mark(savemark)
   getsearch oldsearch
   if .last then
      .line=0
      while .line<.last do
         .line=.line+1
         getline line
         if line<>'' then
            parse value line with wrd rest
            i=verify(wrd,'({:;','M',1)-1
            if i<=0 then i=length(wrd) endif
            firstword=upcase(substr(wrd,1,i))
            if wordpos(firstword,'CASE DEFAULT') then
               markline
               'process_style Case'
               unmark
            elseif substr(line,1,1)='{' then -- function header?
               call highlight_function_header()
            endif
            -- now, we're looking for comments
            i=pos('//',line)
            if i then
               .col=i; mark_char; endline; mark_char
               'process_style Commentaire'
               unmark
            endif
            j=1
            j=pos('/*',line,j)
            if j<i or i=0 then
               k=pos('*/',line,j+2)
               while j and (i=0 or j<i) and k do
                  if k then
                     .col=j; mark_char; .col=k+1; mark_char
                     'process_style Commentaire'
                     unmark
                  endif
                  j=pos('/*',line,k+2); k=pos('*/',line,j+2)
               endwhile
               if j then
                  .col=j; mark_char
                  'xcom L $*/$+'
                  .col=.col+2; mark_char
                  'process_style Commentaire'
                  unmark
                  .line=.line-1
               endif
            endif
         endif
      endwhile
   endif
   setsearch oldsearch
   call prestore_mark(savemark)
   call prestore_pos(savepos)
   sayerror 0
   refresh
compile endif

defc mcindentstyle=
   universal ML_C_indentstyle
   if arg(1)='' then
      sayerror 'Current C indent style : 'ML_C_indentstyle
   elseif (arg(1)>=1 & arg(1)<=3) | (arg(1)>=-3 & arg(1)<=-1) then
      ML_C_indentstyle = arg(1)
      sayerror 'Current C indent style : 'ML_C_indentstyle
   else
      sayerror 'Invalid arguments (|[-]1|[-]2|[-]3)'
   endif

defc indent_c_line=
  call indent_pos()

compile if WANT_CUA_MARKING & EPM
 defkeys my_c_keys clear
compile else
 defkeys my_c_keys
compile endif

def space=
   universal expand_on
   if expand_on then
      if  not my_c_first_expansion() then
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
      if not my_c_second_expansion() then
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
   if not my_c_first_expansion() then
      call my_c_second_expansion()
   endif

def '{'=
   universal expand_on
   universal ML_C_indentstyle

   keyin '{'
   if expand_on then
      getline line
      if line='{' then
         if .col>3 and (ML_C_indentstyle=2 | ML_C_indentstyle=-2) then
            .col=.col-3; deletechar; deletechar; deletechar; keyin '{'
            insertline '',.line+1
            insertline substr('',1,.col-2)'}',.line+2
            .col=.col+2
         else
            temp=substr('',1,.col-2)
            insertline '',.line+1
            insertline temp'}',.line+2
         endif
         .col=.col-1
         if .col=1 then
compile if I_like_highlighting = 1
            call highlight_function_header()
compile endif
            .col=.col+SYNTAX_INDENT
            refresh
         endif
         .line=.line+1
      else
         keyin '}'
         .col=.col-1
      endif
   endif

compile endif  -- EXTRA
 
compile if not EXTRA_EX or INCLUDING_FILE = 'EXTRA.E'  -- Following gets defined in EXTRA.EX if it's being used

compile if I_like_highlighting
defproc highlight_function_header /* Highlight function header */
   call psave_pos(savepos_hfh)
   call psave_mark(savemark_hfh)
   .line=.line-1
   while .line and substr(word(textline(.line),1),1,2)='//' do
      .line=.line-1
   endwhile
   if .line and word(textline(.line),words(textline(.line)))='*/' then
      getsearch savesearch
      .col=wordindex(textline(.line),words(textline(.line)))
      'xcom L $/*$r-'
      setsearch savesearch
      if .col=1 then
         .line=.line-1
      endif
   endif
   mark_line
   while .line and (pos(substr(textline(.line),1,1),' '\9) or
                    pos(';',textline(.line))) do
      .line=.line-1
   endwhile
   mark_line
   if word(textline(.line),1)='typedef' then
      ;
   else
      'process_style Function'
   endif
   call prestore_mark(savemark_hfh)
   call prestore_pos(savepos_hfh)
compile endif

defproc indent_pos  /* Indent current line */
   universal ML_C_indentstyle
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
         if wordpos(firstword,'CASE DEFAULT') then
            getline oline, oldline
            if wordpos('CASE', upcase(strip(oline,'L')))<>1 then
               .col=.col+SYNTAX_INDENT
            endif
         elseif wordpos(firstword, 'IF FOR WHILE DO SWITCH ELSE') then
            .col=.col+SYNTAX_INDENT
         elseif firstword='}' then
            if .col>1 & not pos('while',line) & (ML_C_indentstyle=1 | ML_C_indentstyle=-1) then
               .col=.col-SYNTAX_INDENT
            elseif pos('else',line) then
               .col=.col+SYNTAX_INDENT
            endif
         elseif line='{' & ML_C_indentstyle<>1 & ML_C_indentstyle<>-1 then
            .col=.col+SYNTAX_INDENT
         elseif line='{' and .col=1 then
            .col=SYNTAX_INDENT+1
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

defproc insertbraces(style,ws)
   if style=1 | style=-1 then
      insertline ws'  {',.line+1
      insertline ws'  }',.line+2
   else
      insertline ws'{',.line+1
      insertline ws'}',.line+2
   endif

defproc my_c_first_expansion
   universal ML_C_indentstyle
   retc=1
   if .line then
      getline line
      line=strip(line,'T')
      w=line
      wrd=upcase(w)
      ws = substr(line, 1, max(verify(line, ' '\9)-1,0))
      if wrd='FOR' then
         if ML_C_indentstyle<0 then
            replaceline w'(; ; )'
         elseif ML_C_indentstyle=3 then
            replaceline w'(; ; ) {'
            insertline ws'}',.line+1
         else
            replaceline w'(; ; )'
            call insertbraces(ML_C_indentstyle,ws)
         endif
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         .col=.col+1
      elseif wrd='IF' then
         if ML_C_indentstyle<0 then
            replaceline w'()'
         elseif ML_C_indentstyle=3 then
            replaceline w'() {'
            insertline ws'} else {',.line+1
            insertline ws'}',.line+2
         else
            replaceline w'()'
            call insertbraces(ML_C_indentstyle,ws)
         endif
         if not insert_state() then insert_toggle
         call fixup_cursor()
         endif
         .col=.col+1
      elseif wrd='WHILE' then
         if ML_C_indentstyle<0 then
            replaceline w'()'
         elseif ML_C_indentstyle=3 then
            replaceline w'(){'
            insertline ws'}',.line+1
         else
            replaceline w'()'
            call insertbraces(ML_C_indentstyle,ws)
         endif
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         .col=.col+1
      elseif wrd='DO' then
         if ML_C_indentstyle=3 | ML_C_indentstyle=-3 then
            replaceline w' {'
         else
            replaceline w'{'
         endif
         insertline ws'} while();',.line+1
         call einsert_line()
         .col=.col+SYNTAX_INDENT    /* indent for new line */
      elseif wrd='CASE' then
         replaceline w' :'
         .col=.col+1
      elseif wrd='SWITCH' then
         if ML_C_indentstyle=3 | ML_C_indentstyle=-3 then
            replaceline w'() {'
            insertline substr(wrd,1,length(wrd)-6)'}',.line+1
         else
            replaceline w'()'
            call insertbraces(ML_C_indentstyle,ws)
         endif
         if not insert_state() then insert_toggle
             call fixup_cursor()
         endif
         .col=.col+1    /* move cursor between parentheses of switch ()*/
      elseif wrd='MAIN' then
         call enter_main_heading()
      elseif words(line) then
         if word(line,words(line))='/*' then
            keyin '  */'                                  
            .col=.col-3
         else
            retc=0
         endif
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc my_c_second_expansion
   universal ML_C_indentstyle
   universal ML_autohilite
   retc=1
   if .line then
      getline line
      parse value upcase(line) with '{' +0 a
      brace = pos('{', line)
      if .line < .last then
         next_is_brace = textline(.line+1)='{'
      else
         next_is_brace = 0
      endif
      parse value line with wrd rest
      i=verify(wrd,'({:;','M',1)-1
      if i<=0 then i=length(wrd) endif
      firstword=upcase(substr(wrd,1,i))
      if firstword='FOR' then
         /* do tabs to fields of C for statement */
         cp=pos(';',line,.col)
         if cp and cp>=.col then
            .col=cp+2
         else
            cpn=pos(';',line,cp+1)
            if cpn and (cpn>=.col) then
               .col=cpn+2
            else
               if not brace and next_is_brace then down; endif
               call einsert_line()
               if ML_C_indentstyle<>1 & ML_C_indentstyle<>-1 then
                  .col=.col+SYNTAX_INDENT
               endif
               if not brace and not next_is_brace then .col=.col+SYNTAX_INDENT; endif
            endif
         endif
      elseif firstword='CASE' or firstword='DEFAULT' then
         call psave_mark(savemark)
         mark_line
         call einsert_line()
         if .line>2 then  /* take a look at the previous line */
            getline prevline,.line-2
            prevline=upcase(prevline)
            parse value prevline with w .
            if pos('(', w) then
               parse value w with w '('
            endif
            if pos(':', w) then
               parse value w with w ':'
            endif
            if w='CASE' then  /* align case statements */
               i=pos('C',prevline)
               replaceline substr('',1,i-1)||wrd rest,.line-1
               .col=i+2
            elseif w='DEFAULT' then
               i=pos('D',prevline)
               replaceline substr('',1,i-1)||wrd rest,.line-1
               .col=i+2
            elseif w<>'SWITCH' and w<>'{' and prevline<>'' then  /* shift current line over */
               i=verify(prevline,' ')
               if i then .col=i endif
               if i>SYNTAX_INDENT then i=i-SYNTAX_INDENT else i=1 endif
               .col=i+2
               replaceline substr('',1,i-1)||wrd rest,.line-1
            elseif w='SWITCH' & (ML_C_indentstyle=3 | ML_C_indentstyle=-3) then
               .col=.col+SYNTAX_INDENT
            elseif w='{' then
               i=pos('{',prevline)
               .col=i+2
            endif
            /* get rid of line containing just a ; */
            if firstword='DEFAULT' and .line <.last then
               getline line,.line+1
               if line=';' then
                  deleteline .line+1
               endif
            endif
         endif
         if ML_autohilite then
            'process_style Case'
         endif
         call prestore_mark(savemark)
      elseif firstword='BREAK' then
         call einsert_line()
         c=.col
         if .col>SYNTAX_INDENT then
            .col=.col-SYNTAX_INDENT
         endif
         keyin 'case :';left
         insertline substr('',1,c-1)'break;',.line+1
      elseif firstword='SWITCH' then
         if not brace and next_is_brace then down; endif
         call einsert_line()
         c=.col
compile if I_like_my_cases_under_my_switch
         keyin 'case :';left
compile else
         keyin substr(' ',1,SYNTAX_INDENT)'case :';left
         c=c+SYNTAX_INDENT
compile endif
         insertline substr(' ',1,c+SYNTAX_INDENT-1)'break;',.line+1
         /* look at the next line to see if this is the first time */
         /* the user typed enter on this switch statement */
         if .line<=.last-2 then
            getline line,.line+2
            i=verify(line,' ')
            if i then
               if substr(line,i,1)='}' then
compile if I_like_my_cases_under_my_switch
                  if i>1 then
                     i=i-1
                     insertline substr(' ',1,i)'default:',.line+2
                  else
                     insertline 'default:',.line+2
                  endif
compile else
                  i=i+SYNTAX_INDENT-1
                  insertline substr(' ',1,i)'default:',.line+2
compile endif
                  if ML_autohilite then
                     down;down;call psave_mark(savemark)
                     mark_line
                     'process_style Case'
                     call prestore_mark(savemark)
                     up; up
                  endif
compile if ADD_BREAK_AFTER_DEFAULT
                  insertline substr(' ',1,i+SYNTAX_INDENT)'break;',.line+3
compile elseif I_like_a_semicolon_supplied_after_default then
                  insertline substr(' ',1,i+SYNTAX_INDENT)';',.line+3
compile endif
               endif
            endif
         endif
      elseif a='{' or firstword='{' then  /* firstword or last word {?*/
;        if firstword='{' then
;           replaceline  wrd rest      -- This shifts the { to col 1.  Why???
;           call einsert_line();.col=SYNTAX_INDENT+1
;        else
            call einsert_line()
            if (ML_C_indentstyle<>1 & ML_C_indentstyle<>-1) | .col=1 then
               .col=.col+SYNTAX_INDENT
            endif
;        endif
      elseif firstword='MAIN' then
         call enter_main_heading()
      elseif firstword<>'' & wordpos(firstword, 'DO IF ELSE WHILE') then
         if not brace and next_is_brace then down; endif
         call einsert_line()
         if not brace and not next_is_brace then .col=.col+SYNTAX_INDENT; endif
;        insert
;        .col=length(a)+2
      elseif firstword='}' and not pos('while',line) then
         call einsert_line()
         if .col>1 & (ML_C_indentstyle=1 | ML_C_indentstyle=-1) then
            .col=pos('}',line)-SYNTAX_INDENT
         endif
      elseif pos('/*',line) then
         if not pos('*/',line) then
            end_line;keyin' */'
         endif
         call einsert_line()
      elseif pos('//',line) then
         call einsert_line()
      else
         retc=0
      endif
   else
      retc=0
   endif
   return retc

defproc enter_main_heading
   universal ML_autohilite
compile if I_like_highlighting = 1
   universal curlinedone
   curlinedone = 1 -- protect function header
compile endif
compile if not USE_ANSI_C_NOTATION     -- Use standard notation
   temp=substr('',1,SYNTAX_INDENT)  /* indent spaces */
   replaceline 'main(argc, argv, envp)'
   if ML_autohilite then
      call psave_mark(savemark)
      mark_line
      'process_style Function'
      call prestore_mark(savemark)
   endif
   insertline temp'int argc;',.line+1         /* double indent */
   insertline temp'char *argv[];',.line+2
   insertline temp'char *envp[];',.line+3
   insertline '{',.line+4
   insertline '',.line+5
   mainline = .line
   if .cursory<7 then
      .cursory=7
   endif
   mainline+5
   .col=SYNTAX_INDENT+1
   insertline '}',.line+1
compile else                           -- Use shorter ANSI notation
   replaceline 'main(int argc, char *argv[], char *envp[])'
   if ML_autohilite then
      call psave_mark(savemark)
      mark_line
      'process_style Function'
      call prestore_mark(savemark)
   endif
   insertline '{',.line+1
   insertline '',.line+2
   .col=SYNTAX_INDENT+1
   insertline '}',.line+3
   mainline = .line
   if .cursory<4 then
      .cursory=4
   endif
   mainline+2
compile endif

compile endif  -- EXTRA
