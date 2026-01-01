VERSION 2.00
Begin Form Form1 
   Caption         =   "Subdoc sample project"
   Height          =   6510
   KeyPreview      =   -1  'True
   Left            =   1035
   LinkTopic       =   "Form1"
   ScaleHeight     =   5820
   ScaleWidth      =   7365
   Top             =   1140
   Width           =   7485
   Begin Menu MStart 
      Caption         =   "&Tile"
   End
   Begin Menu MFinish 
      Caption         =   "&Finish"
   End
End
DefInt A-Z

''  This form doesn't do anything much - just a sample
''  of code for subdoc to show off with.
''  *** However try remming out the lines in MStart_Click
''      that take the loss of frame borders into account
''      and see what happens.



Dim T() As TILE                    ' will contain tiles

Sub MFinish_Click ()
    End
End Sub

Sub MStart_Click ()
''  Start the sample application:-
''      ask for name, create tiles, compute form
''      dimensions then lay out tiles.
''  *** Interesting code modification in this procedure ***

n$ = InputBox$("Please input a name", "", "Geoffrey")
nc = Len(n$)


fw = form1.Width        ' INCORRECT !!!!
fh = form1.Height

'   divide form EXACTLY into NC squares each way
fw = form1.Width - lostframewidthintwips()
fh = form1.Height - lostframeheightintwips(True)
'   rem the preceeding two lines out and see what happens


intvlx = fw / nc         ' intervals
intvly = fh / nc
form1.FontSize = Tilefontsize


ReDim T(1 To nc, 1 To nc) As TILE
For r = 1 To nc
    For c = 1 To nc
        T(r, c).top = (r - 1) * intvly
        T(r, c).left = (c - 1) * intvlx
        T(r, c).bottom = (r) * intvly
        T(r, c).right = (c) * intvlx
        T(r, c).letter = Mid$(n$, 1 + (r + c - 2) Mod nc, 1)
        T(r, c).clr = QBColor(1 + ((r + c) Mod 15))
        Call showtile(r, c)
    Next c
Next r
End Sub

Sub showtile (r, c)
''  Show the tile in the gloabl array T()
''  R and C are row and column indeces
form1.DrawWidth = 1
Dim ti As TILE
ti = T(r, c)    ' current tile working var

Line (ti.left, ti.top)-(ti.right, ti.bottom), ti.clr, BF
Line (ti.left, ti.top)-(ti.right, ti.bottom), QBColor(0), B
lw = form1.TextWidth(ti.letter)
lh = form1.TextHeight(ti.letter)

form1.CurrentX = (ti.left + ti.right - lw) / 2
form1.CurrentY = (ti.top + ti.bottom - lh) / 2
form1.Print ti.letter;

End Sub

