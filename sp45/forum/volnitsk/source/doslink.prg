 #include       "setcurs.ch"
 #include       "CTK.CH"

     static    DosScreen
     static    DosRow
     static    DosColor                 // Does we have to save DOS color ?

FUNCTION      InitCTK   (nLangScheme, nLangToggleKey)
     local     SetCnt
     public    xSet      := {}     // array storing all CTK sets

     //-------------- save system seting in public xSet ---------------------

     FOR  SetCnt := 1  to _SET_COUNT
          xSet ({SetCnt},  set(SetCnt))
     ENDFOR

     //-------------- set CTK default parametes  ---------------------------

     // window shadow dimensions - for SetWindow()
     xSet ({xSHADOW_WIDTH},        2)
     xSet ({xSHADOW_HEIGHT},       2)

     // default work area  - for SetWorkArea()/DeleteWorkArea()
     xSet ({xWORK_AREA, TOP},      0)
     xSet ({xWORK_AREA, LEFT},     0)
     xSet ({xWORK_AREA, BOTTOM},   maxrow())
     xSet ({xWORK_AREA, RIGHT},    maxcol())

     // cursor stuff
     xSet ({xINS_CURSOR},  SC_INSERT)  // cursor shape for insert mode
     xSet ({xOVR_CURSOR},  SC_NORMAL)  // cursor shape for overwrite mode
     xSet ({xNO_CURSOR},   SC_NONE)    // cursor shape when cursor is off
     xSet ({xCURSOR},     .F.)        // no need at start up for cursor

     // general sounds
     xSet ({xSOUND,xSYSBELL},            B_SYSBELL)
     xSet ({xSOUND,xERROR},              B_ERROR)
     xSet ({xSOUND,xWRONG_KEY},          B_ERROR)
     xSet ({xSOUND,xLANGUAGE_TOGGLE},    B_TOGGLE)

     // sounds of get system
     xSet ({xSOUND,xGS_DING},            B_DING)     // Succesfuly entered by typeout when Confirm off
     xSet ({xSOUND,xGS_UPDATE},          B_UPDATE)   // Succesfuly entered
     xSet ({xSOUND,xGS_ERROR},           B_ERROR)    // not valid entered value
     xSet ({xSOUND,xGS_WRONG_KEY},       B_ERROR)    // wrong key pressed for this data type

     // video mode
     xSet ({xMODE},                          IF (iscolor(), CO80, MONO))


//--COLORS ----------------------------------------------------------------
 // color consist from two elements - first for color, second for B/W mode

     xSet ({xCOLOR, xSYSTEM},                {{'',''},{'',''},{'',''},{'',''},{'',''},{'',''},{'',''}})

     // screen color after InitCTK()
     xSet ({xCOLOR, xBACKGROUND},            {'',''})

     // window shadow color
     xSet ({xCOLOR, xSHADOW},                {'',''})

     // F-key bar colors
     xSet ({xCOLOR, xFKEY_LABEL, xTEXT},     {"n/gb", "i"})  // labels
     xSet ({xCOLOR, xFKEY_LABEL, xHEAD},     {"w/n", ""})  // digits

     //  Menu() default colors
     xSet ({xCOLOR, xMENU, xTEXT},           {"w/b", "w/n"})
     xSet ({xCOLOR, xMENU, xHIGHLIGHTED},    {"g/n", "i"})
     xSet ({xCOLOR, xMENU, xUNAVAILABLE},    {"n/w", "u"})
     xSet ({xCOLOR, xMENU, xHEAD},           {"g/b", ""})
     xSet ({xCOLOR, xMENU, xFRAME},          {"w/b", ""})

     xSet ({xCOLOR, xSTAT, xTEXT},           {"g/n", ""})
     xSet ({xCOLOR, xSTAT, xHEAD},           {"gb/n", ""})

     // default MsgBox() and PromptBox() colors
     xSet ({xCOLOR, xMSGBOX, xTEXT},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xMSGBOX, xHEAD},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xMSGBOX, xFRAME},       {"n/gb", "n/w"})
     xSet ({xCOLOR, xMSGBOX, xPROMPT},      {"n/gb,w+/n", "n/w,w+/n"})

     xSet ({xCOLOR, xMESSAGE, xTEXT},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xMESSAGE, xHEAD},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xMESSAGE, xFRAME},       {"n/gb", "n/w"})
     xSet ({xCOLOR, xMESSAGE, xPROMPT},      {"n/gb,w+/n", "n/w, w+/n"})

     xSet ({xCOLOR, xHELP, xTEXT},        {"n/w", "n/w"})
     xSet ({xCOLOR, xHELP, xHEAD},        {"n/w", "n/w"})
     xSet ({xCOLOR, xHELP, xFRAME},       {"n/w", "n/w"})
     xSet ({xCOLOR, xHELP, xPROMPT},      {"n/w", "n/w"})

     xSet ({xCOLOR, xNAME_PLATE, xTEXT},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xNAME_PLATE, xFRAME},       {"n/gb", "n/w"})

     xSet ({xCOLOR, xVERIFY, xTEXT},        {"w+/g", "n/w"})
     xSet ({xCOLOR, xVERIFY, xHEAD},        {"n/gb", "n/w"})
     xSet ({xCOLOR, xVERIFY, xFRAME},       {"w+/g", "n/w"})
     xSet ({xCOLOR, xVERIFY, xPROMPT},      {"w+/g,w+/n", "n/w, w+/n"})

     // defualt InBox() colors
     xSet ({xCOLOR, xINBOX, xTEXT},        {"g/n",     ""})
     xSet ({xCOLOR, xINBOX, xHEAD},        {"gb/n",    ""})
     xSet ({xCOLOR, xINBOX, xFRAME},       {"gb/n",    ""})
     xSet ({xCOLOR, xINBOX, xGET},         {"g/n,g/n", ""})

     DosScreen := SaveScreen (0, 0, MaxRow(), MaxCol())
     DosRow    := Row()
     DosColor  := SetColor(xSet [xCOLOR, xBACKGROUND, xSet[xMODE]])
     cls

     //------------------ set get system and national langauge support -------

     // no need at start up for cursor
     set  bell        on
     set  scoreboard  off               // scoreboard can interfiar w\windows

     // set standard clipper get system behavior
     xSet ({xLANGUAGE},     1)
     xSet ({xSC_LANGUAGE  }, {""}        )
     xSet ({xSC_INS       }, "Ins"       )
     xSet ({xSC_OVR       }, "   "       )
     xSet ({xSC_BAD_DATE  }, "Bad Date"  )
     xSet ({xSC_BAD_RANGE }, "Range: "   )
     xSet ({xSC_NOT_VALID }, ""          )


     IF  empty(nLangScheme)             // tern off national language support
          RETURN nil
     ENDIF

     ChkParm (valtype(nLangScheme)    == 'N', "Language scheme")
     ChkParm (valtype(nLangToggleKey) =='N', "Toggle inkey code")

     //----- national langauge support setups -----------------------------

     xSet ({xLANGUAGE},            2)      // initial will be basic language
     xSet ({xLOGIC_TOGGLE_STR},    " ")    // space bar will toggle logic values


     // default language toggle key and block
     xSet ({xLANGUAGE_TOGGLE_KEY},    nLangToggleKey)
     xSet ({xLANGUAGE_TOGGLE_BLOCK},  { ||;
               xSet [xLANGUAGE] := xSet [xLANGUAGE] % len (xSet[xKEY_TABLE]) + 1,;
               beep(xSet [xSOUND] [xLANGUAGE_TOGGLE]),;
			ShowScoreboard();
     })

     SetKey (nLangToggleKey, xSet [xLANGUAGE_TOGGLE_BLOCK])


     //----- specific languages setups -----------------------------

     DO CASE

          CASE  nLangScheme == LS_ENGLISH                 // enhanced english
               xSet ({xKEY_TABLE},     {KB_ENGLISH, KB_ENGLISH})
               xSet ({xLOGIC_YES_STR}, 'TtYy'      )
               xSet ({xLOGIC_NO_STR},  'FfNn'      )
               xSet ({xSC_LANGUAGE  }, {"",""}     )
               xSet ({xSC_INS       }, "Ins"       )
               xSet ({xSC_OVR       }, "Ovr"       )
               xSet ({xSC_BAD_DATE  }, "Bad Date"  )
               xSet ({xSC_BAD_RANGE }, "Range: "   )
               xSet ({xSC_NOT_VALID }, "Error"     )


          CASE  nLangScheme == LS_RUSSIAN
               set date to german
               xSet ({xKEY_TABLE},     {KB_ENGLISH, KB_RUSSIAN})
               xSet ({xLOGIC_YES_STR}, 'Дд')
               xSet ({xLOGIC_NO_STR},  'Нн')
               xSet ({xSC_LANGUAGE  }, {"Лат","Рус"} )
               xSet ({xSC_INS       }, "Вст"         )
               xSet ({xSC_OVR       }, "Заб"         )
               xSet ({xSC_BAD_DATE  }, "Плохая дата" )
               xSet ({xSC_BAD_RANGE }, "Диапазон: "  )
               xSet ({xSC_NOT_VALID }, "Ошибка"      )
               xSet ({xALPHABET_UPPER}, ALPHABET_UPPER_RUSSIAN)
               xSet ({xALPHABET_LOWER}, ALPHABET_LOWER_RUSSIAN)



          CASE  nLangScheme == LS_UKRANIAN
               set date to german
               xSet ({xKEY_TABLE},     {KB_ENGLISH, KB_UKRANIAN})
               xSet ({xLOGIC_YES_STR}, 'ТтДд'        )
               xSet ({xLOGIC_NO_STR }, 'Нн'          )
               xSet ({xSC_LANGUAGE  }, {"Лат","Укр"} )
               xSet ({xSC_INS       }, "Вст"         )
               xSet ({xSC_OVR       }, "Заб"         )
               xSet ({xSC_BAD_DATE  }, "Погана дата" )
               xSet ({xSC_BAD_RANGE }, "Дiапазон: "  )
               xSet ({xSC_NOT_VALID }, "Помилка"     )
               xSet ({xALPHABET_UPPER}, ALPHABET_UPPER_UKRANIAN)
               xSet ({xALPHABET_LOWER}, ALPHABET_LOWER_UKRANIAN)



          CASE  nLangScheme == LS_UKRANIAN_RUSSIAN
               set date to german
               xSet ({xKEY_TABLE},     {KB_ENGLISH, KB_UKRANIAN, KB_RUSSIAN})
               xSet ({xLOGIC_YES_STR}, 'ТтДд'        )
               xSet ({xLOGIC_NO_STR }, 'Нн'          )
               xSet ({xSC_LANGUAGE  }, {"Лат","Укр","Рос"} )
               xSet ({xSC_INS       }, "Вст"         )
               xSet ({xSC_OVR       }, "Заб"         )
               xSet ({xSC_BAD_DATE  }, "Погана дата" )
               xSet ({xSC_BAD_RANGE }, "Дiапазон: "  )
               xSet ({xSC_NOT_VALID }, "Помилка"     )
               xSet ({xALPHABET_UPPER}, ALPHABET_UPPER_UKRANIAN_RUSSIAN)
               xSet ({xALPHABET_LOWER}, ALPHABET_LOWER_UKRANIAN_RUSSIAN)



          OTHERWISE
               ChkParm(.f., 'Language Scheme')
     ENDCASE

 RETURN  nil


FUNCTION      EOJ   ()
     Close all
     Restore  screen from DosScreen
     SetPos (DosRow, 1)
     SetColor(DosColor)
     Quit
 RETURN  nil