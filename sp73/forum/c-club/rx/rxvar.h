/*--------------------------------------------------------------------      */
/* rxvar.h                                                                  */
/*NOTE:                                                                     */
/*This is a completly experimental program in it's pre-beta version.        */
/*It is not guaranteed to work properly under all circumstances, although   */
/*it has been tested for a couple of weeks. Everyone who uses this program  */
/*does this on his own risk, so if your machine explodes, don't tell me     */
/*you didn't know.                                                          */
/*                                                                          */
/*Andreas Gruen releases this software "as is", with no express or          */
/*implied warranty, including, but not limited to, the implied warranties   */
/*of merchantability and fitness for a particular purpose.                  */
/*                                                                          */
/*This program is completly free for everyone.                              */
/*You can do with it and its sources whatever you want, but it would        */
/*be fine to leave my name somewhere in the program or startup-banner.      */
/*---------------------------------------------------------------------     */

char *button_text[12] = {
"BS_PUSHBUTTON", "BS_DEFPUSHBUTTON",
"BS_CHECKBOX",   "BS_AUTOCHECKBOX",
"BS_RADIOBUTTON","BS_3STATE",
"BS_AUTO3STATE", "BS_GROUPBOX",
"BS_USERBUTTON", "BS_AUTORADIOBUTTON",
"BS_PUSHBOX",    "BS_OWNERDRAW"};

char *edit_text[3] = {"ES_LEFT","ES_CENTER","ES_RIGHT"};

char *static_text[13] = {
"SS_LEFT",       "SS_CENTER",
"SS_RIGHT",      "SS_ICON",
"SS_BLACKRECT",  "SS_GRAYRECT",
"SS_WHITERECT",  "SS_BLACKFRAME",
"SS_GRAYFRAME",  "SS_WHITEFRAME",
"SS_USERITEM",   "SS_SIMPLE",
"SS_LEFTNOWORDWRAP" };

char *combo_text[4] = {
"","CBS_SIMPLE","CBS_DROPDOWN","CBS_DROPDOWNLIST"};

struct _texttab {
  char *text;
  UCHAR val;
  };

typedef struct _texttab TEXTTAB;

TEXTTAB virt_text[] = {
{"LBUTTON",0x01 },
{"RBUTTON",0x02 },
{"CANCEL",0x03 },
{"MBUTTON",0x04 },
{"BACK",0x08 },
{"TAB",0x09 },
{"CLEAR",0x0C },
{"RETURN",0x0D },
{"SHIFT",0x10 },
{"CONTROL",0x11 },
{"MENU",0x12 },
{"PAUSE",0x13 },
{"CAPITAL",0x14 },
{"ESCAPE",0x1B },
{"SPACE",0x20 },
{"PRIOR",0x21 },
{"NEXT",0x22 },
{"END",0x23 },
{"HOME",0x24 },
{"LEFT",0x25 },
{"UP",0x26 },
{"RIGHT",0x27 },
{"DOWN",0x28 },
{"SELECT",0x29 },
{"PRINT",0x2A },
{"EXECUTE",0x2B },
{"SNAPSHOT",0x2C },
{"INSERT",0x2D },
{"DELETE",0x2E },
{"HELP",0x2F },
{"NUMPAD0",0x60 },
{"NUMPAD1",0x61 },
{"NUMPAD2",0x62 },
{"NUMPAD3",0x63 },
{"NUMPAD4",0x64 },
{"NUMPAD5",0x65 },
{"NUMPAD6",0x66 },
{"NUMPAD7",0x67 },
{"NUMPAD8",0x68 },
{"NUMPAD9",0x69 },
{"MULTIPLY",0x6A },
{"ADD",0x6B },
{"SEPARATOR",0x6C },
{"SUBTRACT",0x6D },
{"DECIMAL",0x6E },
{"DIVIDE",0x6F },
{"F1",0x70 },
{"F2",0x71 },
{"F3",0x72 },
{"F4",0x73 },
{"F5",0x74 },
{"F6",0x75 },
{"F7",0x76 },
{"F8",0x77 },
{"F9",0x78 },
{"F10",0x79 },
{"F11",0x7A },
{"F12",0x7B },
{"F13",0x7C },
{"F14",0x7D },
{"F15",0x7E },
{"F16",0x7F },
{"NUMLOCK",0x90 },
{"", 0x00}    };
