/*------------------------------------------------------*/
/*       DevMan - Online Manual For DevShell            */
/*  (C) Copyright 1991, 1992 Frank V. Castellucci       */
/*             All Rights Reserved                      */
/*                 $Revision: 1.3 $                     */
/*------------------------------------------------------*/
pull choice
rc=0;

if(choice = "" ) then do
    r=lineout(,"Use ? <command> or Help <command> for verbose listing");
    r=lineout(," ");
    r=lineout(,"ALIAS       - Lists the alias name and references");
    r=lineout(,"ASET        - Sets alias macro for session");
    r=lineout(,"CONFIG      - Displays Standard Configuration");
    r=lineout(,"CSET        - Sets configuration macro for session"); 
    r=lineout(,"COMSTACK    - Lists command stack");
    r=lineout(,"DSETS       - Lists open data sets");
    r=lineout(,"EXIT        - Exits DevShell and returns to OS");
    r=lineout(,"GO          - Changes to volume assignment");
    r=lineout(,"INFO        - Displays general information about session");
    r=lineout(,"QUIT        - Same as exit");
    r=lineout(,"REINIT      - Reinits DevShell from config file");
    r=lineout(,"VOLUMES     - List the volume cross assignments");
    r=lineout(,"VSET        - Sets a volume reference for session");
    r=lineout(," ");
    end
    
else
    do
    select
        when (choice = 'ALIAS') then do
            r=lineout(," "); 
            r=lineout(,"Usage : alias ");
            r=lineout(," "); 
            r=lineout(,"    Displays the configuration alias list");
            r=lineout(," "); 
            end
            
        when (choice = 'ASET') then do
            r=lineout(," ");
            r=lineout(,"Usage : aset <aliasname> <assignment>");
            r=lineout(," ");
            r=lineout(,"    Re-assigns alias <aliasname> with")
            r=lineout(,"    <assignment>. Example:");
            r=lineout(," ");
            r=lineout(,"    aset ed exec using EDIT ?");
            r=lineout(," ");                   
            r=lineout(,"    would assign alias ed to indirectly"); 
            r=lineout(,"    execute the application configured for EDIT ");
            r=lineout(,"    and prompt the user for an argument string");
            r=lineout(," ");
            r=lineout(,"    If an entry for edit existed, it would");
            r=lineout(,"    be replaced. If no entry exists, then a new");
            r=lineout(,"    alias is created. This assignment will ");
            r=lineout(,"    last for the current session only");
            r=lineout(," ");
            end
            
        when (choice = 'CONFIG') then do
            r=lineout(," ");  
            r=lineout(,"Usage : config ");
            r=lineout(," "); 
            r=lineout(,"    Displays the configuration replacement");
            r=lineout(,"    parameters for the editor, browser, etc");
            r=lineout(," ");  
            end
            
        when (choice = 'CSET') then do
            r=lineout(," ");  
            r=lineout(,"Usage : cset <configname> <assignment>");
            r=lineout(," ");   
            r=lineout(,"    Re-assigns name <configname> with")
            r=lineout(,"    <assignment>. Example:");
            r=lineout(," ");
            r=lineout(,"    cset EDIT C:\OS2\E.EXE");
            r=lineout(," ");             
            r=lineout(,"    would assign configname EDIT to C:\OS2\E.EXE"); 
            r=lineout(," ");
            r=lineout(,"    If an entry for EDIT existed, it would");
            r=lineout(,"    be replaced. If no entry exists, then a new");
            r=lineout(,"    configname is created. This assignment will ");
            r=lineout(,"    last for the current session only");
            r=lineout(," ");
            end
       
            
        when (choice = 'COMSTACK') then do
            r=lineout(," ");
            r=lineout(,"Usage : comstack | coms");
            r=lineout(," "); 
            r=lineout(,"    Lists the command stack with the oldest");
            r=lineout(,"    entry on the top ( position 0 ).");
            r=lineout(," ");
            r=lineout(,"    Individual entries ( 0 - x ) can be re-");
            r=lineout(,"    executed by entering the number to the");
            r=lineout(,"    left of the command displayed in the list");
            r=lineout(," "); 
            end
            
        when (choice = 'DSETS') then do
            r=lineout(," ");  
            r=lineout(,"Function does not exist, so neither does help");
            r=lineout(," ");
            end

        when (choice = 'EXIT') then do
            r=lineout(," ");  
            r=lineout(,"Usage : exit");
            r=lineout(," ");
            r=lineout(,"    Exits DevShell and returns to OS or other shell");
            r=lineout(," ");
            end
            
        when (choice = 'GO') then do
            r=lineout(," ");  
            r=lineout(,"Usage : go <volsassign> | <path>");
            r=lineout(," ");
            r=lineout(,"    changes directory and drive to either the");
            r=lineout(,"    volume assigned in volassign or the drive");
            r=lineout(,"    and directory as specified in path");
            r=lineout(," ");
            end
            
        when (choice = 'INFO') then do
            r=lineout(," ");
            r=lineout(,"Usage : info "); 
            r=lineout(," "); 
            r=lineout(,"    Displays general information and statistics"); 
            r=lineout(,"    about the current session."); 
            r=lineout(," "); 
            end
            
        when (choice = 'QUIT') then do
            r=lineout(," ");  
            r=lineout(,"Usage : quit");
            r=lineout(," ");
            r=lineout(,"    Exits DevShell and returns to OS or other shell");
            r=lineout(," ");
            end
            
        when (choice = 'REINIT') then do
            r=lineout(," "); 
            r=lineout(,"Usage : reinit "); 
            r=lineout(," "); 
            r=lineout(,"    Reinits DevShell from configuration file"); 
            r=lineout(," "); 
            end
            
        when (choice = 'VOLUMES') then do
            r=lineout(," ");  
            r=lineout(,"Usage : volumes");
            r=lineout(," ");   
            r=lineout(,"    Displays the list of volume drive and directory");   
            r=lineout(,"    assignments");   
            r=lineout(," ");   
            end
            
        when (choice = 'VSET') then do
            r=lineout(," ");  
            r=lineout(,"Usage : vset <volname> <path>");
            r=lineout(," ");   
            r=lineout(,"    Re-assigns name <volname> with")
            r=lineout(,"    <path>. Example:");
            r=lineout(," ");
            r=lineout(,"    vset cursrc F:\DEVLP\SRC");
            r=lineout(," ");             
            r=lineout(,"    would assign volname cursrc to F:\DEVLP\SRC"); 
            r=lineout(," ");
            r=lineout(,"    If an entry for cursrc existed, it would");
            r=lineout(,"    be replaced. If no entry exists, then a new");
            r=lineout(,"    volname is created. This assignment will ");
            r=lineout(,"    last for the current session only");
            r=lineout(," ");   
            end
            
        otherwise
            r=lineout(," ");
            r=lineout(,"Help not found for :" choice);
            r=lineout(," ");
            rc=1
        end
        
    end
    
exit (rc);

