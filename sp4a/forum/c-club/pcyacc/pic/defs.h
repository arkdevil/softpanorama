
#define LISTSZ 128
#define PNTS 16
#define FATAL 1
#define NONFT 0
#define TRUE  1
#define FALSE 0

typedef struct {
  int shape;
  int color;
  int style;
  int fill;
  int npoints;
  int x_coord[PNTS];
  int y_coord[PNTS];
} Object;

typedef struct sc {
  char   *namep;
  Object *value;
  struct sc *next;
} Symbol;

extern Object *objlst[], anObject;
extern Symbol *symlst[];
extern int ocount;

