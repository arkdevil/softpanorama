/* VIDEO.H
 *
 * This is the include file for the SpeedGraphics video library.
 */

#define         VIDEO           0x10
#define         ATTR(fore,back) (back<<4)|fore  /* defines the attribute byte */

    /* video card types */
#define         VIDEO_NONE              0x00
#define         MONO                    0x01
#define         HERC                    0x02
#define         MCGA                    0x03
#define         CGA                     0x04
#define         EGA                     0x05
#define         VGA                     0x06

        /* Video Modes Supported */
#define         EGA_MODE_0x0D           0x00            /* 320x200x16  */
#define         EGA_MODE_0x0E           0x01            /* 640x200x16  */
#define         EGA_MODE_0x10           0x02            /* 640x350x16  */
#define         VGA_MODE_0x12           0x03            /* 640x480x16  */
#define         VGA_MODE_0x13           0x04            /* 320x200x256 */

    /* Text cursor types */
#define         NORMAL          0               /* normal flat line */
#define         INSERT          1               /* half-box */
#define         FULLBOX         2               /* full-box */
#define         INVISIBLE       3               /* turn off cursor */

    /* color types */

#if !defined(BLINK)
#define BLINK       128 /* blink bit */
#endif

#if !defined(__COLORS)
#define __COLORS

enum COLORS {
    BLACK,          /* dark colors */
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    BROWN,
    LIGHTGRAY,
    DARKGRAY,       /* light colors */
    LIGHTBLUE,
    LIGHTGREEN,
    LIGHTCYAN,
    LIGHTRED,
    LIGHTMAGENTA,
    YELLOW,
    WHITE
};
#endif

#if !defined(bool)
#define         bool    char
#endif

#if !defined(TRUE)
#define TRUE    1
#define FALSE   0
#endif

/* Describes one alignment of a mask-image pair */
typedef struct {
   int ImageWidth; /* image width in addresses in display memory (also
                      mask width in bytes) */
   unsigned int ImagePtr; /* offset of image bitmap in display mem */
   char *MaskPtr;  /* pointer to mask bitmap */
} AlignedMaskedImage;

/* Describes all four alignments of a mask-image pair */
typedef struct {
   AlignedMaskedImage *Alignments[4]; /* ptrs to AlignedMaskedImage
                                      structs for four possible destination 
                                      image alignments */
} MaskedImage;

/****************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif

/* General Screen Functions */

void                    SGInitVideo(void);
void                    SGSetVideoMode(int newmode);
char                    SGGetVideoMode(void);
int                     SGDetectVideoType(void);
void                    SGCloseVideo(void);

/* Screen Text Functions */

void                    SGFastPuts(char *string);
void                    SGPositionXY(int x,int y);
int                     SGGetXPos(void);
int                     SGGetYPos(void);
void                    SGSetTextForeground(char foreground);
void                    SGSetTextBackground(char background);
void                    SGScrollTextUp(void);
void                    SGMoveCursor(char xpos,char ypos);
void                    SGFastPutChar(char character);
bool                    SGFieldGetText(char *buffer,int maxlen,char foreground,char background);
void                    SGFastClearScreen(void);
char                    SGGetTextForeground(void);
char                    SGGetTextBackground(void);
void                    SGFastPutCharA(char character,char attribute);
void                    SGFastDrawChars(char *string,char attribute);
void                    SGSetCursorSize(int newsize);
void                    SGFastPutStringA(char *string,char foreground,char background);
bool                    SGFieldTextEdit(char *string,int maxlen,char foreground,char background);
void                    SGFastColorLine(int xpos,int ypos,int number,char attribute);
void                    SGFastClearEOL(void);
void                    SGFastPutStringXY(int x,int y,char *string,char foreground,char background);
bool                    SGFieldEdit(int xpos,int ypos,char *buffer,char maxlen,char initpos,char foreground,char background);
void                    SGFastPrintf(char *format,...);
void                    SGFastPrintfA(char foreground,char background,char *format,...);
void                    SGFastPrintfXYA(char x,char y,char foreground,char background,char *format,...);
void                    SGTextBox(char x1,char y1,char x2,char y2,char attribute);

/* Graphics functions */

void                    SGDrawLine(int x1,int y1,int x2,int y2);
void                    SGRectangleFill(int x1,int y1,int x2,int y2);
void                    SGGrClearScreen(void);
void                    SGDisplayText(char far *string,int len,char color,int x,int y);
void                    SGPutImage(int x,int y,int width,int height,unsigned char far *buffer);
void                    SGPutPixel(int x,int y);
char                    SGGetPixel(int x,int y);
void                    SGSetColor(char newcolor);
int                     SGGetXMax(void);
int                     SGGetYMax(void);
void                    SGShowPage(unsigned int startoffset);
void                    SGSetPage(unsigned int segaddr);
void                    SGFillPolygon(int numpts,...);

/* 16-color mode specific graphics functions */

void                    palette_setsingle(char reg,char value);
void                    palette_setarray(char far *);

void                    drawline_ega(int x1,int y1,int x2,int y2);
void                    rectanglefill_ega(int x1,int y1,int x2,int y2);
void                    putimage_ega(int x,int y,int width,int height,unsigned char far *buffer);
void                    getblock_ega(int x, int y, int width,int height,char far *buffer);
void                    putblock_ega(int x, int y, int width,int height,char far *buffer);
char                    getpixel_ega(int x,int y);
void                    putpixel_ega(int x,int y);
void                    putimage_egamasked(int x,int y,int width,int height,unsigned char far *buffer,unsigned char far *maskbuff);

/* Mode 13h (320x200x256) specific graphics functions */

void                    putpixel_vga(int x,int y);
char                    getpixel_vga(int x,int y);
void                    rectanglefill_vga(int x1,int y1,int x2,int y2);
void                    drawline_vga(int x1,int y1,int x2,int y2);
void                    putimage_vga(int x,int y,int width,int height,unsigned char far *buffer);

/* Mode X (320x240x256) specific graphics functions */

void                    CopySystemToScreenX(int SourceStartX, int SourceStartY,int SourceEndX, int SourceEndY, int DestStartX,int DestStartY, char* SourcePtr, unsigned int DestPageBase,int SourceBitmapWidth, int DestBitmapWidth);
void                    CopyScreenToScreenX(int SourceStartX, int SourceStartY,int SourceEndX, int SourceEndY, int DestStartX,int DestStartY, unsigned int SourcePageBase,unsigned int DestPageBase, int SourceBitmapWidth,int DestBitmapWidth);
void                    FillPatternedX(int StartX, int StartY, int EndX, int EndY,unsigned int PageBase, char* Pattern);
void                    FillRectangleX(int StartX, int StartY, int EndX, int EndY,unsigned int PageBase, int Color);
unsigned int            ReadPixelX(int X, int Y, unsigned int PageBase);
void                    Set320x240Mode(void);
void                    WritePixelX(int X, int Y, unsigned int PageBase, int Color);
void                    CopySystemToScreenMaskedX(int SourceStartX,int SourceStartY, int SourceEndX, int SourceEndY,int DestStartX, int DestStartY, char * SourcePtr,unsigned int DestPageBase, int SourceBitmapWidth,int DestBitmapWidth, char * MaskPtr);
void                    CopyScreenToScreenMaskedX(int SourceStartX,int SourceStartY, int SourceEndX, int SourceEndY,int DestStartX, int DestStartY, MaskedImage * Source,unsigned int DestPageBase, int DestBitmapWidth);

#ifdef __cplusplus
}
#endif
