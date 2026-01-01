uses
  Lists,

   . . .

var
  ItemList : ListPtr;
  i   : byte;
  VIP : VisualItemPtr;

begin

   . . .

  i:=1;
  with ItemList^ do
    begin
      ResetList;
      while (i <= TotalRows) and not AtEndOfList do
        begin
          VIP:=VisualItemPtr(CurrentItem);
          VIP^.Show(1, i, TotalCols, TextAttr);
          NextItem;
          Inc(i)
        end
    end;

     . . .

end.
