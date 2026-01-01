/*--------------------------------------------------*/
/*  Wordcnt -   Text File Word and Line Counter     */
/*  (C) Copyright 1991 Frank V. Castellucci         */
/*  All Rights Reserved                             */
/*                                                  */
/*  $Source: g:/rexxapps/RCS/wordcnt.cmd $          */
/*  $Revision: 1.4 $                                */
/*--------------------------------------------------*/
parse upper arg FileName;

result = 'ffff'x;

if(FileName <> "") then do
    if(stream(FileName,'c','query exist') <> "") then do
        result = LcAndWc(FileName);
        end
    end
    
else do
    r=charout(,"0d0a"x"[Enter file name]: ")
    parse value linein() with FileName
    if(stream(FileName,'c','query exist') <> "") then do
        result = LcAndWc(FileName);
        end
    end
    
if(result = 'ffff'x) then do
    r=lineout(,"Invalid or non-existant filename entered");
    end
    
exit

/*  Line and word counting procedure    */

LcAndWc: procedure
fname = Arg(1);

r=lineout(,'Opening 'fname);

state = stream(fname,'c','open read');

if(state = 'READY:') then do
    wc=0;
    lc=0;
    
    do while ( lines(fname) )
        c = charout(,'.');
        lc = lc+1;
        cc=0;dc=1;
        
        bigstring = linein(fname);
        dummy = bigstring;    
        
        
        do while(dummy <> "")
            dummy = subword(bigstring,dc,1);
            
            if(dummy <> "" & datatype(dummy,'m')) then do
                cc = cc+1;
                end
                
            dc = dc+1;    
            end
            
        wc = wc + cc;
        end
        
    r=lineout(," ");
    r=lineout(,LEFT('File',20) "Words   Lines");
    r=lineout(,LEFT(fname,20)   wc'     'lc);
    state = stream(infname,'c','close');
    end
    
else do
    r=lineout(,'Unable to open file' infname' for reading.');
    r=lineout(,stream(infname,'d'));
    r=lineout(,stream(infname,'s'));
    end
    
return 0;

/*
$Log:	wordcnt.cmd $
Revision 1.4  91/12/09  02:09:25  FJC
Added '.' feedback for each line read from file.

Revision 1.3  91/12/08  19:51:47  FJC
Corrected couting summary and output positioning

*/
