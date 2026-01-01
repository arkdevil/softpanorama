/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * This file contains the prototype definitions for any of the hardware
 *  dependent modules (such as hwhpux.c).
 */
void hw_xygoto ARGS((void));
int hw_clreol ARGS((void));
int hw_c_avail ARGS((void));
int hw_c_input ARGS((void));
void hw_c_output ARGS((int c));
int hw_linedel ARGS((int line));
int hw_lineins ARGS((int line));
void hw_terminate ARGS((void));
void hw_initialize ARGS((void));
int hw_backspace ARGS((void));
int hw_c_insert ARGS((void));
int hw_c_delete ARGS((void));
int hw_scroll_up ARGS((int top, int bottom));
int hw_scroll_down ARGS((int top, int bottom));
int hw_os_shell ARGS((void));
