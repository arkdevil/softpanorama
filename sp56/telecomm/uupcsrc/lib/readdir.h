/*--------------------------------------------------------------------*/
/*    r e a d d i r . h                                               */
/*                                                                    */
/*    Reads a spooling directory with optional pattern matching       */
/*                                                                    */
/*    Copyright 1991 (C), Andrew H. Derbyshire                        */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/*                            linked list                             */
/*--------------------------------------------------------------------*/

struct file_queue {
   char name[8/*system*/+1/*\*/+1/*X*/+1/*\*/+12/*import*/+1/*\0*/];
   struct file_queue *next_link;
} ;

char       *xreaddir(char *xname,
                    const char *remote,
                    const char *subdir,
                          char *pattern );
