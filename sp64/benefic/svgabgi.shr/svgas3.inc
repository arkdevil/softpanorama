(************************************************)
(* 						*)
(*	  SuperVGA S3 BGI driver defines	*)
(*		Copyright (c) 1992		*)
(*	    Jordan Hargraphix Software		*)
(*						*)
(************************************************)

(* These are the currently supported modes *)
const
  SVGAS3_640x480x256	= 0;
  SVGAS3_800x600x256	= 1;
  SVGAS3_1024x768x256 	= 2;
  SVGAS3_800x600x16	= 3;
  SVGAS3_1024x768x16	= 4;
  SVGAS3_1280x960x16	= 5;
  SVGAS3_1280x1024x16	= 6;
  SVGAS3_640x480x32768	= 7;

function RGB(R,G,B : Word) : Word;
begin
  RGB := ((R and 31)SHL 10) OR ((G and 31)SHL 5) OR (B and 31);
end;

function RealDrawColor(Color : Word) : Word;
begin
  if (GetMaxColor > 256) then
    SetRgbPalette(1024,(Color SHR 10) AND 31,(Color SHR 5) AND 31,Color AND 31);
  RealDrawColor := Color;
end;

function RealFillColor(Color : Word) : Word;
begin
  if (GetMaxColor > 256) then
    SetRgbPalette(1025,(Color SHR 10) AND 31,(Color SHR 5)AND 31,Color AND 31);
  RealFillColor := Color;
end;

function RealColor(Color : Word) : Word;
begin
  if (GetMaxColor > 256) then
    SetRgbPalette(1026,(Color SHR 10) AND 31,(Color SHR 5)AND 31,Color AND 31);
  RealColor := Color;
end;
