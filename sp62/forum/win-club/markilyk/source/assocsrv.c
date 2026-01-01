//------------------------------------------------------------------
//   ASSOCSRV.C   
//
//   (C)1992-93 Александр Маркилюк
//   тел. (056-72)37-110, (056-72)37-702 (рабочие)
//  
//   Главный модуль сервера DDE. Содержит WinMain и глобальные
//   переменные
//
//   Компилятор: BC++ 3.1
//------------------------------------------------------------------
#define STRICT

#include <windows.h>
#include <windowsx.h>
#pragma  hdrstop

#include "assocsrv.h"

char*            szApp = "AssocSrv";            // имя пpиложения
char*            szClass = "AssocSrvWin";         // Windows класс главного окна
char*            szMenuClass = "MenuWindow";    // Windows класс для окна меню
char*            szTopic = "File";              // Topic name for DDE
char*            szItem = "Filename";           // Item name for DDE
char*            szProfileFile = "ASSOC.INI";  // Profile file name
char*            szAppName = "File Association Utility";     // Main window title
char             szFile [MAXTOPIC];
char             szIniFile [MAXLINE];
char*            szFilter = "Programs|*.com;*.exe;*.bat;*.pif|All files|*.*|";
char*            szHeader = "Pick an application";

RUNSTYLES        rsStyles [STYLE_NUM] = {{SW_SHOW, "Normal"},
                                 {SW_SHOWMAXIMIZED, "Maximized"},
                                 {SW_SHOWMINIMIZED, "Minimized"}};
HINSTANCE        hInst;
HWND             hMain;

LPMENUCH           lpCurrentChain;              // указатель на текущий список элементов меню
LPEXTCONTROL       lpContArray;                 // указатель на массив списков элементов меню
int                nContArrSize;                // pазмеp этого массива
int                nActiveList = 0;             // ID активного List Box
BOOL               bChanged = FALSE;
BOOL               bNeedConfigure = FALSE;

#pragma argsused
int PASCAL WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
  MSG msg;

  if (!hPrevInstance){                  // Возможно иметь только 1 экземпляp
     InitApplication (hInstance);

     if (!InitOptions (hInstance)){
        lpContArray = (LPEXTCONTROL)NULL;       // если нет INI-файла или не
        nContArrSize = 0;}                      // смогли его пpочитать

     if (!InitInstance (hInstance, nCmdShow))
        return FALSE;

     while (GetMessage (&msg, NULL, NULL, NULL)){
           TranslateMessage (&msg);
           DispatchMessage (&msg);}

     return msg.wParam;}
  else
       return FALSE;
}



