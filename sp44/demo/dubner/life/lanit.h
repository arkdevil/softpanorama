#ifndef LANIT_H
#define LANIT_H

extern int lanit_hidden;
extern WINDOW *lanit_wnd;

ENTRY void StartLanit(void);

#define HideLanit()	wnd_Hide(lanit_wnd)
#define ShowLanit()	wnd_UnHide(lanit_wnd)

ENTRY void LanitMoveRight(void);
ENTRY void LanitMoveLeft(void);
ENTRY void LanitMoveUp(void);
ENTRY void LanitMoveDown(void);


#endif