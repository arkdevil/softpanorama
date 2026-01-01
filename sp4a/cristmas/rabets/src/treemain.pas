{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit TreeMain;  { Детализация ChristmasTree }
                { Unit for ChristmasTree.  Edition 21-11-92.  V.S. Rabets }
interface

uses DOS, CRT,
     MainUtil, TreeUtil, TreeGvar;

procedure V_lesu;
procedure rodilas_yolochka;
procedure V_lesu_ona_rosla;
procedure Zimoy_i_letom_stroynaya__Zelyonaya_byla;
procedure Metel_ey_pela_pesenku__Spi_yolochka_Bye_Bye;
procedure Moroz_snezhkom_ukutyval__Smotry_ne_zasypay;
procedure I_vot_ona_naryadnaya;
procedure Na_prazdnik_k_nam_prishla;
procedure I_mnogo_mnogo_radosty__Detishkam_prinesla;
procedure The;


implementation

procedure V_lesu;
begin
  Sky;
  SkyLine;
  Forest;
  Hut;
  KeyOrTimePause (PauseBetweenEvents);
end;

procedure rodilas_yolochka;
begin
  FirTree (450,310, 24, 6,2, 1);
  KeyOrTimePause (PauseBetweenEvents);
end;

procedure V_lesu_ona_rosla;
var b: byte;
begin
  for b:=2 to 20 do
  FirTree (450,130+b*10, b*10, 6,1, 1);
end;

procedure Zimoy_i_letom_stroynaya__Zelyonaya_byla;
begin
  FirTree (450,330, 200, 6,2, 1);
  KeyOrTimePause (PauseBetweenEvents);
end;

procedure Metel_ey_pela_pesenku__Spi_yolochka_Bye_Bye;
begin
   TurnOffStars;
  OpenStorm;
  MoveStorm;
  CloseStorm;
   TurnOnStars;
   KeyOrTimePause (PauseBetweenEvents);
end;

procedure Moroz_snezhkom_ukutyval__Smotry_ne_zasypay;
begin
  OpenSnow;
   TurnOffStars;
  MoveSnow;
   LightStars;
  CloseSnow;
   KeyOrTimePause (PauseBetweenEvents);
end;

procedure I_vot_ona_naryadnaya;
begin
  MakeSpheres;
   KeyOrTimePause (0);
  MakeChains;
   KeyOrTimePause (PauseBetweenEvents);
end;

procedure Na_prazdnik_k_nam_prishla;
begin
  Wind (StarColor);
  RotateFirTree;
end;

procedure I_mnogo_mnogo_radosty__Detishkam_prinesla;
begin
  SwapPalette;
  RotateFirTree;
end;

procedure The;
var b: byte;
begin
  for b:=15 downto 1 do
  begin
      SetOnePaletteRegister (b, 32+16+8 {rl+gl+bl});
      delay (TurnOffPictureDuration div 16);
      if KeyPressed then b:=1;
  end;
end;

end.
