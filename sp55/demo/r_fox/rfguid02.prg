set talk off
restore from R_FOX                    && Считать кодировочные таблицы 
restore from R_FOX_IC additive        && для индексирования
use DICT
set index to
delete tag all of DICT                && Очистить индексный файл
                                      && и переиндексировать
index on sys(15,R_FOX,WORD) tag NoIgnCase of DICT   && Регистрозависимый индекс
index on sys(15,R_FOX_IC,WORD) tag IgnCase of DICT  && Регистронезависимый индекс
use
do RFGUID01.PRG           && Выполнить пример N1.