// Object dbKit preprocessor definitions file

// 1   Symbolic constants
#define         TRUE                    .t.
#define         FALSE                   .f.
#define         ON                      .t.
#define         OFF                     .f.

// 2   Additional language constructions:
// 2.1 repeat ... until construction
#xcommand REPEAT => WHILE(.t.)
#xcommand UNTIL <expr> => if (<expr>); exit; endif; end

// 2.2 for ... do construction
#xcommand FOR <i>:=<s> TO <n> DO <*statement*> =>;
         FOR <i>:=<s> TO <n> ; <statement> ; END

// 2.3 if ... then construction
#xcommand if <cond> then <*statement*>  =>  if <cond> ; <statement>; endif

// 2.5 default ... to construction
#command DEFAULT <p> TO <v> [, <p2> TO <v2> ] => ;
                 <p> := IF(<p> == NIL, <v>, <p>) ;
                 [; <p2> := IF (<p2> == NIL, <v2>, <p2>) ]


// 4   Object & method functions
// 4.1 Extract method caller object: self()->object
#xtranslate self() => QSELF()
// 4.2 Extract method caller object data: selfdata()->array
#xtranslate selfdata()        => qself()\[O_OBJECT_DATA\]
// 4.3 Extract method caller class: selfclass()->oClass
#xtranslate selfclass()       => qself()\[O_OBJECT_CLASS\]
// 4.4 Extract method caller ancestor: selfanc()->oClass
#xtranslate selfanc()         => qself()\[O_OBJECT_CLASS\]\[O_OBJECT_DATA\]\[O_CLASS_ANC\]
// 4.5 Assign object data: assign oObject1 := oObject2
#xcommand   assign <x> := <y> => <x>\[O_OBJECT_DATA\] := <y>\[O_OBJECT_DATA\]
// 4.6 Extract object ancestor: ancestor(<x>)->oClass
#xtranslate ancestor(<x>)     => <x>\[O_OBJECT_CLASS\]\[O_OBJECT_DATA\]\[O_CLASS_ANC\]
// 4.7 Extract object class: class(<x>)->oClass
#xtranslate class(<x>) => <x>\[O_OBJECT_CLASS\]

// 5   Object operations
// 5.1 Create new class
#command CLASS <classname> ;
         [ ANCESTOR <anc> ] ;
         [ SIZE <size> ] ;
         [ <keep:KEEP> ] ;
         [ VARIABLES <v1> IS <w1> [,<vN> IS <wN> ] ] ;
         [ METHODS <m1> IS <p1> [, <mN> IS <pN> ] ] => ;
         <classname>:=classnew(<"classname">,[<"anc">],[<size>],[<.keep.>]) ;
         [ ;<classname>:addvar(<"v1">,<"w1">) ]   ;
         [ ;<classname>:addvar(<"vN">,<"wN">) ]   ;
         [ ;<classname>:addmethod(<"m1">,<"p1">) ] ;
         [ ;<classname>:addmethod(<"mN">,<"pN">) ]

// 5.2 Create new object
#xcommand NEW <object> OF <class> [WITH <list,...>]=>;
       <object>:=new(<"class">,<list>)

// 5.3 Describe method
#xcommand METHOD <name> [WITH <list,...>] =>;
    procedure <name>([<list>]) ;;
    local self:=self(),selfData:=selfdata()

// 5.4 Describe function method
#xcommand FMETHOD <name> [WITH <list,...>] =>;
    function <name>([<list>]) ;;
    local self:=self(),selfData:=selfdata()

// 5.5 Describe variable method
#xcommand VMETHOD <name> WITH <list,...> => ;
    function <name>(xData) ;;
    local selfdata:=selfdata() ;;
    return if(xData<>NIL,selfData\[<list>\]:=xData,selfData\[<list>\])

// 5.5 Describe read-only variable method
#xcommand RVMETHOD <name> WITH <list,...> => ;
    function <name>() ;;
    return (selfData()\[<list>\])

// 5.6 Describe constructor
#command CONSTRUCTOR <name> [WITH <list,...>] =>;
    function <name>([<list>]) ;;
    local self:=self(),selfData:=selfdata()

#command END_CONSTRUCTOR => ;
    return self

// 5.7 Describe destructor
#command DESTRUCTOR <name> [WITH <list,...>] =>;
    function <name>() ;;
    local self:=self(),selfdata:=selfdata() ;;
    local ins_number:=ascan(self:class():allinstances(),self)


#command END_DESTRUCTOR => ;
   if ins_number<>0 ;;
     aTrueDel(self:class():allInstances(),ins_number) ;;
   endif ;;
   self[O_OBJECT_DATA]:=self:=NIL ;;
   return self

