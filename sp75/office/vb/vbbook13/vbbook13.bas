Type Flags                   'Misc flag variables
  CurDate As Integer
  DoHeader As Integer
  FileTitle As Integer
  Linelen As Integer
  LineWrap As Integer
  PgNumber As Integer
  tempmrg As Integer          'right side left margin
End Type

'Used to tell how much memory we have
Declare Function GetFreeSpace Lib "Kernel" (ByVal wFlags As Integer) As Long


