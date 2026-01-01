
typedef struct {
  int hotspotx;
  int hotspoty;
  int andmask[16];
  int xormask[16];
} mouseshape;

typedef mouseshape *MouseShapePtr;

void setmouseshape(MouseShapePtr m);

void showmouse(void);

void hidemouse(void);

int mouseinstalled(void);

void settextmode(void);

void setgraphmode(void);
