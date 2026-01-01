/* Version number of GNU diff.  */

#ifdef MSDOS
char *version_string
  =  "1.15 (compiled " __DATE__ " " __TIME__ " for MS-DOS)";
#else /* not MSDOS */
char *version_string = "1.15";
#endif /* not MSDOS */
