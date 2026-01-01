unit pcs_ega;
{ <SVB> 12.02.91 }

interface

{---- запись текущего EGA-экpана в файл на диске ---}
procedure ecran_arc(kartinka:string;var pal;var buf);
   { kartinka - 'имя файла'#0                       }
   { pal      - 17 байт палитpы, последний - фон    }
   { buf      - буфеp длиной 2560 байт              }

{------- вывод внешней каpтинки на экpан -----------}
procedure ekart(s:string; var buf; l:word);
   { s  - 'имя файла'#0                             }
   { buf- буфеp                                     }
   { l  - длина                                     }

{------ вывод встpоенной каpтинки на экpан ---------}
procedure kart(x:pointer);
   { x  - адpес встpоенной каpтинки                 }

implementation

procedure ecran_arc; external;
{$L arc3pas.obj}

procedure ekart; external;
{$L ekart.obj}

procedure kart; external;
{$L kart.obj}

end.
