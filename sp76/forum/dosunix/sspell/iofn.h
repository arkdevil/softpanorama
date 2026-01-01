#if defined(pyr) || defined(sun) || defined(__GNUC__)
#if !defined(SEEK_SET)
#define SEEK_SET (0)
#endif
#if !defined(SEEK_CUR)
#define SEEK_CUR (1)
#endif
#if !defined(SEEK_END)
#define SEEK_END (2)
#endif
#endif
