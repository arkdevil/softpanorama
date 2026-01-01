#include "classes.ch"
#include "oop.ch"
/*
***********************************
* класс Class                     *
***********************************
Функции класса:           Методы класса:
  getclass()
  new()

Переменные класса:
[1] O_CLASS_NUM  - номер класса [Clipper]
[2] O_CLASS_LEN  - размер данных класса
[4] O_CLASS_METH - массив методов класса:
                    1 эл. подмассива - имя селектора
                    2 эл. подмассива - имя метода
[5] O_CLASS_ANC    - ссылка на родителя
[6] O_CLASS_CHILD  - массив потомков класса
[7] O_CLASS_KEEP   - признак запоминания экземпляров
[3] O_CLASS_LIVE - массив живых экземпляров класса
*/

static  Object,sClass:=NIL


/*** Конструктор класса
   oClass:=classnew("Имя класса",["Имя родителя"],["Размер области данных"],[<Помнящий>])
*/
function classnew(pName,pAnc,pLen,pKeep)
  local i,oClass,oAnc
  default pLen to 0,;
          pKeep to FALSE

  // Блок инициализации класса классов и класса объектов
********************************************************
  if sClass==NIL                                  // если еще не создан
    // Создание и инициализация класса классов
    sClass:=__classnew("Class",2)                 // создать Clipper-класс
    __classadd(sClass,"ADDMETHOD","CLADDMETHOD")  // определить метод
                                                 // добавления методов

   // Создать первый класс-объект и поместить в него себя (класс классов)
   oClass:=__classIns(sClass)                     // создать класс-объект себя
   oClass[O_OBJECT_CLASS]:=oClass                // класс - сам
   oClass[O_OBJECT_DATA]:=array(O_CLASS_SIZE)
   oClass[O_OBJECT_DATA][O_CLASS_NUM]:= sClass    // Clipper-номер класса
   oClass[O_OBJECT_DATA][O_CLASS_LIVE]:={oClass} // Первый экземпляр - свой
   oClass[O_OBJECT_DATA][O_CLASS_CHILD]:={}        // детей нет
   oClass[O_OBJECT_DATA][O_CLASS_METH]:={{"AddMethod","clAddMethod"}}
   sClass:=oClass ; oClass:=NIL // Перебросим ссылки

    // добавить оставшиеся методы
    sclass:addmethod("AddVar","clAddVar")
    sclass:addmethod("AllMethods","clAllMeth")
    sclass:addmethod("Method","clMethod")
    sclass:addmethod("MethodCount","clMethCount")
    sclass:addmethod("GetMethod","clGetMethod")
    sclass:addmethod("CopyMethods","clCopyMethods")
    sclass:addmethod("AllChildren","clAllChild")
    sclass:addmethod("Child","clChild")
    sclass:addmethod("ChildCount","clChildCount")
    sclass:addmethod("AllInstances","clAllIns")
    sclass:addmethod("Instance","clInstance")
    sclass:addmethod("InsCount","clInsCount")
    sclass:addmethod("New","clNew")
    sclass:addmethod("Done","clDone")
    sclass:addmethod("Name","clName")

    sclass:addvar("Number","clNumber")
    sclass:addvar("Len","clLen")
    sclass:addvar("Keep","clKeep")
    sclass:addvar("Ancestor","clAncestor")

   sClass:Len := O_CLASS_SIZE
   sClass:Keep:= TRUE


    // Создать класс-объект Object уже используя методы Class
    class Object size O_OBJECT_SIZE ;
       methods ;
          Init       is objInit,;
          Done       is objDone,;
          Copy       is objCopy,;
          CopyShare  is objCopyShare,;
          Class      is objClass,;
          isKindOf   is objisKindOf,;
          isMemberOf is objisMemberOf,;
          respondsTo is objResponds,;
          Size       is objSize

    // Сделать класс классов потомком класса объектов
    sClass:copyMethods(Object)
    sClass:ancestor := Object
    aadd(object[O_OBJECT_DATA][O_CLASS_CHILD],sClass)
  endif

***************************************************
   // продолжим создание класс-объекта
   // создается новый класс-объект
   oClass:=sclass:new(sClass)
   oClass:Number:=__classNew(pName,2)
   oClass:Len:= pLen
   oClass:Keep:= pKeep
   oClass[O_OBJECT_DATA][O_CLASS_LIVE]:={}             // живые экземпляры
   oClass[O_OBJECT_DATA][O_CLASS_METH]:={}             // методы
   oClass[O_OBJECT_DATA][O_CLASS_CHILD]:={}            // потомки
   if pAnc<>NIL                      // затребовано наследование
      oAnc:=getclass(pAnc)           // найти родителя
      if oAnc<>NIL
        oClass:ancestor:=oAnc        // занести ссылку на родителя
        oClass:copyMethods(oAnc)     // копировать методы
        aadd(oAnc[O_OBJECT_DATA][O_CLASS_CHILD],oClass)
      else                           // ошибка - родителя нет
      endif
   endif
   return oClass                     // и вернуть его же


****** Методы класса Class ******************************************
/**/
//constructor clInit with pName,pLen
//     self:number:=__classNew(pName,2)
//     self:len:= pLen
//     selfdata[O_CLASS_LIVE]:={}             // живые экземпляры
//     selfdata[O_CLASS_METH]:={}             // методы
//     selfdata[O_CLASS_CHILD]:={}            // потомки
//end_constructor

/**/
destructor clDone
  local i,oAnc:=self:ancestor
  // Убить всех потомков
  if self:childCount>0
     for i:=1 to self:childCount
        self:child(i):done()
     next
  endif
  // убить все свои экземпляры
  if self:insCount>0
     for i:=1 to self:insCount()
        self:instance(i):done()
     next
  endif
  // удалить себя из родителя
  if !empty(oAnc)
     i:=ascan(oAnc:allChildren,self)
     if i<>0
        aTrueDel(oAnc:allChildren,i)
     endif
  endif
end_destructor

/*** Добавление методов в класс
   oClass:addMethod("Имя селектора","Имя метода")
*/
method clAddMethod with pSel,pMeth
   if pSel<>NIL
     __classadd(selfdata[O_CLASS_NUM],pSel,pMeth)      // добавить в методы Clipper
     aadd(selfdata[O_CLASS_METH],{upper(pSel),upper(pMeth)})
   endif

/*** Добавление переменных в класс 
   oClass:addVar("Имя переменной"[,"Имя функции-обработчика"])
*/
method clAddVar with pName,pImpl
   if pName<>NIL
     self:addMethod(pName,pImpl)
     self:addMethod("_"+pName,pImpl)
   endif

/**/
rvmethod clAllChild with O_CLASS_CHILD

/**/
fmethod clChild with Number
   return (selfdata[O_CLASS_CHILD][Number])

/**/
fmethod clChildCount
   return (len(selfdata[O_CLASS_CHILD]))

/**/
rvmethod clAllIns with O_CLASS_LIVE

/**/
rvmethod clAllMeth with O_CLASS_METH

/**/
fmethod clMethod with Number
  return (selfdata[O_CLASS_METH][Number])

/**/
fmethod clMethCount
  return (len(selfdata[O_CLASS_METH]))

/* Копирование всех верхних методов из класса */
method clCopyMethods with oAnc
   local aMeth:=oAnc[O_OBJECT_DATA][O_CLASS_METH],i
   if oAnc:ancestor<>NIL
      self:copymethods(oAnc:ancestor)
   endif
   for i:=1 to len(aMeth)   // занести все методы и перем.
     __classadd(selfdata[O_CLASS_NUM],aMeth[i][1], aMeth[i][2] )
//     self:addMethod( aMeth[i][1], aMeth[i][2] )
   next

/* */
fmethod clInsCount
   return (len(selfdata[O_CLASS_LIVE]))

/* */
fmethod clInstance with number
   return (selfdata[O_CLASS_LIVE][number])

/**/
fmethod clGetMethod with cSelector
   local oClass:=self,cMeth:="",xSelector:=upper(cSelector),i
   i:=ascan(oClass:allMethods(),{|x| x[1]==xSelector}) // есть такой?
   if i <= 0
      while oClass:ancestor<>NIL
        oClass:=oClass:ancestor
        i:=ascan(oClass:allMethods(),{|x| x[1]==xSelector})
        if i > 0
           exit
        endif
      end
   endif
   if i > 0
      cMeth:=oClass:method(i)[2]
   endif
   return (cMeth)

/***
   Метод - создание экземпляра объекта
   oObject:=oClass:new()
*/
fmethod clNew
   local oObject
   oObject:=__classIns(self:number)  // создать экземпляр
   oObject[1]:=self                            // 1 элемент - ссылка на класс
   oObject[2]:=array(self:len)
   aadd(selfdata[O_CLASS_LIVE],oObject)        // список экземпляров
   return oObject

/* */
fmethod clName
 return __className(self:number)

vmethod clNumber with O_CLASS_NUM

vmethod clLen with O_CLASS_LEN

vmethod clKeep with O_CLASS_KEEP

vmethod clAncestor with O_CLASS_ANC

*** Методы класса Object ************************************
constructor objInit
end_constructor

destructor objDone
end_destructor

/**/
fmethod objClass
   return self[O_OBJECT_CLASS]

/**/
fmethod objCopyShare
   local obj:=(self:class()):new()
   assign obj:=self
   return obj

/**/
fmethod objCopy
   local obj:=(self:class()):new()
   obj[O_OBJECT_DATA] := aclone(selfdata)
   return obj

/**/
fmethod objisMemberOf with cClass
   local oClass:=getclass(cClass),lRet:=FALSE
   if oClass<>NIL
      if (self:class()==oClass)
         lRet:=TRUE
      endif
   endif
   return lRet

/**/
fmethod objisKindOf with cClass
   local oClass:=getclass(cClass),lRet:=FALSE,selfclass:=self:class
   if oClass<>NIL
      if (selfclass==oClass)
         lRet:=TRUE
      else
         while selfclass:ancestor<>NIL
           if selfclass:ancestor==oClass
              lRet:=TRUE
              exit
           else
              selfclass:=selfclass:ancestor
           endif
         end
      endif
   endif
   return lRet

/**/
fmethod objResponds with cSelector
   local oClass:=self:class(),lRet:=FALSE,xSelector:=upper(cSelector)
   if (ascan(oClass:allMethods(),{|x| x[1]==xSelector}) > 0 )
      lRet:=TRUE
   else
      while oClass:ancestor<>NIL
        oClass:=oClass:ancestor
        if (ascan(oClass:allMethods(),{|x| x[1]==xSelector}) > 0 )
           lRet:=TRUE
           exit
        endif
      end
   endif
   return lRet


*** Прочие функции ******************************************
/* пустая функция */
function FNIL()
  return NIL

/*** функция - Поиск класса в массиве по имени
   oClass:=getclass("Имя класса")
*/
function getclass(pName)
  local i:=ascan(sclass:AllInstances(),;
           {|x| x:name==upper(pName)})
    return if(i<=0,NIL,sclass:instance(i))

/***
   Функция - Создание экземпляра и вызов конструктора
    oObject:=new("имя класса")
*/
function NEW(pName,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
  local oObject,oClass
  oClass:=getclass(pName)   // искать класс в массиве
  if oClass<>NIL
     oObject:=oClass:new()  // если найден - вызов метода-конструктора
     oObject:init(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
  else
     oObject:=NIL
  endif
  return oObject

* Eof o1.prg
