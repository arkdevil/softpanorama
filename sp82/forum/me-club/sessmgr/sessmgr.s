#IFDEF windows
	#include windows.sh
	#include mew.sh
	#include fprompt.sh
	#include dialog.sh
	#include mewlist2.sh
	#include metools.sh
	#include mewlogo.sh
	#include mewlib.sh

	#define SESSMGR_HELPLINK "SESSION MANAGER"
	#define SESMGRSETUP_HELPLINK "SESSION MANAGER SETUP"

//  #include mew.sh  There is a redundant global declaration in here so we do this instead
prototype mew
{
	void ProcessMEWInit ();
}
#ELSE
	#include selctdir.sh
#ENDIF

global {
//	int session_list_number;
	int session_names_number;
	int sm_active_win_id;
	int SM_IGNORE_en_Change;
}

macro_file sessmgr;



/********************************************************************************
															 MULTI-EDIT MACRO FILE

Name: SESSMGR

Description:  The ME Session Manager


	// Session Manager settings
	set_global_int('!@SESSVIEW@!',1);				// default to view names (1=true)
	set_global_int('!@SESSMODMSG@!',0);     // change existing name on exit (1=true)
	set_global_int('!@SESSRSTRMSG@!',1);    // show restore message (1=true)



								(C) Copyright 1994 by American Cybernetics, Inc.
****************************************************************************** */



// we need the prototypes for calls to macros within exit.s
#include exit.sh

#IFDEF windows
#DEFINE _SESSION_EXTENSION ".MEW"
#define ME_VERSION_LENGTH 34            // actual - 1 (major + .)
#DEFINE ME_VERSION_TEXT "@MULTI-EDIT FOR WINDOWS VERSION "
#ELSE
#DEFINE _SESSION_EXTENSION ".ME"
#define ME_VERSION_LENGTH 22            // actual - 1 (major + .)
#DEFINE ME_VERSION_TEXT "@MULTI-EDIT VERSION "
#ENDIF



// to remember what  restore=3  is
#defIne ENCODED_FILES_MODE 3
#define IN_ENCODED_MODE (global_int('@RESTORE')==ENCODED_FILES_MODE)
#define SM_NAME_TITLE "Session Manager"
#define SM_NAME_VIEW_BTN "&View Dir Sessions"
#define SM_DIR_TITLE "Session Manager -(Directory Sessions)"
#define SM_DIR_VIEW_BTN "&View Named Sessions"
#define SM_name_title_ctrl 701
#define SM_name_ctrl 702
#define SM_dir_title_ctrl 703
#define SM_dir_ctrl 704
#define SM_list_ctrl 600
#define SM_accept_ctrl 800
#define SM_Browse_ctrl 801
#define SM_Create_ctrl 802
#define SM_Delete_Ctrl 803
#define SM_Update_ctrl 804
#define SM_Setup_Ctrl  805
#define SM_Sort_Ctrl   806
#define SM_OK          1001
#define SM_CANCEL      1002
#define SM_HELP        1003
#define SM_BOX1    650
#define SM_BOX2    651
#define SM_Box3    652
#define SM_Str1    653
#define SM_Str2    654
#define SM_BITMAP  655

/******************** Multi-Edit VOID Macro Function ************************

 NAME:         cantdelete()

 DESCRIPTION:  notify the user that they cant delete the session that
							 they are currently working in from the session list

 PARAMETERS:	 None.

 RETURNS:			 None.

*****************************04-05-93 04:20pm*******************************/

void cantdelete()
{
	int  menu = menu_create ;
	menu_set_item( menu, 1, 'From the SESSION MANAGER: ','','/L=3/C=3',10,0, 0);
	menu_set_item( menu, 2, 'You may not delete the current','','/L=5/C=3',10,0, 0);
	menu_set_item( menu, 3, 'session that you are working on.','','/L=6/C=3',10,0,0);
	menu_set_item( menu, 4, 'Select another session.','','/L=8/C=3',10,0,0);

	return_int = menu;
#ifdef WINDOWS
	RM('UserIn^Data_In /HN=1/A=1/#=4/T=Warning/H=' + SESSMGR_HELPLINK);
#else
	RM('UserIn^Data_In /HN=1/H=*/A=1/#=4/T= Warning ');
#endif

	menu_delete( menu );
}

int check_dir(str dir_spec) {
	int ret_value = true,
			root_flag = false;
// special check for root directory
	if (xpos("\\",fix_dir_spec(dir_spec),1) ==
			length(fix_dir_spec(dir_spec))) {
		root_flag = !first_file(fix_dir_spec(dir_spec) + "*.*");
	}

	if ((((file_exists(dir_spec)) && (file_attr(dir_spec) & 0x10)) ||
			(dir_spec == "")) || (root_flag)) {
		ret_value = true;
	} else {

		RM("USERIN^VERIFY /BL=" + dir_spec + "/T=Directory does not exist. Create?");
		if (return_int) {
			int DOS_Error = MKDIR(dir_spec);
			if (DOS_Error == 0) {
				ret_value = True;
			} else {
				RM("MEERROR^MESSAGEBOX /B=1/M=Error #" + str(DOS_Error) +
						" while attempting to create the directory: " + dir_spec);
				ret_value = False;
			}
		}
	}
	return(ret_value);
}

void SM_CONFIGURE() {
	int dlg;
	int restore_mode = global_int("@RESTORE");

	DlgCreate( dlg );

	DlgAddCtrl( dlg, DLG_BitmapStatic, "BT_GN_121",1,1,0,0,150,0,"");

  DlgAddCtrl( dlg, DLG_GroupBox, 'Restore status method',10, 1, 41, 5, 2002, 0, "" );

	DlgAddCtrl( dlg, DLG_RadioButton, '&No status saved',DLG_PosOffset + 1,DLG_PosOffset + 1,0,0,1100,0,"");
	DlgSetInt( dlg, 1100, restore_mode == 0);

	DlgAddCtrl( dlg, DLG_RadioButton, '&Status file in each dir',DLG_PosOffset,DLG_PosOffset + 1,0,0,1101,0,"");
	DlgSetInt( dlg, 1101, restore_mode == 1);

	DlgAddCtrl( dlg, DLG_RadioButton, 'One &global status file',DLG_PosOffset,DLG_PosOffset + 1,0,0,1102,0,"");
	DlgSetInt( dlg, 1102, restore_mode == 2);

	DlgAddCtrl( dlg, DLG_RadioButton, '&Encoded status files for each dir',DLG_PosOffset,DLG_PosOffset + 1,0,0,1103,0,"");
	DlgSetInt( dlg, 1103, restore_mode == 3);


	DlgAddCtrl( dlg, DLG_Static, 'Stat&us file path:',1,DLG_PosOffset + 2,0,0,2003,0,"");
	DlgAddCtrl( dlg, DLG_Text, global_str("@RESTORE_PATH"),DLG_PosOffset + 18,DLG_PosOffset,32,0,1104,0,"/ML=128");

	DlgAddCtrl( dlg, Dlg_GroupBox, 'Options', 1, Dlg_PosOffset + 2, 50, 4, 1300, 0, "");

	DlgAddCtrl( dlg, DLG_Checkbox, '&Restore screen position on startup',DLG_PosOffset + 1,DLG_PosOffset + 1,0,0,1105,0,"");
	DlgSetInt( dlg, 1105, Restore_Flags & _REST_SCREEN_POS );


	DlgAddCtrl( dlg, DLG_Checkbox, 'Restore &tool bars from session to session',DLG_PosOffset,DLG_PosOffset + 1,0,0,1106,0,"");
	DlgSetInt( dlg, 1106, Restore_Flags & _REST_TOOL_BARS );

	DlgAddCtrl( dlg, DLG_Checkbox, 'Use &current session when creating',DLG_PosOffset,DLG_PosOffset + 1,0,0,1107,0,"");
	DlgSetInt( dlg, 1107, !global_int("~SESSION_NEW_EMPTY"));


	DlgAddCtrl( dlg, DLG_PushButton, "OK",1,DLG_PosOffset + 2,Dlg_StanBtnWidth,0,100,DLGF_DefButton,"/R=1");
	DlgAddCtrl( dlg, DLG_PushButton, "Cancel",DLG_PosOffset  + Dlg_StanBtnWidth + 2,DLG_PosOffset,Dlg_StanBtnWidth,0,101,0,"/R=0");
	DlgAddCtrl( dlg, DLG_PushButton, "&Help",42,DLG_PosOffset,Dlg_StanBtnWidth,0,102,0,"/R=2");

  if(DlgExecute( dlg, 100, "Restore, Session Manager Setup", SESMGRSETUP_HELPLINK, "", 0 ))
	{
		Set_Global_Int('SETUP_CHANGED',Global_Int('SETUP_CHANGED') | $01);

		// Setup restore options
		restore_mode = 0;
		if( DlgGetInt(dlg,1101))
		{
			restore_mode = 1;
		}
		else if ( DlgGetInt(dlg,1102) )
		{
			restore_mode = 2;
		}
		else if ( DlgGetInt(dlg,1103) )
		{
			restore_mode = 3;
		}
		set_global_int( "@RESTORE", restore_mode );
		set_global_str("@RESTORE_PATH", DlgGetStr(dlg,1104) );
		restore_flags = (restore_flags & 0xFE) | DlgGetInt(dlg, 1105);

		restore_flags = (restore_flags & 0xFD) | (DlgGetInt(dlg, 1106) << 1);

		Set_Global_Int('~SESSION_NEW_EMPTY',!DlgGetInt(dlg,1107));
	}
	DlgKill( dlg );
	return_int = 0;
}

void SM_PUT_LIST_DATA(str s_name, s_dir) {
/* This macro assumes the session manager list window is active
	 and your cursor is already on the desired line
*/
	put_line("NAME=" + s_name + "DIR=" + s_dir);

	RETURN();
}

void SM_GET_LIST_DATA(str &s_name, &s_dir) {
/* This macro assumes the session manager list window is active
	 and your cursor is already on the desired line
*/

	s_name = parse_str("NAME=",get_line);
	s_dir = parse_str("DIR=",get_line);

	RETURN();
}

void SM_DO_SORT(int list_hwnd) {
    int t_window_id = window_id,
        list_win_id,
        list_win_num,
        sort_win_id = 0,
        sort_win_num,
        numlines,
        current_selection,
        selection_set = 0,
        ascend = !Global_int("!SESS_SORT_DESCEND"),
        by_dir =  Global_int("!SESS_SORT_BY_DIR") * 80,
        t_int
        ;

    list_win_id = window_id;  // we may have this as a passed parameter
    list_win_num = cur_window;
    switch_window(window_count);
    create_window;
    sort_win_id = window_id;
    sort_win_num = cur_window;
    file_name = "SESSSORT.TMP";

    switch_win_id(list_win_id);
    current_selection = c_line;
  //  mark_pos;
    tof;
    while (!at_eof) {
      put_line_to_win(
        copy(parse_str("NAME=",get_line) +
  "                                                                              ",
        1, 80) +
        copy(parse_str("DIR=",get_line) +
  "                                                                              ",
        1, 80) +
        "LINE#=" +
        str(c_line),
        c_line,
        sort_win_num,
        0
      );
      down;
    }

  // clear out existing stuff in list window
    numlines = c_line - 1;
    block_begin;
    tof;
    delete_block;

  // sort temporary list
    switch_win_id(sort_win_id);
    Qsort_Lines(1, numlines, ascend, by_dir + 1, 80, 1);

  // rebuild list using sort results
    for (t_int = 0; t_int < numlines; ++t_int) {
      if (list_hwnd) {
        SendMessage( list_hwnd, LB_DELETESTRING, 0, 0 ); // delete selections
      }
      if (!selection_set) {
        if (parse_int("LINE#=",get_line) == current_selection) {
          selection_set = true;
          current_selection = c_line;
        }
      }
      put_line_to_win(
        "NAME=" + shorten_str(copy(get_line, 1, 80)) +
        "DIR=" + shorten_str(copy(get_line, 81, 80)),
        c_line,
        list_win_num,
        0
      );
      down;
    }

  // tell windows how many new selections there are
    if (list_hwnd) {
      for (t_int = 0; t_int < numlines; ++t_int) {
        SendMessage( list_hwnd, LB_ADDSTRING, 0, 0 );
      }
    }


    if (switch_win_id(sort_win_id)) {
      delete_window;
    }

    switch_win_id(list_win_id);
  //  goto_mark;
    goto_line(current_selection);
    if (list_hwnd) {
      sendmessage( list_hwnd, LB_SETCURSEL, c_line - 1, 0);
    }
    switch_win_id(t_window_id);
}

void SM_SORT_LIST() {
  int result,
      dlg;

  DlgCreate(dlg);

  DlgAddCtrl(dlg, DLG_GroupBox,
              "Sort Order",
              1,
              1,
              17,
              3,
              2001,
              0,
              "");

	DlgAddCtrl( dlg, DLG_RadioButton,
              "&Ascending",
              DLG_PosOffset | 1,
              DLG_PosOffset | 1,
							0,
							0,
              2002,
							0,
							"");
  DlgSetInt(dlg, 2002, !Global_Int("!SESS_SORT_DESCEND"));

	DlgAddCtrl( dlg, DLG_RadioButton,
              "&Descending",
              Dlg_PosOffset,
              Dlg_PosOffset | 1,
							0,
							0,
              2003,
							0,
							"");
  DlgSetInt(dlg, 2003, Global_Int("!SESS_SORT_DESCEND"));

  DlgAddCtrl(dlg, DLG_GroupBox,
              "Sort By",
              21,
              1,
              14,
              3,
              2005,
              0,
              "");

	DlgAddCtrl( dlg, DLG_RadioButton,
              "&Name",
              DLG_PosOffset | 1,
              DLG_PosOffset | 1,
							0,
							0,
              2006,
							0,
							"");
  DlgSetInt(dlg, 2006, !Global_Int("!SESS_SORT_BY_DIR"));

	DlgAddCtrl( dlg, DLG_RadioButton,
              "&Directory",
              Dlg_PosOffset,
              Dlg_PosOffset | 1,
							0,
							0,
              2007,
							0,
							"");
  DlgSetInt(dlg, 2007, Global_Int("!SESS_SORT_BY_DIR"));

  DlgAddCtrl( dlg, DLG_PushButton, "OK",
    1, 5,
    DLG_StanBtnWidth, 0, SM_OK, 0, "/R=1");

  DlgAddCtrl( dlg, DLG_PushButton, "Cancel",
    DLG_PosOffset+DLG_StanBtnWidth+2, DLG_PosOffset,
    DLG_StanBtnWidth, 0, SM_Cancel, 0, "/R=0");

  DlgAddCtrl( dlg, DLG_PushButton, "&Help",
    26, DLG_PosOffset,
    DLG_StanBtnWidth, 0, SM_HELP, 0, "/R=2");

  result = DlgExecute( dlg, SM_OK, "Sort Sessions", SESSMGR_HELPLINK, "", 0);

  if (result) {

    Set_Global_Int("!SESS_SORT_DESCEND", DlgGetInt(dlg, 2003));
    Set_Global_Int("!SESS_SORT_BY_DIR" , DlgGetInt(dlg, 2007));

    RM("SETUP^SETSAVE");

    SM_DO_SORT(GetDlgItem(parse_int("/DLGHANDLE=",mparm_str), SM_list_ctrl));
  }
  DlgKill(dlg);
}


/****************** Multi-Edit INTEGER Macro Function ***********************

 NAME:         sm_make_list(session_list_id)

 DESCRIPTION:  Creates a new window and builds of a list of the directories
							 currently covered by encoded status files.
							 Leaves the cursor on the line for the current directory.


 PARAMETERS:   session_list_id, the window on which to create the file list

 RETURNS:      the length of the longest line in the file list

 ----------------------------------------------------------------------------
 MODIFICATIONS
 ----------------------------------------------------------------------------
 040893[scm]: while creating the list of sessions, the authenticity of the
							status files is kept by checking the existence of the
							directories that the encoded status files refer to.
							If the directory does not exist, the status file is deleted.

 091093[scm]:	actually delete the status file / thx2 jeff fontanesi


 063094[tmj]: conditionally compile for DOS or Windows
							add Windows support

 081194[scm]: add support for 'named' sessions
							For EncodedStatusFiles mode only, the user can view
							the session list either by directory name or by a
							useful description of the edit session.

*****************************04-05-93 04:06pm*******************************/
int sm_make_list(session_names_id, str old_sess_name)
			 trans
{
	str fn[128] = make_restr_name( ENCODED_FILES_MODE,"");	// restore file for current dir
	str curfn[128] = fn;
	str buf;
	str bff,bff2,bfname;
	int tfile_search_attr = file_search_attr;
	int sresult,hn,jx,jy,jz1,jz2, tx, fexists;
	int SV_Refresh = refresh;
	int cline_pos;

//  switch_win_id( session_list_id ); // shouldn't we already be there?
//	erase_window; 										// clear the window
	refresh = false;

	// 082493[scm]
	// display 'search in progress
#IFDEF WINDOWS
	make_message('Searching for all sessions...');
	working;
#ELSE
	Put_Box(13, 8, 50, 11, LIGHTGRAY, BLACK, '', TRUE);
	Write('Searching for All Sessions...',16,9,LIGHTGRAY,BLACK);
#ENDIF

	file_search_attr = 1;

	// Find first file in list
	str sext = _SESSION_EXTENSION;
	sresult = first_file( get_path(fn) + '*'+ _SESSION_EXTENSION );
		// As long as dos is returing 0, loop
	while( !sresult )
	{
			// Open the file up
		if( !s_open_file( get_path(fn) + last_file_name, 0x20, hn ) )
		{
				// read the first 250 bytes
			if( !s_read_bytes( buf, hn, 250 ))
			{

				tx = xpos("\r",buf,1); // make sure we have only 1 line
				buf = copy(buf,1,tx - 1);

					// check to see if it is a valid restore file
				if(copy(buf, 1, ME_VERSION_LENGTH) == (ME_VERSION_TEXT  + Copy(version,1,2)))
				{
						bfname = parse_str("SESS_BY_NAME=",buf);
						if (svl(bfname)) {
							switch_win_id(session_names_id);
							SM_PUT_LIST_DATA(bfname,parse_str("SESS_HOME_DIR=",buf));
							down;
						}
				}
			}
			s_close_file(hn);
		}
		sresult = next_file;
	}

	// 0842493[scm]
	// kill the 'searching...' box
#IFDEF WINDOWS
	make_message('');
#ELSE
	Kill_Box;
#ENDIF

	up;         // Sort the list and name list
	qsort_lines( 1, c_line,1, 1, 2048, 0 );

	switch_win_id(session_names_id);
	up;
	qsort_lines( 1, c_line,1, 150, 2048, 0);
	tof;

	file_search_attr = tfile_search_attr;

	tof;
// find current named session list
  if (!svl(old_sess_name)) {
    old_sess_name = global_str("!SESSION_NAME");
  }
  find_text("NAME=" + old_sess_name + "", 0, 0)

	goto_col(1);

	refresh = SV_Refresh;

	return (64);

}

void SM_SET_CTRLS(hdlg) {

	SM_ignore_en_change = true; // tell hook proc not to enable the accept button

	switch_window(session_names_number);
	str s_dir, s_name;
	SM_GET_LIST_DATA(s_name,s_dir);
	SetDlgItemText(hdlg, SM_name_ctrl, s_name);
	SetDlgItemText(hdlg, SM_dir_ctrl, s_dir);

	int item_count = SendDlgItemMessage(hdlg, SM_List_ctrl,
		LB_GETCOUNT, 0, 0);

	if (item_count == 0) {
		EnableWindow(GetDlgItem(hdlg, SM_name_ctrl), FALSE);
		EnableWindow(GetDlgItem(hdlg, SM_name_title_ctrl), FALSE);
		EnableWindow(GetDlgItem(hdlg, SM_dir_ctrl), FALSE);
		EnableWindow(GetDlgItem(hdlg, SM_dir_title_ctrl), FALSE);
		EnableWindow(GetDlgItem(hdlg, SM_browse_ctrl), FALSE);
		EnableWindow(GetDlgItem(hdlg, SM_Ok), FALSE);
		SetDefaultButton(hdlg,SM_Create_ctrl);
	} else {
		EnableWindow(GetDlgItem(hdlg, SM_name_ctrl), true);
		EnableWindow(GetDlgItem(hdlg, SM_name_title_ctrl), true);
		EnableWindow(GetDlgItem(hdlg, SM_dir_ctrl), true);
		EnableWindow(GetDlgItem(hdlg, SM_dir_title_ctrl), true);
		EnableWindow(GetDlgItem(hdlg, SM_browse_ctrl), true);
		EnableWindow(GetDlgItem(hdlg, SM_Ok), true);
		SetDefaultButton(hdlg,SM_OK);
	}

	EnableWindow(GetDlgItem(hdlg, SM_accept_ctrl), false);


	SM_ignore_en_change = false;
}

/******************** Multi-Edit VOID Macro Function ************************

 NAME:         sm_delete()

 DESCRIPTION:  Run by SM_DIALOG when the Del button is pressed

*****************************04-18-93 01:09pm*******************************/
void sm_delete(
	int list_win = parse_int('/LW=',mparm_str),
	int name_win = parse_int('/NW=',mparm_str)
)
{
	int curwin = cur_window;
	int clpos = c_line;
	str s_name, s_dir;
#IFDEF WINDOWS
	int dialog_handle = parse_int('/DLGHANDLE=',mparm_str);
	int listbox_id    = parse_int('/LB=',mparm_str);
	int list_hwnd = GetDlgItem(dialog_handle,listbox_id);
	int jx, record_count;
	int currentlbsel;
#ENDIF
	str tstr1;


	switch_window(name_win);
	goto_line(clpos);


	goto_col(1);
	SM_GET_LIST_DATA(tstr1, s_dir);

	if ( tstr1 == global_str("!SESSION_NAME") )
	{
			cantdelete();
	}
	else
	{
#ifdef WINDOWS
		RM("USERIN^VERIFY /H=" + SESSMGR_HELPLINK +
				"/BL=Confirm/T=Delete \""+ tstr1 + "\"?");
#else
		RM("USERIN^VERIFY /H=PROMPTS/BL=Confirm/T=Delete \""+ tstr1 + "\"?");
#endif

		if (Return_Int)
		{
				// delete the encoded file
				tstr1 = make_restr_name(ENCODED_FILES_MODE,"0:" + tstr1) + ".MEW";

				del_file(tstr1);


				// Delete the line from the session list
				currentlbsel = c_line - 1;
				del_line;

				if(at_eof)
					up;

				mark_pos;
				eof;
				record_count = c_line;
				goto_mark;

				call reset_list;
				call redraw_list;
				SM_SET_CTRLS(dialog_handle);
		}
	}
	return_int = 0;
	goto_col(1);
	goto exit_del;

#IFDEF WINDOWS
{
reset_list:
	jx = SendMessage( list_hwnd, LB_GETCURSEL, 0, 0 );
	SendMessage( list_hwnd, LB_DELETESTRING, jx, 0 );
	--jx;
	sendmessage( list_hwnd, LB_SETCURSEL, c_line - 1, 0);
	ret;

redraw_list:
	RedrawWindow( list_hwnd, 0, 0, rdw_Invalidate );
	RET;
}
#ENDIF

exit_del:
	redraw;

	return_int = 0;
}

int SM_CHECK_NAME(str s_name, int line_num) {
// checks for naming conflicts.  assumes you are already in the
// list box window.  returns 0 if there is a conflict
	int return_value = 1;
	str t_name;

	mark_pos;

	tof;
	while (!at_eof) {
		if ((c_line != line_num /* this prevents looking at existing line */)
				&& (caps(fix_cmd_param(s_name)) ==
				caps(fix_cmd_param(parse_str("NAME=",get_line))))) {
			return_value = 0;
			t_name = parse_str("NAME=",get_line);
		}
		down;
	}

	goto_mark;

	if (return_value == 0) {
		RM("MEERROR^MESSAGEBOX /B=1/T=Name Conflict/M=The session name '" +
				s_name +
				"' will create a status file of the same name as the existing session '" +
				t_name + "'.");
	}

	RETURN(return_value);
}

void SM_UPDATE() {
	int hDLG = parse_int("/DLGHANDLE=",mparm_str),
			cur_list_window,
			active_window = window_id;
	str s_name,
			s_dir,
			cur_sess_name = global_str("!SESSION_NAME");

	cur_list_window = SendDlgItemMessage(hdlg, SM_list_ctrl, WM_ML2_GETLISTBUF, 0 ,0);
	switch_window(cur_list_window);
	SM_GET_LIST_DATA(s_name,s_dir);

// run status to replace the current status file for this session
	set_global_str("!SESSION_NAME",s_name);
	switch_win_id(sm_active_win_id);
	RM("STATUS");
	set_global_str("!SESSION_NAME",cur_sess_name);

	switch_window(cur_list_window);
	SM_PUT_LIST_DATA(s_name, fexpand(""));

	RedrawWindow(GetDlgItem(hdlg, SM_list_ctrl), 0, 0, RDW_INVALIDATE);

	switch_win_id(active_window);
	return_int = 0;
}

void SM_NEW() {
	int hDLG = parse_int("/DLGHANDLE=",mparm_str),
			cur_list_window,
			hList,
//			item_count,
			t_insert_mode = insert_mode,
			active_window = window_id;
	str s_dir,
			cur_path = fexpand(""),
			cur_sess_name = global_str("!SESSION_NAME");

	cur_list_window = SendDlgItemMessage(hdlg, SM_list_ctrl, WM_ML2_GETLISTBUF, 0 ,0);
	switch_window(cur_list_window);

	if (SM_check_name("(no name)",0)) {
// run STATUS so we have a session file to work with
		set_global_str("!SESSION_NAME","(no name)");
		switch_win_id(sm_active_win_id);
		RM("STATUS /NEW=" + str(global_int("~SESSION_NEW_EMPTY")));

		set_global_str("!SESSION_NAME",cur_sess_name);

		switch_window(cur_list_window);
		goto_col(1);
		if (!at_eof) {
			eol;
			insert_mode = true;
			cr;
		}

		SM_PUT_LIST_DATA("(no name)",fexpand(""));
		insert_mode = t_insert_mode;

		SendMessage(GetDlgItem(hdlg, SM_list_ctrl), WM_SETREDRAW, 0, 0);
		SendMessage(GetDlgItem(hdlg, SM_list_ctrl), LB_ADDSTRING, 0, 0);
		sendmessage(GetDlgItem(hdlg, SM_list_ctrl), LB_SETCURSEL, c_line - 1, 0);
		SendMessage(GetDlgItem(hdlg, SM_list_ctrl), WM_SETREDRAW, 1, 0);
		SendMessage(GetDlgItem(hdlg, SM_list_ctrl), WM_ML2_REDRAW, 0, 0);
	}
	sm_set_ctrls(hdlg);
	SetFocus(GetDlgItem(hdlg, SM_name_ctrl));
// this highlights the text in the name control
  SendMessage(GetDlgItem(hdlg, SM_name_ctrl), EM_SETSEL, 0, 0xFFFF0000);

	switch_win_id(active_window);
	return_int = 0;
}

void SM_ACCEPT() {
	int hDLG = parse_int("/DLGHANDLE=",mparm_str),
			cur_list_window;
	str old_s_name,
			cur_sess_name = global_str("!SESSION_NAME"),
			cur_path = fexpand(""),
			old_s_dir,
			new_s_name,
			new_s_dir;

	cur_list_window = SendDlgItemMessage(hdlg, SM_list_ctrl, WM_ML2_GETLISTBUF, 0 ,0);
	switch_window(cur_list_window);
	GetDlgItemText(hdlg, SM_name_Ctrl, new_s_name, 128);
	GetDlgItemText(hdlg, SM_dir_ctrl, new_s_dir, 128);
	new_s_dir = caps(new_s_dir);


	if (check_dir(fix_dir_spec(new_s_dir))) {
		if (SM_check_name(new_s_name,c_line)) {
		SM_GET_LIST_DATA(old_s_name, old_s_dir);
// rename the staus file if they changed the session name
		int dos_error = 0;
		if (old_s_name != new_s_name) {
			dos_error = rename_file(
					make_restr_name( ENCODED_FILES_MODE,"0:" + old_s_name) + ".MEW",
					make_restr_name( ENCODED_FILES_MODE,"0:" + new_s_name) + ".MEW"
					);
		}
		if (dos_error == 0) {
			create_window;
// load the status file and change the name and home directory
			load_file(make_restr_name( ENCODED_FILES_MODE,"0:" + new_s_name) + ".MEW");
			if (!search_fwd("",1)) {
				eol;
			}
			str t_str = copy(get_line,1,c_col - 1);
			put_line(t_str +
					"SESS_BY_NAME=" + new_s_name +
					"SESS_HOME_DIR=" + new_s_dir
					);
			save_file;
			delete_window;

		} else {
// if we get here it is probably because we did not have an existing
// status file to rename.  Create one from scratch by running STATUS.

			set_global_str("!SESSION_NAME",new_s_name);
			change_dir(fix_dir_spec(new_s_dir));
			RM("STATUS");
			change_dir(fix_dir_spec(cur_path));
			error_level = 0;
			set_global_str("!SESSION_NAME",cur_sess_name);
		}
// change the stuff in the list box
		switch_window(cur_list_window);

		SM_PUT_LIST_DATA(new_s_name, new_s_dir);

		SetFocus(GetDlgItem(hdlg, SM_list_ctrl));
		RedrawWindow(GetDlgItem(hdlg, SM_list_ctrl), 0, 0, RDW_INVALIDATE);
		SetDefaultButton(hdlg,SM_OK);
		EnableWindow(GetDlgItem(hdlg, SM_accept_ctrl), False);
		} else {
			SetFocus(GetDlgItem(hdlg, SM_name_ctrl));
		}
	}

	if (new_s_name == cur_sess_name) {
		if (fix_dir_spec(cur_path) != fix_dir_spec(new_s_dir)) {
			change_dir(fix_dir_spec(new_s_dir));
		}
	}

	return_int = 0;
}

void SM_BROWSE() {
	int hdlg = parse_int("/DLGHANDLE=",mparm_str),
			dlg = parse_int("/DATAHANDLE=",mparm_str);
	str s_dir;

	GetDlgItemText(hdlg, SM_Dir_Ctrl, s_dir, 128);

AGAIN:
	if (SelectDirectory( hdlg,            // int parent,
												s_dir,                      // str &fn,
												"Select a home directory", // str title,
												"SESSMGRNEWDIR",          // str help,
												0                         // int flags
											)
			) {
		SetFocus(GetDlgItem(hdlg, SM_dir_ctrl));
		DlgSetStr(dlg, SM_Dir_ctrl, s_dir);
		SetWindowText(GetDlgItem(hdlg, SM_dir_ctrl), s_dir);
		SendDlgItemMessage(hdlg, SM_browse_ctrl, BM_SETSTYLE, BS_PUSHBUTTON, TRUE);
		SendDlgItemMessage(hdlg, SM_accept_ctrl, BM_SETSTYLE, BS_DEFPUSHBUTTON, TRUE);
	}
	return_int = 0;
}

/****************** Multi-Edit INTEGER Macro Function ***********************

 NAME:         sm_dialog

 DESCRIPTION:  the dialog box from which the user selects sessions
							 the user can insert new sessions, delete sessions from
							 the list, select a session from the list, or escape.

 PARAMETERS:   int longest_line_length
									Used to evenly display the session list
							 int session_list_id,
									The window where the list has been built
							 int session_list_number,
									The number of the window where the list has been built
									Used by the dialog box /WIN parameter (where's the list?)


 RETURNS:      Directory name of session selected, or "" if ESC was hit.

*****************************04-05-93 04:22pm*******************************/
str sm_dialog(	int longest_line_length,
//										int session_list_id,
//										int session_list_number,
										int session_names_id,
										int session_names_number )
				trans
{

#IFNDEF WINDOWS

	int Active_Window = 	Window_Id;
	int T_Insert_Mode = 	Insert_Mode;
	int T_Refresh = 			Refresh;
	int cc = 							longest_line_length;		// cc vars used for box
	int ll;
	int menu;
	str s_dir, s_name = "";

	str sessname[80];
	str cursessname[80];
	str cursesspath[80];
	str cursessid[80];
	str otherstr[20];
	int svwinid;
	int mh, mi = 0;
	int viewoffset=0;
	int cline_pos;
	int session_view_win;
	int lll;
	int dfltitem = 1;

	dfltitem=6;
	switch ( global_int('!@SESSVIEW@!') )
	{
		case 1 :		// view session name
			cline_pos = c_line;
			switch_win_id(session_names_id);
			goto_line(cline_pos);
			sessname = remove_space(copy(get_line,1,70));
			cursessname = sessname;
			otherstr= ' Path';
			session_view_win = session_names_number;
			switch_win_id(session_list_id);
			goto_line(cline_pos);
			cursesspath = remove_space(copy(get_line,1,xpos(' ',get_line,1)));
			switch_win_id(session_names_id);
				break;
		case 0 :		// view session path
		default:
			cline_pos = c_line;
			switch_win_id(session_list_id);
			goto_line(cline_pos);
			sessname = remove_space(copy(get_line,1,xpos(' ',get_line,1)));
			cursesspath = sessname;

			switch_win_id(session_names_id);
			goto_line(cline_pos);
			cursessname = remove_space(copy(get_line,1,70));
			switch_win_id(session_list_id);
			otherstr = ' Name';
			session_view_win = session_list_number;
			break;
	}

	menu = menu_create;

MENU_LOOP:


	menu_delete(menu);
	menu = menu_create;
	mi = 0;
	refresh = false;
	longest_line_length = 40;

/*1*/	menu_set_item(menu,++mi,'Current Session:','','/W=20/C=2/L=2',10,0,0);
	switch(global_int('!@SESSVIEW@!'))
	{
		case 1 :
			cursessid = cursessname;
			break;
		case 0 :
		default:
			cursessid = cursesspath;
			break;
	}

/*2*/ menu_set_item(menu,++mi, cursessid,'','/W=30/ML=50/C=2/L=3',10,0,0);

/*3*/ menu_set_item(menu,++mi,'New directory', '',
					'/KC=<Ins>/W=18/K1=0/K2=82/R=3/L=6/C=50' /*+ str(cc)*/, 11, 0, 0);

/*4*/ menu_set_item(menu,++mi,'Remove session',
						'SM_DELETE /NW='+
						str(session_names_number)+
						'/LW='+str(session_list_number), '/M=1'+
						'/KC=<Del>/W=19/K1=0/K2=83/R=4/L=8/C=50'/* + str(cc + 20)*/, 11, 0, 0);

/*5*/ menu_set_item(menu,++mi,'View '+otherstr,'','/KC=<F6>/W=13/ML=28/K1=0/K2=64/R=5/L=10/C=50',11,0,0);

/*6*/ menu_set_item(menu,++mi,'Select directory to work in:', '', '/ML=35/W=' + str(longest_line_length + 1) + '/L=5/C=2/DC=1/WIN='+STR(session_view_win)+'/OR='+STR(C_ROW), 15, 0, 0);
			dfltitem = mi;


	Return_Int = menu;

	//RM("USERIN^DATA_IN  /NK=1/Y=4/H=SESSMGR/HN=1/PRE=SS/#="+
	//        str(mi)+"/T=Session Manager/S="+
	//        STR(DFLTITEM)+"/NC=1/OR=" + Str(C_Row));
	RM("USERIN^DATA_IN  /H=SESSMGR/HN=1/A=0/PRE=SS"+
				"/NK=1/Y=4"+
				'/#='+str(mi)+'/T=Session Manager/S='+
				str(dfltitem)+"/NC=1/OR=" + Str(C_Row));

forced:
	if (Return_Int == 1) {
		switch ( global_int('!@SESSVIEW@!') )
		{
			case  1:
				svwinid = window_id;
				switch_win_id(session_names_id);

				SM_GET_LIST_DATA(s_name, s_dir);

				switch_win_id(svwinid);
				break;
			case  0:
			default:
				svwinid=window_id;
				switch_win_id(session_list_id);
				s_dir = shorten_str(copy(get_line,1,149));
				switch_win_id(svwinid);
				break;
		}
	}
	else if ( Return_Int == 0 )
	{
		Return_Int = 0;						// user aborted
		s_dir = "";
	}
	else if ( Return_Int == 3 )		// *** NEW SESSION ***
	{
		switch ( global_int('!@SESSVIEW@!') )
		{
			case  1:
				RM("MEERROR^MESSAGEBOX /B=2/M=Need a dialog box for this!!!");
				break;
			case  0:
			default:
				Return_Str = "";
				Return_Int = 0;
				s_dir = select_dir_dlg();
/*
				if ( copy(s_dir,svl(s_dir),1) == '\' )
				{
					s_dir = copy(s_dir,1,svl(s_dir)-1);
				}
*/
				s_dir = fix_dir_spec(s_dir);
				if (s_dir == '') // *** ESCAPE ***
				{
					goto MENU_LOOP;
				}
				else if ((file_attr(s_dir) & 0x10) == 0)
				{
					rm("MEERROR^MessageBox /B=1/M=Directory does not exist");
					goto menu_loop;
				}
				break;
		}
	}
	else
		Goto MENU_LOOP;

	Insert_Mode = T_Insert_Mode;
	Refresh = T_Refresh;
	menu_delete(menu);
	switch_win_id(active_window);
	return ("DIR=" + s_dir + "NAME=" + s_name);

#ELSE       // ------------------- Windows version -----------------------


	int Active_Window = 	Window_Id;
	int T_Insert_Mode = 	Insert_Mode;
	int T_Refresh = 			Refresh;
	int cc = 							longest_line_length;		// cc vars used for box
	int ll;
	int dlg;
	str s_dir, s_name = "";

	str sessname[80];
	str cursessname[80];
	str cursesspath[80];
	str cursessid[80];
	str otherstr[40],
			titlestr[40],
			result_str;
	int svwinid;
	int mh;
	int ctrl_style, Create_style, Select_style;
	int viewoffset=0;
	int cline_pos;
	int session_view_win;
	int lll;
	int dfltitem = 1,
			new_flag = 0;


	int dlgidCurrentSession;
	int dlgidToggleView;

	refresh=false;

	dfltitem=6;
	sessname = global_str("!SESSION_NAME");
	cursessname = sessname;
	ctrl_style = 0;
	Create_style = 0;
	Select_style = DLGF_Defbutton;
	otherstr = SM_NAME_VIEW_BTN;
	titlestr = SM_NAME_TITLE;
	session_view_win = session_names_number;

// This will get the length to determine if we need a HSCROLL Bar.
  switch_window(session_view_win);

// while we're at it, sort the list
  SM_DO_SORT(0);

	int maxlength = 0;
	mark_pos;
	tof;
	while ( !at_eof ) {
		if ( length(parse_str("DIR=", get_line) ) > maxlength) {
			maxlength = length(parse_str("DIR=", get_line));
		}
		down;
	}
	goto_mark;
// End HSCROLL

	switch_win_id(session_names_id);
	if ((c_line == 1) && (at_eof)) {
		ctrl_style = DLGF_Disable;
		Create_style = Dlgf_Defbutton;
		Select_style = 0;
	}
	set_global_int('!@SESSVIEW@!',1);
	SM_GET_LIST_DATA(s_name, s_dir);
	refresh=false;

	DlgCreate(dlg);

	refresh = false;
	longest_line_length = 40;

	DlgAddCtrl(dlg,DLG_BitmapStatic, "BT_GN_121", 3, 3 , 0,0,SM_BITMAP, 0, "" );
	DlgAddCtrl(dlg,DLG_Blackframe,'',13,dlg_units + 4,60,1,SM_BOX1,0,'');
	DlgAddCtrl(dlg,DLG_Static,'Current Session:',dlg_posoffset + 1,dlg_PosOffset + dlg_units + 2,0,0,SM_STR1,0,'');

	if (svl(cursessname)) {
			cursessid = cursessname;
	} else {
			cursessid = cursesspath;
	}
	DlgAddCtrl(dlg,DLG_Static,cursessid,dlg_posoffset + 18,dlg_PosOffset,0,0,SM_STR2,0,"");

	DlgAddCtrl(dlg,DLG_Blackframe,'',13,dlg_units + 28,60,dlg_units + 29,SM_BOX2,0,'');
	DlgAddCtrl(dlg,DLG_Static,'Name:',dlg_posoffset + 1,Dlg_posOffset,0,0,SM_name_title_ctrl,ctrl_style,'');
	DlgAddCtrl(dlg,DLG_text, s_name, dlg_posoffset + 12,dlg_posOffset,30,0,SM_name_ctrl,ctrl_style,'/ML=30');
	DlgAddCtrl(dlg,DLG_Static,'Directory:',Dlg_Negoffset + 12,Dlg_posOffset + dlg_units + 16,0,0,SM_dir_title_ctrl,ctrl_style,'');
	DlgAddCtrl(dlg,DLG_text,s_dir, dlg_posoffset + 12,dlg_posOffset,30,0,SM_dir_ctrl,ctrl_style,'/ML=128');

	DlgAddCtrl(dlg,DLG_PushButton,"&Accept",
				DLG_PosOffset+32,dlg_NegOffset + dlg_units + 17,
				DLG_StanBtnWidth + 2,0,
				SM_Accept_ctrl,Dlgf_disable,"/R="+str(SM_Accept_Ctrl) + "/M=SM_ACCEPT /NW=" +
				str(session_names_number) +
				"/LID=" + str(SM_List_ctrl));
	DlgAddCtrl(dlg,DLG_PushButton,"&Browse...",
				DLG_PosOffset,dlg_PosOffset + dlg_units + 17,
				DLG_StanBtnWidth + 2,0,
				SM_Browse_ctrl,ctrl_style,"/R="+str(SM_Browse_Ctrl) + "/M=SM_BROWSE /NW=" +
				str(session_names_number));

	DlgAddCtrl(dlg,Dlg_ListBox,'"NAME=/W=29DIR=/W=29"',
				13, dlg_units + 64,
				60,7,
				SM_list_ctrl, DLGF_ES_AUTOHSCROLL,
				'/WIN='+str(session_view_win)+'/OR='+str(c_row)+
				'/INCO=1/DC=1/INSWCMD=' + str(sm_create_ctrl) +
				'/DELWCMD=' + str(sm_delete_ctrl) + '/HSCROLL=' + str(maxlength + 45));
			dfltitem = SM_list_ctrl;

	DlgAddCtrl(dlg,DLG_PushButton,"&Create",
				1,Dlg_PosOffset,
				DLG_StanBtnWidth,0,
				sm_create_ctrl,0 | Create_style,"/R="+str(SM_Create_Ctrl) +
				"/M=SM_NEW");

	DlgAddCtrl(dlg,Dlg_PushButton,'&Delete',
			DLG_PosOffset,DLG_PosOffset + dlg_units + 20,
			Dlg_StanBtnWidth,0,sm_delete_ctrl,0,
			'/R='+str(SM_Delete_Ctrl)+
			'/M=SM_DELETE /NW='+str(session_names_number)+
								'/DH='+str(dlg)+'/LB='+str(SM_List_Ctrl));

	DlgAddCtrl(dlg,Dlg_PushButton,'&Update',
			DLG_PosOffset,DLG_PosOffset + dlg_units + 20,
			Dlg_StanBtnWidth,0,SM_Update_Ctrl,0,
			'/R='+str(SM_Update_Ctrl)+
			'/M=SM_UPDATE');

  DlgAddCtrl(dlg,Dlg_PushButton,'&Sort...',
      DLG_PosOffset,DLG_PosOffset + dlg_units + 20,
      Dlg_StanBtnWidth,0,SM_Sort_Ctrl,0,
      '/R='+str(SM_Sort_Ctrl)+
      '/M=SM_SORT_LIST');

	DlgAddCtrl( dlg, DLG_PushButton, "Se&lect",
		1, dlg_units + 158,
		DLG_StanBtnWidth, 0, SM_OK, ctrl_style | Select_style, "/R=1");

	DlgAddCtrl( dlg, DLG_PushButton, "Cancel",
		DLG_PosOffset+DLG_StanBtnWidth+2, DLG_PosOffset,
		DLG_StanBtnWidth, 0, SM_Cancel, 0, "/R=0");

	DlgAddCtrl( dlg, DLG_PushButton, "&Help",
		63, DLG_PosOffset,
		DLG_StanBtnWidth, 0, SM_HELP, 0, "/R=2");

	return_int = DlgExecute( dlg, SM_list_Ctrl, titlestr, SESSMGR_HELPLINK, '/HOOK=SessMessageProc /TEST=1', 0);
	DlgKill(dlg);

forced:
	s_dir = "";
	s_name = "";
	if (Return_Int == 1) {
		svwinid = window_id;
		switch_win_id(session_names_id);
		SM_GET_LIST_DATA(s_name, s_dir);
		switch_win_id(svwinid);
	}
	else // if ( Return_Int == 0 )
	{
		Return_Int = 0;						// user aborted
		s_dir = "";
	}

	Insert_Mode = T_Insert_Mode;
	Refresh = T_Refresh;
	switch_win_id(active_window);
	return ("DIR=" + s_dir + "NAME=" + s_name);

#ENDIF

}

/*
//======================================================================
//	New routines to simulate mesys^parms1 and mesys^parmload code that
//	sets temp global variables (those whose prefix is one of !@.~)
//======================================================================
void SM_PARMS1()
{
	int Parm_Number;
	int jx, default_back, kspeed ;
	str TStr;
	char Tchar;

	set_global_int("@NO_MOUSE_SET", TRUE );

	if (length(temp_path) == 0) {
		GetTempFileName(GetTempDrive(jx), "", 0, tstr);
		temp_path = get_path(tstr);
	}
	return_str = temp_path;
	Set_Global_Str('~TEMP_PATH', temp_path );
	rm('XlateCmdLine');
	temp_path = return_str;


	return_str = backup_path;
	Set_Global_Str('~BACKUP_PATH', backup_path );
	rm('XlateCmdLine');
	backup_path = return_str;

     // Do we need to set default colors?
	if(  global_int('DEFAULT_COLORS')  ) {
		intr($11);
		if(  (r_ax & $0030) == $0030  ) {
			call set_mono;
		} else {
			call set_color;
		}
	}

	#IFNDEF windows
	kspeed = (Global_Int('NO_KEYSPEED') == 0);
	if(  kspeed  ) {
		R_BX = (Global_Int('KEYDELAY') << 8) | GLOBAL_INT('KEYSPEED');
		R_AX = $0305;
		INTR( $16 );
		Set_Global_Int('NO_KEYSPEED', 0 );
	}
	#ENDIF
	goto exit;

color_defaults:
#IFNDEF WINDOWS
	stat1_color = lightgray | default_back;
	stat2_color = white | default_back;
	message_color = lightgray | default_back;
	fnum_color = lightgray | default_back;
	fkey_color = 112;
	w_t_color = LightGray | default_back;
	w_s_color = yellow | default_back;
	w_b_color = lightgray | default_back;
	w_h_color = 112;
	w_eof_color = white | default_back;
	w_l_color = yellow | default_back;
	w_lb_color = 113;
	w_c_color = white | default_back;
	m_t_color = LightGray | default_back;
	m_s_color = white | default_back;
	m_b_color = white | default_back;
	m_k_color = cyan | default_back;
	m_h_color = 112;
	d_t_color = m_t_color;
	d_s_color = m_s_color;
	d_b_color = m_b_color;
	d_h_color = m_h_color;
	h_t_color = lightgray | default_back;
	h_s_color = white | default_back;
	h_r_color = yellow | default_back;
	h_b_color = lightgray | default_back;
	h_h_color = 112;
	h_f_color = 112;
	h_t1_color = 33;
	h_t2_color = 41;
	h_t3_color = 240;
	working_color = 240;
	background_color = default_back | white;
	Error_color = white | default_back;
	Shadow_Color = LightGray | default_back;
	Shadow_Char = Char(177);
	button_color = 7;
	button_key_color = 15;
	button_shadow_color = default_back | lightgray;
	Set_Global_Str('&SYNTAX_COLORS','/RWC=271/SYC=271/ECC=880/SCC=265/C1C=880/C2C=880/NCC=0');
#ENDIF
	ret;

set_color:
#IFNDEF WINDOWS
	Error_Color = 79;
	Shadow_Color = 8;
	Shadow_Char = '|0';
	W_T_Color = 23;
	W_H_Color = 96;
	W_B_Color = 27;
	W_C_Color = 31;
	w_l_color = 30;
	w_lb_color = 110;
	W_EOF_Color = 20;
	W_S_Color = 30;
	M_T_Color = 112;
	M_S_Color = 113;
	M_B_Color = 112;
	M_H_Color = 95;
	m_k_color = 120;
	CB_H_Color = 63;
	CB_T_Color = 48;
	CB_S_Color = 49;
	Button_Color = 27;
	Button_Key_Color = 30;
	Button_Shadow_Color = 120;
	D_T_Color = 112;
	D_S_Color = 113;
	D_B_Color = 112;
	D_H_Color = 80;
	H_T_Color = 23;
	H_T1_Color = 27;
	H_T2_Color = 28;
	H_T3_Color = 127;
	H_S_Color = 31;
	H_B_Color = 23;
	H_H_Color = 112;
	H_R_Color = 30;
	H_F_Color = 112;
	FKey_Color = 112;
	FNum_Color = 49;
	Stat1_Color = 112;
	Stat2_Color = 113;
	Message_Color = 112;
	Working_Color = 192;
	Background_Color = 23;
	Set_Global_Str('&SYNTAX_COLORS','/RWC=283/SYC=267/ECC=316/SCC=298/C1C=268/C2C=268/NCC=266');
#ENDIF
	ret;

set_mono:
#IFNDEF WINDOWS
	CB_H_Color = 112;
	CB_T_Color = 7;
	CB_S_Color = 15;
	default_back = 0;
	Call Color_Defaults;
	Set_Global_Str('&SYNTAX_COLORS','/RWC=271/SYC=271/ECC=880/SCC=265/C1C=880/C2C=880');
#ENDIF
	ret;

exit:
}
*/
/******************** Multi-Edit VOID Macro Function ************************

 NAME:         clr_tmp_globals()

 DESCRIPTION:  Clears out global variables whose prefix is one of !@.~

 PARAMETERS:   None

 RETURNS:      None

*****************************09-15-93 03:45pm*******************************/
void clr_tmp_globals()
  // clear out globals that don't begin with ~
	//
{
	int jx;
	str tstr;

	TStr =  First_Global( jx );
	while ( Tstr != '' )
	{
    if (XPOS(str_char(tstr,1),'~',1) == 0) {
			if(  jx == 1  ) {
				set_global_int(tstr,0);
			} else {
				set_global_str(tstr,'');
			}
			TStr = First_Global(jx);
		}
		else
		{
			TStr = Next_Global(jx);
		}
	}
}



/****************** Multi-Edit INTEGER Macro Function ***********************

 NAME:         sm_restart(

 DESCRIPTION:  restarts Multi-Edit

 PARAMETERS:   None.

 RETURNS:      False if failure, true if success

*****************************04-05-93 04:32pm*******************************/
int sm_restart(str parms)
{
	if ( !global_int('!@RUNSESSMGR@!') )
	{

		int count, winid;
		int T_Refresh = refresh;

		// for use in clear_temp_globals subroutine:
		int jx;
		str tstr;


		rm("EXIT /NE=1/SN=" + parse_str("NAME=",parms)); // save current system status and shut down
		if ( return_int )
			{
			// this was prompted by noticing that the same files were always
			// checked out of my VCS library, yet vcs support was configured
			// for encoded status files.  found out some global variables were
			// not being cleared.
			clr_tmp_globals(); // added 091593[scm] - clear !@. prefixed vars.

			// kill all editable windows
			refresh=false;
			for ( count=WINDOW_COUNT; count > 0; count-- )
			{
				winid = count;
				switch_window(winid);
				if ( (WINDOW_ATTR & $80) == 0 ) /* editable window? */
				{
					Redraw;
					Delete_Window;
				}
			}
			make_message('');
			refresh=T_Refresh;
			return(1);                   // success
		}
		else
		{
			refresh=T_Refresh;
			return(0);                   // failed
		}
	}
	return(1);
}


/******************** Multi-Edit VOID Macro Function ************************

 NAME:         SM_Not_Active()

 DESCRIPTION:  Inform the user that the Session Manager can not be used
							 unless the Restore feature is configured for 'Encoded Files'

 PARAMETERS:   None.

 RETURNS:      None.

*****************************04-05-93 04:34pm*******************************/
void SM_Not_Active()
{
	int  menu = menu_create ;

	return_int = menu;
	//RM('UserIn^Data_In /HN=1/H=INRE/A=1/#=11/T=Session Manager');
#ifdef WINDOWS
	menu_set_item( menu, 1, 'The Multi-Edit SESSION MANAGER','','/L=1/C=3',10,0, 0);
	menu_set_item( menu, 2, 'is not active at this time.','','/L=2/C=3',10,0, 0);
	menu_set_item( menu, 3, 'To activate the SESSION MANAGER, you must','','/L=4/C=3',10,0,0);
	menu_set_item( menu, 4, 'select "Encoded status files for each dir" ','','/L=5/C=3',10,0,0);
	menu_set_item( menu, 5, 'from the Session Status Method option','','/L=6/C=3',10,0,0);
	menu_set_item( menu, 6, 'from the Session Manager Setup dialog box','','/L=7/C=3',10,0,0);
	menu_set_item( menu, 7, '','','/L=8/C=3',10,0,0);
	RM('UserIn^Data_In /HN=1/A=1/#=7/T=Session Manager/H=' +
			SESSMGR_HELPLINK);
#else
	menu_set_item( menu, 1, 'The Multi-Edit SESSION MANAGER','','/L=3/C=3',10,0, 0);
	menu_set_item( menu, 2, 'is not active at this time.','','/L=4/C=3',10,0, 0);
	menu_set_item( menu, 3, 'To activate the SESSION MANAGER, you must','','/L=6/C=3',10,0,0);
	menu_set_item( menu, 4, 'select "Encoded status files for each dir" ','','/L=7/C=3',10,0,0);
	menu_set_item( menu, 5, 'from the Restore Previous Status option','','/L=8/C=3',10,0,0);
	menu_set_item( menu, 6, 'from the User Interface Settings dialog box','','/L=9/C=3',10,0,0);
	menu_set_item( menu, 7, '                                             ','','/L=10/C=3',10,0,0);
	menu_set_item( menu, 8, 'Main Menu --','','/L=12/C=3',10,0,0);
	menu_set_item( menu, 9, 'Other --','','/L=13/C=6',10,0,0);
	menu_set_item( menu,10, 'Install --','','/L=14/C=9',10,0,0);
	menu_set_item( menu,11, 'User Interface --','','/L=15/C=12',10,0,0);
	menu_set_item( menu,12, 'Restore Previous Status','','/L=16/C=15',10,0,0);
	RM('UserIn^Data_In /HN=1/H=INRE/A=1/#=12/T=Session Manager');
#endif

	menu_delete( menu );

}



/******************** Multi-Edit VOID Macro Function ************************

 NAME:         SessMgr()

 DESCRIPTION:  The driver routine of the Session Manager

 PARAMETERS:   /SESSION=name    Switch directly to specified session.

 RETURNS:      None.

*****************************04-05-93 04:36pm*******************************/
void SessMgr()
{
		int i;												// loop counter
		int session_names_id = 0;         // window id of session name list
		int longest_line_length; 	 		// longest length in filespec list
		int using_name;
		str buffer, s_dir = "", s_name = "";     // will contain the filespec text
		int no_switch = (parse_int("/NOSWITCH=",mparm_str) != 0); // special flag used when calling from DOS command line

		int svcurscrn = global_int('CUR_SCRN');

		// save the handle of the starting window for use if user presses escape
		int last_window_active = window_id;
		int window_to_switch_to = window_id;

		int T_Refresh = refresh;

		int session_hidden = 0;

		sm_active_win_id = window_id;
		refresh = false;

	// FORCED SETTINGS
	set_global_int('!@SESSVIEW@!',1);				// default to view names (1=true)
	set_global_int('!@SESSMODMSG@!',0);     // change existing name on exit (1=true)
	set_global_int('!@SESSRSTRMSG@!',1);    // show restore message (1=true)

		working;
		if ( !IN_ENCODED_MODE ) // must be in Encoded Files mode!!!
		{
			SM_Not_Active();
		}
		else
		{


			// ask user for session to switch to
			int user_is_picking;
			user_is_picking = 1;

			while(user_is_picking)
			{
				s_name = parse_str("/SESSION=", mparm_str);
				if (s_name == "") {
					create_window;                      // create window for session names
					session_names_id = window_id;
					file_name = 'SESSNAMES';

					// create the list and fetch the longest line length
          longest_line_length = sm_make_list(session_names_id, parse_str("/SN=", mparm_str));
					if (!no_switch) { // don't do this if they used the /SM switch
						if (global_str("!SESSION_NAME") == "") {
// assume this to be a new session named the current directory unless we find a more appropriate name
              Set_Global_Str("!SESSION_NAME", fexpand(""));
							if(LocateDBPage( "MECONFIG", "SESSMGR.CFG", FALSE ) )
							{
                down;
                str t_name = get_line;
                if (svl(t_name)) {
                  switch_win_id(session_names_id);
                  mark_pos;
                  if (find_text("NAME=" + t_name + "", 0, 0)) {
                    if (parse_str("DIR=",get_line) == global_str("!SESSION_NAME")) {
// only if the last session had the same directory do we set it
                      Set_Global_Str("!SESSION_NAME", t_name);
                    }
                  }
                  goto_mark;
                }
							}
						}
					}

          switch_win_id(session_names_id);
					session_names_number = cur_window;
	//RETURN();
					buffer = sm_dialog(       longest_line_length,
																		session_names_id,
																		session_names_number);
	/*
	messagebeep(-1);
	make_message("[" + buffer + "]");
	while (!check_key) {
	}
	*/
          ProcessMsgQueue( 10 );
					s_dir = fix_dir_spec(parse_str("DIR=",buffer));
					s_name = parse_str("NAME=",buffer);
				}
				if ((s_dir != "") || (s_name != ""))
				{
					using_name = false;
					if (svl(s_name)) { // if this is a named session
						using_name = true;
					}
					working;
					if( switch_win_id(session_names_id))
						delete_window;

					working;

						// 04-06-93[scm]: should we not switch back to the saved active window?
						// by not doing so, rm(exit) begins having some unknown window active
						// which caused the restore to return to a window other than what
						// was active at the time of saving that sessions status.

						switch_win_id(last_window_active);
						working;
						if (no_switch) {
/* this is a special case for calling the session manager from
	 the DOS command line.  in this case, we do not need or want to
	 save the current session because there is not current session.
 */
// delete any editable windows
							int count;

							for (count = WINDOW_COUNT; count > 0; count--) {
								switch_window(count);
								if ((WINDOW_ATTR & $80) == 0 ) {
									Delete_Window;
								}
							}
							goto SKIP_SWITCH;
						}

							// try to restart the system
							if ( sm_restart(buffer) )
							{
								if(!no_switch)
								{
									session_hidden = TRUE;
									ShowWindow( frame_handle, SW_Hide );
									MewLogo( 0 );
								}
SKIP_SWITCH:
								error_level = 0;
								// change to directory of new session
								if( !using_name && (s_dir != ""))
									change_dir(fix_dir_spec(s_dir));

								if (Error_Level)
//								if ((Error_Level) && (!using_name))
								{
									Beep;
#IFDEF WINDOWS
									if (using_name) {
										MessageBox(frame_handle,
											'Unable to change directory to '+s_dir,
											'Warning: Session Manager',
											mb_Ok|mb_IconExclamation);
									} else {
										MessageBox(frame_handle,
											'Unable to change directory to '+s_dir,
											'Error: Session Manager',
											mb_Ok|mb_IconExclamation);
									}
#ELSE
									make_message('unable to change directory to '+s_dir);
									read_key;
#ENDIF
									Error_Level = 0;
									if (using_name) {
										goto DO_SWITCH;
									}
								}
								else
								{
DO_SWITCH:
				// ***** Clear up the display while switching *****
									refresh = true;
									redraw;							// 090993[scm]
									new_screen;
				// ************************************************

									working;
//									rm( user_id + 'INIT' );
										ProcessMEWInit();

									working;

// is this necessary? hmmm.... ----------------------------------------------
									// kill the file history we used ????
									// make next file->open use clean history list?
									str fhnum[4] = parse_str('/#=',global_str('FILE_HISTORY'));
									set_global_str('FILE_HISTORY'+fhnum,'');

									fprompt_last_path = "";
// --------------------------------------------------------------------------

//                  sm_parms1();

#ifdef WINDOWS
// code necessary to rebuild toolboxes on session change

// NOTE:
// until the positions are saved per session, the toolboxes
// may jump around or off screen
									if(!no_switch)
									{
											Rm("SETCONFIG /DB=MECONFIG");
											rm('Load_Wcmds');
									}
#ENDIF
									if(!no_switch)
									{
											RM('.STARTUP^STARTUP');
											rm('KEYMAC_LOAD /NE=1');
									}
									ERROR_LEVEL = 0;
#IFDEF WINDOWS
									if (using_name) {
										rm("RESTORE /M=0/SS=" + str(!no_switch) + "/SN=" + s_name +
												"/SD=" + s_dir); // restore status according to name
									} else {
										rm("RESTORE /M=0/SS=" + str(!no_switch)); // restore status according to that directory
									}
#ELSE
									rm("RESTORE /M=0/CC="+str(svcurscrn)); // restore status according to that directory
#ENDIF
									if (parse_int("NEW=",buffer)) {
/* This creates a status file for the new session so that the new
 session will appear in the list the next time the session manager
 is invoked */
										RM("STATUS");
									}

									#IFDEF windows
									SendMessage(frame_handle,WM_USER+101,0,0); // WM_PARENTSIZE
									if(!restoreresult)
									{
											rm('tbmgr^build_toolboxes');  // forced build accordingly to db file
											rm('WOrganize /M=0');
									}
									#ENDIF

									window_to_switch_to = return_int;
									user_is_picking = 0;
									 if(!no_switch)
									 {
											rm("VCSCHK^VcsStartup");    // Initialize the vcs support
											// 090293[scm] - call macro named by @startup_mac_2
											// variables set by startup.mac be may overridden by
											// those contained in the status file just restored
											// (see mesys^parmload for the sequence of startup events)
											if(  (Length(Global_Str('@STARTUP_MAC_2')))  ) {
												RM(Global_Str('@STARTUP_MAC_2'));
												Error_Level = 0;
											}
									 }
									 make_message("Session \"" + s_name + "\" restored.");
								}
							}
							else
							{
									Make_Message('Session Manager: Save Files aborted. Returned to current session.');
							}

				}
				else
				{
					make_message("");
//					switch_win_id(session_list_id);
//					delete_window; // yes, we should be at session_list_id window
					switch_win_id(session_names_id);
					delete_window;
					switch_win_id(last_window_active); // back to where we started
					user_is_picking = 0;
					switch_win_id(window_to_switch_to); // 082493[scm]
				}
			} /* end while user_is_picking */
		}
		refresh = T_Refresh;

	if(session_hidden)
	{
		ShowWindow( frame_handle, SW_Show );
		SendMessage ( frame_handle, WM_PARENTSIZE, 0, 0);
		MewLogo( 1 );
	}
	session_names_number = 0;
	sm_active_win_id = 0;

}


int SessMessageProc(int &retval, int window, message, wparam, lparam, str parms )
{
	if(message == WM_COMMAND) {
		switch( wparam ) {
			case SM_name_ctrl :
			case SM_dir_ctrl :
				if (((lparam >> 16) == en_Change) &&
						(!SM_ignore_en_Change)) {
					EnableWindow(GetDlgItem(window, SM_accept_ctrl), TRUE);
					SetDefaultButton(window,SM_accept_ctrl);
				}
				break;

			case SM_list_ctrl :
				switch ( lparam >> 16 ) {
					case LBN_SELCHANGE :
						SM_SET_CTRLS(window);
						break;
				}
				break;
		}
	}
	return(DlgMessageProc(retval, window,message,wparam,lparam, parms ));

}