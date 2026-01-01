/* mltools.e - this is the E part of the MlTools package     940522 */

/* This file was created from scratch, until I realized that        */
/* I was recreating bookmark.e :-/                                  */
/*                                                                  */
/* Parts Copyright (c) 1994 Martin Lafaix.                          */

/* 940522: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adding mfind/mgo/mnext.                                        */
/*  .Removing ML_function_index.                                    */
/*                                                                  */
/* 940515: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .New popupmenu handling.                                        */
/*                                                                  */
/* 940508: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Adding mode support (and a new statusline flag: %t, file mode) */
/*  .This package now supersedes bookmark.e (except for Workframe). */
/*                                                                  */
/* 940502: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .A new universal, ML_function_index.  Contains the 'Function'   */
/*   style index.                                                   */
/*  .mloadattributes/msaveattributes functions added.               */
/*  .mpopupmenu function added (yeah! :)                            */
/*                                                                  */
/* 940501: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Writing docs.                                                  */
/*                                                                  */
/* 940428: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Changing from MyTools to MlTools. (What a change! :)           */
/*                                                                  */
/* 940427: Martin Lafaix (lafaix@sophia.inria.fr)                   */
/*                                                                  */
/*  .Initial work.                                                  */
/*                                                                  */


;  Usage:                                                           
;
;  Preliminary notes
;
;     This package is designed to be used as an external module.
;     Put MLTOOLS.EX somewhere along your EPMPATH, and insert the
;     following statement in your profile.erx (you can issue the
;     command, if you just want to try it) :
;
;        link MLTOOLS
;
;     All functions names are prefixed with an 'm', in order to
;     prevent name-clash with future (possible) EPM functions.
;     (We can't expect them to share the same definition, can we? :)
;
;     This package mainly works on attributed (aka hilited) files, so
;     it's recommended that you use it with a hiliting-package (as
;     MLHILITE).  If you want to use the mode hook, you have to link
;     MLHOOK, too.
;
;     Popup menus require the MPOPUP.EXE program to be running.
;
;  mfindfunction
;
;     This function pops up a listbox containing all functions
;     defined in current file, with option to jump to a specific
;     function.
;     A function is something which has the 'Function' style.  If a
;     function spans on more than one line, only the first line is
;     shown in the listbox.
;
;  mfind start_fid dest_fid style
;
;     This function copies the first line of items of style 'style',
;     from start_fid to dest_fid.
;
;  mnext style [P]
;
;     This function locates the next (or previous, if P is specified)
;     item of style 'style'.  If such an item is found, the cursor is
;     moved.  Otherwise, nothing occurs.
;
;  mgo style string
;
;     This function locates the specified string with the given style
;     in current file.  If the string is found, the cursor is moved.
;     Otherwise, nothing occurs.
;     'string' should be the beginning of the desired style.
;     mgo finds the first matching string.
;
;  mnextfunction [P]
;
;     This function locates the next (or previous, if P is specified)
;     function header.  If such a function is found, the cursor is
;     moved.  Otherwise, nothing occurs.
;     This function can be assigned to a key, allowing you quick
;     movements in your files.  Put the following in your profile.erx
;     if you want to assign 'mnextfunction P' to 'Alt+up_arrow' and
;     'mnextfunction' to Alt+down_arrow :
;
;        buildaccel '*' 34 24 1234 mnextfunction
;        buildaccel '*' 34 22 1235 mnextfunction P
;        activateaccel
;
;     [34 stands for AF_VIRTUALKEY+AF_ALT, 24 is the down_arrow
;      keycode, and 22 is the up_arrow keycode.  1234 and 1235 can be
;      any numbers, but they have to be unique.]
;
;  mloadattributes [Not yet completed]
;
;     This function loads current file attributes from its EAs.  It 
;     supports the new (compact) attribute format.  It can read
;     attributes from an old EPM file, though...
;
;  msaveattributes [Not yet completed]
;
;     This function save the current file attributes in its EAs.  They
;     are saved in the new (compact) attribute format.
;
;  mpopupmenu menu
;
;     This function popups a menu.  The poped up menu depends on the
;     cursor location.  This popupmenu support is actually a kludge.
;     If menu is 10, an application-related popupmenu is shown.
;     Otherwise, a contextual menu is displayed.
;
;  msetstatusline newstatusline
;
;     This function replaces the old setstatusline.  Same usage, same 
;     effects (it just remembers the actual statusline value).
;
;  msetfilemode filemode
;
;     This function sets the current file mode.  It can be any string 
;     (but a short one is recommended, though...).  The filemode will
;     be shown on the statusline if this statusline contains '%t'.
;
;     Example:
;
;        msetfilemode 'C++ mode'
;
;     The current file mode will now be 'C++ mode'.  This string will 
;     appears in the statusline if it contains '%t'.  (The
;     show_mode_hook has to be in effect.)
;
;  show_mode_hook
;
;     This hook is used to display the file mode in the statusline. 
;     If you want to have the current file mode displayed in the
;     status line, put the following in your profile.erx :
;
;        maddhook 'select_hook 'show_mode_hook
;
;     and define a new statusline, which contains '%t' :
;
;        msetstatusline 'Line %l of %s  Column %c   %f   %i     %m %t'
;
;     If no file mode is defined, 'Text mode' will appear.
;
;     [Using hooks requires a hook-package, eg MLHOOK, to be linked.]
;
;  mautoindent [|on|off]
;
;     This command sets the indentation mode (on by default).  If
;     no parameters are given, it shows the current indentation state.
;     Autoindentation is mode-dependant.
;
;  mindentline
;
;     This function indents the current line.  It's mode dependant.
;     It can be assigned to a key; put the following in your profile
;     if you want to assign it to the tab key :
;
;        buildaccel '*' 0 9 1236 mindentline
;        activateaccel
;
;  newtop
;
;     This function makes the current line the top-line.  It's used
;     by a popupmenu option (Scroll to top).
;



compile if not defined(BLACK)
const
   ml_tools_is_external = 1
   INCLUDING_FILE = 'MLTOOLS.E'
   WANT_APPLICATION_INI_FILE = 1
   EXTRA_EX = 0
   include 'stdconst.e'
compile else
   const ml_tools_is_external = 0
compile endif
compile if not defined(NLS_LANGUAGE)
   const NLS_LANGUAGE = 'ENGLISH'
compile endif
include NLS_LANGUAGE'.e'

const
   COLOR_CLASS = 1
   BOOKMARK_CLASS = 13
   STYLE_CLASS =  14
   FONT_CLASS =  16
   EAT_ASCII    = \253\255    -- FFFD
   EAT_MVST     = \222\255    -- FFDE

definit
   universal defaultmenu
   universal ML_autoindent
   ML_autoindent = 1
   -- popupmenu kludge
   buildacceltable 'defaccel', 'markword', AF_VIRTUALKEY+AF_ALT,0,9200
   buildacceltable 'defaccel', 'marktoken', AF_VIRTUALKEY+AF_ALT,0,9201
   buildacceltable 'defaccel', 'findword', AF_VIRTUALKEY+AF_ALT,0,9202
   buildacceltable 'defaccel', 'key 1 c+f1', AF_VIRTUALKEY+AF_ALT,0,9203
   buildacceltable 'defaccel', 'key 1 c+f2', AF_VIRTUALKEY+AF_ALT,0,9204
   buildacceltable 'defaccel', 'key 1 s+f5', AF_VIRTUALKEY+AF_ALT,0,9205
   buildacceltable 'defaccel', 'newtop', AF_VIRTUALKEY+AF_ALT,0,9206
   buildacceltable 'defaccel', 'ml_make', AF_VIRTUALKEY+AF_ALT,0,9208
   buildacceltable 'defaccel', 'ml_build', AF_VIRTUALKEY+AF_ALT,0,9209
   buildacceltable 'defaccel', 'fill', AF_VIRTUALKEY+AF_ALT,0,9210
   buildacceltable 'defaccel', 'key 1 a+P', AF_VIRTUALKEY+AF_ALT,0,9211
   buildacceltable 'defaccel', 'key 1 c+f3', AF_VIRTUALKEY+AF_ALT,0,9212
   buildacceltable 'defaccel', 'key 1 c+f4', AF_VIRTUALKEY+AF_ALT,0,9213
   buildacceltable 'defaccel', 'sort', AF_VIRTUALKEY+AF_ALT,0,9214
   buildacceltable 'defaccel', 'key 1 c+f7', AF_VIRTUALKEY+AF_ALT,0,9220
   buildacceltable 'defaccel', 'key 2 c+f7', AF_VIRTUALKEY+AF_ALT,0,9221
   buildacceltable 'defaccel', 'key 3 c+f7', AF_VIRTUALKEY+AF_ALT,0,9222
   buildacceltable 'defaccel', 'key 1 c+f8', AF_VIRTUALKEY+AF_ALT,0,9224
   buildacceltable 'defaccel', 'key 2 c+f8', AF_VIRTUALKEY+AF_ALT,0,9225
   buildacceltable 'defaccel', 'key 3 c+f8', AF_VIRTUALKEY+AF_ALT,0,9226

defc mfind
   universal EPM_utility_array_ID
   parse arg start_fid dest_fid style
   do_array 3, EPM_utility_array_ID, 'sn.'style, style_index
   class=14; line=0; col=0; off=-255
   attribute_action 1, class, off, col, line, start_fid
   while class do
      query_attribute class, val, IsPush, off, col, line, start_fid
      if val=style_index then
         getline selected, line, start_fid
         insertline strip(selected,'T'), dest_fid.last+1, dest_fid
         attribute_action 3, class, off, col, line, start_fid
      endif
      class=14; off=-255; col=col+1
      attribute_action 1, class, off, col, line, start_fid
   endwhile

defc mgo
   parse arg style fn
   .line=0
   do forever
      line=.line; col=.col
      'mnext' style
      if line=.line & col=.col then
         sayerror style' not found'
         return
      endif
      if fn=substr(textline(.line),.col,length(fn)) then return; endif
   enddo

defc mnext
   universal EPM_utility_array_ID
   parse arg style next .
   do_array 3, EPM_utility_array_ID, 'sn.'style, style_index
   class = 14
   col = .col+1; line=.line; offst=-255
   if next='P' then col=col-2; endif
   do forever
      attribute_action 1+(next='P'), class, offst, col, line -- 1=FIND NEXT ATTR; 2=FIND PREV ATTR
      if class=0 then
         return
      endif
      query_attribute class, val, IsPush, offst, col, line
      if val=style_index & IsPush=1 then
         if line < .line-.cursory+1 | line > .line-.cursory+.windowheight then
            .cursory=.windowheight%2
         else
            .cursory=.cursory-.line+line
         endif
         line; .col=col
         return
      endif
   enddo

defc mfindfunction=
   getfileid start_fid
   'xcom e /c .mytools'
   .autosave=0
   getfileid tools_fid
   'mfind' start_fid tools_fid 'Function'
   buff=buffer(CREATEBUF,'MYTOOLS',filesize()+.last+1,1)
   rc=buffer(PUTBUF,buff,1,0,17)
   .modify=0
   'xcom quit'
   lb=listbox('Available functions',
 compile if EPM32
              \0 || atol(buffer(USEDSIZEBUF,buff)) || atoi(32) || atoi(buff),
 compile else
              \0 || atoi(buffer(USEDSIZEBUF,buff)) || atoi(buff) || atoi(32),
 compile endif
--              '/~Go to/~Delete/Cancel/Help',
              '/~Go to/Cancel/Help',
              0,0,10,70,
 compile if EVERSION >= 5.60
              gethwndc(APP_HANDLE) || atoi(1) || atoi(1) || atoi(6030) ||
 compile else
              atoi(1) || atoi(1) || atoi(6030) || gethwndc(APP_HANDLE) ||
 compile endif
              ' [In the help panels, read ''function'' instead of ''Bookmark'']' \0)
   rc=buffer(FREEBUF,buff)
   parse value lb with button 2 function \0
   if button=\1 then
      'mgo Function' function
--   elseif button=\2 then
--      'deletefunction' function
   endif

defc mnextfunction
   parse arg next .
   'mnext Function' next

defc mautoindent
   universal ML_autoindent
   uparg=upcase(arg(1))
   if uparg=ON__MSG then
      ML_autoindent = 1
      call select_edit_keys()
   elseif uparg=OFF__MSG then
      ML_autoindent = 0
      call select_edit_keys()
   elseif uparg='' then
      sayerror 'AUTOINDENT:' word(OFF__MSG ON__MSG, ML_autoindent+1)
   else
      sayerror INVALID_ARG__MSG ON_OFF__MSG')'
      stop
   endif

defc mindentline
;   déterminer le langage
   language=.userstring
   if isadefc('mindent_'language'_line') then
      'mindent_'language'_line'
   else
      if .line then
         oldline=.line
         .line=.line-1
         while .line & textline(.line)='' do
            .line=.line-1
         endwhile
         if .line then
            call pfirst_nonblank()
         else
            .col=1
         endif
         .line=oldline
         newpos=.col
         call pfirst_nonblank()
         if .col<newpos then
            for i=1 to newpos-.col
               keyin ' '
            endfor
         elseif .col>newpos then
            for i=1 to .col-newpos
               deletechar
            endfor
         endif
      endif
   endif

defproc mpopup
   popupid=dynalink('PMWIN','WINWINDOWFROMID',atoi(0)||atoi(1)||atoi(1234),2)
   choice=windowmessage(0,popupid,4097,getpminfo(EPMINFO_EDITCLIENT),arg(1))

defc mpopupmenu
   if arg(1)=10 then
      call mpopup(11)
   elseif mouse_in_mark() then
      if leftstr(marktype(),1)='C' then
         call mpopup(1+arg(1))
      else
         call mpopup(4+arg(1))
      endif
   elseif leftstr(marktype(),1)<>' ' then
      'MH_gotoposition'
      call mpopup(2+arg(1))
   else
      'MH_gotoposition'
      call mpopup(3+arg(1))
   endif

defc newtop 
   l=.line; .cursory=1; l

defc msetstatusline
   universal ML_array_ID
   parse arg statusline
   do_array 2, ML_array_ID, 'statusline', statusline
   'setstatusline' statusline

defproc mgetfilemode
   universal ML_array_ID
   getfileid fileid
   if get_array_value(ML_array_ID, fileid'.mode', mode) then
      return ''
   else
      return mode
   endif
 
defc msetfilemode
   universal ML_array_ID
   getfileid fileid
   parse arg mode
   do_array 2, ML_array_ID, fileid'.mode', mode
   'mcallhook select_hook'

defc show_mode_hook
   universal ML_array_ID
   if get_array_value(ML_array_ID, 'statusline', statusline) then
      return
   endif
   getfileid fileid
   if get_array_value(ML_array_ID, fileid'.mode', mode) then
      mode='Text mode'
   endif
--   statusline = 'Line %l of %s  Column %c   %f   %i    %m    %t'
   p=pos('%t',statusline)
   if p then
      'setstatusline' insertstr(mode,delstr(statusline,p,2),p)
   endif

; Dependencies:  put_file_as_MVST()
defc msaveattributes
   universal EPM_utility_array_ID
   universal app_hini
   universal default_font
   getfileid start_fid
;; call psave_pos(savepos)
   'xcom e /c attrib'
   if rc<>-282 then  -- -282 = sayerror("New file")
      sayerror ERROR__MSG rc BAD_TMP_FILE__MSG sayerrortext(rc)
      return
   endif
   browse_mode = browse()     -- query current state
   if browse_mode then call browse(0); endif
   .autosave = 0
   getfileid attrib_fid
   delete  -- Delete the empty line
;; activatefile start_fid
   line=0; col=1; offst=0; found_font = 0
   style_line=0; style_col=0; style_offst=0; style_list=''
   do forever
      class = 0  -- Find any class
      attribute_action 1, class, offst, col, line, start_fid -- 1=FIND NEXT ATTR
      if class=0 then leave; endif
      query_attribute class, val, IsPush, offst, col, line, start_fid
      l = line
      if class=BOOKMARK_CLASS then  -- get name
         if IsPush<>4 then iterate; endif    -- If not permanent, don't keep it.
         do_array 3, EPM_utility_array_ID, 'bmi.'val, bmname  -- Get the name
         l = l bmname
      elseif class=COLOR_CLASS then  -- don't save if out of range
;;       if val>255 then iterate; endif
         if line=style_line & col=style_col & (offst=style_offst+1 | offst=style_offst+2) then iterate; endif
;;       if line=style_line & col=style_col & offst=style_offst+2 then iterate; endif
      elseif class=FONT_CLASS then  -- get font info
;;       if val>255 then iterate; endif
         if line=style_line & col=style_col & offst=style_offst+1 then iterate; endif
         l = l queryfont(val)
         found_font = 1
      elseif class=STYLE_CLASS then  -- get style info
         do_array 3, EPM_utility_array_ID, 'si.'val, stylename -- Get the style name
         style_line=line; style_col=col; style_offst=offst
--         l = l stylename
         if val<256 & not pos(chr(val), style_list) then  -- a style we haven't seen yet
            if style_list='' then
               'xcom e /c style'
               if rc<>-282 then  -- -282 = sayerror("New file")
                  sayerror ERROR__MSG rc BAD_TMP_FILE__MSG sayerrortext(rc)
                  if browse_mode then call browse(1); endif  -- restore browse state
                  return
               endif
               .autosave = 0
               getfileid style_fid
               delete  -- Delete the empty line
            endif
            style_list = style_list || chr(val)
compile if WANT_APPLICATION_INI_FILE
            insertline stylename || \0 || queryprofile(app_hini, 'Style', stylename), style_fid.last+1, style_fid
compile else
            insertline stylename || \0 , style_fid.last+1, style_fid
compile endif
            val=pos(chr(val), style_list) -- style pos in EPM.STYLES
         else
            l = l stylename
         endif  -- new style
      endif  -- class=STYLE_CLASS
      insertline class val ispush offst col l, attrib_fid.last+1, attrib_fid
   enddo
   if found_font & .font <> default_font then
      insertline FONT_CLASS .font 0 0 0 (-1) queryfont(start_fid.font), 1, attrib_fid  -- Insert at beginning.
   endif
   call put_file_as_MVST(attrib_fid, start_fid, 'EPM.ATTRIBUTES')
   if style_list <> '' then
      call put_file_as_MVST(style_fid, start_fid, 'EPM.STYLES')
      style_fid.modify = 0
      'xcom quit'
   endif
   attrib_fid.modify = 0
   'xcom quit'
   if browse_mode then call browse(1); endif  -- restore browse state

; Dependencies:  find_ea() from EA.E                                 
defc mloadattributes
   universal EPM_utility_array_ID, app_hini, load_var
   getfileid fid    
   oldmod = .modify
   val = get_EAT_ASCII_value('EPM.TABS')
   if val<>'' then
      .tabs = val
      load_var = load_var + 1  -- Flag that Tabs were set via EA
   endif
   val = get_EAT_ASCII_value('EPM.MARGINS')                     
   if val<>'' then
      .margins = val
      load_var = load_var + 2  -- Flag that Tabs were set via EA
   endif
   if find_ea('EPM.STYLES', ea_seg, ea_ofs, ea_ptr1, ea_ptr2, ea_len, ea_entrylen, ea_valuelen) then
      val = peek(ea_seg, ea_ptr2,min(ea_valuelen,8))
      style_list=''
      if leftstr(val,2)=EAT_MVST & substr(val,7,2)=EAT_ASCII then
         num = itoa(substr(val,5,2),10)
         ea_ptr2 = ea_ptr2 + 8
         do i=1 to num
            len = itoa(peek(ea_seg, ea_ptr2, 2), 10)
            parse value peek(ea_seg, ea_ptr2 + 2, len) with stylename \0 stylestuff
compile if WANT_APPLICATION_INI_FILE
            if queryprofile(app_hini, 'Style', stylename)='' then  -- Don't have as a local style?
               call setprofile(app_hini, 'Style', stylename, stylestuff)  -- Add it.
            endif                                                                                 
compile endif                                                                       
            style_list = style_list stylename
            ea_ptr2 = ea_ptr2 + len + 2
         enddo
      endif
   endif
   need_colors=0; need_fonts=0
   if find_ea('EPM.ATTRIBUTES', ea_seg, ea_ofs, ea_ptr1, ea_ptr2, ea_len, ea_entrylen, ea_valuelen) then
      val = peek(ea_seg, ea_ptr2,min(ea_valuelen,8))
      if leftstr(val,2)=EAT_MVST & substr(val,7,2)=EAT_ASCII then
         num = itoa(substr(val,5,2),10)
         ea_ptr2 = ea_ptr2 + 8
         do_array 3, EPM_utility_array_ID, 'bmi.0', bmcount          -- Index says how many bookmarks there are
         do_array 3, EPM_utility_array_ID, 'si.0', stylecount
         fontsel=''; bg=''  -- Initialize to simplify later test                                               
         do i=1 to num
            len = itoa(peek(ea_seg, ea_ptr2, 2), 10)            
            parse value peek(ea_seg, ea_ptr2 + 2, len) with class val ispush offst col line rest
            ea_ptr2 = ea_ptr2 + len + 2
            if class=BOOKMARK_CLASS then  -- get name
               if not get_array_value(EPM_utility_array_ID, 'bmn.'rest, stuff) then  -- See if we already had it
                  parse value stuff with oldindex oldfid .
                  if oldfid = fid then                                                                          
                     'deletebm' rest
                  endif
               endif
               bmcount = bmcount + 1
               do_array 2, EPM_utility_array_ID, 'bmi.'bmcount, rest -- Store the name at this index position
               if IsPush<2 then IsPush=4; endif  -- Update old-style bookmarks
               stuff = bmcount fid IsPush  -- flag as permanent                                              
               do_array 2, EPM_utility_array_ID, 'bmn.'rest, stuff -- Store the index & fileid under this name
               val = bmcount  -- Don't care what the old index was.
            elseif class=COLOR_CLASS then                                                                     
               need_colors = 1                                     
            elseif class=FONT_CLASS then
               parse value rest with fontname '.' fontsize '.' fontsel
               if fontsel='' then iterate; endif  -- Bad value; discard it
               val=registerfont(fontname, fontsize, fontsel)  -- Throw away old value
               if line=-1 then                                            
                  .font = val                                                        
                  iterate
               endif
               need_fonts = 1
            elseif class=STYLE_CLASS then  -- Set style info
compile if WANT_APPLICATION_INI_FILE
               if val<256 then                              
                  stylename = word(val, style_list)
               else
                  parse value rest with stylename
               endif
               stylestuff = queryprofile(app_hini, 'Style', stylename)
               if stylestuff='' then iterate; endif  -- Shouldn't happen
               parse value stylestuff with fontname '.' fontsize '.' fontsel '.' fg '.' bg
               if get_array_value(EPM_utility_array_ID, 'sn.'stylename, val) then  -- Don't have it; add:
                  stylecount = stylecount + 1                                 -- Increment index
                  do_array 2, EPM_utility_array_ID, 'si.'stylecount, stylename  -- Save index.name       
                  do_array 2, EPM_utility_array_ID, 'sn.'stylename, stylecount  -- Save name.index
                  val = stylecount                                                                
               endif                                                                              
compile else
               iterate
compile endif
            endif
            insert_attribute class, val, ispush, 0, col, line
            if class=STYLE_CLASS then  -- Set style info
               if fontsel<>'' then
                  fontid=registerfont(fontname, fontsize, fontsel)
                  if fontid<>.font then  -- Only insert font change for style if different from base font.
                     insert_attribute FONT_CLASS, fontid, ispush, 0, col, line
                     need_fonts = 1                                                                       
                  endif
               endif
               if bg<>'' then
                  insert_attribute COLOR_CLASS, bg*16 + fg, ispush, 0, col, line
                  need_colors = 1
               endif
            endif
         enddo
         do_array 2, EPM_utility_array_ID, 'bmi.0', bmcount          -- Store back the new number
         do_array 2, EPM_utility_array_ID, 'si.0', stylecount
         if need_colors then                                                                     
            call attribute_on(1)  -- Colors flag
         endif
compile if EVERSION >= 5.50  -- GPI has font support
         if need_fonts then
            call attribute_on(4)  -- Mixed fonts flag
         endif
compile endif                                        
         call attribute_on(8)  -- "Save attributes" flag
      else   
         sayerror UNEXPECTED_ATTRIB__MSG                
      endif
   endif
   .modify = oldmod
