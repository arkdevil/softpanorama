/*      video.h

        Definitions for user's interfase functions.

        Copyright (C) 1991, E.S.E. Extraware, Inc.
        All Rights Reserved.

        Use with files videox.lib,
        where 'x' means first letter of the memory model.
*/

#if __STDC__
#define _Cdecl
#else
#define _Cdecl  cdecl
#endif

#ifndef NULL
#if defined( __TINY__ ) || defined( __SMALL__ ) || defined( __MEDIUM__ )
#define NULL            0
#else
#define NULL            0l
#endif
#endif

#define SIZE            0
#define POSITION        1
#define HOR             0
#define VERT            1
#define WN_UP           6
#define WN_DOWN         7
#define WN_RIGHT        0x4b
#define WN_LEFT         0x4d
#define SINGLE          1
#define DOUBLE          2
#define SINGLE_DOUBLE   3
#define DOUBLE_SINGLE   4

struct keybar {
               unsigned         line;
               unsigned         column;
               unsigned char  * unshifted;
               unsigned char  * shift;
               unsigned char  * control;
               unsigned char  * alternate;
              };

struct  menu_color {
                    unsigned char       normal_color;
                    unsigned char       sheddow_color;
                    unsigned char       highlighted_color;
                    unsigned char       normal_hotkey;
                    unsigned char       highlighted_hotkey;
                    unsigned char       helpstr_color;
                   };

struct  item {
              unsigned         pu_line;
              unsigned         pu_column;
              unsigned         pu_length;
              unsigned         pu_position;
              unsigned char  * pu_option;
              int          ( * pu_function )( void );
              int              pu_keyup;
              int              pu_keydown;
              int              pu_keyleft;
              int              pu_keyright;
             };

struct  keys {
              unsigned char     key;
              int           ( * f )( void );
             };

struct  pu_menu {
                 unsigned        pu_whole;
                 unsigned        pu_last;
                 unsigned        pu_upline;
                 unsigned        pu_dnline;
                 unsigned        pu_lfcol;
                 unsigned        pu_rtcol;
                 struct  item  * pu_item;
                 unsigned        pu_nkeys;
                 struct keys  *  pu_keys;
                 struct keybar * pu_keybar;
                };

struct s_bar {
              unsigned      mode;
              unsigned      fpos;
              unsigned      lpos;
              unsigned      bar;
              unsigned      numb;
             };

struct sbar_color {
                   unsigned char   top_simbol;
                   unsigned char   bottom_simbol;
                   unsigned char   ptr_simbol;
                   unsigned char   gnd_simbol;
                   unsigned char   ptr_color;
                   unsigned char   gnd_color;
                  };

struct one {
            char       * name;
            char         lat;
            unsigned     l_n;
            unsigned     len;
            int      ( * fnc )( void );
            char       * help;
           };

struct v_menu {
               struct one        * v_one;
               unsigned            v_q_s;
               unsigned            v_last;
               unsigned            v_run;
               unsigned            v_up;
               unsigned            v_down;
               unsigned            v_left;
               unsigned            v_right;
               unsigned            v_t_bdr;
               struct menu_color * v_cl;
               unsigned            v_h;
               unsigned            v_l_h;
               unsigned            v_lc_h;
               unsigned            v_rc_h;
               struct keys       * v_hlp;
               unsigned            v_q_u;
               struct keys       * v_u;
               struct keybar     * v_bar;
              };

struct h_menu {
               char          * h_name;
               char            h_lat;
               unsigned        h_u_f;
               int         ( * h_f )();
               unsigned        h_lth;
               unsigned        h_pls;
               unsigned        h_n_l;
               unsigned char   h_key;
               char          * h_s;
               struct v_menu * h_v_m;
              };

struct m_menu {
               unsigned            m_nl;
               unsigned            m_n_al;
               struct menu_color * m_cl;
               struct h_menu     * m_h_m;
               unsigned            m_n_l;
               unsigned            m_lc;
               unsigned            m_rc;
               unsigned char       m_inp_k;
               unsigned            m_nst;
               unsigned char     * m_st;
               unsigned            m_run;
               unsigned char       m_out_k;
               struct keys       * m_h;
               unsigned            m_hl;
               unsigned            m_l_h;
               unsigned            m_lc_h;
               unsigned            m_rc_h;
               unsigned            m_q_u;
               struct keys       * m_u;
               struct keybar     * m_bar;
              };

#ifndef  __STDC__

/* Video */

struct vpg { struct { char s,m; } c[25][80]; };

extern struct vpg far *_Cdecl screen;

#define simbol(ln,cl)    (screen->c[ln][cl].s)
#define attribute(ln,cl) (screen->c[ln][cl].m)

#endif

void             _Cdecl crestore    ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned char * );
unsigned char *  _Cdecl cstore      ( unsigned , unsigned , unsigned ,
                                      unsigned );
void             _Cdecl cursor_size ( unsigned , unsigned );
void             _Cdecl draw_box    ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned );
void             _Cdecl draw_win    ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned char );
unsigned char    _Cdecl get_char    ( struct keybar * kb );
void             _Cdecl get_cursor  ( unsigned , unsigned  * , unsigned  * );
int              _Cdecl get_str     ( int , int , char * ,
                                      int , struct keybar * , int ,
                                      struct keys  * );
unsigned char    _Cdecl h_menu      ( struct m_menu * );
void             _Cdecl init_video  ( void );
int              _Cdecl m_menu      ( struct m_menu * );
void             _Cdecl open_window ( int , int , int ,
                                      int , unsigned char );
int              _Cdecl pop_up      ( struct pu_menu * ,
                                      struct menu_color * );
void             _Cdecl put_str     ( unsigned , unsigned , unsigned char * );
void             _Cdecl reclose     ( int , int , int ,
                                      int , unsigned char * );
void             _Cdecl restore     ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned char * );
void             _Cdecl reset_h_menu( struct m_menu * );
void             _Cdecl scroll      ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned , unsigned ,
                                      unsigned char );
void             _Cdecl set_h_menu  ( struct m_menu * );
void             _Cdecl set_bar     ( struct s_bar * , struct sbar_color * );
void             _Cdecl set_cursor  ( unsigned , unsigned );
void             _Cdecl set_window  ( unsigned , unsigned , unsigned ,
                                      unsigned , unsigned char ,
                                      unsigned char , unsigned );
int              _Cdecl small_menu  ( struct pu_menu * ,
                                      struct menu_color * );
void             _Cdecl spase_bar   ( struct s_bar * , struct sbar_color * ,
                                      unsigned );
unsigned char  * _Cdecl store       ( unsigned , unsigned , unsigned ,
                                      unsigned );
int              _Cdecl v_menu      ( struct v_menu * );
int              _Cdecl win_get     ( unsigned , unsigned , unsigned ,
                                      unsigned char * , unsigned char * ,
                                      unsigned , unsigned char ,
                                      unsigned char , struct keybar * ,
                                      unsigned , struct keys * );
void             _Cdecl wnroll      ( int , int , int , int , int , int ,
                                      char );
