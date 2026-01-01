/* (C) Copyright, KurP, 1991
 *
 *  mouse.h
 *
 *  Turbo C++ compiler
 *  Microsoft mouse library
 *
 *  Version 1.01
 */

#ifndef __cplusplus
#error Turbo C++ compiler or compartible is neccessary
#endif

#ifndef _BOOL_
#  define  _BOOL_
   typedef  int     bool;
#  define   FALSE   0
#  define   TRUE    !FALSE
#endif     _BOOL_

#ifndef NULL
#  if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#    define NULL 0
#  else
#    define NULL 0L
#  endif
#endif

#define mouseINT(arg) _AX = arg; asm int 0x33;
#define l_ES_DX(arg) _ES = *((int *) &arg + 1); _DX = *((int *) &arg);
#define s_ES_DX(arg) *((int *) &arg + 1) = _ES; *((int *) &arg) = _DX;

typedef void far (*mhand)(void);

#define SOFTCURSOR 0
#define HARDCURSOR 1

#define _00TPS     0
#define _30TPS     1
#define _50TPS     2
#define _100TPS    3
#define _200TPS    4

#define LEFTPRES   1
#define RIGHTPRES  2
#define MIDDPRES   4

#define LEFTBUT    0
#define RIGHTBUT   1
#define MIDDPBUT   2

bool  far mouse_install        (int far& buttons);
void  far mouse_show_ptr       (void);
void  far mouse_hide_ptr       (void);
int   far mouse_query_ptr      (int far& hor, int far& ver);
void  far mouse_move_ptr       (int hor, int ver);
int   far mouse_query_press    (int button, int far& hor, int far& ver);
int   far mouse_query_release  (int button, int far& hor, int far& ver);
void  far mouse_hor_range      (int hmin, int hmax);
void  far mouse_ver_range      (int vmin, int vmax);
void  far mouse_graph_shape    (int hhot, int vhot, void far * cursor);
void  far mouse_text_shape     (int ctype, int par1, int par2);
void  far mouse_query_motion   (int far& hor, int far& ver);
void  far mouse_event_hand     (int mask, mhand hand);
void  far mouse_lightpen       (void);
void  far mouse_no_lightpen    (void);
void  far mouse_ptr_speed      (int hspeed, int vspeed);
void  far mouse_exclusion      (int left, int top, int right, int bottom);
void  far mouse_max_speed      (int mspeed);
mhand far mouse_new_event_hand (int far& mask, mhand hand);
int   far mouse_status_size    (void);
void  far mouse_save_status    (void far * buff);
void  far mouse_rest_status 	 (void far * buff);
bool  far mouse_set_key_hand   (int mask, mhand hand);
mhand far mouse_get_key_hand   (int mask);
void  far mouse_set_sens       (int horsp, int versp, int doubsplim);
void  far mouse_query_sens     (int far& horsp, int far& versp, int far& doubsplim);
void  far mouse_int_rate       (int rate);
void  far mouse_set_page       (int npage);
int   far mouse_query_page     (void);
bool  far mouse_disable        (void);
void  far mouse_enable         (void);
bool  far mouse_reset          (int far& buttons);
