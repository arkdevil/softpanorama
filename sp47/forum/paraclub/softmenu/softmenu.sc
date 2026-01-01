
CREATELIB "SOFTMENU"

;SOFT_MENU

; This routine puts a pull down on the screen at a specified canvas location
; It waits for a user response, and returns the users selection off the menu.
;
; It is called as follows:
;
;    SOFT_MENU(parm1, parm2, parms3 thru 17,parms18 thru 32, parm33,
;                  parm34, parm35, parm36, parm 37)
;
; where   parm1 =              level of the menu (1, 2, 3, etc.)
;                                 The top-most menu should be level 1, and each
;                                 menu displayed aftert that should have a
;                                 level representing its position relative 
;                                 to the top-most menu 
;
;         parm2 =              beginning row for the menu
;         parm3 =              beginning col for then menu
;         parm4 thru 18 =      menu choices, each in it's own text string.
;                              null strings "" are used for non-existant choices
;         parm19 thru parm33 = menu choice descriptions, each corrisponding to
;                              to a menu choice.  null string "" are used for
;                              non-existant choices.
;         parm34 =             box_color
;         parm35 =             text_color
;         parm36 =             cursor_color
;         parm37 =             Description color
;         parm38 =             Menu Description Location
;
; An example is as follows:
;
; menu_choice_a = SOFT_MENU(1, 4, 12,
;          "Add a record",
;          "Change a record",
;          "Delete a record",
;          "Return",
;          "","","","","","","","","","","",
;          "Add records to the Master Table and the Transaction Table",
;          "Change all the Non Keyed Fields In Both the Master and Trans Tables",
;          "Delete Records in the Trans Table(Not the Master Table)",
;          "Return To Interactive Paradox",
;          "","","","","","","","","","","",
;          box_color,text_color,cursor_color,desc_color,desc_loc)

PROC soft_menu(level, beg_row, beg_col, c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,
   d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,
   box_color,text_color,cursor_color,desc_color,desc_loc)

   PRIVATE  num_choices, a, x, n, max_length, key_pressed, curr_choice,
   descr, choices_list, start_choice, end_row, end_col

   CURSOR OFF

   max_length = 0 ; start width of longest menu choice at 0

   ARRAY choices_list[15] ; define maximum of 15 array elements
   ARRAY descr[15] ; define maximum of 15 array elements

   IF level = 1 THEN
      ARRAY menu_lastchoice[15] ; 15 possible menu levels
      menu_lastchoice[1] = 1
      ARRAY menu_box[4*15]
      ARRAY menu_options[15*15]
      ARRAY menu_color[3*15]
   ENDIF
   FOR x FROM level+1 TO 15
      menu_lastchoice[x] = 1
   ENDFOR

   num_choices = 0 ; start number of choices variable at 0
   SWITCH
      CASE IsBlank(c2) : num_choices = 1
      CASE IsBlank(c3) : num_choices = 2
      CASE IsBlank(c4) : num_choices = 3
      CASE IsBlank(c5) : num_choices = 4
      CASE IsBlank(c6) : num_choices = 5
      CASE IsBlank(c7) : num_choices = 6
      CASE IsBlank(c8) : num_choices = 7
      CASE IsBlank(c9) : num_choices = 8
      CASE IsBlank(c10): num_choices = 9
      CASE IsBlank(c11): num_choices = 10
      CASE IsBlank(c12): num_choices = 11
      CASE IsBlank(c13): num_choices = 12
      CASE IsBlank(c14): num_choices = 13
      CASE IsBlank(c15): num_choices = 14
      OTHERWISE        : num_choices = 15
   ENDSWITCH

   choices_list[1] = c1
   choices_list[2] = c2
   choices_list[3] = c3
   choices_list[4] = c4
   choices_list[5] = c5
   choices_list[6] = c6
   choices_list[7] = c7
   choices_list[8] = c8
   choices_list[9] = c9
   choices_list[10]= c10
   choices_list[11]= c11
   choices_list[12]= c12
   choices_list[13]= c13
   choices_list[14]= c14
   choices_list[15]= c15

   descr[1]= d1
   descr[2]= d2
   descr[3]= d3
   descr[4]= d4
   descr[5]= d5
   descr[6]= d6
   descr[7]= d7
   descr[8]= d8
   descr[9]= d9
   descr[10]=d10
   descr[11]=d11
   descr[12]=d12
   descr[13]=d13
   descr[14]=d14
   descr[15]=d15

   IF num_choices=0 THEN;there were no strings passed to the routine
      CURSOR NORMAL
      RETURN ""
   ENDIF

   FOR x FROM 1 TO num_choices              ;loop once for each choice
      IF LEN(choices_list[x]) > max_length THEN;is this choice the biggest so far
         max_length = LEN(choices_list[x])       ;assign its length to the counter
      ENDIF
   ENDFOR

   end_row=num_choices+beg_row+1
   end_col=max_length+3+beg_col
   menu_box[((level-1)*4)+1]   = beg_row
   menu_box[((level-1)*4)+2]   = beg_col
   menu_box[((level-1)*4)+3]   = end_row
   menu_box[((level-1)*4)+4]   = end_col
   menu_color[((level-1)*3)+1] = box_color
   menu_color[((level-1)*3)+2] = text_color
   menu_color[((level-1)*3)+3] = cursor_color
   FOR n FROM 1 TO num_choices
      menu_options[((level-1)*15)+n] = choices_list[n]
   ENDFOR
   paint_menu_box(level)
   curr_choice=1
   curr_choice = menu_lastchoice[level]

   RETVAL = softmenu_select()

   RETURN RETVAL

ENDPROC
WRITELIB "SOFTMENU" soft_menu
RELEASE PROCS ALL

PROC softmenu_select()

   WHILE true
      CANVAS OFF
      @ desc_loc,1 ?? SPACES(78)
      PaintCanvas ATTRIBUTE desc_color desc_loc,1,desc_loc,78

; Center the Menu Choice Description

      @desc_loc,INT(40-LEN(descr[Curr_Choice])/2)
      ?? descr[curr_choice]
      PaintCanvas ATTRIBUTE desc_color desc_loc,1,desc_loc,78
      CANVAS ON
      @curr_choice+beg_row,beg_col+2
      STYLE ATTRIBUTE cursor_color ;Highlight current selection
      ?? choices_list[curr_choice] ; write the choice
      key_pressed=GETCHAR()
      @curr_choice+beg_row,beg_col+2
      STYLE ATTRIBUTE text_color

      ?? choices_list[curr_choice] ; write the choice
      SWITCH
         CASE (key_pressed>=65 AND key_pressed<=90) OR
            (key_pressed>=97 AND key_pressed<=122) :
            start_choice = curr_choice
            FOR x FROM start_choice-1 TO 1 STEP -1
               IF UPPER(SUBSTR(choices_list[x],1,1)) = UPPER(CHR(key_pressed)) THEN
                  curr_choice = x
               ENDIF
            ENDFOR
            FOR x FROM num_choices TO start_choice+1 STEP -1
               IF UPPER(SUBSTR(choices_list[x],1,1)) = UPPER(CHR(key_pressed)) THEN
                  curr_choice = x
               ENDIF
            ENDFOR
         CASE key_pressed=-71:                  ;Key was [Home]
            curr_choice=1                        ;Select first item
         CASE key_pressed=-79:                  ;Key was [End]
            curr_choice=num_choices              ;Select last item
         CASE key_pressed=-72:                  ;Key was [Up]
            IF curr_choice<>1 THEN;are we somewhere other than the top?
               curr_choice=curr_choice-1          ;Select new curr_choice
            ELSE
               curr_choice=num_choices            ;go to the last choice
            ENDIF
         CASE key_pressed=-80:                  ;Key was [Down]
            IF curr_choice<>num_choices THEN;Are we somewhere except the bottom?
               curr_choice=curr_choice+1          ;Select new curr_choice
            ELSE
               curr_choice=1                      ;goto the top
            ENDIF
         CASE key_pressed=13:                   ;Key was [Enter]
            @curr_choice+beg_row,beg_col+2
            STYLE ATTRIBUTE cursor_color
            ?? choices_list[curr_choice]          ;write the choice
            menu_lastchoice[level] = curr_choice
            STYLE
            @0,0
            CURSOR NORMAL
            RETURN choices_list[curr_choice]      ;Return selection
         CASE key_pressed=27:                   ;Key was [Esc]
            @0,0
            CURSOR NORMAL
            STYLE
            RETURN "Esc"
         OTHERWISE:                             ;Illegal key
            BEEP
      ENDSWITCH
   ENDWHILE

ENDPROC
WRITELIB "SOFTMENU" softmenu_select
RELEASE PROCS ALL

;===================

PROC paint_menu_box(level)
   PRIVATE n,x

   CANVAS OFF
   CLEAR
   FOR n FROM 0 TO 24
      @ n,0 ?? FILL(CHR(177),80)
   ENDFOR

   FOR n FROM 1 TO level

      beg_row     =   menu_box[((n-1)*4)+1]
      beg_col     =   menu_box[((n-1)*4)+2]
      end_row     =   menu_box[((n-1)*4)+3]
      end_col     =   menu_box[((n-1)*4)+4]
      box_color    = menu_color[((n-1)*3)+1]
      text_color   = menu_color[((n-1)*3)+2]
      cursor_color = menu_color[((n-1)*3)+3]
      @ beg_row,beg_col
      STYLE ATTRIBUTE box_color
      ?? "┌",FILL("─",(end_col-beg_col)-1),"┐"
      STYLE

      STYLE ATTRIBUTE text_color
      FOR x FROM 1 TO end_row-beg_row-1 ;2
         @beg_row+x,beg_col;-1
         STYLE ATTRIBUTE box_color
         ?? "│"
         STYLE ATTRIBUTE text_color
         ?? " "+menu_options[((n-1)*15)+x]
         ?? FILL (" ",(end_col)-COL())
         @beg_row+x,end_col;-1
         STYLE ATTRIBUTE box_color
         ?? "│"
      ENDFOR
      @beg_row+x,beg_col
      ?? "└",FILL("─",(end_col-beg_col)-1),"┘"
      STYLE

      curr_choice = menu_lastchoice[n]
      @curr_choice+beg_row,beg_col+2
      STYLE ATTRIBUTE cursor_color
      ?? menu_options[((n-1)*15)+curr_choice]
      STYLE

   ENDFOR

   CANVAS ON

ENDPROC
WRITELIB "SOFTMENU" paint_menu_box
RELEASE PROCS ALL

PROC release_menu_vars()

; This proc should be called after the 1st level menu has been exited.
; It simply releases the arrays that allow the menus to cascade and
; reappear.

   RELEASE VARS menu_options, menu_color, menu_box, menu_lastchoice

ENDPROC
WRITELIB "SOFTMENU" release_menu_vars
RELEASE PROCS ALL


INFOLIB "SOFTMENU"
