DefInt A-Z
Global Const twipsperinch = 1440    ' how many twips in one inch
Global Program_state%               ' 1=In progress (signal for stop/go button)
''  This is only a demo so don't worry about the
''  unfortunate proliferation of odd variables in
''  strange places getting up to curious things.
Type TILE
    Left As Integer
    top As Integer
    right As Integer
    bottom As Integer
    letter As String * 1    ' will be shown on face
    clr As Long             ' background colour
End Type
''  Tile is a bit like a scrabble tile with one letter on it.

Global Const Tilefontsize = 13      ' how big will letters be?

