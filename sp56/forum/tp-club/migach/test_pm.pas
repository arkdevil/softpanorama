
PROGRAM TestFont_PM;

USES Font_Pm;

VAR
   Key : BOOLEAN;

BEGIN
     PMLineList ( '    Проба шрифта печатающей машинки', Key );
     PMLineList ( '', Key );
     PMLineList ( '         (c)  I P M    Croup', Key );

END.
