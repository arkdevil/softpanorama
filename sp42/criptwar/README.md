```



 ..............                           ............                    ....
   ...       ..                            ...      ...                    ..
   ..         .                            ..        ..                    ..
   ..                                      ..        ..                    ..
   ..                                      ..        .                     ..
   ..        ..    .....   .....           ..        ...     .    ...      ..
  ......   ..  ..    ..     ..      .      .........  ........  ..   ..    ..
   ..     ..    ..    ..   ..        ..    ..         ..    .. ..     ..   ..
   ..     ..    ..     .. .   ...........  ..         ..     . ..     ..   ..
   ..     ..    ..      ..    ...........  ..         ..       ..  .. ..   ..
   ..     ..    ..     . ..          ..    ..         ..        ...   ..
   ..     ..    ..    ..  ..        .      ..         ..              ..
   ..      ..  ..    ..    ..              ..         ..        .    ..    ..
 ......      ..    .....   ....          ......      ....        ....      ..






   Пользователям FoxBASE и всем заинтеpесованным лицам !

   Иногда может быть интересно (необходимо) получить исходные тексты
программ  из псевдокомпилированных файлов  FoxBASE. Программа Fox2Prg!
позволит Вам это сделать. Она ретранслирует компилированные файлы
FoxBASE+ 2.00, FoxBASE+ 2.10, КАРАТ-М в программные файлы.

   Посмотрев демонстрационную версию ( Fox2Demo.exe ), Вы получите
практически полное представление о самой программе. DEMO - версия
генерирует только первые слова команд и имена переменных, стоящих в
левой части оператора присваивания. Но и сама программа Fox2Prg! уже
находится на Вашем диске !  Воспользоваться всеми ее возможностями,
Вы сможете выполнив следующие действия :

     1. Послать почтовым переводом 20 рублей по адресу :
     614105  г. Пермь - 105  п. Новые Ляды а/я 8359 Лобанову Александpу
     ( Автоp смеет надеется, что пеpвые же 5 минут реальной pаботы
     программы окупят Ваши затраты )

     2. Послать открытку по этому же адресу с Вашими координатами,
     указав номер квитанции почтового перевода.

     3.  После  получения  автором  денег  (смотри п.1.) и Вашего адреса
     (п.2.), Вам будет выслана открытка с паролем.

     4. Выполнив  программу PKUNZIP  с полученным паролем, Вы получите
     "заказанную" программу.

                               * * *

The file fox2prg.exe is 'stored' in the archive, i.e no compression used.
After examination of fox2demo.exe it can be assumed that fox2prg.exe is
also contain plain text string:
'PKLITE Copr. 1990 PKWARE Inc. All Rights Reserved'
embedded in the exe header.
Using btrack (https://github.com/kimci86/bkcrack):
$echo 'PKLITE Copr. 1990 PKWARE Inc. All Rights Reserved' > plain.txt
$./bkcrack -C FOX2PRG\!.ZIP -c FOX2PRG\!.EXE -p plain.txt -o 30
77.6 % (161996 / 208703)
[00:03:41] Keys
abf6d789 c378077f a38bf1c9

$tar tvf FOX2PRG\!.ZIP
-rw-rw-rw-  0 0      0       34866 Aug 15  1991 FOX2PRG!.EXE

The zip header size is 42 bytes, therefore the file size of fox2prg.exe
is 34866 + 12 for encryption header, so cipherfile size is 34878.
Extract cipherfile file from the zip archive:
$dd if=FOX2PRG\!.ZIP of=cipherfile bs=1 skip=42 count=34878

Decrypt fox2prg.exe:
$./bkcrack -c cipherfile -k abf6d789 c378077f a38bf1c9 -d fox2prg.exe
[01:01:48] Keys
abf6d789 c378077f a38bf1c9
Wrote deciphered text.
```
