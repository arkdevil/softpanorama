//////////////////////////////////////
// Object dbKit Classes definitions //
//////////////////////////////////////
// 0
// 1   object structure  definitions
#define O_OBJECT_CLASS 1                // индекс класса
#define O_OBJECT_DATA  2                // индекс данных
#define O_OBJECT_SIZE  0

// 2   class data definitions
#define O_CLASS_NUM   O_OBJECT_SIZE+1    // номер класса (Clipper)
#define O_CLASS_LEN   O_OBJECT_SIZE+2    // длина области данных
#define O_CLASS_METH  O_OBJECT_SIZE+3    // массив методов
#define   O_METH_SEL  1                  // подмассив селекторов
#define   O_METH_METH 2                  // подмассив методов
#define O_CLASS_ANC   O_OBJECT_SIZE+4    // родитель класса
#define O_CLASS_CHILD O_OBJECT_SIZE+5    // массив потомков
#define O_CLASS_KEEP  O_OBJECT_SIZE+6    // признак хранения экземпляров
#define O_CLASS_LIVE  O_OBJECT_SIZE+7    // массив живых экземпляров
#define O_CLASS_SIZE  O_CLASS_LIVE

