*FUNCTION: Return the roman numeral for a number 0..10
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Roman
 Parameters num
 Private db, rstr
 Declare db[10]

 set talk off

 if num = 0
    rstr = "0"
 else
    db[1] = "I"
    db[2] = "II"
    db[3] = "III"
    db[4] = "IV"
    db[5] = "V"
    db[6] = "VI"
    db[7] = "VII"
    db[8] = "VIII"
    db[9] = "IX"
    db[10] = "X"

    if num <= 10
       rstr = db[num]
    else
       rstr = ".none."
    endif
 endif

 Release db
Return rstr
