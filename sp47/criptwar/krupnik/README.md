```
      Перед Вами графический редактор IMAGE 72 v.5.1.
Требования к аппаратуре и операционной системе: IBM PC XT/AT, 640 кб
памяти, DOS 3.3 и выше, адаптер EGA или VGA, принтер EPSON 9-ти или 24-х
игольчатый или HP LaserJet II, мышь.
      Эта программа распространяется как SHAREWARE. Разрешается свободное ко-
пирование при условии сохранения целостности материала и отсутствии коммер-
ческой выгоды. Чтобы стать зарегистрированным пользователем, необходимо выс-
лать автору 50 руб.
      Зарегистрированным пользователям автор обязуется сообщать о новых вер-
сиях IMAGE 72, новых шрифтах и программах, связанных с IMAGE 72.
      Среди файлов IMAGE 72 находится зашифрованный архив IMAGE.SEC. В нем со-
держится экранный сдиральщик IMGRAB.COM и 7 русских векторных шрифтов.
Архив зашифрован программой DISCREET из NU 6.0. Те, кто пришлет 100 рублей,не
только станут зарегистрированными пользователями, но и получат ключ к архиву.

Aвтор признателен Ю.И. Панкову за разрешение использовать в IMAGE 72 дисплей-
ные шрифты, опубликованные в СОВТПАНОРАМЕ 4.2.
Хочу поблагодарить С.В.Беляева за  русские векторные шрифты, а также за раз-
решение использовать экранный сдиральщик EGA4ARC.COM и вьюер EGA3VIEW.COM.
Наконец, я признателен В.И.Крамнику за полезные советы и разрешение использо-
вать русские векторные шрифты EURO и LCOM.

Адрес автора:

Российская Федерация, 603074, Н.НОВГОРОД, ул. Народная 38-443.
Крупнику Александру Борисовичу

тел.:    (831-2) 36-35-93(р)

                               * * *

The image.sec file is encrypted by Diskreet utility from Norton Utilities 6
package using proprietary encryption algorithm.
The cite from "Norton's [In]Diskreet" article by Peter Gutmann:
[..]
 How do we perform a known-plaintext attack?  It's quite simple actually, since
Diskreet itself provides us with about as much known plaintext as we need.  The
file format is:

    General header

    BYTE[ 16 ]          "ABCDEFGHENRIXYZ\0"
    char[ 13 ]          fileName
    LONG                fileDate
    BYTE                fileAttributes
    LONG                fileSize
    LONG                file data start
    BYTE[ 16 ]          0

    File data

    BYTE[ 32 ]          0

    Padding to make it a multiple of 512 bytes

Everything from the 16-byte magic value to the end of the file is encrypted in
blocks of 512 bytes.  The proprietary scheme will directly reveal its key
stream on the 16-byte check value, the 16 bytes of zeroes at the start, and the

32 bytes (minimum) of zeroes at the end of the data.
```
