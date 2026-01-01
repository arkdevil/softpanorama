/*
 *  EXAMPLE3.C - Example program uses POSIX directory functions
 *
 *	usage:  example3 [pathname]
 *
 *  Modification history:
 *   V1.0  22-Jun-94, J Mathews  Original version.
 */

#include "dirent.h"

main(argc, argv)
     int argc;
     char** argv;
{
 DIR* dirp;
 struct dirent* dp;
 char *path = (argc==1) ? DIR_CUR : argv[1];

 printf("Directory of %s\n\n", path);
 dirp = opendir(path);
 while ((dp = readdir(dirp)) != NULL)
   {
     printf("%-40s", dp->d_name);
   }
 closedir(dirp);
}
