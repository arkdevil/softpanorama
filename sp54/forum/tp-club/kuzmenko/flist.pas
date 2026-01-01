{***************************************************************
*                                                              *
*               Dimarker's Software 1992                       *
*                                                              *
*                FileList objects                              *
*                                                              *
***************************************************************}

{$F+,N+,E+,O+,X+}

unit FList;

interface

uses Objects;

type
 PFRList = ^TFRList;
 TFRList = object(TStringCollection)
  procedure GetFiles(Mask: string);
  function GetFileName(Item: integer): string;
 end;

 PDRList = ^TDRList;
 TDRList = object(TStringCollection)
  procedure GetFiles(Mask: string);
  function GetFileName(Item: integer): string;
 end;

implementation

uses Dos;

 procedure TFRList.GetFiles(Mask: string);
  const
   FindAttr = ReadOnly + Archive;
  var
   S: SearchRec;
   Dir: DirStr;
   Name: NameStr;
   Ext: ExtStr;
  begin
   Mask := FExpand(Mask);
   FSplit(Mask, Dir, Name, Ext);
   FindFirst(Mask, FindAttr, S);
   while (DosError = 0) do
    begin
     if (S.Attr and Directory = 0) then
      begin
       Insert(NewStr(Dir+S.Name));
      end;
     FindNext(S);
    end;
  end;

 function TFRList.GetFileName(Item: integer): string;
  begin
   GetFileName:=PString(At(Item))^;
  end;

 procedure TDRList.GetFiles(Mask: string);
  var
   S: SearchRec;
   Dir: DirStr;
   Name: NameStr;
   Ext: ExtStr;
  begin
   Mask := FExpand(Mask);
   FSplit(Mask, Dir, Name, Ext);
   FindFirst(Mask, Directory, S);
   while (DosError = 0) do
    begin
     if (S.Attr and Directory <> 0) and (S.Name[1] <> '.') then
      begin
       Insert(NewStr(S.Name));
      end;
     FindNext(S);
    end;
  end;

 function TDRList.GetFileName(Item: integer): string;
  begin
   GetFileName:=PString(At(Item))^;
  end;

end.
