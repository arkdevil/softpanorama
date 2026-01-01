;  T-Node configuration file
    ADDRESS 2:463/67
;        Your net address.
;
    UTC +3
;        Timing zone.
;
    FILE_BOXES C:\MODEM\OUTBOUND\
;        T-Mail filebox path.
;
    NODELISTPATH C:\MODEM\NODELIST\
;        Nodelist path where must be fresh NDXLIST.T-? and where be create
;        personal T-Node index.
;
    PACKETS C:\MODEM\PACKETS
;        T-Mail packets path.
;
    MAIL_OUT C:\MODEM\NETMAIL
;        Path to outbound netmail.
;
    BORDER white black
    TITLE lightwhite black
    INFO lightwhite black
    SEARCH lightwhite black
    NORMAL lightwhite black
    SELECT black white
    HELP lightwhite black
    WARNING red black
;        Variable, specifying colour of display according to border,
;        heading, information about nodes, line of search, nodelist line,
;        cursor,help window and warning messages.
;
    FLAG CM YELLOW BLACK NAME
;        To indicate yellow on black sysop names, stations of which
;        work CM.
;
    FLAG ZYX LIGHTGREEN BLACK STATION
;        To indicate lightgreen on black station with Zyxel.
;
    UFLAG HOLD, RED BLACK FULL
    UFLAG DOWN, RED BLACK FULL
;        To indicate red all stations in hold or down mode. The point stands
;        for it, that the stations with names such HoldNext were not allocated.
;        Selected all line
;
    UFLAG 380-44-244 YELLOW LIGHTBLUE ADDRESS NAME
        To indicate yellow on dark bluey station in Kiev, located on 244
        telephone station.
        Sysop name and address are highlighted.
;
    NOBLINK
;        If wants to have 16 colours of background without blinking - use this
;        command.
;
;    TOP 1
;    LEFT 1
;    HIGH 21
;    WIDTH 78
;        According to coordinate of left-hand top corner, hight and
;        width of window, in which the viewing will be produced. Maximum
;        values setting reliable to current video-mode.
;
;    L_STATION 29
;    L_NAME 21
;        The width of fields with names of station and sysop name. The sizes
;        of fields of address and flags are fixed.
;
;    TIMEOUT 0
;        The time on seconds of expectation of depression of keys. On
;        expiration of time the program terminates the work. The value 0
;        switches off this option.
;        Works only in DOS.
;
;    NOSOUND
;        Prevent from beeping in some time.
;
;    NOASK
;        Disable onexit asking.
;
; End of T-Node config file
