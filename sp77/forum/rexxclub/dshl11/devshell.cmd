/*------------------------------------------------------*/
/*         DevShell - Developers Shell                  */
/*         Version 1.0 $Revision: 1.10 $                 */
/*     (C) Copyright 1991 Frank V. Castellucci          */
/*             All Rights Reserved                      */
/*------------------------------------------------------*/

/*------------------------------------------------------*/
/*  Global variable areas                               */
/*------------------------------------------------------*/

Config.maxcfg   = 0;
Config.maxalias = 0;
Config.maxvol   = 0;
                
CntlShell.          = "";
CntlShell.usedalias = 0;
OpenFiles.          = "";

Commands.num    = 0;
Commands.cur    = "";

/*  Pull command line arguments             */

Parse Upper Arg CommandLine

/*  Fetch count of arguments                */

argc = GetArgC(CommandLine);

if(argc > 0) then do
    Commands.cur = CommandLine;
    end

/*------------------------------------------*/
/*  If the configuration file inits ok, loop*/
/*  through user input until the exit or    */
/*  quit command is entered.                */
/*------------------------------------------*/

if(InitConfig(argc,CommandLine) = "READY:") then do
    do until (i=0)
        i=FetchInput();
        if( i > 0 & i <> 'ffff'x) then do
            r=dispatch(i,Commands.cur);
            end
        end
    Call Header;
    End
    
else do
    say "Error in configuration file management"
    end
    
/*------------------------------*/
/* The only exit in the house   */
/*------------------------------*/
    
exit i;

/*------------------------------------------------------*/
/*  Displays Header Information                         */
/*------------------------------------------------------*/
Header: procedure
say; say;

loop = 1;
do until LEFT(sourceline(loop),4) = "    "
    String = sourceline(loop);
    if(LEFT(String,4) = "more" | LEFT(String,4) = "More") then do
        r=lineout(,"Press [ENTER] to continue");
        linein()
        end
    else do
        r=lineout(,String);
        end
    loop = loop+1;
    end

return;

/*------------------------------------------------------*/
/*  Routine to fetch number of arguments passed by user */
/*------------------------------------------------------*/

GetArgC: procedure 
BigString = Arg(1)
count = 0
do while(BigString <> "")
    Parse Var BigString Drop BigString
    count = count+1
    end
    
return count;

/*------------------------------------------------------*/
/*  Routine to fetch additional command line arguments  */
/*  Here argv. is exposed to pass the information to    */
/*  other functions either locally or externally        */
/*------------------------------------------------------*/

FetchInput: procedure expose Commands.

r=charout(,"0d0a"x"[ready]: ")
parse value linein() with Ops

i = GetArgC(Ops);

if( i > 0) then do
    PARSE UPPER VAR Ops argv0 rest
    if(argv0 = 'EXIT' | argv0 = 'QUIT') then do
        i = 0;
        end
    end

    /*  Otherwise the enter key was hit with no input   */
    
else do
    i = 'ffff'x;
    end
    
if( i > 0 & i <> 'ffff'x) then do
    t = Commands.num
    Commands.t = Ops
    Commands.cur = Ops
    Commands.num = t+1
    end
        
return i;

/*------------------------------------------------------*/
/*  Dispatch what the user wanted to call us for        */
/*  Argc    -   Counts of words in entry string         */
/*  Ops     -   Fully entered string                    */
/*  Spare   -   Same, I forget why?                     */
/*------------------------------------------------------*/

DisPatch: procedure expose Config. Commands. CntlShell.

argc    = Arg(1)
Ops     = Arg(2)
spare   = Arg(2)

HlpStr = '@call 'CntlShell.Help'\devman()';  

    /*------------------------------------------------------*/
    /*    Parse out arguments into automatic array          */
    /*------------------------------------------------------*/
    
    i = 0
    do while ( i < argc )
        if( i = 0 ) then do
            parse var Ops argv.i Ops
            end
        else do
            parse var Ops argv.i Ops
            end
        
        i = i+1
        end
    
    
    results = 1;                        /*  Return status       */
    uparg0  = translate(argv.0);        /*  Force upper case    */
    
    select  
        /*--------------------------------------------------------------*/
        /*  If the argument is a number, we assume a stacked command    */
        /*--------------------------------------------------------------*/
        when (datatype( argv.0 ) = "NUM") then do
            Commands.num = Commands.num - 1;         
            if(argv.0 < Commands.num) then do
                t = argv.0
                results = dispatch(GetArgC(Commands.t),Commands.t)
                end
            else do
                r=lineout(,argv.0 "not in command stack");
                end
            end
            
        /*--------------------------------------------------------------*/         
        /*  Direct call to the operating system, we first remove 'OS'   */
        /*--------------------------------------------------------------*/
        
        when(uparg0 = 'OS') then do
            parse var spare dump spare
            spare
            results = 0;
            end
            
        /*--------------------------------------------------------------*/ 
        /*  Query Options Command                                       */
        /*--------------------------------------------------------------*/ 
        
        when (argv.0 = "?" | uparg0 = "HELP") then do
            if(argc > 1) then do
                push argv.1;
                end
            else do
                push "";
                end
            HlpStr;
            end
            
        /*--------------------------------------------------------------*/ 
        /*  Display alias list as currently assigned                    */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'ALIAS' ) then do
            i=0
            do while(i < Config.maxalias)
                t = Config.i
                string = LEFT(Config.i,15) "=" Config.i.t
                r=lineout(,string);
                i = i+1
                end
            end
            
        /*--------------------------------------------------------------*/   
        /*  Change or add an alias string                               */
        /*--------------------------------------------------------------*/
        
        when ( uparg0 = 'ASET' ) then do
            if(argc > 2) then do
                i=0;
                t=0;
                Ops = argv.1;
                parse var spare dummy0 dummy1 argv.2 
                
                do while( i < Config.maxalias)
                    if(compare(Config.i,Ops) = 0) then do
                        Config.i.Ops = argv.2
                        i = Config.maxalias;
                        t = 1;
                        end
                    i = i+1;
                    end
                    
                if( t = 0 ) then do
                    i = Config.maxalias;
                    Config.i = Ops;
                    Config.i.Ops = argv.2;
                    i = i+1;
                    Config.maxalias = i;
                    end
                end
            else do
                push 'ASET';
                HlpStr;
                end
            end
            
        /*--------------------------------------------------------------*/ 
        /*  Display configuration list as current                       */
        /*--------------------------------------------------------------*/         
        
        when ( uparg0 = 'CONFIG' ) then do
            i = 0;
            do while(i < Config.maxcfg)
                r=lineout(,LEFT("Config."Config.FUNCTIONS.i,15) "=",
                                         Config.FUNCTIONS.i.0);
                i = i+1;
                end
            end
        
        /*--------------------------------------------------------------*/ 
        /*  Change or add a configuration string                        */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'CSET') then do
   
            if(argc > 2) then do
                parse var spare dummy Ops;
                CfgCmd = "";
                CfgCmd = CheckConfig(Ops);
            
                if( CfgCmd <> "") then do
                    CfgCmd = translate(argv.1);
                    t=0;
                    do while( Config.FUNCTIONS.t <> CfgCmd )
                        t = t+1;
                        end
                    Config.FUNCTIONS.t.0 = argv.2;
                    end          
                else do
                    CfgCmd = translate(argv.1);
                    t=Config.maxcfg;
                    Config.FUNCTIONS.t = CfgCmd;
                    Config.FUNCTIONS.t.0 = argv.2;
                    Config.maxcfg = Config.maxcfg + 1;
                    end
                end
            else do
                push 'CSET';
                HlpStr;
                end
            end
            
        /*--------------------------------------------------------------*/ 
        /*  Display the command stack                                   */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'COMSTACK' | uparg0 = 'COMS') then do
            if(argc < 2) then do
                i = 0
                do while( i < Commands.num)
                    string = LEFT(i,5)" "Commands.i
                    r=lineout(,string);
                    i = i+1
                    end
                end
            else do
                
                /*------------------------------------------*/
                /*  The '.' parameter resets the stack to 0 */
                /*------------------------------------------*/
                
                if(argv.1 = '.') then do
                    Commands.num = 0;
                    end 
                end
            end

        /*--------------------------------------------------------------*/ 
        /*  Change to directory listed in volser list, or do direct     */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'GO' ) then do
            if(argc > 1) then do
                NewVol = CheckVolumes(argv.1);
                if(NewVol <> "") then do
                    CntlShell.CurDir = directory(NewVol);
                    end
                else do
                    NewVol = directory(argv.1);
                    if(NewVol <> "" ) then do
                        CntlShell.CurDir = NewVol;
                        
                        end
                    else do
                        r=lineout(,"VOL assignment "argv.1" not found");
                        r=lineout(,"and directory change returned error");
                        end
                    end
                end
            else do
                push 'GO';
                HlpStr;
                end
            end
            
        /*--------------------------------------------------------------*/     
        /*  Go to directory listed in the config file                   */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'HOME' ) then do
            CntlShell.CurDir = directory(CntlShell.Home);
            end
            
        /*--------------------------------------------------------------*/
        /*  Show general information about session parameters           */
        /*--------------------------------------------------------------*/
        
        when ( uparg0 = 'INFO' ) then do
            r=lineout(,' '); 
            r=lineout(,'Current Directory 'CntlShell.CurDir);
            r=lineout(,'Home Directory    'CntlShell.Home);
            r=lineout(,'Help Directory    'CntlShell.Help);
            r=lineout(,' ');
            r=lineout(,'Config File       'CntlShell.Cfg);
            r=lineout(,'Apps Configured = 'Config.maxcfg);
            r=lineout(,'Vols Configured = 'Config.maxvol);
            r=lineout(,'Alias Execs     = 'Config.maxalias);
            r=lineout(,' ');
            r=lineout(,'Command stack   = 'Commands.num);
            end
        
        /*--------------------------------------------------------------*/ 
        /*  Reinitialize the configuration file, assumed edited         */
        /*--------------------------------------------------------------*/ 
        
        when (uparg0 = "REINIT") then do
            results = InitConfig(0);
            end
        
        /*--------------------------------------------------------------*/ 
        /*  List volumes assigned from configuration file, or session   */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'VOLUMES' ) then do
            i=0;
            do while(i < Config.maxvol)
                r=lineout(,LEFT("VOL."Config.VOLSERS.i,15) "=",
                                        Config.VOLSERS.i.0);
                i = i+1;
                end
            end
            
        /*--------------------------------------------------------------*/     
        /*  Change or add volume look-aside assignment                  */
        /*--------------------------------------------------------------*/ 
        
        when ( uparg0 = 'VSET') then do
            if(argc > 2) then do
                NewVol = "";
                NewVol = CheckVolumes(argv.1);
                if(NewVol <> "") then do
                    t=0;
                    do while(Config.VOLSERS.t <> argv.1)
                        t=t+1;
                        end
                    Config.VOLSERS.t.0 = argv.2;
                    end
                else do
                    t = Config.maxvol;
                    Config.VOLSERS.t = argv.1;
                    Config.VOLSERS.t.0 = argv.2;
                    Config.maxvol = Config.maxvol +1;
                    end
                end
            else do
                push 'ASET';
                HlpStr;
                end
            end
        
        /*--------------------------------------------------------------*/ 
        /*  Falling through we check configuration cross-reference or   */
        /*  alias command strings, worst case we report an error        */
        /*--------------------------------------------------------------*/ 
        
        otherwise
            CfgCmd = "";
            CfgCmd = CheckConfig(spare);
        
            if(CfgCmd <> "" ) then do
                if(argc > 1) then do
                    CfgCmd argv.1
                    end
                else do
                    CfgCmd
                    end
                end
            
            else if( CheckAlias(spare) = 1) then do
                r=lineout(,"Unknown command " spare);
                end
                
        end
        
return results;

/*------------------------------------------------------*/
/*  Loads configuration file and checks for alternate   */
/*  Potential Arguments:                                */
/*                      -C Alternate Config File        */
/*------------------------------------------------------*/

InitConfig:procedure expose Config. CntlShell.

argc = Arg(1);
Ops  = Arg(2);
Spare= Arg(2);

cfgfile = "DSHELL.CFG"                  /*  Default Name            */
Call Header;                            /*  Show Header             */

Config. = "";                           /*  Reset alias and config  */
Config.maxalias = 0;                    /*  Loop control alias      */
Config.maxcfg   = 0;                    /*  Loop control configs    */
Config.maxvol   = 0;                    /*  Loop control volsers    */

CntlShell.CurDir = directory();         /*  Get Current Directory   */

    /*--------------------------------------------------*/
    /*  The following assumes that we are in a re-init  */
    /*  state as called by user. This is based on the   */
    /*  re-init argument values of 0 and NULL           */
    /*--------------------------------------------------*/
    
if(CntlShell.Home <> "") then do
    if(CntlShell.usedalias = 1 & CntlShell.Cfg <> "") then do
        cfgfile = CntlShell.Cfg;
        end
    else do
        if(CntlShell.Home <> CntlShell.CurDir) then do
            cfgfile = CntlShell.Home'\'CntlShell.Cfg;
            end
        end
    end

if( argc > 0 ) then do
    t = 0;
    
    do while(spare <> "")
        parse var spare argv.t spare;
        t = t+1;
        end
        
    l = 0
    
    do while( l < argc )
        if( LEFT(argv.l,2) = "-C") then do
            len = LENGTH(argv.l);
            len = len - 2;
            cfgfile = COPIES(RIGHT(argv.l,len),1)
            r=lineout(,"Alternate configuration file used " cfgfile);
            CntlShell.usedalias = 1;
            end
            
        else if(LEFT(argv.l,2) = "-D") then do
            len = LENGTH(argv.l);
            len = len - 2;
            CntlShell.CurDir = directory(COPIES(RIGHT(argv.l,len),1));
            r=lineout(,"Home directory set to " CntlShell.CurDir);
            end
            
        l = l+1    
        end
    end
    
state=stream(cfgfile,c,"OPEN");                 /*  Open file           */

if( state = "READY:" ) then do                  /*  If opened ok        */

    if(lines(cfgfile) > 0) then do              /*  And contains data   */
    
        fileline = 0;                           /*  Set filelines       */
                
        do while lines(cfgfile)                 /*  While more lines    */
        
            fileline = fileline+1;              /*  Have a valid one    */
        
            BigLine = linein(cfgfile);          /*  Get next line in    */
            

            BigLine = ClearGarbage(strip(BigLine));
            
            parse var BigLine option delim parm1 parm2
            
            option = translate(option);
            
            /*--------------------------------------*/ 
            /*  If blank or comment ignore process  */
            /*--------------------------------------*/ 
            
            if( option = "" ) then nop;
            
            /*  Assign Alias Options    */
            
            /*--------------------------------------*/
            /*  Assign alias members to array off   */
            /*  the config trunk                    */
            /*--------------------------------------*/             

            else if(option = "ALIAS") then do
                parm1 = CheckComment(strip(parm1));
                if(parm1 <> "") then do
                    parm2=CheckComment(strip(parm2));
                    if(parm2 <> "")   then do
                        t = Config.maxalias;
                        Config.t = parm1;
                        Config.t.parm1 = parm2;
                        t = t+1
                        Config.maxalias = t;
                        end
                    else do
                        r=lineout(,"Line: "fileline" invalid");
                        end
                    end
                    
                else do
                    r=lineout(,"Line: "fileline" contains null alias");
                    end
                end
                
            /*--------------------------------------*/
            /*  Assign volume lookaside for easy    */
            /*  movement control                    */
            /*--------------------------------------*/
            
            else if( option = "VOL") then do
                parm1 = CheckComment(strip(parm1));
                if(parm1 <> "") then do
                    parm2 = CheckComment(strip(parm2));
                    if(parm2 <> "") then do
                        t = Config.maxvol;
                        Config.VOLSERS.t = parm1;
                        Config.VOLSERS.t.0 = parm2;
                        t = t+1;
                        Config.maxvol = t;
                        end
                    else do
                        r=lineout(,"VOL" parm1" set to . at line" fileline);
                        end
                    end
                else do
                    r=lineout(,"VOL statement line" fileline" contains null");
                    end
                end
                
            /*--------------------------------------*/
            /*  Assign Directorys for home and      */
            /*  Help manuals                        */
            /*--------------------------------------*/
            
            else if(option = "HOME") then do
                parm1 = CheckComment(strip(parm1));
                if(parm1 <> "") then do
                    CntlShell.Home = parm1;
                    end
                end                         /*  End Home assigns    */
                
            else if(option = "HELP") then do
                parm1=CheckComment(strip(parm1));
                if(parm1 <> "") then do
                    CntlShell.Help = parm1;
                    end
                end                         /*  End Help assigns    */
                
            /*--------------------------------------*/ 
            /*  Assign leaf to step                 */
            /*  Using the function branch members   */
            /*--------------------------------------*/
            
            else do
                parm1=CheckComment(strip(parm1));
                if(parm1 <> "") then do
                    t = Config.maxcfg;
                    Config.FUNCTIONS.t = option
                    Config.FUNCTIONS.t.0 = parm1;
                    t = t+1;
                    Config.maxcfg = t;
                    end
                else do
                    r=lineout(,Config.option "set to . at Fileline :"fileline);
                    end
                end                         /*  End Config assigns  */
            
            end                             /*  End DoWhile Lines   */

        if(CntlShell.Cfg = "") then do
            CntlShell.Cfg = cfgfile; 
            end
            
        state = stream(cfgfile,c,"CLOSE"); 
        
        if(CntlShell.Home = "")  then do
            CntlShell.Home = CntlShell.CurDir;
            end
            
        if(CntlShell.Help = "") then do
            CntlShell.Help = CntlShell.CurDir;
            end
        
        end                                 /*  End if file found   */
        
    else do
        state = stream(cfgfile,c,"CLOSE"); 
        r=lineout(,"Configuration file not found!");
        CntlShell.usedalias = 0;
        'del' cfgfile;
        end                                 /*  End empty file      */
        
    end                                     /*  End open ready      */
    
else do
    r=lineout(,"File open error on" cfgfile "="stream(cfgfile,'D'));
    CntlShell.usedalias = 0;
    end

return state;

/*------------------------------------------------------*/
/*  Direct and Indirect operating system call           */
/*------------------------------------------------------*/

BaseExec: procedure expose Config.
Arg OsCall

hit   = 0;

parse var OsCall Command Rest

if(strip(Rest) = '?') then do
    r=charout(,"Enter option(s) for" Command "call : ");
    parse value linein() with Rest
    end
    
else do
    if ( wordpos("using",Command) | wordpos("USING",Command)) then do
        parse var Rest indirect Rest
        if( strip(Rest) = '?') then do
            r=charout(,"Enter option(s) for" indirect "call : ");
            parse value linein() with Rest
            end
        Command = CheckConfig(strip(indirect));
        hit = 1;
        
        if(Command <> "") then do
            Command Rest
            end
            
        else do
            r=lineout(,"Error processing indirect" indirect Rest);
            end    
        end
    end
       
if(hit = 0) then do 
    Command Rest
    end
return 0;

/*------------------------------------------------------*/
/*  Clear unwanted characters from line                 */
/*------------------------------------------------------*/
ClearGarbage: procedure
string = CheckComment(Arg(1));

    if(string <> "" & pos('#',string) <> 1) then do
        slen   = length(string);
        loop   = 1;

        do while(loop <= slen)
            if( c2d( substr(string,loop,1) ) < 32) then do
                string = overlay('20'x,string,loop,1);
                end
            loop = loop+1;
            end
        end
    else do
        string = "";
        end

return string;

/*------------------------------------------------------*/
/*  Checks string for comment character                 */
/*------------------------------------------------------*/
CheckComment: procedure

string = Arg(1);                    /*  Passed string   */

if(string <> "") then do            /*  If not null     */
    t=pos("#",string);              /*  Check control   */
    if(t) then do                   /*  If we have it   */
        string = left(string,t);    /*  Copy prefix     */
        end
    end
    
return string;                      /*  Return results  */

/*------------------------------------------------------*/
/*  Checks the alias list for a match and operation     */
/*------------------------------------------------------*/
CheckAlias: procedure expose Config.

Parse Arg InComing Rest

rc=1
t=0;

do while(t < Config.maxalias)
    if(COMPARE(Config.t,InComing) = 0) then do
        rc = 0;
        PARSE UPPER VAR Config.t.InComing command argument
        if(command = 'EXEC') then do
            rc=BaseExec(argument);
            t = Config.maxalias;
            end
        else do
            r=lineout(,"Syntax error in alias line "Config.t.InComing);
            end
        end
    t = t+1
    end

return rc;

/*------------------------------------------------------*/
/*  Checks the configuration function list for the      */ 
/*  passed parameter and returns match string if found  */
/*------------------------------------------------------*/ 
CheckConfig: procedure  expose Config.

Parse Upper Arg InComing Rest

i = 0;
match = "";

do while ( i < Config.maxcfg )
    if(InComing = Config.FUNCTIONS.i) then do
        match = Config.FUNCTIONS.i.0;
        i = Config.maxcfg;        
        end
    i = i+1;
    end

return match;

/*------------------------------------------------------*/ 
/*  Checks the volser list for a match with the passed  */
/*  parameter and returns matching string if found      */
/*------------------------------------------------------*/
CheckVolumes: procedure expose Config.

InComing = Arg(1);

match = "";
i = 0;
    
do while( i < Config.maxvol )
    if( InComing = Config.VOLSERS.i) then do
        match = Config.VOLSERS.i.0;
        i = Config.maxvol;
        end
    i = i+1;
    end
    
return match;
 
/*
$Log:	devshell.cmd $
Revision 1.10  91/12/22  21:23:36  FJC
Cleaned up configuration parser
Added Vset Aset and Cset commands
Added Info command
Fixed problem with tabs in config file
Removed CDD ( go does same thing only better )
Extended Help File Manual

Revision 1.9  91/12/08  18:26:48  FJC
Included command line parsing in init routine

Revision 1.8  91/12/08  18:18:34  FJC
Corrected command line argument processing on startup

Revision 1.7  91/12/08  12:55:53  FJC
Tested indirect rexx call as alias command

*/
