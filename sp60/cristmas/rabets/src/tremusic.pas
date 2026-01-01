{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit TreMusic;  { Фоновая музыка }
                { Unit for ChristmasTree.  Edition 22-11-92.  V.S. Rabets }
interface

uses DOS, CRT,
     TreeGvar;
procedure Let_us_sing;

{ Автор выражает благодарность С.В. Колпаковой за неоценимую помощь,
  оказанную при создании данного модуля }
{----------------------------------------------------------}

implementation

const GooseMusicData =
                     #9't4l r'#10'o1' + { Header }
                      'f1e1d1c1g2 0g2 0f1e1d1c1g2 0g2 0' +    { Melody }
                      'f1a1 0a1f1e1g1 0g1e1d1e1f1d1c2 0c2 4'; { Melody }
      FirTreeMusicData =
             #9't6b$r0o1' + { Header }
               'c1a1a1g1a1f1c1c1c1a1a1b1g1O+c3' +
               'c1O-d1d1b1b1a1g1f1c1a1a1g1a1f2 1';

const Tone: array [1..12, 0..4] of word = (
 { octave:    0       1       2       3        4             }
 { C     } ( 131  ,  262  ,  523  ,  1040  ,  2093 ), { До   }
 { C#/Db } ( 139  ,  277  ,  554  ,  1103  ,  2217 ), {      }
 { D     } ( 147  ,  294  ,  587  ,  1176  ,  2349 ), { Ре   }
 { D#/Eb } ( 156  ,  311  ,  622  ,  1241  ,  2489 ), {      }
 { E     } ( 165  ,  330  ,  659  ,  1311  ,  2637 ), { Ми   }
 { F     } ( 175  ,  349  ,  698  ,  1391  ,  2794 ), { Фа   }
 { F#/Gb } ( 185  ,  370  ,  740  ,  1488  ,  2960 ), {      }
 { G     } ( 196  ,  392  ,  784  ,  1568  ,  3136 ), { Соль }
 { G#/Ab } ( 208  ,  415  ,  831  ,  1662  ,  3322 ), {      }
 { A     } ( 220  ,  440  ,  880  ,  1760  ,  3520 ), { Ля   }
 { A#/Bb } ( 233  ,  466  ,  932  ,  1866  ,  3729 ), {      }
 { B     } ( 248  ,  494  ,  988  ,  1973  ,  3951 ));{ Си   }

const PosInOctave: array ['A'..'G'] of byte = ( 10, 12, 1, 3, 5, 6, 8 );

const Octave: byte = 1;
      Rep: word = 0;
      CurRep: word = 0;
      Legato: boolean = false;
      Counter: byte = 2;
      T: longint = 0; { Next note time }
      D: byte = 9;   { Duration of 1, tick }
      MusicInProgress: boolean = false;
      { TickInDay = ???; }

var MusicSaveInt8: pointer;
    MusicData: string;

function Num: byte;
var n: byte;
begin
  N:= byte ( MusicData[ succ(Counter) ] );
  if char(N) in ['0'..'9'] then dec (N, byte('0'));
  Num:=N;
end;

procedure IncreaseCounter;
begin inc (Counter,2);
      if Counter > length(MusicData) then begin
         Counter:=1;
         if Rep<>0 then inc(CurRep);
         if CurRep>Rep then begin SetIntVec (8, MusicSaveInt8); nosound end;
      end;
end;

{$F+}
procedure BackGroundMusic; interrupt;
var N: char; { Note }
begin
  asm pushF
      call dword ptr MusicSaveInt8
      STI
  end;
  if MusicInProgress then exit;
  if T>=CurrentTime then exit;
  MusicInProgress:= true;
  if not Legato then nosound;
  N:=MusicData[Counter];
  if N='O' then
     begin case MusicData[succ(Counter)] of
                '+': inc(Octave);
                '-': dec(Octave);
                else Octave:=Num;
           end;
           IncreaseCounter; N:=MusicData[Counter];
     end;
  T:=CurrentTime + D*Num;
  if N=' ' then nosound else sound ( Tone[PosInOctave[N],Octave] );
  IncreaseCounter;
  MusicInProgress:= false;
end;
{$F-}
{-----------------------^BACKGROUND^---vINITv--------------}

procedure InitMusic;
var HeaderLength,
    b: byte;
begin
  for b:=1 to length(MusicData) do MusicData[b]:=UpCase(MusicData[b]);
  HeaderLength:=byte(MusicData[1]);
  while Counter<HeaderLength do begin
    case MusicData[Counter] of
         'O': Octave:=Num;
         'A'..'G': case MusicData[succ(Counter)] of
                        '#': inc( PosInOctave[ MusicData[Counter] ] );
                        '$': dec( PosInOctave[ MusicData[Counter] ] );
                   end;
         'L': legato:=true;
         'R': Rep:=Num;
         'T': D:=Num
    end;
    inc (Counter,2);
  end;
  delete (MusicData, 1, HeaderLength);
  Counter:=1;
end;

procedure Let_us_sing;
begin
   if not Music then exit;
  { if AltMelody then MusicData:=GooseMusicData else }
   MusicData:=FirTreeMusicData;
   InitMusic;
   GetIntVec (8, MusicSaveInt8);
   SetIntVec (8, @BackGroundMusic);
end;

end.
