unit Lists;

interface

type
  ItemPtr = ^Item;
  Item    = object
              Prev, Next : ItemPtr;
              constructor Init;
              procedure   Link(IP : ItemPtr);
              procedure   Unlink;
              procedure   ProcessItem; virtual;
              destructor  Done; virtual;
            end;

  ListPtr = ^List;
  List    = object(Item)
              Head : ItemPtr;
              CIP  : itemPtr;
              constructor Init;
              function    ListEmpty : boolean;
              function    AtHeadOfList : boolean;
              function    AtEndOfList  : boolean;
              function    CurrentItem  : ItemPtr;
              procedure   PrevItem;
              procedure   NextItem;
              procedure   ResetList;
              procedure   InsertItem(IP : ItemPtr);
              procedure   RemoveItem(IP : ItemPtr);
              procedure   ProcessItems; virtual;
              procedure   DisposeList; virtual;
              destructor  done; virtual;
            end;

implementation

constructor Item.Init;
begin
  Prev:=@Self;
  Next:=@Self
end;

procedure Item.Link(IP : ItemPtr);
begin
  Next:=IP;
  Prev:=IP^.Prev;
  IP^.Prev^.Next:=@Self;
  IP^.Prev:=@Self
end;

procedure Item.Unlink;
begin
  Prev^.Next:=Next;
  Next^.Prev:=Prev;
  Prev:=@Self;
  Next:=@Self
end;

procedure Item.ProcessItem;
begin
end;

destructor Item.Done;
begin
end;

constructor List.Init;
begin
  Head:=nil;
  CIP:=nil;
  Item.Init
end;

function List.ListEmpty;
begin
  ListEmpty:=(Head = nil)
end;

function List.AtHeadOfList;
begin
  AtHeadOfList:=(Head <> nil) and (CIP = Head)
end;

function List.AtEndOfList;
begin
  AtEndOfList:=(Head <> nil) and (CIP = Head^.Prev)
end;

function List.CurrentItem : ItemPtr;
begin
  CurrentItem:=CIP
end;

procedure List.PrevItem;
begin
  if CIP <> nil then
     CIP:=CIP^.Prev
end;

procedure List.NextItem;
begin
  if CIP <> nil then
     CIP:=CIP^.Next
end;

procedure List.ResetList;
begin
  CIP:=Head
end;

procedure List.InsertItem(IP : ItemPtr);
begin
  if IP <> nil then
     if Head = nil then
        begin
          Head:=IP;
          CIP:=IP
        end
     else
        IP^.Link(CIP)
end;

procedure List.ProcessItems;
begin
  CIP:=Head;
  if CIP <> nil then
     repeat
       CIP^.ProcessItem;
       NextItem
     until CIP = Head
end;

procedure List.RemoveItem(IP : ItemPtr);
begin
  if IP^.Next = IP then
     begin
       Head:=nil;
       CIP:=nil
     end
  else
     begin
       if IP = Head then
          Head:=Head^.Next;
       if CIP = IP then
          CIP:=CIP^.Next
     end;
  IP^.Unlink
end;

procedure List.DisposeList;
var
  IP : ItemPtr;
begin
  while not ListEmpty do
    begin
      IP:=CIP;
      RemoveItem(IP);
      if (Seg(IP^) <> DSeg) and (Seg(IP^) <> SSeg) then
         Dispose(IP, Done)
      else
         IP^.Done
    end
end;

destructor List.Done;
begin
  if Head <> nil then
     DisposeList;
  Item.Done
end;

end.


