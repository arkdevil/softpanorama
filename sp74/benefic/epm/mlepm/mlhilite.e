/* mlhilite.e - this is the E part of the MlHilite package   940507 */

/* Copyright (c) 1994 Martin Lafaix.  All Rights Reserved.          */

/* 940507: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Hooks used.  So, on-the-fly hiliting is there!                 */
/*  .Improved loadattribute/saveattribute scheme added.             */
/*                                                                  */
/* 940504: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Added munhilitemark and mpackhilite.                           */
/*                                                                  */
/* 940501: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Writing docs.                                                  */
/*  .Speed improvements (stdctrl.e now takes 5'34 -- was ~8')       */                                        
/*                                                                  */
/* 940428: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Initial work :                                                 */
/*    mhilitedef language extensions                                */
/*    mhiliteadd language level style expr                          */
/*    mhiliteclr language [level]                                   */
/*    mhilite[file]                                                 */
/*    munhilite[file]                                               */
/*    mrehilite[file]                                               */
/*    [and all 'highlight' synonyms]                                */
/*                                                                  */


;  Usage:                                                           
;
;  Preliminary notes
;
;     This package is designed to be used as an external module.
;     Put MLHILITE.EX somewhere along your EPMPATH, and insert the
;     following statement in your profile.erx (you can issue the
;     command, if you just want to try it) :
;
;        link MLHILITE
;
;     All functions names are prefixed with an 'm', in order to
;     prevent name-clash with future (possible) EPM functions.
;     (We can't expect them to share the same definition, can we? :)
;
;     Whenever a function has the string 'hilite' in it, this string
;     can be replaced with 'highlight'.  And if a part of a function
;     name is enclosed in square-brackets, this part is optional.  So,
;     the function
;
;        mhilite[file]
;
;     stands for
;
;        mhilite, mhighlight, mhilitefile and mhighlightfile
;
;     Autohiliting requires MLHOOK to be loaded and MPOPUP.EXE to be
;     up and running.
;
;  mhilitedef language extensions
;
;     This command defines a new language, or redefines an existing
;     one.  A file whose extension matches one in 'extensions' will be
;     handled with the rules defined for 'language'.  If an extension
;     is part of more than one language, the last defined language
;     will win the race.  Extensions are case-insensitive.
;
;     Example:                                                      
;
;        mhilitedef REXX CMD ERX                                     
;
;     It defines the REXX language.  Files ending with '.cmd' or
;     '.erx' will be recognized as 'REXX' files
;
;  mhiliteadd language level style expr                              
;
;     This command defines a new language rule.  If 'language' has not
;     be previously defined, an error occurs.  'level' is an integer
;     (in range 1..4) which defines the "priority" of the rule.  Level
;     1 is the highest priority.  (See example below for more
;     explanations on levels.)  'style' is any style defined in the
;     Style...  dialog box (reachable via the Edit menu).  Specifying
;     an unknown style name is not an error -- but no styles will be
;     assigned to the matching expressions in files.  (Styles ARE
;     case- sensitive.)  'expr' is a string which specifies the
;     matching expressions.  Its format is:
;
;        <delim>expr1<delim>[expr2<delim>]                          
;
;     where <delim> is any character, and expr1 a regular expression.
;     (If present, expr2 is a regexp, too.)  A matching expression is
;     defined by expr1, or, if expr2 is present, included between
;     expr1 and expr2.
;
;     Examples:                                                     
;
;        mhiliteadd REXX 1 Commentaire _/\*_\*/_
;        mhiliteadd REXX 4 Function ~^[a-zA-Z_][a-zA-Z0-9_]*:~
;
;     The first line defines a rule which matches a REXX comment.
;     The language is REXX, the level is 1, the style name is
;     'Commentaire', and the expression is composed of a '_'
;     delimiter, a first expression, '/\*' and a second one, '\*/'.
;     The first expression matches the REXX opening comment, and the
;     second matches the closing comment token.  Note the '\'
;     character in front of '*', as both expressions are regular
;     expressions.
;
;     The second line defines a REXX label, that is, something which
;     starts on column 1, composed of letters, digits or underscores,
;     and immediately followed by ':'.  Note that the REXX label rule
;     level is 4, too.  This means that, if a text matching the rule
;     (A) is found inside a region of text which has already been
;     matched by a rule (B) of a higher level, the rule (A) will not
;     be applied on this matching occurrence.  While I realize it's
;     not that clear :), let me try an example.  Suppose we have the
;     following REXX fragment :
;
;        /* bla bla bla
;        foo: ggffggf
;        bar: 940401
;        */                     
;        baz:
;
;     The first rule matches the comment (/* bla ... */), and the
;     second matches (baz:).  It does not matche 'foo:' nor 'bar:',
;     as theses two expressions are in a region of text which as been
;     recognized by our first rule (of a higher level).
;
;     So, here is the golden rule on levels :
;
;     "A rule of a level l does not apply to an expression if this
;     expression is enclosed in an expression matched by a rule of a
;     level m <= l."
;
;     Note the '<=';  It means that the rules' order is important in
;     a given level.  Rules are tried in a first-defined/first-tried
;     order.
;
;  mhiliteclr language [level]
;
;     This command erases rules defined for a specified language.  If 
;     'language' has not been previously defined, an error occurs.  If
;     'level' is given, only rules of level 'level' will be removed;
;     otherwise, ALL rules will be removed.
;
;     Example:
;
;        mhiliteclr REXX 4
;
;     It will remove the 'REXX label' rule (assuming we were using the
;     previously defined samples statements.)
;
;  mhilite[file]
;
;     This command highlights the current file.  If the file's
;     language has a specific highlight function, this function is
;     used.  Otherwise, language's rules are used.
;     A specific highlight function is a function whose name follows
;     the format:
;
;        'mhilite_'language'_mark'
;
;     [The MyCKeys package defines such a function, mlhilite_C_mark.]
;
;  munhilite[file]
;
;     This command unhighlights the current file.  That is, all
;     attributes are removed from the file.
;
;     Note: It removes bookmarks, too.
;
;  mrehilite[file]
;
;     This command first unhighlights the file, and then rehighlights
;     it.  It's just the same as issuing 'munhilite' followed by
;     'mhilite'.
;
;  munhilitemark
;
;     This command unhighlights the current mark.  That is, all
;     attributes are removed from the mark.
;
;  mpackhilite [Not yet completed]
;
;     This command packs highlight-attributes, in order to save space
;     and time while saving attributes.
;
;  mautohilite
;
;     This command actives or desactives autohighlighting.  The following
;     parameters are allowed : on, off, 0, 1 or nothing.
;
;     Examples:
;
;        mautohilite
;        mautohilite on
;
;     The first example shows the current state.  The second sets
;     autohighlighting mode on.
;
;  hilite_modify_hook
;
;     This hook enables autohighlighting.  Add this hook on modify_hook:
;
;        maddhook modify_hook hilite_modify_hook
;
;  hilite_load_hook
;
;     This hook is used to find out a file's language.  Add this hook on
;     load_hook:
;
;        maddhook load_hook hilite_load_hook
;



compile if not defined(BLACK)
const
   ml_hilite_is_external = 1
   INCLUDING_FILE = 'MLHILITE.E'
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const ml_hilite_is_external = 0
compile endif
compile if not defined(NLS_LANGUAGE)
   const NLS_LANGUAGE = 'ENGLISH'
compile endif
include NLS_LANGUAGE'.e'

definit
   universal ML_array_ID
   universal ML_autohilite
   universal curline
   ML_autohilite = 1
   curline=0
   do_array 6, ML_array_ID, 'MLARRAY'
   if ML_array_ID='' then
      do_array 1, ML_array_ID, 'MLARRAY'
   endif

defc mautohilite, mautohighlight
   universal ML_autohilite
   uparg=upcase(arg(1))
   if uparg=ON__MSG then
      ML_autohilite = 1
      call select_edit_keys()
   elseif uparg=OFF__MSG then
      ML_autohilite = 0
      call select_edit_keys()
   elseif uparg='' then
      sayerror 'AUTOHILITE:' word(OFF__MSG ON__MSG, ML_autohilite+1)
   else
      sayerror INVALID_ARG__MSG ON_OFF__MSG')'
      stop
   endif
 
defc mhighlightadd, mhiliteadd=
   universal ML_array_ID
   parse arg language level style expr
   do_array 3, ML_array_ID, 'languages', languages
   if wordpos(language,languages)=0 then
      sayerror 'Undefined language 'language
   else
      if get_array_value(ML_array_ID,'hl.'language'.'level'.0',item) then
         item=0
      endif
      item=item+1
      do_array 2, ML_array_ID, 'hl.'language'.'level'.0', item
      stem=style expr
      do_array 2, ML_array_ID, 'hl.'language'.'level'.'item, stem
   endif
   return

defc mhighlightdef, mhilitedef=
   universal ML_array_ID
   parse arg language extensions
   call get_array_value(ML_array_ID, 'languages', languages)
   if wordpos(language,languages)=0 then
      languages = language' 'languages
   endif
   do_array 2, ML_array_ID, 'lg.'language, extensions
   do_array 2, ML_array_ID, 'languages', languages
   return

defc mhighlightclr, mhiliteclr=
   universal ML_array_ID
   parse arg language level
   if level='' then
      for i = 1 to 4
         do_array 4, ML_array_ID, 'hl.'language'.'i'.0'
      endfor
   else
      do_array 4, ML_array_ID, 'hl.'language'.'level'.0'
   endif

defc hilitedbg=
   universal ML_array_ID
   do_array 3, ML_array_ID, 'languages', languages
   do_array 3, ML_array_ID, 'hl.E.1.0', item
   sayerror 'Defined languages : 'languages', E.1.0='item

defc munhighlightfile, munhilitefile, munhilite, munhighlight=
   call psave_mark(savemark)
   class=0; line=0; col=0; off=-255
   attribute_action 1, class, off, col, line
   while class do
      attribute_action 16, class, off, col, line
      class=0; off=-255
      attribute_action 1, class, off, col, line
   endwhile
   call prestore_mark(savemark)

defc mrehighlightfile, mrehilitefile, mrehilite, mrehighlight=
   'munhilitefile'
   'mhilitefile'

defc munhilitemark, munhighlightmark=
   call checkmark()
   mt = leftstr(marktype(),1)
   getmark fstline, lstline, fstcol, lstcol, fid
   class=0; line=fstline; col=fstcol; off=-255
   attribute_action 1, class, off, col, line
   while class & line<=lstline do
      if mt='L' | 
         (mt='B' & col >= fstcol & col <= lstcol) |
         (mt='G' & (line < lstline | col <= lstcol)) then
         attribute_action 16, class, off, col, line
      endif
      class=0; off=-255
      attribute_action 1, class, off, col, line
   endwhile

defc mpackhilite
   call psave_mark(savemark)
   class=14; line=0; col=0; off=-255; oldval=0; oldline=0; oldcol=0; oldoff=0
   attribute_action 1, class, off, col, line
   while class do
      query_attribute class, val, IsPush, off, col, line
      if IsPush=0 & val=oldval then
         -- si cote à cote, supprimer
         attribute_action 16, class, oldoff, oldcol, oldline
         attribute_action 16, class, off, col, line
      endif
   endwhile
   call prestore_mark(savemark)

defproc isinside(pure)
   universal ML_array_ID
   class=14; line=.line; col=.col; off=-255
   attribute_action 1, class, off, col, line
   if class=14 then
      query_attribute class, val, IsPush, off, col, line
      if IsPush=1 then
         return 0
      else
         if pure=0 then
            .line=line; .col=col -- side-effect!
         endif
         return 1
      endif
   else
      return 0
   endif

defc setuserstring
   parse arg str
   .userstring=str
   .autosave=1

defc hilite_load_hook, highlight_load_hook
   universal ML_array_ID, vDEFAULT_AUTOSAVE
   parse value reverse(.filename) with ext'.'remainder
   ext=upcase(reverse(ext)); language=''
   do_array 3, ML_array_ID, 'languages', languages
   for i=1 to words(languages)
      do_array 3, ML_array_ID, 'lg.'word(languages,i), extensions
      if wordpos(ext,extensions) then
         language=word(languages,i)
         leave
      endif
   endfor
   if language='' then
      .userstring=''
      .autosave=vDEFAULT_AUTOSAVE
   else
      'setuserstring 'language
   endif
 
defc hilite_modify_hook, highlight_modify_hook
   universal curline, curlinedone, ML_autohilite
   if .userstring='' | .modify=0 | ML_autohilite=0 then
      return
   endif
   .modify=1
   if curline=0 then curline=.line; endif
   if .line<>curline then
      if not curlinedone then
         'ml_hilite_line'
      endif
      curline=.line
   endif
   curlinedone=0
   popupid=dynalink('PMWIN','WINWINDOWFROMID',atoi(0)||atoi(1)||atoi(1234),2)
   choice=windowmessage(0,popupid,4098,getpminfo(EPMINFO_EDITCLIENT),curline)

defc ml_hilite_line
   universal ML_array_ID
   universal EPM_utility_array_ID
   universal app_hini
   universal curline, curlinedone
   if curlinedone then return; else curlinedone=1; endif
   if curline>.last then return; endif
   language=.userstring
   getsearch oldsearch
   call psave_pos(savepos)
   call psave_mark(savemark)
   .line=curline; .col=1
   if isinside(1)=0 then
      mark_line
      display -12
      oldmod=.modify
      -- unhilite_line
;     getline line
;     replaceline line
      class=0; line=curline; col=0; off=-255
      attribute_action 1, class, off, col, line
      while class & line=curline do
         attribute_action 16, class, off, col, line
         class=0; off=-255
         attribute_action 1, class, off, col, line
      endwhile
      -- rehilite_line
      for i=1 to 4
         do_array 3, ML_array_ID, 'hl.'language'.'i'.0', item
         if item='' then
            iterate
         endif
         for j=1 to item
            do_array 3, ML_array_ID, 'hl.'language'.'i'.'j, stem
            parse value stem with stylename exp
            -- extracting stylename infos
            stylestuff = queryprofile(app_hini, 'Style', stylename)
            if stylestuff='' then return; endif  -- Shouldn't happen
            parse value stylestuff with fontname '.' fontsize '.' fontsel '.' fg '.' bg
            if bg<>'' then fg=bg*16 + fg; else fg=''; endif
            if fontsel<>'' then
               fontid=registerfont(fontname, fontsize, fontsel)
            else
               fontid=''
            endif
            if get_array_value(EPM_utility_array_ID, 'sn.'stylename, styleindex) then  -- See if we have an index
               do_array 3, EPM_utility_array_ID, 'si.0', styleindex          -- Get the
               styleindex = styleindex + 1                                 --   next index
               do_array 2, EPM_utility_array_ID, 'si.0', styleindex          -- Save next index
               do_array 2, EPM_utility_array_ID, 'si.'styleindex, stylename  -- Save index.name
               do_array 2, EPM_utility_array_ID, 'sn.'stylename, styleindex  -- Save name.index
            endif
            -- extracting regexps
            parse value exp with delim 2 starte (delim) ende (delim)
-- sayerror '==> 'starte' / 'ende' <=='i','j','style
            -- Here starts the time-critical part
            .line=curline; .col=0
            if ende='' then
               do forever
compile if EVERSION < 5.60
                  'xcom l 'delim||starte||delim'+gm'
compile else
                  'xcom l 'delim||starte||delim'+xm'
compile endif
                  if rc=-273 then leave; endif -- sayerror 'String not found'
                  if i+j>1 & isinside(1) then iterate; endif
                  fstline=.line; fstcol=.col
                  .col=.col+getpminfo(EPMINFO_LSLENGTH)
                  -- process_style stylename
                  if fg<>'' then
                     insert_attribute 1, fg, 1, -1, fstcol, fstline
                     insert_attribute 1, fg, 0, -1, .col, .line
                  endif
                  if fontid<>'' then
                     insert_attribute 16, fontid, 1, -2, fstcol, fstline
                     insert_attribute 16, fontid, 0, -2, .col, .line
                  endif
                  insert_attribute 14, styleindex, 1, -3, fstcol, fstline
                  insert_attribute 14, styleindex, 0, -3, .col, .line
--                repeatfind
               enddo
            else
               do forever
compile if EVERSION < 5.60
                  'xcom l 'delim||starte||delim'+gm'
compile else
                  'xcom l 'delim||starte||delim'+xm'
compile endif
                  if rc=-273 then leave; endif -- sayerror 'String not found'
                  if i+j>1 & isinside(1) then iterate; endif
                  -- process_style stylename
                  if fg<>'' then
                     insert_attribute 1, fg, 1, -1, .col, .line
                  endif
                  if fontid<>'' then
                     insert_attribute 16, fontid, 1, -2, .col, .line
                  endif
                  insert_attribute 14, styleindex, 1, -3, .col, .line
                  .col=.col+getpminfo(EPMINFO_LSLENGTH)
--                repeatfind
               enddo
               .line=curline; .col=0
               do forever
compile if EVERSION < 5.60
                  'xcom l 'delim||ende||delim'+gm'
compile else
                  'xcom l 'delim||ende||delim'+xm'
compile endif
                  if rc=-273 then leave; endif -- sayerror 'String not found'
                  .col=.col+getpminfo(EPMINFO_LSLENGTH)
                  -- process_style stylename
                  if fg<>'' then
                     insert_attribute 1, fg, 0, -1, .col, .line
                  endif
                  if fontid<>'' then
                     insert_attribute 16, fontid, 0, -2, .col, .line
                  endif
                  insert_attribute 14, styleindex, 0, -3, .col, .line
--                repeatfind
               enddo
            endif
         endfor
      endfor
      .modify=oldmod
      display 12
   endif
   call prestore_mark(savemark)
   call prestore_pos(savepos)
   setsearch oldsearch

defc mhighlightfile, mhilitefile, mhilite, mhighlight=
   universal ML_array_ID
   parse value reverse(.filename) with ext'.'remainder
   ext=upcase(reverse(ext)); language=''
   do_array 3, ML_array_ID, 'languages', languages
   for i=1 to words(languages)
      do_array 3, ML_array_ID, 'lg.'word(languages,i), extensions
      if wordpos(ext,extensions) then
         language=word(languages,i)
         leave
      endif
   endfor
   if language='' then
      sayerror 'Unknown file type <'ext'>'
      return
   endif
   if isadefc('mhilite_'language'_mark') then
      'mhilite_'language'_mark'
   else
      call hiliteit(language)
   endif

defproc hiliteit
   universal ML_array_ID
   universal EPM_utility_array_ID
   universal app_hini
   parse arg language
   sayerror 'Highlighting...'
   display -3
   getsearch oldsearch
   call psave_pos(savepos)
   call psave_mark(savemark)
   oldmod=.modify
   for i=1 to 4
      do_array 3, ML_array_ID, 'hl.'language'.'i'.0', item
      if item='' then
         iterate
      endif
      for j=1 to item
         do_array 3, ML_array_ID, 'hl.'language'.'i'.'j, stem
         parse value stem with stylename exp
         -- extracting stylename infos
         stylestuff = queryprofile(app_hini, 'Style', stylename)
         if stylestuff='' then return; endif  -- Shouldn't happen
         parse value stylestuff with fontname '.' fontsize '.' fontsel '.' fg '.' bg
         if bg<>'' then fg=bg*16 + fg; else fg=''; endif
         if fontsel<>'' then
            fontid=registerfont(fontname, fontsize, fontsel)
         else
            fontid=''
         endif
         if get_array_value(EPM_utility_array_ID, 'sn.'stylename, styleindex) then  -- See if we have an index
            do_array 3, EPM_utility_array_ID, 'si.0', styleindex          -- Get the
            styleindex = styleindex + 1                                 --   next index
            do_array 2, EPM_utility_array_ID, 'si.0', styleindex          -- Save next index
            do_array 2, EPM_utility_array_ID, 'si.'styleindex, stylename  -- Save index.name
            do_array 2, EPM_utility_array_ID, 'sn.'stylename, styleindex  -- Save name.index
         endif
         -- extracting regexps
         parse value exp with delim 2 starte (delim) ende (delim)
-- sayerror '==> 'starte' / 'ende' <=='i','j','style
         -- Here starts the time-critical part
         .line=0
         if ende='' then
            do forever
compile if EVERSION < 5.60
               'xcom l 'delim||starte||delim'+g'
compile else
               'xcom l 'delim||starte||delim'+x'
compile endif
               if rc=-273 then leave; endif -- sayerror 'String not found'
               if i>1 & isinside(0) then iterate; endif
               fstline=.line; fstcol=.col
               .col=.col+getpminfo(EPMINFO_LSLENGTH)
               -- process_style stylename
               if fg<>'' then
                  insert_attribute 1, fg, 1, -1, fstcol, fstline
                  insert_attribute 1, fg, 0, -1, .col, .line
               endif
               if fontid<>'' then
                  insert_attribute 16, fontid, 1, -2, fstcol, fstline
                  insert_attribute 16, fontid, 0, -2, .col, .line
               endif
               insert_attribute 14, styleindex, 1, -3, fstcol, fstline
               insert_attribute 14, styleindex, 0, -3, .col, .line
            enddo
         else
            do forever
compile if EVERSION < 5.60
               'xcom l 'delim||starte||delim'+g'
compile else
               'xcom l 'delim||starte||delim'+x'
compile endif
               if rc=-273 then leave; endif -- sayerror 'String not found'
               if i>1 & isinside(0) then iterate; endif
               fstline=.line;fstcol=.col; .col=.col+getpminfo(EPMINFO_LSLENGTH)
compile if EVERSION < 5.60
               'xcom l 'delim||ende||delim'+g'
compile else
               'xcom l 'delim||ende||delim'+x'
compile endif
               .col=.col+getpminfo(EPMINFO_LSLENGTH)
               -- process_style stylename
               if fg<>'' then
                  insert_attribute 1, fg, 1, -1, fstcol, fstline
                  insert_attribute 1, fg, 0, -1, .col, .line
               endif
               if fontid<>'' then
                  insert_attribute 16, fontid, 1, -2, fstcol, fstline
                  insert_attribute 16, fontid, 0, -2, .col, .line
               endif
               insert_attribute 14, styleindex, 1, -3, fstcol, fstline
               insert_attribute 14, styleindex, 0, -3, .col, .line
            enddo
         endif
      endfor
   endfor
   .modify=oldmod+1
   call attribute_on(4)  -- Mixed fonts flag
   call attribute_on(1)  -- Colors flag
   call attribute_on(8)  -- "Save attributes" flag
   call prestore_mark(savemark)
   call prestore_pos(savepos)
   setsearch oldsearch
   display 3
   sayerror 0

