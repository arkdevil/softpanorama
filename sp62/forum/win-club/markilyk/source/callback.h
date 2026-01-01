//------------------------------------------------------------------
//   CALLBACK.H
//
//   (C)1992-93 Александр Маркилюк
//   тел. (056-72)37-110, (056-72)37-702 (рабочие)
//
//   В файле описаны прототипы функций, экспортируемых ASSOCSRV.EXE
//
//   Компилятор: BC++ 3.1
//------------------------------------------------------------------

LRESULT CALLBACK        WndProc (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
LRESULT CALLBACK        MenuWndProc (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        About (HWND hDlg, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        Config (HWND hDlg, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        EditExtension (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        EditMenu (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        AppendExtension (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
BOOL    CALLBACK        AppendMenuItem (HWND hWnd, UINT msg, WPARAM wPar, LPARAM lPar);
