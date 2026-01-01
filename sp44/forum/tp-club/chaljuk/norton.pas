{╔════════════════════════════════════════════════════════════════════════════╗}
{║   ┌────────────────────────────────────────────────────────────────────┐   ║}
{║   │  ∙ JOHN (¤) ∙ Eugene Chalyuk, Kharkov Polytechnic Institute, USSR  │   ║}
{║   └────────────────────────────────────────────────────────────────────┘   ║}
{╠════════════════════════════════════════════════════════════════════════════╣}
{║ ░░░░░░░░░░░░░░░░░  This program was generated with JGen  ░░░░░░░░░░░░░░░░░ ║}
{╟────────────────┬───────────────────────────────────────────────────────────╢}
{║                │                                                           ║}
{║ Input file     │ norton.001                                                ║}
{║ Output file    │ norton.ppp                                                ║}
{║ Date           │ 30/09/1991                                                ║}
{║ Time           │ 22:19:23                                                  ║}
{║                │                                                           ║}
{╚════════════════╧═══════════════════════════════════════════════════════════╝}
uses CRT;

procedure FastWrite(Str : string; Row,Col,Attr : byte); 

var
   SaveAttr : byte;

begin {FastWrite}

   SaveAttr:=TextAttr;
   TextAttr:=Attr;
   GoToXY(Col,Row);
   Write(Str);
   TextAttr:=SaveAttr;

end;  {FastWrite}

begin
   TextBackground(1);
   Clrscr;

   FastWrite('╔═══════ E:\JOHN\PAS\PROJ\SEDIT ═══════╗╔═══════',  1,  1,$1B);
   FastWrite(' E:\JOHN\SOFTPAN\SCRINF ',  1, 49,$30);
   FastWrite('═══════╗',  1, 73,$1B);
   FastWrite('║',  2,  1,$1B);
   FastWrite('Name',  2,  6,$1E);
   FastWrite('│',  2, 14,$1B);
   FastWrite('Name',  2, 19,$1E);
   FastWrite('│',  2, 27,$1B);
   FastWrite('Name',  2, 32,$1E);
   FastWrite('║║',  2, 40,$1B);
   FastWrite('Name',  2, 46,$1E);
   FastWrite('│',  2, 54,$1B);
   FastWrite('Name',  2, 59,$1E);
   FastWrite('│',  2, 67,$1B);
   FastWrite('Name',  2, 72,$1E);
   FastWrite('║',  2, 80,$1B);
   FastWrite('║..          │            │            ║║..          │            │            ║',  3,  1,$1B);
   FastWrite('║SCRINF      │            │            ║║jgen     exe│            │            ║',  4,  1,$1B);
   FastWrite('║VIEWER      │            │            ║║',  5,  1,$1B);
   FastWrite('jsaver   exe',  5, 42,$30);
   FastWrite('│            │            ║',  5, 54,$1B);
   FastWrite('║SAVER       │            │            ║║jviewer  exe│            │            ║',  6,  1,$1B);
   FastWrite('║GENSCR      │            │            ║║scrinf   exe│            │            ║',  7,  1,$1B);
   FastWrite('║sedit    lzh│            │            ║║jviewer  pas│            │            ║',  8,  1,$1B);
   FastWrite('║dirinfo     │            │            ║║scrinf   pas│            │            ║',  9,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 10,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 11,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 12,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 13,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 14,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 15,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 16,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 17,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 18,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 19,  1,$1B);
   FastWrite('║            │            │            ║║            │            │            ║', 20,  1,$1B);
   FastWrite('╟────────────┴────────────┴────────────╢╟────────────┴────────────┴────────────╢', 21,  1,$1B);
   FastWrite('║SCRINF       '#16'SUB-DIR'#17' 12-07-90  5:01p║║jsaver.exe       17408  9-28-91  4:10p║', 22,  1,$1B);
   FastWrite('╚══════════════════════════════════════╝╚══════════════════════════════════════╝', 23,  1,$1B);
   FastWrite('E:\JOHN\SOFTPAN\SCRINF>                                                         ', 24,  1,$07);
   FastWrite('1', 25,  1,$07);
   FastWrite('Left  ', 25,  2,$30);
   FastWrite(' 2', 25,  8,$07);
   FastWrite('Right ', 25, 10,$30);
   FastWrite(' 3', 25, 16,$07);
   FastWrite('View..', 25, 18,$30);
   FastWrite(' 4', 25, 24,$07);
   FastWrite('Edit..', 25, 26,$30);
   FastWrite(' 5', 25, 32,$07);
   FastWrite('      ', 25, 34,$30);
   FastWrite(' 6', 25, 40,$07);
   FastWrite('      ', 25, 42,$30);
   FastWrite(' 7', 25, 48,$07);
   FastWrite('Find  ', 25, 50,$30);
   FastWrite(' 8', 25, 56,$07);
   FastWrite('Histry', 25, 58,$30);
   FastWrite(' 9', 25, 64,$07);
   FastWrite('EGA Ln', 25, 66,$30);
   FastWrite(' 10', 25, 72,$07);
   FastWrite('Tree  ', 25, 75,$30);
{ - - - - - - - - -  конец генерации - - - - - - - }
end.
