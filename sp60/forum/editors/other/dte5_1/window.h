/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * prototypes for window.c functions
 */
int open_window ARGS((windows *window, char *name));
void choose_window ARGS((char *name, windows *window));
void size_window ARGS((windows *window));
void get_help ARGS((windows *old_window));
void finish ARGS((windows *window));
int create_window ARGS((windows *prev, int top, int bottom,
        text_ptr cursor, file_infos *file));
int create_file ARGS((file_infos *prev));
