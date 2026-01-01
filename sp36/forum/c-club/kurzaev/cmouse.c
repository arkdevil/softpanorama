/* (C) Copyright, KurP, 1991
 *
 *  mouse.c
 *
 *  Turbo C++ compiler
 *  Microsoft mouse library
 */

#pragma inline
#include "cmouse.h"

bool far mouse_install(int far& buttons)
{
   mouseINT(0);
   _CX = _BX;
   buttons = _CX;
   return bool(_AX == 0xFFFF);
}

void far mouse_show_ptr(void)
{
   mouseINT(1);
}

void far mouse_hide_ptr(void)
{
   mouseINT(2);
}

int far mouse_query_ptr(int far& hor, int far& ver)
{
   mouseINT(3);
   _AX = _BX;
   hor = _CX;
   ver = _DX;
   return _AX;
}

void far mouse_move_ptr(int hor, int ver)
{
   _CX = hor;
   _DX = ver;
   mouseINT(4);
}

int far mouse_query_press(int button, int far& hor, int far& ver)
{
   _BX = button;
   mouseINT(5);
   _AX = _BX;
   hor = _CX;
   ver = _DX;
   return _AX;
}

int far mouse_query_release(int button, int far& hor, int far& ver)
{
   _BX = button;
   mouseINT(6);
   _AX = _BX;
   hor = _CX;
   ver = _DX;
   return _AX;
}

void far mouse_hor_range(int hmin, int hmax)
{
   _CX = hmin;
   _DX = hmax;
   mouseINT(7);
}

void far mouse_ver_range(int vmin, int vmax)
{
   _CX = vmin;
   _DX = vmax;
   mouseINT(8);
}

void far mouse_graph_shape(int hhot, int vhot, void  far * cursor)
{
   _BX = hhot;
   _CX = vhot;
   l_ES_DX(cursor);
   mouseINT(9);
}

void far mouse_text_shape(int ctype, int par1, int par2)
{
   _BX = ctype;
   _CX = par1;
   _DX = par2;
   mouseINT(10);
}

void far mouse_query_motion(int far& hor, int far& ver)
{
   mouseINT(11);
   hor = _CX;
   ver = _DX;
}

void far mouse_event_hand(int mask, mhand hand)
{
   _CX = mask;
   l_ES_DX(hand);
   mouseINT(12);
}

void far mouse_lightpen(void)
{
   mouseINT(13);
}

void far mouse_no_lightpen(void)
{
   mouseINT(14);
}

void far mouse_ptr_speed(int hspeed, int vspeed)
{
   _CX = hspeed;
   _DX = vspeed;
   mouseINT(15);
}

void far mouse_exclusion(int left, int top, int right, int bottom)
{
   asm push si
   asm push di
   _CX = left;
   _DX = top;
   _SI = right;
   _DI = bottom;
   mouseINT(16);
   asm pop di
   asm pop si
}

void far mouse_max_speed(int mspeed)
{
   _DX = mspeed;
   mouseINT(19);
}

mhand far mouse_new_event_hand(int far& mask, mhand hand)
{
   _CX = mask;
   l_ES_DX(hand);
   mouseINT(20);
   mask = _CX;
   s_ES_DX(hand);
   return hand;
}

int far mouse_status_size(void)
{
   mouseINT(21);
   return _BX;
}

void far mouse_save_status(void far * buff)
{
   l_ES_DX(buff);
   mouseINT(22);
}

void far mouse_rest_status(void far * buff)
{
   l_ES_DX(buff);
   mouseINT(23);
}

bool far mouse_set_key_hand(int mask, mhand hand)
{
   _CX = mask;
   l_ES_DX(hand);
   mouseINT(24);
   return bool(_AX == 0x18);
}

mhand far mouse_get_key_hand(int mask)
{
   _CX = mask;
   mouseINT(25);
   if (_CX == 0) return NULL;
   mhand hand;
   s_ES_DX(hand);
   return hand;
}

void far mouse_set_sens(int horsp, int versp, int doubsplim)
{
   _BX = horsp;
   _CX = versp;
   _DX = doubsplim;
   mouseINT(26);
}

void far mouse_query_sens(int far& horsp, int far& versp, int far& doubsplim)
{
   mouseINT(27);
   _AX = _BX;
   horsp = _AX;
   versp = _CX;
   doubsplim = _DX;
}

void far mouse_int_rate(int rate)
{
   _BX = rate;
   mouseINT(28);
}

void far mouse_set_page(int npage)
{
   _BX = npage;
   mouseINT(29);
}

int far mouse_query_page(void)
{
   mouseINT(30);
   return _BX;
}

bool far mouse_disable(void)
{
   mouseINT(31);
   return bool(_AX == 0x1F);
}

void far mouse_enable(void)
{
   mouseINT(32);
}

bool far mouse_reset(int far& buttons)
{
   mouseINT(33);
   _CX = _BX;
   buttons = _CX;
   return bool(_AX == 0x21);
}
