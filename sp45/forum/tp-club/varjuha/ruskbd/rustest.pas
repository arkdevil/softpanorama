{====================================================================}
{                                                                    }
{             Copyright (c) 1992, 93 by Serge N. Varjukha            }
{                     Tallinn. Phone (0142) 666 500                  }
{                                                                    }
{====================================================================}
{ Module RusTest - Testing program for RusKbd and RusFont units.     }
{====================================================================}

{$X+}
uses
  RusKbd,
  RusFont;

begin
  LoadRusFont(ft8x16);
{  LoadFontFile('font8x16.fnt', 0, 16, 0); }
  Writeln('Press Left Alt to switch russian mode.');
  InstallRusKbd;
  Readln
end.
{eof rustest.pas}
