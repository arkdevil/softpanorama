//------------------------------------------------------------------
//   HANDLER.H
//
//   (C)1992-93 Александр Маркилюк
//   тел. (056-72)37-110, (056-72)37-702 (рабочие)
//
//   В файле описаны прототипы функций, вызываемых для обработки
//   сообщений от Control'ов
//
//   Компилятор: BC++ 3.1
//------------------------------------------------------------------

void            HandleExtList (HWND hWnd, LPARAM lParam);
void            HandleMenuList (HWND hWnd, LPARAM lParam);
BOOL            HandleClose (HWND hWnd);
void            HandleSave (void);
int             HandleEdit (HWND hWnd);
int             HandleAppend (HWND hWnd);
void            HandleDelete (HWND hWnd);
void            SetStyles (HWND hWnd, int nStyleIndex);

