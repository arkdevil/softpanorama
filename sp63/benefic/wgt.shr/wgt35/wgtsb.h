/* WordUp Graphics Toolkit v3.5
   SoundBlaster Routines	*/

#ifdef __cplusplus
extern "C" {
#endif

extern unsigned int sbstat;
extern int sbintnum,sbioaddr;
typedef char far * wgtvoice;
typedef char far * wgtsong;

extern int winitsb(void);
extern int wsbversion(void);
extern void waddr(int);
extern void wirq(int);
extern void wdeinitsb(void);
extern void wsetspeaker(int);
extern void wplayvoc(wgtvoice);
extern void wsample(wgtvoice,long);
extern void wstopvoc(void);
extern int wpausevoc(void);
extern int wresumevoc(void);
extern void wfreevoc(wgtvoice);
extern wgtvoice wnewvoice(long);
extern wgtvoice wloadvoc(wgtvoice);


extern unsigned char fmstat;
extern int fmint;
extern void wfmsetstatus(unsigned,unsigned);
extern unsigned wfmversion(void);
extern int wfmreset(void);
extern void wfmstopmusic(void);
extern void wfmsongspeed(unsigned);
extern void wfminstrument(unsigned,unsigned,int);
extern int wfindfm();
extern void wfmplay(unsigned,unsigned);
extern void wplaycmf(wgtsong);
extern wgtsong *wloadcmf(char *);
extern void wfreesong(wgtsong);
#ifdef __cplusplus
}
#endif
