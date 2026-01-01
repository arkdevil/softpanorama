
#define Uses_TEventQueue
#define Uses_TEvent
#define Uses_TProgram
#define Uses_TApplication
#define Uses_TKeys
#define Uses_TRect
#define Uses_TMenuBar
#define Uses_TSubMenu
#define Uses_TMenuItem
#define Uses_TStatusLine
#define Uses_TStatusItem
#define Uses_TStatusDef
#define Uses_TDeskTop
#define Uses_TView
#define Uses_TWindow
#define Uses_TFrame
#define Uses_TScroller
#define Uses_TScrollBar
#define Uses_TDialog
#define Uses_TButton
#define Uses_TSItem
#define Uses_TCheckBoxes
#define Uses_TRadioButtons
#define Uses_TLabel
#define Uses_TInputLine
#define Uses_TCollection
#define Uses_THistory
#define Uses_TListBox
#define Uses_TStringCollection
#include <tv.h>

const cmTry = 150;

struct TListboxRec
{
    TCollection* collection;
    short focused;
};

class TMyApp : public TApplication
{
public:
    TMyApp();
    static TStatusLine *initStatusLine(TRect r);
    virtual void handleEvent(TEvent& event);
};

TMyApp::TMyApp() :
    TProgInit( &TMyApp::initStatusLine,
	       &TMyApp::initMenuBar,
	       &TMyApp::initDeskTop
	     )
{
}

TStatusLine *TMyApp::initStatusLine( TRect r )
{
    r.a.y = r.b.y - 1;     // move top to 1 line above bottom
    return new TStatusLine( r,
      *new TStatusDef(0, 0xFFFF) +
      *new TStatusItem("~Alt-X~ Exit", kbAltX, cmQuit) +
      *new TStatusItem("~F9~ Try dialog", kbF9, cmTry)
    );
}

//******Insert makeDialog here*****


dataRec a;

void TMyApp::handleEvent(TEvent& event)
{
    TApplication::handleEvent(event);
    if( event.what == evCommand && event.message.command == cmTry )
	{
	 TDialog* dialog = makeDialog();
	 if (validView(dialog))
	   {
	   //the line below removes any initialization in makeDialog, so
	   //it may be desirable to remove it.
	   dialog->setData(&a);
	   if (deskTop->execView(dialog) != cmCancel)
	      dialog->getData(&a);
	   destroy(dialog);
	   }
	 clearEvent(event);
	}
}

int main()
{
    TMyApp myApp;
    myApp.run();
    return 0;
}


