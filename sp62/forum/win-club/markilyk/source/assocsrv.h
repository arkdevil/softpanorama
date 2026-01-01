//------------------------------------------------------------------
//   ASSOCSRV.C
//
//   (C)1992-93 Александр Маркилюк
//   тел. (056-72)37-110, (056-72)37-702 (рабочие)
//
//   В файле определяются основные константы, структуры данных,
//   с которыми работает ASSOCSRV.EXE и описываются прототипы вызы-
//   ваемых функций
//
//   Компилятор: BC++ 3.1
//------------------------------------------------------------------

#define  MAXTOPIC   128
#define  MAXLINE    128
#define  DEF_SIZE   10240
#define  STYLE_NUM  3

#define  IDM_FIRST  401
#define  IDM_ABOUT  512

#define  WM_CONFIGUREDIALOG        WM_USER + 1

// Стpуктуpа для хpанения списка меню для каждого pасшиpения
typedef struct tagMenuCh {
        char far*               lpMenuItem;     // указатель на стpоку меню
        char far*               lpCommand;       // указатель на стpоку команды
        struct tagMenuCh far*   lpNext;         // указатель на следующую стpуктуpу списка
        int                     nStyle;
}MENUCH;
typedef MENUCH far*     LPMENUCH;

// Стpуктуpа описания меню для каждого pасшиpения
typedef struct tagExtControl {
        char far   szExtension [4];             // pасшиpение файла
        LPMENUCH   lpChain;                     // указатель на соответствующий список меню
}EXTCONTROL;
typedef EXTCONTROL far* LPEXTCONTROL;

/*typedef struct tagCommandChain {
        char   far*             lpBuffer;
        struct tagCommandChain* lpNext;
        HGLOBAL                 hNext;
}COMMANDCHAIN;
typedef COMMANDCHAIN far*       LPCOMMANDCHAIN;*/

typedef struct tagRunStyles {
        int    nStyleConst;
        char   cStyleName [10];
}RUNSTYLES;


void                    InitApplication (HINSTANCE hInst);
BOOL                    InitInstance (HINSTANCE hInst, int nShow);
BOOL                    InitOptions (HINSTANCE hInst);
void                    ProcessIt (HWND hWnd);
void                    DestroyArray (void);
void                    DestroyStructure (LPSTR lpFirst, LPSTR lpSecond);
void                    GetExtension (char *szFile, char *szExt);
LPMENUCH                SearchExtension (char *szExt);
BOOL                    GetCommandLine (LPMENUCH lpCurChain, UINT wNumber, char *szCommand, int* nStyle);
void                    MakeMyMenu (HWND hWindow);
LRESULT                 FillControls (HWND hWindow);
LRESULT                 ShowCommands (HWND hWindow, int nIndex);
void                    DestroyMenuCh (LPMENUCH lpChain);
UINT                    ExpandArray (LPVOID* lpArray, UINT nOldSize, UINT nSizeOf, UINT nBy);
LPMENUCH                AppendList (int nArrIndex);
int                     ExtractStyle (LPSTR lpBuffer);



