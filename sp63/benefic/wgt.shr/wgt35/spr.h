/* WordUp Graphics Toolkit Sprite Library V3.5
   Copyright 1993 Chris Egerter
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
      unsigned char num;
      int x;
      int y;
      int ox;
      int oy;
      unsigned char on;
      int maxx;
      int maxy;
      int minx;
      int miny;
      block old;
      char animon;
      int anm[41];
      unsigned char ans[41];
      char curan;
      unsigned char delcnt;

      char movexon;
      int mvx[15];
      int mvn[15];
      unsigned char mvxs[15];
      char curxmove;
      int curmnx;
      unsigned char mvxcnt;

      char moveyon;
      int mvy[15];
      int mvny[15];
      unsigned char mvys[15];
      char curymove;
      int curmny;
      unsigned char mvycnt;


      } sprit;
extern sprit s[41];

extern block spritescreen;         

extern int spon,spclip;

extern void animate(int,char *);
extern void animoff(int);
extern void animon(int);
extern void drawspr(void);
extern void erasespr(void);
extern void initspr(void);
extern void movex(int,char *);
extern void movey(int,char *);
extern void movexoff(int);
extern void movexon(int);
extern void moveyoff(int);
extern void moveyon(int);
extern int  overlap(int,int);
extern void spriteoff(int);
extern void spriteon(int,int,int,int);

#ifdef __cplusplus
}
#endif
