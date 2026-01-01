#ifdef __cplusplus
extern "C" {
#endif

extern block fliscreen;
extern int flickdly;
extern int framenumber;
extern int maxframe;
extern int flicp1,flicp2,flicp3,flicp4,flicpn;

extern void nextframe(void);
extern void openfli(char *);
extern void copyfli(void);
extern void closefli(void);


#ifdef __cplusplus
}
#endif
