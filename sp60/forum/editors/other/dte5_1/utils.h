/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * This file contains the prototypes for functions in utils.c
 */

/*
 * possible answers to various questions - see get_yn, get_ynaq and get_oa
 */
#define A_YES 1
#define A_NO 2
#define A_ALWAYS 3
#define A_QUIT 4
#define A_ABORT 5
#define A_OVERWRITE 6
#define A_APPEND 7

int get_yn ARGS((windows *window));
int get_ynaq ARGS((windows *window));
int get_oa ARGS((windows *window));
int get_name ARGS((char *prompt, int lines, char *name));
void un_copy_line ARGS((windows *window));
int linelen ARGS((text_ptr s));
int prelinelen ARGS((text_ptr s));
int myisalnum ARGS((char c));
int display ARGS((do_func doit, int reserved));
text_ptr find_next ARGS((text_ptr s));
void copy_line ARGS((windows *window));
text_ptr find_prev ARGS((text_ptr current));
int load_file ARGS((char *name, int fixup));
void fix_marks ARGS((windows *window, text_ptr pos, long len));
void setup_window ARGS((windows *window));
int first_non_blank ARGS((char *s));
int update_line ARGS((windows *window, text_ptr orig, int line,
        text_ptr cursor));
void scroll_up ARGS((windows *window));
void scroll_down ARGS((windows *window));
void page_down ARGS((windows *window));
void page_up ARGS((windows *window));
void save_file ARGS((windows *window, int kind));
void save_as_file ARGS((windows *window));
