#ifdef MODERN
#  if (!defined(M_XENIX) && !(defined(__GNUC__) && defined(sun)))
#    include <stddef.h>
#  endif
#  include <stdlib.h>
#  if defined(SYSV) || defined(__386BSD__)
#    include <unistd.h>
#  endif
#else
   char *malloc();
#  define void int
#endif

