/***************************************************************/
/*                                                             */
/*              KIVLIB  include file  MUSIC.H                  */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___MUSIC_H___
#define ___MUSIC_H___



#define TUSH "t250o3c2e4g4>c8c8c8c8c8c8c8c8d8d8d8d8d8d8d8d8e2d2c4<g4>c2"

#define LAMBADA "t180o4e4.d8c8<b8a4a8>c8<b8a8g8a8e8d8e4e2.\
>e4.d8c8<b8a4a8>c8<b8a8g8a8e8d8e4e2.>d4.\
c8<f4f8a8>e4d8c8<f4a8>c8<b8.a16g2a8g8a4a2"

#define MANDL "t150o3e8>e4e4e4.d8c4c4c4.<b8a4a4g+8.\
a16b8.a16g4f4f4.e8>f4f4f4.e8d4d4d4.c8<b4b4b-8.b16>e8.d16c2."

#define QUAQUA "t180o4g8g8a8a8e8e8g4g8g8a8a8e8e8g4g8g8a8a8>c8c8<b4b4a4g4f4\
f8f8g8g8d8d8f4f8f8g8g8d8d8f4f8f8g8g8b8b8a4a4g4f4e4\
g8g8a8a8e8e8g4g8g8a8a8e8e8g4g8g8a8a8>c8c8<b4b4a4g4f4f8f8\
g8g8d8d8f4f8f8g8g8d8d8f4f8f8g8g8a8b8>c4<g4a4b4>c2"

#define KONY "t110o3b8a8g4d4g4>e8c8d4d2<b8a8g4d4g4>e8c8d2.\
p32o3b8b8o4g4f4e4d8g8f4f2g8g8f4g8e8d4c4g2.\
p32o3b8b8o4g4f4e4d8g8f4f2g8g8f4g8e8d4c4g2."

#define NICH "t180o3b4a4g4g4f4+e4f4+f4+f4+f4+d4+<b4b4+>d4f4+a4g4f4+e2.\
e4g4g4g4g4f4+e4a4a4a4a4b4>c4<b4b4b4b4f4+g4e2.\
p4g4g4g4g4f4+e4a4a4a4a4b4>c4<b4b4b4b4f4+g4e2."

#define SLROM "t230o3b4p2a+16b4p2>c8<b8b8a8e8<b8>b8p2>c8<b8b8>e8f+8g8c8<b8b8>e8f+8g8f+8p4.e8p8e4.p2\
<a4p2g+16a4p2>c8<b8b8a8g8f+8a4p2>c8<b8b8a8g8f+8>c8<b8b8a8b8>c8c8p4.<b8p8b4p2b4p2a+16\
b4p2>c8<b8b8g8e8<b8>b4p8e8f+8g8f+4.e8f+8g8f+4.d8e8f+8e8p4.d8p8d4p2>c8c8c8p8<b8p8\
o3>c8c8c8p8<b8p8b8>d8d8c+8c+8c8c8<b8a+8b8>c8<b8b8b8b8p8a8p8b8b8b8p8a8p8a8>c8c8\
<b8b8a8a8g8f+8g8a8g8a8a8a8p8g8p8g8g8g8p8f+8p8a8a8a8p8g8p8>d8d8d8p8c8p8<b4.p4.a+16b4.p4.a+16\
b4.p4.a+16b4.p4."

#define KUKUR "t200o3a8g8a8e8c8e8<a8>p8a8g8a8e8c8e8<a8>p8a8b8>c8<b8>c8<a8b8a8b8g8a8g8a8f8a8p8\
a8g8a8e8c8e8<a8>p8a8g8a8e8c8e8<a8>p8a8b8>c8<b8>c8<a8b8a8b8g8a8g8a8b8>c8p8"

#define ODESSA "T400O4E4P2C4<B4A4p4e8p8e4>c8p8c4d4c4<b4p2>d4p2<b4a4g+4\
p4>e8p8e8p8e8p8e4d4f4e4p2e4p2c4<b4a4p4a16>e16e8<a16>e16.e8<a16>e16.e8<b16\
>a16.a8c+16g16.g8d16f16f2a8p8a8p8a8p8g8p8f8p8a4e4p4f4e8f16e16d8e16d16c8\
d16c16<b8>c16<b16a2>a4"

#define HOLMS "T250O3F2P4.F8A4P4>C4P4F8E8D8E8F2P4E4P4D8P8c8<b8\
a8b8>c2p4<b4p4a8p8a2c4p8c4f4p8c4p8f4p8c4p8f2p4.f8a4p4>c4p4a8g8\
f8g8a2p4g4p4f8p8e8f8g8f8e8p8g8p8e8p8g8p8d8p8f8p8e8f8g8f8e8p8g8\
p8e8p8g8p8d8p8f8p8e8p8e8d8c8p8c8<b8a8p8>c8p8f2p4g8p8e4.f16p16f1"


#define KIEV "t120o3g4g8g8a8.b8>c4.<b4>c8d4.c4<b8a2.b4e8e8f+8g8b4.a4.g4.d+4f+8e4..p1p1"

#ifdef __cplusplus
extern "C" {
#endif

int cdecl PlayString(char * s, int StopKbd);
void cdecl PlayProc(void far (*Proc)(), int StopKbd);
int cdecl PlayToFile(char * s, char * filename);


//background play
void cdecl StopPlay();
void cdecl SetPlay(void far (*Proc)());
void cdecl StopPlayAtEnd(int StopKbd);


void far cdecl Odessa(void);
void far cdecl Ukraine(void);
void far cdecl Holms(void);
void far cdecl Moria(void);
void far cdecl Lambada(void);
void far cdecl Slrom(void);
void far cdecl Kiev(void);



#ifdef __cplusplus
}
#endif

#endif


