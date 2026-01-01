Uses Dos;
const
  mon : array [1..12] of String[3] =
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
var
  f: text;
  filename, yr, dr, Mess: string;
  I, y, m, d, dow : Word;

Begin
  WriteLn('Create File, The KN Programs, Copyright (C) May 1992, Nikita E.Korzun (KN)');
  WriteLn('             Version 3.0, Last Edition 05/05/92');
  WriteLn;
  GetDate(y,m,d,dow);
  Str(y,yr);
  Str(d,dr);
  Filename := dr + '_' + mon[m] + '.' + copy(yr,3,2);
  Assign(f,filename);
  Rewrite(f);
  Close(f);
End.
