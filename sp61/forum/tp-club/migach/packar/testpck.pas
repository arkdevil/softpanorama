
PROGRAM Tect_PackArray;

        { Тест упаковщика массивов }

USES Crt, PackAr;

VAR
   NameFl_S : STRING;
            { Имя исходного файла }

   NameFl_D : STRING;
            { Имя упакованного файла }

   Fl_S : FILE;
            { Упаковываемый файл }

   Fl_D : FILE;
            { Упакованный файл }

   Arr_S : BoxBytesPtr;
            { Указатель на упаковываемый массив }

   Arr_D : BoxBytesPtr;
            { Указатель на упакованный массив }

   Fact : WORD;
            { Размер упакованного массива }

   UnSize : WORD; { Размер исходного массива }

BEGIN
      { Подготовка файлов }

     NameFl_S := PARAMSTR ( 1 );
     IF ( NameFl_S = '' ) THEN
        BEGIN
             WRITELN ( 'Задайте имя упаковываемого файла в качестве' );
             WRITELN ( 'первого параметра ' );
             HALT ( 1 )
        END;
     NameFl_D := PARAMSTR ( 2 );
     IF ( NameFl_D = '' ) THEN
        BEGIN
             WRITELN ( 'Задайте имя упакованного файла в качестве' );
             WRITELN ( 'второго параметра ' );
             HALT ( 1 )
        END;
     ASSIGN ( Fl_S, NameFl_S );
     ASSIGN ( Fl_D, NameFl_D );
     RESET ( Fl_S, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Нет исходного файла на диске' );
             HALT ( 1 )
        END;
     REWRITE ( Fl_D, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка создания упакованного файла' );
             HALT ( 1 )
        END;
     IF ( FILESIZE ( Fl_S ) > $FFFE ) THEN
        BEGIN
             WRITELN ( 'Максимальная длина исходного файла 64 Кбайт' );
             HALT ( 1 )
        END;

     UnSize := FILESIZE ( Fl_S );
     GETMEM ( Arr_S, UnSize );
     GETMEM ( Arr_D, UnSize );

     BLOCKREAD ( Fl_S, Arr_S^, UnSize );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка чтения файла' );
             HALT ( 1 )
        END;

     PackArray ( Arr_S, UnSize, Arr_D, Fact );

     BLOCKWRITE ( Fl_D, Arr_D^, Fact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка записи' );
             HALT ( 1 )
        END;

     FREEMEM ( Arr_S, UnSize );
     FREEMEM ( Arr_D, UnSize );

     CLOSE ( Fl_S );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка закрытия исходного файла' );
             HALT ( 1 )
        END;

     CLOSE ( Fl_D );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка закрытия упакованного файла' );
             HALT ( 1 )
        END;

     WRITELN ( 'Успешная упаковка !!!' );
     WRITELN ( 'Осталось после упаковки - ',
               Fact / ( UnSize / 100.0 ) : 5 : 2, ' %' )

END.