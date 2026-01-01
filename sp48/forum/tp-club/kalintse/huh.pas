unit Huh;
interface

function HuhS: String;

implementation

const
  Msg01 = 'Eat sand.';
  Msg02 = 'Suck methanol.';
  Msg03 = 'Another cup of coffee ?';
  Msg04 = 'Never eat raw LSD baby.';
  Msg05 = 'If u''ll shown me how u could do that'#13^C'one thing will less to worry about.';
  Msg06 = 'Water in co-processor detected.';
  Msg07 = 'Cut off your fingers asshole.';
  Msg08 = 'Fucking drive C:, please standby...';
  Msg09 = 'Relax asshole, u dreaming !!';
  Msg10 = 'Cannot move head arm in drive A:'#13^C+'Rust detected. Call doctor.';
  Msg11 = 'Virus in mouse detected.'#13^C+'Reboot immediately !';
  Msg12 = 'Virus invasion on LPT3: !!!'#13^C'Check out your printer !';
  Msg13 = 'Hey! Here is not WC!'#13^C+'This IS COMPUTER - not a wash-stand.';
  Msg14 = 'Run out here and cry.';
  Msg15 = 'U loose that game, asshole!'#13^C+'Hah-hah-hah !!!';
  Msg16 = 'Wow! U''ve missed again...';
  Msg17 = 'Matches is not a toy baby.';
  Msg18 = 'Brick is crawling on a wall,'#13^C+'He''s Red Army warrior.'#13^C+
          'And another one next him -'#13^C+'That means their nest there.';
  Msg19 = 'Axe is swimming in a river'#13^C+'from the Zooevo village.'#13^C+
          'And so let him swim alone'#13^C+'We dont need that iron.';
  Msg20 = 'Dont waste your time and power,'#13^C+'take a big hammer and...'#13^C+
          '...and strike your oak head !!!';
  Msg21 = 'Bend over drive A: hole and say'#13^C+'in low voice what u want.';
  Msg22 = 'Take a keyboard and strike'#13^C+'your dumb head, fucker !';
  Msg23 = 'Push your mouse into your ass'#13^C+'and click right button';
  Msg24 = 'Please, dont worry.'#13^C+'I''ll format ALL your disks,'#13^C+'at nearest vacant time.';
  Msg25 = 'AC voltage critically low !'#13^C+'Push finger into power unit'#13^C+'and check voltage level!';
  Msg26 = 'Never study her pantyhose'#13^C+'while formatting anything !';
  Msg27 = 'Buy elephant.';
  Msg28 = 'BRU -- Starting tape 1 on MT0:';
  Msg29 = 'BRU -- Starting verify pass on MT0:';
  Msg30 = 'MCR -- Not logged in.';
  Msg31 = 'FMT -- Privileged command.';
  Msg32 = 'Nah. Better not.';
  Msg33 = 'Visit psychiatrist, please.';
  Msg34 = 'I hate moody guys like u.';
  Msg35 = 'Hey mop! Clean your eye with spirit'#13^C+'and read that message again';
  Msg36 = 'Push your finger into your ass'#13^C+'and press any key...';
  Msg37 = 'U are finished idiot.';
  Msg38 = 'I''m hungry! Insert HAMBURGER'#13^C+'into drive A: and press any key';
  Msg39 = 'Insert tractor toilet paper'#13^C+'into printer on LPT1:';
  Msg40 = 'Warning !'#13^C+'In drive A: are two diskettes.';
  Msg41 = 'Plug off your mouse!'#13^C+'Here is some cats.';
  Msg42 = 'Communist spy intervention!'#13^C+'Call CIA immediately !';
  Msg43 = 'Bad idea. Leave your comp alone and squat for 20 times.';
  Msg44 = 'No pain - no gain.';
  Msg45 = 'Your place is children-garden, little bastard !';
  Msg46 = '...with heart filled hatred black blood runs thru my veins...';
  Msg47 = 'U moving so fast so I cannot understand what u want.';
  Msg48 = 'If u want to see a Black Monkey, look at nearest mirror.';
  Msg49 = 'I''ll not be offended if your finger ''ll push right keys.';
  Msg50 = 'Take that fucker off my keyboard !';

function HuhS: String;
var
  A: Byte;

begin
  A := Random(50);
  case A of
     1: HuhS := Msg01;
     2: HuhS := Msg02;
     3: HuhS := Msg03;
     4: HuhS := Msg04;
     5: HuhS := Msg05;
     6: HuhS := Msg06;
     7: HuhS := Msg07;
     8: HuhS := Msg08;
     9: HuhS := Msg09;
    10: HuhS := Msg10;
    11: HuhS := Msg11;
    12: HuhS := Msg12;
    13: HuhS := Msg13;
    14: HuhS := Msg14;
    15: HuhS := Msg15;
    16: HuhS := Msg16;
    17: HuhS := Msg17;
    18: HuhS := Msg18;
    19: HuhS := Msg19;
    20: HuhS := Msg20;
    21: HuhS := Msg21;
    22: HuhS := Msg22;
    23: HuhS := Msg23;
    24: HuhS := Msg24;
    25: HuhS := Msg25;
    26: HuhS := Msg26;
    27: HuhS := Msg27;
    28: HuhS := Msg28;
    29: HuhS := Msg29;
    30: HuhS := Msg30;
    31: HuhS := Msg31;
    32: HuhS := Msg32;
    33: HuhS := Msg33;
    34: HuhS := Msg34;
    35: HuhS := Msg35;
    36: HuhS := Msg36;
    37: HuhS := Msg37;
    38: HuhS := Msg38;
    39: HuhS := Msg39;
    40: HuhS := Msg40;
    41: HuhS := Msg41;
    42: HuhS := Msg42;
    43: HuhS := Msg43;
    44: HuhS := Msg44;
    45: HuhS := Msg45;
    46: HuhS := Msg46;
    47: HuhS := Msg47;
    48: HuhS := Msg48;
    49: HuhS := Msg49;
  else HuhS := Msg50;
  end;
end;

begin
  Randomize;
end.

