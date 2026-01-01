// Временное моделирование процесса создания классов Turbo Vision
#include "CLASSES.CH"
#include "OOP.CH"

proc main()
local i,tview,tcluster,tcheckboxes,tradiobuttons,;
        tframe,tgroup,tdesktop,tprogram,tapplication,twindow,;
        thistorywindow,tdialog,tbackground,tbutton,tstatictext,;
        tlabel,tparamtext,tlistviewer,thistoryviewer,tlistbox,;
        tmenuview,tmenubar,tmenubox,tscrollbar,tscroller,ttextdevice,;
        tterminal,tstatusline,tInputLine,tHistory

? 'start',seconds(), memory(0),memory(1),memory(2)

class tview ancestor Object
for i:=1 to 75 do tview:addmethod("TVIEW"+ltrim(str(i)),"Dummy")

class tcluster ancestor tview
for i:=1 to 18 do tview:addmethod("TCLUS"+ltrim(str(i)),"Dummy")

class tcheckboxes ancestor tcluster
for i:=1 to 3 do tview:addmethod("Tcheck"+ltrim(str(i)),"Dummy")

class tradiobuttons ancestor tcluster
for i:=1 to 5 do tview:addmethod("trad"+ltrim(str(i)),"Dummy")

class tframe ancestor tview
for i:=1 to 5 do tview:addmethod("tframe"+ltrim(str(i)),"Dummy")

class tgroup ancestor tview
for i:=1 to 33 do tview:addmethod("tgroup"+ltrim(str(i)),"Dummy")

class tdesktop ancestor tgroup
for i:=1 to 6 do tview:addmethod("tdesk"+ltrim(str(i)),"Dummy")

class tprogram ancestor tgroup
for i:=1 to 15 do tview:addmethod("tprog"+ltrim(str(i)),"Dummy")

class tapplication ancestor tprogram
for i:=1 to 2 do tview:addmethod("tappl"+ltrim(str(i)),"Dummy")

class twindow ancestor tgroup
for i:=1 to 19 do tview:addmethod("twind"+ltrim(str(i)),"Dummy")

class thistorywindow ancestor twindow
for i:=1 to 6 do thistorywindow:addmethod("thist"+ltrim(str(i)),"Dummy")

class tdialog ancestor twindow
for i:=1 to 4 do tdialog:addmethod("tdia"+ltrim(str(i)),"Dummy")

class tbackground ancestor tview
for i:=1 to 6 do tbackground:addmethod("tback"+ltrim(str(i)),"Dummy")

class tbutton ancestor tview
for i:=1 to 13 do tbutton:addmethod("tbutt"+ltrim(str(i)),"Dummy")

class tstatictext ancestor tview
for i:=1 to 8 do tstatictext:addmethod("tstat"+ltrim(str(i)),"Dummy")

class tlabel ancestor tstatictext
for i:=1 to 8 do tlabel:addmethod("tlab"+ltrim(str(i)),"Dummy")

class tparamtext ancestor tstatictext
for i:=1 to 8 do tparamtext:addmethod("tpar"+ltrim(str(i)),"Dummy")

class thistory ancestor tview
for i:=1 to 7 do thistory:addmethod("thist"+ltrim(str(i)),"Dummy")

class tlistviewer ancestor tview
for i:=1 to 19 do tlistviewer:addmethod("tlist"+ltrim(str(i)),"Dummy")

class thistoryviewer ancestor tlistviewer
for i:=1 to 6 do thistoryviewer:addmethod("thist"+ltrim(str(i)),"Dummy")

class tlistbox ancestor tlistviewer
for i:=1 to 9 do tlistbox:addmethod("tlibo"+ltrim(str(i)),"Dummy")

class tinputline ancestor tview
for i:=1 to 18 do tinputline:addmethod("tinpu"+ltrim(str(i)),"Dummy")

class tmenuview ancestor tview
for i:=1 to 13 do tmenuview:addmethod("tmenu"+ltrim(str(i)),"Dummy")

class tmenubar ancestor tmenuview
for i:=1 to 3 do tmenubar:addmethod("tmbar"+ltrim(str(i)),"Dummy")

class tmenubox ancestor tmenuview
for i:=1 to 3 do tmenubox:addmethod("tmbox"+ltrim(str(i)),"Dummy")

class tscrollbar ancestor tview
for i:=1 to 17 do tscrollbar:addmethod("tsbar"+ltrim(str(i)),"Dummy")

class tscroller ancestor tview
for i:=1 to 14 do tscroller:addmethod("tscrol"+ltrim(str(i)),"Dummy")

class tstatusline ancestor tview
for i:=1 to 11 do tstatusline:addmethod("tstat"+ltrim(str(i)),"Dummy")

class ttextdevice ancestor tscroller
for i:=1 to 2 do ttextdevice:addmethod("ttext"+ltrim(str(i)),"Dummy")

class tterminal ancestor tscroller
for i:=1 to 16 do tterminal:addmethod("tterm"+ltrim(str(i)),"Dummy")


? 'end',seconds(),memory(0),memory(1),memory(2)
* Eof kaka.prg
