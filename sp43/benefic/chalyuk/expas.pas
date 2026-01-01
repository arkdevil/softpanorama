
{╔════════════════════════════════════════════════════════════════════════════╗}
{║   ┌────────────────────────────────────────────────────────────────────┐   ║}
{║   │  ∙ JOHN (¤) ∙ Eugene Chalyuk, Kharkov Polytechnic Institute, USSR  │   ║}
{║   └────────────────────────────────────────────────────────────────────┘   ║}
{╠════════════════════════════════════════════════════════════════════════════╣}
{║ ░░░░░░░░░░░░░░░░░  This program was generated with UI-2  ░░░░░░░░░░░░░░░░░ ║}
{╟────────────────┬───────────────────────────────────────────────────────────╢}
{║                │                                                           ║}
{║ Input file     │ EXPAS.TEM                                                 ║}
{║ Output file    │ EXPAS.PRG                                                 ║}
{║ Date           │ October 1, 1991                                           ║}
{║ Time           │ 12:17:25                                                  ║}
{║                │                                                           ║}
{╚════════════════╧═══════════════════════════════════════════════════════════╝}
Program EXPAS;

uses TpCrt;

begin

{ ------------- Background screen --------------- }

   TextAttr:=$0F;
   ClrScr;

{ ------------- Box N 1 --------------- }

   FrameChars:='╔╚╗╝═║';
   FrameWindow(19,6,56,9,$3B,$3B,'');
   Window(20,7,55,8);
   TextAttr:=$3B;
   ClrScr;
   FastWrite('Как бы Вы такую пограмму      ║',7,26,$3B);
   FastWrite('написали вручную ?         ║',8,29,$3B);

{ ------------- Box N 2 --------------- }

   FrameChars:='╓╙╖╜─║';
   FrameWindow(10,12,70,22,$1C,$1C,'');
   Window(11,13,69,21);
   TextAttr:=$1C;
   ClrScr;
   FastWrite('║',13,70,$1C);
   FastWrite('║',14,70,$1C);
   FastWrite('║',15,70,$1C);
   FastWrite('║',16,70,$1C);
   FastWrite('║',17,70,$1C);
   FastWrite('║',18,70,$1C);
   FastWrite('║',19,70,$1C);
   FastWrite('║',20,70,$1C);
   FastWrite('║',21,70,$1C);
   FastWrite('┬',14,20,$1F);
   FastWrite('┬',14,25,$1F);
   FastWrite('┬─────',14,28,$1E);
   FastWrite('┬',14,36,$1B);
   FastWrite('┬',14,45,$1A);
   FastWrite('┌─────┐',14,55,$19);
   FastWrite('│',15,20,$1F);
   FastWrite('│',15,25,$1F);
   FastWrite('│',15,28,$1E);
   FastWrite('│',15,36,$1B);
   FastWrite('│',15,45,$1A);
   FastWrite('│',15,55,$19);
   FastWrite('│',15,61,$19);
   FastWrite('│',16,20,$1F);
   FastWrite('│',16,25,$1F);
   FastWrite('│',16,28,$1E);
   FastWrite('│',16,36,$1B);
   FastWrite('│',16,45,$1A);
   FastWrite('│',16,55,$19);
   FastWrite('│',16,61,$19);
   FastWrite('├────┤',17,20,$1F);
   FastWrite('├───┤',17,28,$1E);
   FastWrite('│',17,36,$1B);
   FastWrite('│',17,45,$1A);
   FastWrite('│',17,55,$19);
   FastWrite('│',17,61,$19);
   FastWrite('│',18,20,$1F);
   FastWrite('│',18,25,$1F);
   FastWrite('│',18,28,$1E);
   FastWrite('│',18,36,$1B);
   FastWrite('│',18,45,$1A);
   FastWrite('│',18,55,$19);
   FastWrite('│',18,61,$19);
   FastWrite('│',19,20,$1F);
   FastWrite('│',19,25,$1F);
   FastWrite('│',19,28,$1E);
   FastWrite('│',19,36,$1B);
   FastWrite('│',19,45,$1A);
   FastWrite('│',19,55,$19);
   FastWrite('│',19,61,$19);
   FastWrite('┴',20,20,$1F);
   FastWrite('┴',20,25,$1F);
   FastWrite('┴─────',20,28,$1E);
   FastWrite('┴─────┘',20,36,$1B);
   FastWrite('┴─────┘',20,45,$1A);
   FastWrite('└─────┘',20,55,$19);
end.
