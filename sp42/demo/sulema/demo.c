#include	"video.h"
#include	"color.h"
#include	"key.h"

struct  one  lms1[]={   /*          */

    "New",              /*          */
    'N',                /*          */
    0u,                 /*          */
    4u,                 /*          */
    0,                  /*          */
    " Creat  new  item",/*          */

	     "Load  F3",'L',0u,8u,0," Load  library  in  memory",
	     "Change  dir",'C',0u,12u,0," Change  current  directory",
	     "Directory",'D',0u,10u,0," View  directory"

		    };

struct  one  lms2[]={

	     "Number",'N',0u,6u,0," Search  on  number",
	     "Author",'A',0u,6u,0," Search  on  autnor",
	     "Title",'T',0u,5u,0," Search  on  title",
	     "Copyright",'C',0u,9u,0," Search  on  number",
	     "Position",'P',0u,8u,0," Search  on  position",
	     "Keyword",'K',0u,7u,0," Search  on  keyword"

		     };

struct  one  lms3[]={

	     "New search",'N',0u,11u,0," Delete  current  search",
	     "Continue search",'C',0u,16u,0," Continue  current  search",
	     "Sort      (on)",'S',0u,15u,0," Functions  of  sort"

		     };

struct  one  lms4[]={

	     "Write to  F2",'W',0u,12u,0," Write  library  on  disk",
	     "Rename",'R',0u,7u,0," Rename  library",
	     "Delete",'D',0u,7u,0," Delete  library",
	     "Creat  dir",'C',0u,11u,0," Creat  new  directory",
	     "dElete  dir",'E',1u,12u,0," Delete  directory",
	     "Print",'P',0u,6u,0,"Print  library"

		     };

struct  menu_color  color={                  /*          */

			 B_CYAN|C_BLACK,     /*        */
			 B_BLACK|LIGHTWHITE, /*        */
			 B_BLACK|LIGHTWHITE, /*        */
			 B_CYAN|LIGHTWHITE,  /*        */
			 B_BLACK|C_YELLOW,   /*        */
			 B_WHITE|C_BLACK     /*        */

			   };

struct  keys  help={  /*          */
   F1, /*          */
   0   /*          */
		   };

struct  keys  user[]={ /*          */
   F2, /*          */
   0,  /*          */
   F3, /*          */
   0   /*          */
		     };

struct  keybar  bar={  /*          */
   24, /*          */
   0,  /*          */
" F2-Load  F3-Write to  F9-Menu  F10-Quit  , keys  not  press...           ",
" SHIFT:  A-abort  B-begin  C-choose  I-insert  F-fatal portrate  V-view   ",
" CTRL:  F4-Zoom  F5-Switch  F6-Pick  S-Control  R-rebild                  ",
" ALT:  L-library  S-Search  O-Options  R-Report  H-Shell  Q-Quit          "
		    };

struct  v_menu  gbr1={ /*          */

   lms1,    /*          */
   6u,      /*          */
   0u,      /*          */
   0u,      /*          */
   2u,      /*          */
   9u,      /*          */
   0u,      /*          */
   15u,     /*          */
   1u,      /*          */
   &color,  /*          */
   1u,      /*          */
   0u,      /*          */
   0u,      /*          */
   79u,     /*          */
   &help,   /*          */
   2u,      /*          */
   user,    /*          */
   &bar     /*          */

		     };

struct  v_menu  gbr2={

   lms2,4u,0u,0u,2u,7u,14u,26u,1u,&color,1u,0u,0u,79u,&help,2u,user,&bar

		     };

struct  v_menu  gbr3={

   lms3,3u,0u,0u,2u,6u,25u,44u,1u,&color,1u,0u,0u,79u,&help,2u,user,&bar

		     };

struct  v_menu  gbr4={

   lms4,6u,0u,0u,2u,9u,41u,56u,1u,&color,1u,0u,0u,79u,&help,2u,user,&bar

		      };


struct h_menu  utr[]={

   "Library",   /*          */
   'L',         /*          */
   1u,          /*          */
   v_menu,      /*          */
   7u,          /*          */
   3u,          /*          */
   0u,          /*          */
   ALT_L,       /*          */
   " Work  with  libraries  functions", /*          */
   &gbr1,       /*          */

		"Search",'S',1u,v_menu,6u,17u,0u,ALT_S,
		" Functions  of  search  in  library",&gbr2,
		"Options",'O',1u,v_menu,7u,31u,0u,ALT_O,
		" Choose  options",&gbr3,
		"Report",'R',1u,v_menu,6u,46u,0u,ALT_R,
		" Report  about  library",&gbr4,
		"sHell",'H',0u,0,5u,59u,1u,ALT_H,
		" Exit  in  DOS",0,
		"Quit",'Q',0u,0,4u,71u,0u,ALT_Q,
		" Quit  from  menu",0
	   };

struct  m_menu  force={  /*          */

  0u,        /*          */
  6u,        /*          */
  &color,    /*          */
  utr,       /*          */
  1u,        /*          */
  0u,        /*          */
  79u,       /*          */
  F9,        /*          */
  1u,        /*          */
  0,         /*          */
  0u,        /*          */
  F10,       /*          */
  &help,     /*          */
  1u,        /*          */
  0u,        /*          */
  0u,        /*          */
  79u,       /*          */
  2u,        /*          */
  user,      /*          */
  &bar       /*          */

		      };

void	main( void )
{
	char	*rew, /*          */
		*yet; /*          */

	init_video(); /*          */
	yet=store(    /*          */
	2,            /*          */
	24,           /*          */
	0,            /*          */
	79
	);
	open_window(   /*          */
	2,             /*          */
	23,            /*          */
	0,             /*          */
	79,            /*          */
	B_BLUE|        /*          */
	C_YELLOW       /*          */
	);
	draw_box(      /*          */
	2,             /*          */
	23,            /*          */
	0,             /*          */
	79,            /*          */
	4);
	open_window(24,24,0,79,color.helpstr_color);
	put_str(       /*          */
	24,            /*          */
	0,             /*          */
	bar.unshifted  /*          */
	       );
	put_str(2,37," Edit ");
	set_h_menu(&force);      /*          */
	while ( 1 )
	{
	   if ( m_menu(&force) )  /*          */
	    continue;
	   else
	   {
	       reset_h_menu(&force);  /*          */
	       reclose(     /*          */
	       2,           /*          */
	       24,          /*          */
	       0,           /*          */
	       79,          /*          */
	       yet          /*          */
		       );
	       exit(0);
	   }
	}
}
