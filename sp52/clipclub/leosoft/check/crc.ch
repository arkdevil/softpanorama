PRIVATE aNtxData:={
{"имен",         "Names.Dbf",  "Names.Ntx",;
   {|| DbUseArea(.T.,,"Names.Dbf","Names",.F.), ;
       Names->(DbCreateInd("Names.ntx","Upper(Name)",{||Upper(Name)})),;
       Names->(DbCloseArea())}},;
{"отчеств",      "CoNames.Dbf","CoNames.Ntx",
   {|| DbUseArea(.T.,,"CoNames.Dbf","CoNames",.F.),;
       CoNames->(DbCreateInd("CoNames.ntx","Upper(CoName)",{||Upper(CoName)})),;
       CoNames->(DbCloseArea())}},;
{"ключевых слов","Keyword.Dbf","KeyWord.Ntx",;
   {|| DbUseArea(.T.,,"Keyword.Dbf","KeyWord",.F.),;
       KeyWord->(DbCreateInd("KeyWord.ntx","Upper(Word)",{||Upper(Word)})),;
       KeyWord->(DbCloseArea())}};
       }
