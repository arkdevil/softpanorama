

LZW Compression / Decompression


ROUTINE LZW_COMPRESS
STRING=get input character
WHILE there are still input characters DO
    CHARACTER=get input character
    IF STRING+CHARACTER is in the string table THEN
        STRING=STRING+CHARACTER
    ELSE
        output the code for STRING
        add STRING+CHARACTER to the string table
        STRING=CHARACTER
    END of IF
END of WHILE
output the code for STRING

ROUTINE LZW_DECOMPRESS
read OLD_CODE
output OLD_CODE
WHILE there are still input characters DO
    read NEW_CODE
    IF NEW_CODE is not in the translation table THEN
        STRING=get translation of OLD_CODE
        STRING=STRING+CHARACTER
    ELSE
        STRING=get translation of NEW_CODE
    END of IF
    output STRING
    CHARACTER=first character in STRING
    add OLD_CODE+CHARACTER to the translation table
    OLD_CODE=NEW_CODE
END of WHILE
