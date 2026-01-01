
//*********************************************************************
//*                     MULTI-EDIT MACRO                              *
//*                                                                   *
//*                                       Contributed by Bill Feero   *
//* Name: UV_MENU                                                     *
//*                                                                   *
//* Description: Select from UltraVisi on modes                        *
//*                                                                   *
//*                                                                   *
//*********************************************************************

macr o UV_MENU TRANS {

 int menu = menu_create;
 int r1, r2;
 str Tstr;


 REFRESH = False;

 menu_set_item( menu, 1, "Screen Size:" , "", "/QK=1/C=1/L=2", 10, 0, 0);
  menu_set_item( menu, 2,  "80x25 ",  "",  "/C=1/L=3/G=@RADIO@/R=17", 12, 0, 0);
  menu_set_ item( menu, 3,  "80x36 ",  "",  "/C=1/L=4/G=@RADIO@/R=19", 12, 0, 0);
  menu_set_item( menu, 4,  "80x50 ",  "",  "/C=1/L=5/G=@RADIO@/R=18", 12, 0, 0);
  menu_set_item( menu, 5,  "80x63 ",  "",  "/C=1/L=6/G=@RADIO@/R=20", 12, 0, 0);
  menu_set_item( menu,  6,  "94x25 ",  "", "/C=13/L=3/G=@RADIO@/R=25", 12, 0, 0);
  menu_set_item( menu, 7,  "94x36 ",  "", "/C=13/L=4/G=@RADIO@/R=27", 12, 0, 0);
  menu_set_item( menu, 8,  "94x50 ",  "", "/C=13/L=5/G=@RADIO@/R=26", 12, 0, 0);
  menu_set_item( menu, 9,  "94x63 " ,  "", "/C=13/L=6/G=@RADIO@/R=28", 12, 0, 0);
  menu_set_item( menu, 10, "108x25 ", "", "/C=25/L=3/G=@RADIO@/R=33", 12, 0, 0);
  menu_set_item( menu, 11, "108x36 ", "", "/C=25/L=4/G=@RADIO@/R=35", 12, 0, 0);
  menu_set_item( menu, 12, "108x50 ", "", "/C=2 5/L=5/G=@RADIO@/R=34", 12, 0, 0);
  menu_set_item( menu, 13, "108x63 ", "", "/C=25/L=6/G=@RADIO@/R=36", 12, 0, 0);
  menu_set_item( menu, 14, "120x25 ", "", "/C=38/L=3/G=@RADIO@/R=49", 12, 0, 0);
  menu_set_item( menu, 15, "120x36 ", "", "/C=38/L=4/G=@RAD IO@/R=57", 12, 0, 0);
  menu_set_item( menu, 16, "120x50 ", "", "/C=38/L=5/G=@RADIO@/R=50", 12, 0, 0);
  menu_set_item( menu, 17, "120x63 ", "", "/C=38/L=6/G=@RADIO@/R=58", 12, 0, 0);
  menu_set_item( menu, 18, "132x25 ", "", "/C=51/L=3/G=@RADIO@/R=51", 1 2, 0, 0);
  menu_set_item( menu, 19, "132x36 ", "", "/C=51/L=4/G=@RADIO@/R=59", 12, 0, 0);
  menu_set_item( menu, 20, "132x50 ", "", "/C=51/L=5/G=@RADIO@/R=52", 12, 0, 0);
  menu_set_item( menu, 21, "132x63 ", "", "/C=51/L=6/G=@RADIO@/R=60", 12, 0, 0);

  menu_set_int( menu,  2, 2, ext_video_mode == 0x11 );
 menu_set_int( menu,  3, 2, ext_video_mode == 0x13 );
 menu_set_int( menu,  4, 2, ext_video_mode == 0x12 );
 menu_set_int( menu,  5, 2, ext_video_mode == 0x14 );
 menu_set_int( menu,  6, 2, ext_video_mo de == 0x19 );
 menu_set_int( menu,  7, 2, ext_video_mode == 0x1b );
 menu_set_int( menu,  8, 2, ext_video_mode == 0x1a );
 menu_set_int( menu,  9, 2, ext_video_mode == 0x1c );
 menu_set_int( menu, 10, 2, ext_video_mode == 0x21 );
 menu_set_int( menu, 11,  2, ext_video_mode == 0x23 );
 menu_set_int( menu, 12, 2, ext_video_mode == 0x22 );
 menu_set_int( menu, 13, 2, ext_video_mode == 0x24 );
 menu_set_int( menu, 14, 2, ext_video_mode == 0x31 );
 menu_set_int( menu, 15, 2, ext_video_mode == 0x39 );
 menu_set_ int( menu, 16, 2, ext_video_mode == 0x32 );
 menu_set_int( menu, 17, 2, ext_video_mode == 0x3a );
 menu_set_int( menu, 18, 2, ext_video_mode == 0x33 );
 menu_set_int( menu, 19, 2, ext_video_mode == 0x3b );
 menu_set_int( menu, 20, 2, ext_video_mode == 0x3 4 );
 menu_set_int( menu, 21, 2, ext_video_mode == 0x3c );


 menu_set_item( menu, 22, "Font Selection:" , "", "/QK=1/C=1/L=8", 10, 0, 0);
  menu_set_item( menu, 23, "No Change",  "", "/C=20/L=8/G=@RADIO2@/R=0",   12, 0, 0);
  menu_set_item( menu, 24, "BR OADWAY ",  "", "/C=2/L=9/G=@RADIO2@/R=1",    12, 0, 0);
  menu_set_item( menu, 25, "COURIER  ",  "", "/C=2/L=10/G=@RADIO2@/R=2",   12, 0, 0);
  menu_set_item( menu, 26, "DATA     ",  "", "/C=2/L=11/G=@RADIO2@/R=3",   12, 0, 0);
  menu_set_item( menu, 27,  "NEWFONT1 ",  "", "/C=2/L=12/G=@RADIO2@/R=4",   12, 0, 0);
  menu_set_item( menu, 28, "NEWFONT2 ",  "", "/C=2/L=13/G=@RADIO2@/R=5",   12, 0, 0);
  menu_set_item( menu, 29, "NEWFONT3 ",  "", "/C=17/L=9/G=@RADIO2@/R=6",   12, 0, 0);
  menu_set_item( menu, 3 0, "OLDENGL  ",  "", "/C=17/L=10/G=@RADIO2@/R=7",  12, 0, 0);
  menu_set_item( menu, 31, "PC       ",  "", "/C=17/L=11/G=@RADIO2@/R=8",  12, 0, 0);
  menu_set_item( menu, 32, "PC-SC    ",  "", "/C=17/L=12/G=@RADIO2@/R=9",  12, 0, 0);
  menu_set_item( menu , 33, "ROMAN1   ",  "", "/C=17/L=13/G=@RADIO2@/R=10", 12, 0, 0);
  menu_set_item( menu, 34, "ROMAN2   ",  "", "/C=32/L=9/G=@RADIO2@/R=11",  12, 0, 0);
  menu_set_item( menu, 35, "SANS1    ",  "", "/C=32/L=10/G=@RADIO2@/R=12", 12, 0, 0);
  menu_set_item( m enu, 36, "SANS1-SC ",  "", "/C=32/L=11/G=@RADIO2@/R=13", 12, 0, 0);
  menu_set_item( menu, 37, "SANS2    ",  "", "/C=32/L=12/G=@RADIO2@/R=14", 12, 0, 0);
  menu_set_item( menu, 38, "SANS2-SC ",  "", "/C=32/L=13/G=@RADIO2@/R=15", 12, 0, 0);
  menu_set_item ( menu, 39, "SANS3    ",  "", "/C=47/L=9/G=@RADIO2@/R=16",  12, 0, 0);
  menu_set_item( menu, 40, "SANS3-SC ",  "", "/C=47/L=10/G=@RADIO2@/R=17", 12, 0, 0);
  menu_set_item( menu, 41, "SCRIPT1  ",  "", "/C=47/L=11/G=@RADIO2@/R=18", 12, 0, 0);
  menu_set_i tem( menu, 42, "SCRIPT2  ",  "", "/C=47/L=12/G=@RADIO2@/R=19", 12, 0, 0);
  menu_set_item( menu, 43, "WINDOWS  ",  "", "/C=47/L=13/G=@RADIO2@/R=20", 12, 0, 0);

 menu_set_int( menu, 23+Global_Int( '@UVFONT@' ), 2, 1 );


 Return_Int = menu;
 rm('USERIN^Da ta_In /HN=1/#=43/S=1/X=5/Y=5/T=UltraVision');

 if (Return_Int == 1) {

  r1 = Global_Int( '@RADIO@' );
  r2 = Global_Int( '@RADIO2@' );

  if( (r1 != 0) && (ext_video_mode != r1) ) {
   ext_video_mode = r1;

   ext_video_status = 1;
   set_video_mode( 3  );  //3 is for UltraVision

   Run_Macro('SETSCRN');
      if ( mouse == 1 ) {
        mouse = 0;
        mouse = 1;
      }
  }

  if( (r2 > 0) && (r2 != Global_Int( '@UVFONT@' )) ) {
   Tstr = menu_item_str( menu, 23+r2, 1 );
   Return_Str = "c:\\uv\\uv  " + Tstr;
   rm( 'EXEC /SWAP=0/SCREEN=0/RED=NUL/REDERR=STDOUT' );
   Set_Global_Int( '@UVFONT@', r2 );
  }
 }

EXIT:

 menu_delete(menu);
 REFRESH = TRUE;
 NEW_SCREEN;

}

■ Sergey Sotnikov

--- Golded 2.40.P0720+
 * Origin:  ░░▒▒▓▓██ Ozz Land Solar syst$3/18
00 Msk (2:5020/35)
SEEN-BY: 450/10 461/10 462/200 463/6 14 18 30 34 57 73 464/100 469/32 5000/6
SEEN-BY: 5010/2 5015/1 5020/1 6 23 28 35 36 42 48 49 52 71 88 93 96 99 102
SEEN-BY: 5020/106 109 119 128 5030/2 5040/6 5060/1 5090/10
PATH: 5020/35 23 46 MSGID: 2:5020/26 2b50e26c
PID: GED B1207 7819
