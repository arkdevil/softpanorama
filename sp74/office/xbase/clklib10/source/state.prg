*FUNCTION: State- Return a state's name given it's abrv.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 17 Jul 1994


Function State
 Parameters name
 Private rstr, db, done
 Declare db[51]
 
 set talk off
 store "" to rstr

 db[1] = "AL Alabama"
 db[2] = "AK Alaska"
 db[3] = "AZ Arizona"
 db[4] = "AR Arkansas"
 db[5] = "CA California"
 db[6] = "CO Colorado"
 db[7] = "CT Conneticut"
 db[8] = "DE Delaware"
 db[9] = "FL Florida"
 db[10] = "GA Georgia"
 db[11] = "HI Hawaii"
 db[12] = "ID Idaho"
 db[13] = "IL Illinois"
 db[14] = "IN Indiana"
 db[15] = "IA Iowa"
 db[16] = "KS Kansas"
 db[17] = "KY Kentucky"
 db[18] = "LA Louisiana"
 db[19] = "ME Maine"
 db[20] = "MD Maryland"
 db[21] = "MA Massachusetts"
 db[22] = "MI Michigan"
 db[23] = "MN Minnesota"
 db[24] = "MS Mississippi"
 db[25] = "MO Missouri"
 db[26] = "MT Montana"
 db[27] = "NE Nebraska"
 db[28] = "NV Nevada"
 db[29] = "NH New Hampshire"
 db[30] = "NJ New Jersy"
 db[31] = "NM New Mexico"
 db[32] = "NY New York"
 db[33] = "NC North Carolina"
 db[34] = "ND North Dakota"
 db[35] = "OH Ohio"
 db[36] = "OK Oklahoma"
 db[37] = "OR Oregon"
 db[38] = "PA Pennsylvania"
 db[39] = "RI Rhode Island"
 db[40] = "SC South Carolina"
 db[41] = "SD South Dakota"
 db[42] = "TN Tennessee"
 db[43] = "TX Texas"
 db[44] = "UT Utah"
 db[45] = "VT Vermont"
 db[46] = "VA Virginia"
 db[47] = "WA Washington"
 db[48] = "WV West Virginia"
 db[49] = "WI Wisconsin"
 db[50] = "WY Wyoming"
 db[51] = "DC Washington D.C."

 store .F. to done
 store 1 to indx
 do while (.not. done) .and. (Left(db[indx],2) <> Upper(Trim(name)))
    indx = indx +1
    if indx > 51
       done = .T.
    endif
 enddo

 if done
    rstr = ".none."
 else
    rstr = Right(db[indx],Len(db[indx])-3)
 endif
Return rstr
