UNIT Sounds;

INTERFACE
USES Crt;
PROCEDURE Beep;
PROCEDURE Bup;
PROCEDURE Blat;
PROCEDURE Tick;

IMPLEMENTATION
PROCEDURE Beep;
BEGIN Sound(800);  Delay(200); NoSound;  END;

PROCEDURE Bup;
BEGIN Sound(100);  Delay(100);  Sound(50); Delay(200); NoSound;  END;

PROCEDURE Blat;
VAR I:byte;
BEGIN
for I:=1 to 30 do
    begin sound(2*i+60); delay(15); end;
nosound;
end {blat};

PROCEDURE Tick;
BEGIN Sound(500); delay(10); nosound; END;

END {Unit Sounds}.