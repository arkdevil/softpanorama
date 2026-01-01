/* Include file for WGT Joystick Routines
Copyright 1993 Chris Egerter */

#ifdef __cplusplus
extern "C" {
#endif


typedef struct {
    int x,y;
    int cenx,ceny;
    int xrange,yrange;
    int port,buttons;
    int scale;
    } joystick;

extern int wcheckjoystick(void);
extern int wreadjoystick(joystick *);
extern void winitjoystick(joystick *, int);
extern void wcalibratejoystick(joystick *);
#ifdef __cplusplus
}
#endif
