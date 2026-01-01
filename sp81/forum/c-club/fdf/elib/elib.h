/*
 * monk.h
 *
 * header file for Monk C library functions - Atari ST version
 *
 * Roy Bixler
 * Monk Software
 * March 31, 1991
 */



#define HASH_TAB_SIZE 211
#define PATH_SEPARATOR "\\"

/* monklib.c */
int getopt(int argc, char **argv, char *opts);
int ask_user(char *buf);
int hashpjw(char *s);
int is_special(char *d_name);
long cmptime(const struct ffblk *a, const struct ffblk *b);
char *append_dir_to_path(char *path, char *dir);
int delete_file(char *file, char force);
char *skip_whitespace(char *str);
int mark_list(char *num_list, char *mark_list, int max_num);
void zap_trailing_nl(char *str, int max_ch, FILE *stream);
void format_dir(char *dir, char app_slash, char *formatted_dir);
