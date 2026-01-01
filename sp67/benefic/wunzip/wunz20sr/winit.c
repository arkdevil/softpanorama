#include "wizunzip.h"

long FAR PASCAL WizUnzipWndProc(HWND, WORD, WORD, LONG);

/****************************************************************************

    FUNCTION: WizUnzipInit(HANDLE)

    PURPOSE: Initializes window data and registers window class

    COMMENTS:

        Sets up a structure to register the window class.  Structure includes
        such information as what function will process messages, what cursor
        and icon to use, etc.

        This provides an example of how to allocate local memory using the
        LocalAlloc() call instead of malloc().  This provides a handle to
        memory.  When you actually need the memory, LocalLock() is called
        which returns a pointer.  As soon as you are done processing the
        memory, call LocalUnlock so that Windows can move the memory as
        needed.  Call LocalLock() to get a pointer again, or LocalFree() if
        you don't need the memory again.


****************************************************************************/
BOOL WizUnzipInit(HANDLE hInstance)
{
    WNDCLASS wndclass;

    wndclass.style = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc = (long (FAR PASCAL*)(HWND,unsigned ,unsigned,LONG))WizUnzipWndProc;
    wndclass.hInstance = hInstance;
    wndclass.hIcon = LoadIcon(hInstance, "WizUnzip");
    wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndclass.hbrBackground = BG_SYS_COLOR+1; /* set background color */
    wndclass.lpszMenuName = (LPSTR) "WizUnzip";
    wndclass.lpszClassName = (LPSTR) szAppName;
    wndclass.cbClsExtra     = 0;
    wndclass.cbWndExtra     = 0;


    if ( !RegisterClass(&wndclass) )
    {
        return FALSE;
    }

    /* define status class */
    wndclass.lpszClassName = (LPSTR) szStatusClass;
    wndclass.style = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc = (long (FAR PASCAL*)(HWND,unsigned,unsigned,LONG))StatusProc;
    wndclass.hInstance = hInstance;
    wndclass.hIcon = NULL;
    wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndclass.hbrBackground = GetStockObject(WHITE_BRUSH);
    wndclass.lpszMenuName = NULL;

    if ( !RegisterClass(&wndclass) )
    {
        return FALSE;
    }

    return TRUE;
}

