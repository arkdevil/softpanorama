{$S-,I-}

PROGRAM AIDSREST;

  uses dos, crt;

  procedure SoundCrackle(Hz: Word);
  var
    i: Integer;
  begin
    for i:= 1 to 40 do begin
      Sound(Hz);
      Delay(10);
      NoSound;
      Delay(50);
    end;
  end;

  procedure SoundPiu;
  var
    i: Integer;
  begin
    for i:= 500 downto 300 do begin
      Sound(i);
      Delay(1);
    end;
    NoSound;
  end;

  procedure ChangePaletteReg0(color: Byte);
  var
    r: Registers;
  begin
    r.ax:= $1000; { Set single palette register }
    r.bl:= 0;     { Palette register }
    r.bh:= color;
    intr($10, r); 
  end;

  procedure BlinkInRed;
  var
    i: Integer;
  begin
    for i:= 1 to 50 do begin
      ChangePaletteReg0($4 + $20);  { Red(4) + Secondary Red(0x20) }
      Delay(1);              { necessary for fast PC }
      ChangePaletteReg0(0);  { Black(0) }
    end;
  end;

BEGIN
  WriteLn;
  WriteLn('╔══════════════════════════════════╗');
  WriteLn('║    Научный центр  СП "Монолог"   ║');
  WriteLn('║     при ВЦ Академии наук СНГ     ║');
  WriteLn('║            АНТИВИРУС             ║');
  WriteLn('║      Веpсия 700 от 25.10.17      ║');
  WriteLn('║     (c) Copyright 1990, 1992     ║');
  WriteLn('║   Лозинский Дмитрий Николаевич   ║');
  WriteLn('║      Москва, (095) 137-01-84     ║');
  WriteLn('║ BBS (095)135-62-53 (20.00-20.05) ║');
  WriteLn('╚══════════════════════════════════╝');
  WriteLn;

  SoundCrackle(50);
  Write('В памяти вирус! ');
  Delay(700);
  Write('Ох, ну и гадкий... ');
  Delay(700);
  WriteLn('ОБЕЗВРЕЖЕН');

  SoundCrackle(50);
  Delay(700);
  Write('Вирус в блоке питания! Не прикасайтесь к корпусу! ');
  Delay(700);
  BlinkInRed;
  Delay(300);
  WriteLn('ОБЕЗВРЕЖЕН');

  SoundCrackle(100);
  Delay(700);
  Write('Вирус в загрузочном секторе! ');
  Delay(1000);
  Write('Ловим... ');
  SoundCrackle(150);
  WriteLn('убиваем!');
  SoundPiu;

  SoundCrackle(100);
  Write('C:\COMMAND.COM ');
  Delay(1500);
  Write(#13, 'В программе вирус!   ');
  Delay(2000);
  Write(#13, 'Или это не вирус ?   ');
  Delay(2000);
  Write(#13, 'Нет, кажется, вирус. ');
  Delay(2000);
  SoundPiu;
  Write(#13, 'ОБЕЗВРЕЖЕН           ');
  Delay(4000);
  WriteLn(#13, 'Или все-таки это был не вирус? ');

  SoundCrackle(50);
  Write('C:\IO.SYS');
  Delay(2000);
  Write(#13, 'На контроллер винчестера кто-то натянул презерватив... ');
  SoundCrackle(100);
  Write('неисправный...');
  Delay(2000);
  WriteLn(#13, 'Это все же очень редко помогает против компьютерных вирусов...       ');

  SoundCrackle(50);
  Write('C:\MSDOS.SYS');
  Delay(1500);
  WriteLn(#13, 'Странно. Нет вирусов.');

  Delay(2000);
  WriteLn(#13, 'Привет Лозинскому !!!');

  Delay(2000);
  WriteLn('Сейчас будет произведена перезагрузка системы.');
  Delay(2000);
  ClrScr;
  GotoXY(7, 23);
  Write('(C) American Megatrends Inc.,');
  GotoXY(12, 25);
  Write('SSUN-4343-054827-K0');
  GotoXY(1, 1);
  Write('286-BIOS  (C) 1987  American Megatrends Inc.');
  GotoXY(1, 5);
  Write('Press <DEL> if you want to run SETUP');

  Delay(6000);
  GotoXY(74, 25);
  Write('Шутка!');
  SoundCrackle(60);

  Delay(3000);
  ClrScr;
  WriteLn('AIDSREST  Программа-пародия  Версия 1.00');

  Halt(0);
END.
