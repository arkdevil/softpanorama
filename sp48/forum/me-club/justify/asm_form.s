Macro ASM_FORMAT {
/*

  Name: ASM_FORMAT

  Description:  Reformats 8086 assembly language source code.
  Modifications: L.G.Bunich -- Aug 1992

    (C) Copyright 1991 by American Cybernetics, Inc.
*/

  str tstr[10], cw[12];
  str t = "EQU,DB,DW,DD,LABEL,=,RECORD,STRUC,ENDS,SEGMENT,ENDS,PROC,ENDP,GROUP,";
  int  im, space_found ;

  Push_Undo; Refresh = False;
  im = Insert_Mode; Insert_Mode = True;
  working;  mark_pos;

  if (block_stat != 1) goto exit;
  goto_line(block_line1);

  while (c_line <= block_line2) {
    Put_Line_Num(C_Line);
    first_word;
                    /* If first character is a ; then ignore line */
    if (cur_char == ';') goto do_loop;

                    /* Delete all leading characters */
    while (c_col > 1) back_space;

                    /* Position after first word */
    while (not(at_eol) & (xpos(cur_char,' |9:',1) == 0)) right;

    if (cur_char == ':') {      /* If this is a label then go on */
      Right;
      if (cur_char == '|255') goto do_loop;
      CR; continue;
    }

do_indent:
    Mark_Pos;  Word_Right;
    cw = CAPS(Get_Word(' |9')) + ',';  GoTo_Mark;
    goto_col(1);
    if (Xpos(cw,t,1) == 0) tab_right;
    space_found = false;

find_comment:
    tstr = Get_Word('''"; |9');
    if(  (cur_char == '''')  ) {
      right;
      tstr = get_word('''');
      right;
      goto find_comment;
    }
    if(  (cur_char == '"')  ) {
      right;
      tstr = get_word('"');
      right;
      goto find_comment;
    }
    while(  xpos(cur_char,'|9 ',1) != 0  ) {
      del_char;
    }
    if(  not(at_eol)  ) {
      if(  cur_char == ';'  ) {
        while(  c_col < 41  ) {
          tab_right;
        }
        goto do_loop;
      } else {
        if(  space_found == false  ) {
          tab_right;
          space_found = true;
        } else {
          text(' ');
        }
        goto find_comment;
      }
    }

do_loop:
    down;
  }
exit:
  goto_mark;
  Insert_Mode = im;
  Refresh = True; Pop_Undo;
}
