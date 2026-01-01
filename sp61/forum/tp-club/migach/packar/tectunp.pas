
PROGRAM Tect_UnPackArray;

        { Тест распаковщика массивов }

USES Crt, PackAr;

VAR
   NameFl_S : STRING;
            { Имя исходного файла }

   NameFl_D : STRING;
            { Имя распакованного файла }

   Fl_S : FILE;
            { Упаковыванный файл }

   Fl_D : FILE;
            { Распакованный файл }

   Arr_S : BoxBytesPtr;
            { Указатель на упакованный массив }

   Arr_D : BoxBytesPtr;
            { Указатель на распакованный массив }

   Fact : WORD;
            { Размер распакованного массива }

BEGIN
      { Подготовка файлов }

     NameFl_S := PARAMSTR ( 1 );
     IF ( NameFl_S = '' ) THEN
        BEGIN
             WRITELN ( 'Задайте имя упакованного файла в качестве' );
             WRITELN ( 'первого параметра ' );
             HALT ( 1 )
        END;
     NameFl_D := PARAMSTR ( 2 );
     IF ( NameFl_D = '' ) THEN
        BEGIN
             WRITELN ( 'Задайте имя распакованного файла в качестве' );
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
             WRITELN ( 'Ошибка создания распакованного файла' );
             HALT ( 1 )
        END;
     IF ( FILESIZE ( Fl_S ) > $FFFE ) THEN
        BEGIN
             WRITELN ( 'Максимальная длина исходного файла 64 Кбайт' );
             HALT ( 1 )
        END;

     GETMEM ( Arr_D, $FFFE );
     GETMEM ( Arr_S, FILESIZE ( Fl_S ) );

     BLOCKREAD ( Fl_S, Arr_S^, FILESIZE ( Fl_S ) );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка чтения файла' );
             HALT ( 1 )
        END;

     UnPackArray ( Arr_D, Fact , Arr_S, FILESIZE ( Fl_S )  );

     BLOCKWRITE ( Fl_D, Arr_D^, Fact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка записи' );
             HALT ( 1 )
        END;

     FREEMEM ( Arr_S, FILESIZE ( Fl_S ) );
     FREEMEM ( Arr_D, $FFFE );

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

     WRITELN ( 'Успешная распаковка !!!' );

END.