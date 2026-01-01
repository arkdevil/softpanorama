/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * prototypes for block.c functions
 */
void mark_start ARGS((windows *window));
void mark_end ARGS((windows *window));
void block_move ARGS((windows *window));
void block_copy ARGS((windows *window));
void block_read ARGS((windows *window, int fixup));
void block_delete ARGS((windows *window));
void block_indent ARGS((windows *window));
void block_unindent ARGS((windows *window));
void set_marker ARGS((windows *window, int n));
void block_print ARGS((windows *window));
void block_write ARGS((windows *window));

