/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * This file contains all the prototypes for functions in findrep.c
 */

/*
 * cmp_func functions compare two strings
 */
typedef int (*cmp_func) ARGS((char *s1, char *s2));

void replace_string ARGS((windows *window));
void find_string ARGS((windows *window));
void do_last ARGS((windows *window));
void goto_marker ARGS((windows *window, int n));
void goto_top_file ARGS((windows *window));
void goto_end_file ARGS((windows *window));
void match_pair ARGS((windows *window, int forward));
void goto_line ARGS((windows *window));

#ifdef GRIB
void set_grib_count ARGS((windows *window));
void find_grib_error ARGS((windows *window));
#endif
